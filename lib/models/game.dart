class Game {
  final int productId;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String imagePath;

  Game({
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.imagePath,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      productId: json['product_id'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price']),
      stock: json['stock'],
      imagePath: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'image_url': imagePath,
    };
  }
}
