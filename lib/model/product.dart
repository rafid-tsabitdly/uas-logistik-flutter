class Product {
  final int id;
  final String name;
  final String descriptions;
  final int price;
  final int stock;
  final String? image;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.descriptions,
    required this.price,
    required this.stock,
    this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Tanpa Nama',
      descriptions: json['descriptions'] ?? '',
      price: json['price'] ?? 0,
      stock: json['stock'] ?? 0,
      image: json['image'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  // Helper formatting
  String get formattedPrice =>
      'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  String get stockStatus => stock > 0 ? 'Tersedia: $stock' : 'Stok Habis';
}
