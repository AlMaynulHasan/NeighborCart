/// A wholesale pricing tier as configured by the wholesaler — the source
/// data behind the customer-side price-break tiers shown in
/// PoolTier/TierRow (Master Prompt section 11, section 6 "MOQ & Pricing
/// Management"). Kept as a separate, editable model since only the
/// wholesaler side can change it.
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
