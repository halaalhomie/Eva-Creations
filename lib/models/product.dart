import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.cost,
    required this.quantity,
    required this.category,
    required this.barcode,
  });

  final String id;
  final String name;
  final double price;
  final double cost;
  final int quantity;
  final String category;
  final String barcode;

  bool get isLowStock => quantity <= 5;

  double get profitPerUnit => price - cost;

  Product copyWith({
    String? id,
    String? name,
    double? price,
    double? cost,
    int? quantity,
    String? category,
    String? barcode,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      barcode: barcode ?? this.barcode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'cost': cost,
      'quantity': quantity,
      'category': category,
      'barcode': barcode,
    };
  }

  factory Product.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};

    return Product(
      id: doc.id,
      name: (data['name'] ?? '') as String,
      price: ((data['price'] ?? 0) as num).toDouble(),
      cost: ((data['cost'] ?? 0) as num).toDouble(),
      quantity: ((data['quantity'] ?? 0) as num).toInt(),
      category: (data['category'] ?? 'General') as String,
      barcode: (data['barcode'] ?? '') as String,
    );
  }
}
