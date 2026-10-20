import 'package:cloud_firestore/cloud_firestore.dart';

/// A product as managed on the wholesaler side — mirrors `products/{id}`.
class WholesalerProductModel {
  final String id; // empty string = not saved yet
  final String name;
  final String description;
  final String category;
  final double wholesalePrice;
  final int moq; // minimum order quantity
  final int availableQuantity;
  final String shelfLife; // e.g. "6 months"
  final int? shelfLifeDays; // parsed from shelfLife, used for basket suggestions
  final int? unitLastsDays; // days one unit lasts for one person (optional)
  final bool isActive;

  const WholesalerProductModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.category,
    required this.wholesalePrice,
    required this.moq,
    required this.availableQuantity,
    required this.shelfLife,
    this.shelfLifeDays,
    this.unitLastsDays,
    required this.isActive,
  });

  factory WholesalerProductModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? <String, dynamic>{};
    return WholesalerProductModel(
      id: doc.id,
      name: (d['name'] as String?) ?? '',
      description: (d['description'] as String?) ?? '',
      category: (d['category'] as String?) ?? '',
      wholesalePrice: (d['wholesalePrice'] as num?)?.toDouble() ?? 0,
      moq: (d['moq'] as num?)?.toInt() ?? 0,
      availableQuantity: (d['availableQuantity'] as num?)?.toInt() ?? 0,
      shelfLife: (d['shelfLife'] as String?) ?? '',
      shelfLifeDays: (d['shelfLifeDays'] as num?)?.toInt(),
      unitLastsDays: (d['unitLastsDays'] as num?)?.toInt(),
      isActive: (d['isActive'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'category': category,
        'wholesalePrice': wholesalePrice,
        'moq': moq,
        'availableQuantity': availableQuantity,
        'shelfLife': shelfLife,
        'shelfLifeDays': shelfLifeDays,
        'unitLastsDays': unitLastsDays,
        'isActive': isActive,
      };

  bool get isLowStock => availableQuantity < moq;

  WholesalerProductModel copyWith({
    String? name,
    String? description,
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
      description: description ?? this.description,
      category: category ?? this.category,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      moq: moq ?? this.moq,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      shelfLife: shelfLife ?? this.shelfLife,
      shelfLifeDays: shelfLifeDays,
      unitLastsDays: unitLastsDays,
      isActive: isActive ?? this.isActive,
    );
  }
}
