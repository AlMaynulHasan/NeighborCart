import 'pool_tier_model.dart';

/// Represents a local buying pool (e.g. "Saidpur Block-C Pool").
class PoolModel {
  final String id;
  final String name;
  final double collectiveValue;
  final int memberCount;
  final double discountPercent; // currently unlocked discount, e.g. 15
  final String pickupLocation;
  final DateTime deadline;
  final String coordinatorName;
  final String? coordinatorAvatarUrl;
  final List<PoolTier> tiers;
  final double targetForNextTier;
  final double collectedTowardNextTier;

  const PoolModel({
    required this.id,
    required this.name,
    required this.collectiveValue,
    required this.memberCount,
    required this.discountPercent,
    required this.pickupLocation,
    required this.deadline,
    required this.coordinatorName,
    this.coordinatorAvatarUrl,
    required this.tiers,
    required this.targetForNextTier,
    required this.collectedTowardNextTier,
  });
}

/// Lightweight summary used on cards (Nearby Pools list) where the full
/// tier breakdown isn't needed.
class NearbyPoolSummary {
  final String id;
  final String name;
  final double discountPercent;
  final double collectiveOrders;
  final String pickupLocation;
  final String closesLabel; // e.g. "Closes Thu 8 PM"
  final int joinedCount;
  final int extraAvatarCount; // the "+5" shown over avatar stack

  const NearbyPoolSummary({
    required this.id,
    required this.name,
    required this.discountPercent,
    required this.collectiveOrders,
    required this.pickupLocation,
    required this.closesLabel,
    required this.joinedCount,
    required this.extraAvatarCount,
  });
}
