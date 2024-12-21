import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabTapped;
  final int favoriteCount;
  final int cartCount;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTabTapped,
    required this.favoriteCount,
    required this.cartCount,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTabTapped,
      selectedItemColor: const Color.fromARGB(255, 66, 66, 66),
      unselectedItemColor: const Color.fromARGB(255, 66, 66, 66),
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Games'),
        _buildBadge(Icons.favorite, favoriteCount, 'Favorites'),
        _buildBadge(Icons.shopping_cart, cartCount, 'Cart'),
        const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }

  BottomNavigationBarItem _buildBadge(IconData icon, int count, String label) {
    return BottomNavigationBarItem(
      icon: Stack(
        children: [
          Icon(icon),
          if (count > 0)
            Positioned(
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 10)),
              ),
            ),
        ],
      ),
      label: label,
    );
  }
}
