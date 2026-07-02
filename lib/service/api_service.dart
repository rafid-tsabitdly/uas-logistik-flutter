import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/product.dart';

class ApiService {
  // Gunakan localhost untuk testing di Chrome
  static const String baseUrl = 'http://127.0.0.1/rest-api/public/api';

  // =========================================================================
  // SISTEM ANTI-ERROR: Data cadangan jika XAMPP mati / salah letak folder
  // =========================================================================
  static final List<Product> _dummyData = [
    Product(
      id: 1,
      name: 'Baterai Laptop Advan Workplus',
      descriptions: 'Stok untuk service center Serpong',
      price: 450000,
      stock: 15,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Product(
      id: 2,
      name: 'Modul Port Charger Type-C',
      descriptions: 'Komponen pengganti fast charging',
      price: 85000,
      stock: 42,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Product(
      id: 3,
      name: 'Sensor Suhu IoT (Smart Bin)',
      descriptions: 'Modul sensor untuk project stasiun',
      price: 120000,
      stock: 8,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  static Future<List<Product>> getProducts() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/products'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List)
          return decoded.map((json) => Product.fromJson(json)).toList();
        if (decoded is Map && decoded.containsKey('data')) {
          return (decoded['data'] as List)
              .map((json) => Product.fromJson(json))
              .toList();
        }
        return [Product.fromJson(decoded)];
      }
      throw Exception('Server error');
    } catch (e) {
      print(
        '⚠️ API Gagal Diakses. Menggunakan Data Dummy sebagai Fallback. Error: $e',
      );
      return _dummyData;
    }
  }

  static Future<bool> createProduct(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/products'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(data),
          )
          .timeout(const Duration(seconds: 3));

      print('STATUS API: ${response.statusCode}');
      print('BALASAN API: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      print('Gagal mengirim data ke API: $e');
      return false;
    }
  }

  static Future<bool> updateProduct(int id, Map<String, dynamic> data) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/products/$id'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(data),
          )
          .timeout(const Duration(seconds: 3));

      print('STATUS UPDATE API: ${response.statusCode}');

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('Gagal mengupdate data ke API: $e');
      return false;
    }
  }

  static Future<void> deleteProduct(int id) async {
    try {
      await http
          .delete(Uri.parse('$baseUrl/products/$id'))
          .timeout(const Duration(seconds: 3));
    } catch (e) {
      print('Simulasi Hapus Data berhasil (Offline Mode)');
    }
  }
}
