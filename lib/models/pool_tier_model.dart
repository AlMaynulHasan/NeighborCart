/// A single wholesale price-break tier within a pool.
/// Kept as a plain, configurable model so tier thresholds can change
/// without touching UI or calculation code (see Master Prompt section 11).
class PoolTier {
  final String label; // e.g. "Tier 2"
  final double threshold; // e.g. 10000
  final double discountPercent; // e.g. 15
  final bool unlocked;

  const PoolTier({
    required this.label,
    required this.threshold,
    required this.discountPercent,
    required this.unlocked,
  });
}
