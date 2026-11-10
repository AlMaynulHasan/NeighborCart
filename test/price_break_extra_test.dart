import 'package:flutter_test/flutter_test.dart';
import 'package:neighbor_cart/core/utils/price_break.dart';
import 'package:neighbor_cart/models/pricing_tier_model.dart';

void main() {
  const tiers = [
    PricingTierModel(id: 't1', label: 'Tier 1', minimumThreshold: 5000, discountPercent: 10, isActive: true),
    PricingTierModel(id: 't2', label: 'Tier 2', minimumThreshold: 10000, discountPercent: 15, isActive: true),
  ];

  test('supplier bonus stacks on top of the tier discount', () {
    final pb = PriceBreak.compute(tiers, 12000, extraPercent: 2);
    expect(pb.tierDiscountPercent, 15);
    expect(pb.discountPercent, 17);
    expect(pb.applyDiscount(1000), closeTo(830, 0.001));
  });

  test('bonus applies even before any tier is unlocked', () {
    final pb = PriceBreak.compute(tiers, 1000, extraPercent: 3);
    expect(pb.unlockedTier, isNull);
    expect(pb.discountPercent, 3);
  });

  test('no bonus by default', () {
    expect(PriceBreak.compute(tiers, 12000).discountPercent, 15);
  });
}
