import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/game.dart';

class AddGameScreen extends StatefulWidget {
  final Function(Game) onAdd;

  const AddGameScreen({super.key, required this.onAdd});

  @override
  _AddGameScreenState createState() => _AddGameScreenState();
}

class _AddGameScreenState extends State<AddGameScreen> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  final stockController = TextEditingController();
  String? imageFilePath;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageFilePath = pickedFile.path;
      });
    }
  }

  Future<void> _addGame() async {
    final name = nameController.text;
    final price = double.tryParse(priceController.text) ?? 0.0;
    final description = descriptionController.text;
    final stock = int.tryParse(stockController.text) ?? 0;

    if (name.isNotEmpty && description.isNotEmpty && stock > 0) {
      final newGame = Game(
        productId: 0,
        name: name,
        description: description,
        price: price,
        stock: stock,
        imagePath: imageFilePath ?? 'assets/default_image.png',
      );

      final response = await _addGameToDatabase(newGame);

      if (response != null) {
        widget.onAdd(response);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при добавлении игры')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, заполните все поля!')),
      );
    }
  }

  Future<Game?> _addGameToDatabase(Game game) async {
    try {
      final url = Uri.parse('http://192.168.1.6:8080/products');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': game.name,
          'description': game.description,
          'price': game.price,
          'stock': game.stock,
          'image_url': game.imagePath,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return Game.fromJson(responseData);
      } else {
        print('Ошибка: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('Ошибка при добавлении игры в базу данных: $error');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добавить игру')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Название')),
            TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Цена')),
            TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Описание')),
            TextField(
              controller: stockController,
              decoration: const InputDecoration(labelText: 'Количество'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _pickImage, child: const Text('Выбрать изображение')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _addGame, child: const Text('Добавить')),
          ],
        ),
      ),
    );
  }
}
