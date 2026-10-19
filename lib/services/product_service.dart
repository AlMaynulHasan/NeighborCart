import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/wholesaler_product_model.dart';
import 'auth_service.dart';

class ProductService {
  ProductService._();
  static final ProductService instance = ProductService._();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Customer-facing catalog: every active product.
  Stream<List<ProductModel>> watchActiveProducts() {
    return _db
        .collection('products')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(ProductModel.fromDoc).toList();
      list.sort((a, b) => a.name.compareTo(b.name));
      return list;
    });
  }

  /// Wholesaler-facing: only this wholesaler's own products.
  Stream<List<WholesalerProductModel>> watchWholesalerProducts(String uid) {
    return _db
        .collection('products')
        .where('wholesalerUid', isEqualTo: uid)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(WholesalerProductModel.fromDoc).toList();
      list.sort((a, b) => a.name.compareTo(b.name));
      return list;
    });
  }

  /// Creates the product when `product.id` is empty, otherwise updates it.
  Future<void> saveProduct(WholesalerProductModel product) async {
    final uid = AuthService.instance.currentUser!.uid;
    final data = <String, dynamic>{...product.toMap(), 'wholesalerUid': uid};
    if (product.id.isEmpty) {
      await _db.collection('products').add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await _db.collection('products').doc(product.id).set(data, SetOptions(merge: true));
    }
  }

  Future<void> setActive(String productId, bool isActive) {
    return _db.collection('products').doc(productId).update({'isActive': isActive});
  }

  Future<void> deleteProduct(String productId) {
    return _db.collection('products').doc(productId).delete();
  }
}
