import '../../models/pool_tier_model.dart';
import '../../models/pricing_tier_model.dart';

/// Price-break engine (Master Prompt section 11): given the wholesaler's
/// configured tiers and a pool's collected value, works out which tier is
/// unlocked, what's next, and what discount applies. Thresholds come from
/// data (config/pricing in Firestore), never hard-coded here.
class PriceBreak {
  final double collected;
  final List<PoolTier> tiers; // ascending by threshold

  const PriceBreak({required this.collected, required this.tiers});

  factory PriceBreak.compute(List<PricingTierModel> config, double collected) {
    final active = config.where((t) => t.isActive).toList()
      ..sort((a, b) => a.minimumThreshold.compareTo(b.minimumThreshold));
    return PriceBreak(
      collected: collected,
      tiers: [
        for (final t in active)
          PoolTier(
            label: t.label,
            threshold: t.minimumThreshold,
            discountPercent: t.discountPercent,
            unlocked: collected >= t.minimumThreshold,
          ),
      ],
    );
  }

  PoolTier? get unlockedTier {
    final unlocked = tiers.where((t) => t.unlocked).toList();
    return unlocked.isEmpty ? null : unlocked.last;
  }

  PoolTier? get nextTier {
    for (final t in tiers) {
      if (!t.unlocked) return t;
    }
    return null;
  }

  double get discountPercent => unlockedTier?.discountPercent ?? 0;

  double amountNeeded(PoolTier tier) {
    final diff = tier.threshold - collected;
    return diff < 0 ? 0 : diff;
  }

  double get amountToNext => nextTier == null ? 0 : amountNeeded(nextTier!);

  /// Value the progress bar is measured against.
  double get progressTarget =>
      nextTier?.threshold ?? (tiers.isEmpty ? 0 : tiers.last.threshold);

  double get progressToNext {
    final target = progressTarget;
    if (target <= 0) return 0;
    final p = collected / target;
    return p > 1 ? 1 : p;
  }

  double applyDiscount(double amount) => amount * (1 - discountPercent / 100);
}
