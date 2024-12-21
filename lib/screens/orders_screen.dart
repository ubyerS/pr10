import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';  // Для работы с SharedPreferences
import '../api_service.dart';  // Используем ApiService для общения с вашим сервером

class OrdersScreen extends StatefulWidget {
  final String? userId;  // Сделаем userId nullable, так как мы будем использовать SharedPreferences

  const OrdersScreen({super.key, required this.userId});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<dynamic> orders = [];
  late String userId;  // Используем локальную переменную для хранения userId

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  // Получаем userId и загружаем заказы
  Future<void> _fetchOrders() async {
    try {
      // Если userId не был передан через конструктор, пытаемся получить его из SharedPreferences
      if (widget.userId != null && widget.userId!.isNotEmpty) {
        userId = widget.userId!;
      } else {
        final prefs = await SharedPreferences.getInstance();
        userId = prefs.getString('user_id') ?? ''; // Читаем userId из SharedPreferences
      }

      if (userId.isEmpty) {
        throw Exception('Пользователь не авторизован');
      }

      // Получаем заказы для пользователя через API
      final response = await ApiService().fetchOrders(userId);

      setState(() {
        orders = response;  // Обновляем список заказов
      });
    } catch (e) {
      print('Ошибка загрузки заказов: $e');
    }
  }

  // Показываем детали заказа
  void _showOrderDetails(int orderId) async {
    try {
      final items = await ApiService().fetchOrderDetails(orderId);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Детали заказа'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: items.map<Widget>((item) {
              return ListTile(
                title: Text('Товар ID: ${item['game_id']}'),
                subtitle: Text('Количество: ${item['quantity']}'),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Ошибка при загрузке деталей заказа: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои заказы')),
      body: orders.isEmpty
          ? const Center(child: Text('У вас пока нет заказов'))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return ListTile(
                  title: Text('Заказ #${order['id']}'),
                  subtitle: Text('Дата: ${order['created_at']}'),
                  onTap: () => _showOrderDetails(order['id']),
                );
              },
            ),
    );
  }
}
