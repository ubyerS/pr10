import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/game.dart';

class ApiService {
  final String baseUrl = "http://192.168.1.6:8080";
  final Dio dio = Dio();

  Future<List<Game>> fetchGames() async {
  try {
    print("Отправляем запрос на: $baseUrl/products");
    final response = await dio.get('$baseUrl/products');

    if (response.statusCode == 200) {
      List<dynamic> data = response.data;

      print("Ответ сервера: $data");

      return data.map((item) {
        return Game.fromJson(item);
      }).toList();
    } else {
      print("Ошибка сервера: ${response.statusCode}");
      throw Exception('Ошибка при загрузке данных');
    }
  } catch (e) {
    print("Ошибка запроса: $e");
    throw Exception('Не удалось загрузить игры');
  }
}



  Future<Game> createGame(Game game) async {
    final response = await dio.post(
      '$baseUrl/products',
      data: game.toJson(),
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    if (response.statusCode == 201) {
      return Game.fromJson(response.data);
    } else {
      throw Exception('Failed to create game');
    }
  }

  Future<void> updateFavoriteStatus(int productId, bool isFavorite) async {
    await dio.put(
      '$baseUrl/products/$productId/favorite',
      data: {'is_favorite': isFavorite},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
  }

  Future<void> updateCart(int productId, int quantity) async {
    await dio.post(
      '$baseUrl/cart',
      data: {'product_id': productId, 'quantity': quantity},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
  }

  Future<void> clearCart() async {
    await dio.delete('$baseUrl/cart');
  }
}
