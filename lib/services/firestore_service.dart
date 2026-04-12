import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';

enum SaleStatus { success, notFound, outOfStock }

class SaleResult {
  const SaleResult({required this.status, this.product});

  final SaleStatus status;
  final Product? product;
}

class FirestoreService {
  final db = FirebaseFirestore.instance;

  Stream<List<Product>> watchProducts() {
    return db
        .collection('products')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Product.fromDocument).toList());
  }

  Stream<Map<String, double>> watchSalesSummary() {
    return db.collection('sales').snapshots().map((snapshot) {
      double revenue = 0;
      double profit = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        revenue += ((data['revenue'] ?? data['total'] ?? 0) as num).toDouble();
        profit += ((data['profit'] ?? 0) as num).toDouble();
      }

      return {'revenue': revenue, 'profit': profit};
    });
  }

  Future<void> addProduct(Product product) async {
    await db.collection('products').add(product.toMap());
  }

  Future<void> updateProduct(Product product) async {
    await db.collection('products').doc(product.id).update(product.toMap());
  }

  Future<void> updateQuantity(String id, int qty) async {
    await db.collection('products').doc(id).update({'quantity': qty});
  }

  Future<void> addSale(double price, double cost) async {
    String today = DateTime.now().toString().split(' ')[0];

    await db.collection('sales').doc(today).set({
      'revenue': FieldValue.increment(price),
      'profit': FieldValue.increment(price - cost),
    }, SetOptions(merge: true));
  }

  Future<Product?> findProductByBarcode(String barcode) async {
    final query = await db
        .collection('products')
        .where('barcode', isEqualTo: barcode)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      return null;
    }

    return Product.fromDocument(query.docs.first);
  }

  Future<void> deleteProduct(String id) async {
    await db.collection('products').doc(id).delete();
  }

  Future<SaleResult> sellProductByBarcode(String barcode) async {
    final query = await db
        .collection('products')
        .where('barcode', isEqualTo: barcode)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      return const SaleResult(status: SaleStatus.notFound);
    }

    final productDoc = query.docs.first;
    final product = Product.fromDocument(productDoc);

    if (product.quantity <= 0) {
      return SaleResult(status: SaleStatus.outOfStock, product: product);
    }

    final today = DateTime.now().toString().split(' ')[0];
    final salesRef = db.collection('sales').doc(today);
    final productRef = db.collection('products').doc(product.id);

    final batch = db.batch();

    batch.update(productRef, {'quantity': product.quantity - 1});

    batch.set(salesRef, {
      'revenue': FieldValue.increment(product.price),
      'profit': FieldValue.increment(product.price - product.cost),
    }, SetOptions(merge: true));

    await batch.commit();

    return SaleResult(status: SaleStatus.success, product: product);
  }
}
