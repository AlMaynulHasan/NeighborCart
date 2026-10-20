import 'package:cloud_firestore/cloud_firestore.dart';

/// A product as shown to customers (catalog + cart lines).
/// `price` is the listed unit price; pool tier discounts apply on top.
class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final int quantity; // used when the product is a cart line
  final int? shelfLifeDays; // for basket suggestions
  final int? unitLastsDays; // days one unit lasts for one person

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.quantity = 1,
    this.shelfLifeDays,
    this.unitLastsDays,
  });

  factory ProductModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? <String, dynamic>{};
    return ProductModel(
      id: doc.id,
      name: (d['name'] as String?) ?? '',
      description: (d['description'] as String?) ?? '',
      price: (d['wholesalePrice'] as num?)?.toDouble() ?? 0,
      imageUrl: d['imageUrl'] as String?,
      shelfLifeDays: (d['shelfLifeDays'] as num?)?.toInt(),
      unitLastsDays: (d['unitLastsDays'] as num?)?.toInt(),
    );
  }

  factory ProductModel.fromCartItem(Map<String, dynamic> m) {
    return ProductModel(
      id: (m['productId'] as String?) ?? '',
      name: (m['name'] as String?) ?? '',
      description: (m['description'] as String?) ?? '',
      price: (m['price'] as num?)?.toDouble() ?? 0,
      quantity: (m['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toCartItem() => {
        'productId': id,
        'name': name,
        'description': description,
        'price': price,
        'quantity': quantity,
      };

  ProductModel copyWith({int? quantity}) {
    return ProductModel(
      id: id,
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      quantity: quantity ?? this.quantity,
      shelfLifeDays: shelfLifeDays,
      unitLastsDays: unitLastsDays,
    );
  }

  double get subtotal => price * quantity;
}
