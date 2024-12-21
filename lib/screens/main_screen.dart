import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'game_store_screen.dart';
import 'favorite_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import '../models/game.dart';
import '../widgets/bottom_navigation.dart';
import '../api_service.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  List<Game> favoriteGames = [];
  List<CartItem> cartItems = [];
  List<Game> games = [];
  final ApiService _apiService = ApiService();

  @override
void initState() {
  super.initState();
  _fetchGames();
}



Future<void> _fetchGames() async {
  try {
    final fetchedGames = await _apiService.fetchGames();
    print("Игры загружены: $fetchedGames");
    setState(() {
      games = fetchedGames;
    });
  } catch (error) {
    print('Ошибка загрузки игр: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Не удалось загрузить игры')),
    );
  }
}




  Future<void> toggleFavorite(Game game) async {
    try {
      setState(() {
        favoriteGames.contains(game)
            ? favoriteGames.remove(game)
            : favoriteGames.add(game);
      });
      await _apiService.updateFavoriteStatus(game.productId, favoriteGames.contains(game));
    } catch (error) {
      print('Ошибка обновления избранного: $error');
    }
  }

  Future<void> _addToCart(Game game) async {
    try {
      setState(() {
        final existingItem = cartItems.firstWhere(
          (item) => item.game == game,
          orElse: () => CartItem(game, 0),
        );
        if (existingItem.quantity == 0) {
          cartItems.add(CartItem(game, 1));
        } else {
          existingItem.quantity++;
        }
      });
      await _apiService.updateCart(game.productId, 1);
    } catch (error) {
      print('Ошибка добавления в корзину: $error');
    }
  }

  Future<void> updateGame(int productId, Game game) async {
  final String url = 'http://localhost:8080/products/update/$productId';

  try {
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': game.name,
        'description': game.description,
        'price': game.price,
        'stock': game.stock,
        'image_url': game.imagePath,
      }),
    );

    if (response.statusCode == 200) {
      final updatedGame = json.decode(response.body);
      print('Обновлённый продукт: $updatedGame');
    } else {
      print('Ошибка при обновлении продукта: ${response.statusCode}');
    }
  } catch (e) {
    print('Ошибка запроса: $e');
  }
}

  Future<void> _addNewGame(Game game) async {
    try {
      final newGame = await _apiService.createGame(game);
      setState(() {
        games.add(newGame);
      });
    } catch (error) {
      print('Ошибка добавления игры: $error');
    }
  }

  void _onOrderCompleted() async {
    try {
      await _apiService.clearCart();
      setState(() {
        cartItems.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заказ оформлен и корзина очищена!')),
      );
    } catch (error) {
      print('Ошибка при оформлении заказа: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось оформить заказ')),
      );
    }
  }
  
  

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      GameStoreScreen(
        games: games,
        toggleFavorite: toggleFavorite,
        favoriteGames: favoriteGames,
        onAddToCart: _addToCart,
        onAddGame: _addNewGame,
      ),
      FavoriteScreen(
        favoriteGames: favoriteGames,
        toggleFavorite: toggleFavorite,
        addToCart: _addToCart,
      ),
      CartScreen(
        cartItems: cartItems,
        onOrderCompleted: _onOrderCompleted,
      ),
      ProfileScreen(),
      
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTabTapped: (index) => setState(() => _currentIndex = index),
        favoriteCount: favoriteGames.length,
        cartCount: cartItems.length,
      ),
    );
  }
}