import 'package:flutter/material.dart';
import '../models/game.dart';
import 'add_game_screen.dart';
import 'game_detail_screen.dart';

class GameStoreScreen extends StatefulWidget {
  final List<Game> games;
  final List<Game> favoriteGames;
  final Function(Game) toggleFavorite;
  final Function(Game) onAddToCart;
  final Function(Game) onAddGame;

  const GameStoreScreen({
    Key? key,
    required this.games,
    required this.toggleFavorite,
    required this.favoriteGames,
    required this.onAddToCart,
    required this.onAddGame,
  }) : super(key: key);

  @override
  _GameStoreScreenState createState() => _GameStoreScreenState();
}

class _GameStoreScreenState extends State<GameStoreScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Game> filteredGames = [];

  @override
  void initState() {
    super.initState();
    filteredGames = widget.games;
    _searchController.addListener(_filterGames);
  }

  void _filterGames() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredGames = widget.games
          .where((game) =>
              game.name.toLowerCase().contains(query) ||
              game.description.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GameStore'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddGameScreen(onAdd: widget.onAddGame),
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
              ),
            ),
          ),
        ),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
        ),
        itemCount: filteredGames.length,
        itemBuilder: (context, index) {
          final game = filteredGames[index];
          final isFavorite = widget.favoriteGames.contains(game);
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameDetailScreen(
                    game: game,
                    toggleFavorite: widget.toggleFavorite,
                    isFavorite: isFavorite,
                    addToCart: widget.onAddToCart,
                  ),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Expanded(
                    child: game.imagePath != null && game.imagePath!.isNotEmpty
                        ? Image.asset(game.imagePath!, fit: BoxFit.cover)
                        : Image.asset('assets/placeholder.jpg',
                            fit: BoxFit.cover),
                  ),
                  ListTile(
                    title: Text(game.name),
                    subtitle: Text('${game.price} \$'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                          ),
                          onPressed: () => widget.toggleFavorite(game),
                        ),
                        IconButton(
                          icon: const Icon(Icons.shopping_cart),
                          onPressed: () => widget.onAddToCart(game),
                        ),
                      ],
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
