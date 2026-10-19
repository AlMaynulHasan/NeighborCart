import 'package:flutter_test/flutter_test.dart';
import 'package:neighbor_cart/core/utils/price_break.dart';
import 'package:neighbor_cart/models/pricing_tier_model.dart';

void main() {
  const tiers = [
    PricingTierModel(id: 't1', label: 'Tier 1', minimumThreshold: 5000, discountPercent: 10, isActive: true),
    PricingTierModel(id: 't2', label: 'Tier 2', minimumThreshold: 10000, discountPercent: 15, isActive: true),
    PricingTierModel(id: 't3', label: 'Tier 3', minimumThreshold: 15000, discountPercent: 20, isActive: true),
  ];

  test('no discount below the first tier', () {
    final pb = PriceBreak.compute(tiers, 3000);
    expect(pb.unlockedTier, isNull);
    expect(pb.discountPercent, 0);
    expect(pb.nextTier!.label, 'Tier 1');
    expect(pb.amountToNext, 2000);
  });

  test('the highest reached tier applies', () {
    final pb = PriceBreak.compute(tiers, 12400);
    expect(pb.unlockedTier!.label, 'Tier 2');
    expect(pb.discountPercent, 15);
    expect(pb.amountToNext, 2600);
    expect(pb.applyDiscount(2000), closeTo(1700, 0.001));
  });

  test('all tiers unlocked', () {
    final pb = PriceBreak.compute(tiers, 16000);
    expect(pb.unlockedTier!.label, 'Tier 3');
    expect(pb.nextTier, isNull);
    expect(pb.progressToNext, 1);
  });

  test('inactive tiers are ignored', () {
    final custom = [
      tiers[0],
      tiers[1].copyWith(isActive: false),
      tiers[2],
    ];
    final pb = PriceBreak.compute(custom, 12400);
    expect(pb.unlockedTier!.label, 'Tier 1');
    expect(pb.nextTier!.label, 'Tier 3');
  });
}
