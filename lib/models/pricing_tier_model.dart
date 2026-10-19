/// A wholesale pricing tier as configured by the wholesaler. Stored as an
/// array inside `config/pricing` and used by the price-break engine on the
/// customer side.
class PricingTierModel {
  final String id;
  final String label;
  final double minimumThreshold;
  final double discountPercent;
  final bool isActive;

  const PricingTierModel({
    required this.id,
    required this.label,
    required this.minimumThreshold,
    required this.discountPercent,
    required this.isActive,
  });

  factory PricingTierModel.fromMap(Map<String, dynamic> m) {
    return PricingTierModel(
      id: (m['id'] as String?) ?? '',
      label: (m['label'] as String?) ?? 'Tier',
      minimumThreshold: (m['minimumThreshold'] as num?)?.toDouble() ?? 0,
      discountPercent: (m['discountPercent'] as num?)?.toDouble() ?? 0,
      isActive: (m['isActive'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'label': label,
        'minimumThreshold': minimumThreshold,
        'discountPercent': discountPercent,
        'isActive': isActive,
      };

  PricingTierModel copyWith({
    String? label,
    double? minimumThreshold,
    double? discountPercent,
    bool? isActive,
  }) {
    return PricingTierModel(
      id: id,
      label: label ?? this.label,
      minimumThreshold: minimumThreshold ?? this.minimumThreshold,
      discountPercent: discountPercent ?? this.discountPercent,
      isActive: isActive ?? this.isActive,
    );
  }
}
