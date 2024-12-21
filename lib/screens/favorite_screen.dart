import 'package:flutter/material.dart';
import '../models/game.dart';
import 'game_detail_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FavoriteScreen extends StatelessWidget {
  final List<Game> favoriteGames;
  final Function(Game) toggleFavorite;
  final Function(Game) addToCart;

  const FavoriteScreen({
    super.key,
    required this.favoriteGames,
    required this.toggleFavorite,
    required this.addToCart,
  });
  Future<List<Game>> fetchFavorites(int userId) async {
  try {
    final response = await http.get(
      Uri.parse('http://192.168.1.6:8080/favorites/$userId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Game.fromJson(item)).toList();
    } else {
      throw Exception('Ошибка при получении избранных товаров');
    }
  } catch (e) {
    print('Ошибка при получении избранных товаров: $e');
    throw Exception('Ошибка сети');
  }
}


  Future<void> _addToFavorites(Game game) async {
  try {
    final response = await http.post(
      Uri.parse('http://192.168.1.6:8080/favorites'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': 1,
        'product_id': game.productId,
      }),
    );

    if (response.statusCode == 201) {
      print("Игра добавлена в избранное");
    } else {
      throw Exception('Ошибка при добавлении игры в избранное');
    }
  } catch (e) {
    print("Ошибка при добавлении игры в избранное: $e");
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: favoriteGames.isEmpty
          ? const Center(child: Text('Нет избранных игр'))
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
              ),
              itemCount: favoriteGames.length,
              itemBuilder: (context, index) {
                final game = favoriteGames[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameDetailScreen(
                          game: game,
                          toggleFavorite: toggleFavorite,
                          isFavorite: true,
                          addToCart: addToCart,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.asset(
                            game.imagePath,
                            fit: BoxFit.cover,
                          ),
                        ),
                        ListTile(
                          title: Text(game.name),
                          subtitle: Text('${game.price} \$'),
                          trailing: IconButton(
                            icon: const Icon(Icons.favorite),
                            onPressed: () {
                              toggleFavorite(game);
                              _addToFavorites(game);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
