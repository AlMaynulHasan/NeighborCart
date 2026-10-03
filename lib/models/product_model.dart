/// Represents a grocery product shown in "Recommended Items", the Weekly
/// Cart, etc.
class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl; // null -> use placeholder in Phase 1
  final int quantity; // used when the product is inside a cart

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.quantity = 1,
  });

  ProductModel copyWith({int? quantity}) {
    return ProductModel(
      id: id,
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      quantity: quantity ?? this.quantity,
    );
  }

  double get subtotal => price * quantity;
}
