/// A product as managed on the wholesaler side — distinct from the
/// customer-facing ProductModel because it carries MOQ, stock, category
/// and shelf-life fields the household UI never shows.
class WholesalerProductModel {
  final String id;
  final String name;
  final String category;
  final double wholesalePrice;
  final int moq; // minimum order quantity
  final int availableQuantity;
  final String shelfLife; // e.g. "6 months"
  final bool isActive;

  const WholesalerProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.wholesalePrice,
    required this.moq,
    required this.availableQuantity,
    required this.shelfLife,
    required this.isActive,
  });

  bool get isLowStock => availableQuantity < moq;

  WholesalerProductModel copyWith({
    String? name,
    String? category,
    double? wholesalePrice,
    int? moq,
    int? availableQuantity,
    String? shelfLife,
    bool? isActive,
  }) {
    return WholesalerProductModel(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      moq: moq ?? this.moq,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      shelfLife: shelfLife ?? this.shelfLife,
      isActive: isActive ?? this.isActive,
    );
  }
}
