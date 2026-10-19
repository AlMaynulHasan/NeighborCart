/// How much each behaviour counts towards the score. Stored in Firestore
/// (`config/reliability`) so it can be changed without touching the app;
/// falls back to [defaults] when that doc doesn't exist.
class ReliabilityWeights {
  final double payment;
  final double pickup;

  const ReliabilityWeights({required this.payment, required this.pickup});

  static const ReliabilityWeights defaults = ReliabilityWeights(payment: 50, pickup: 50);

  factory ReliabilityWeights.fromMap(Map<String, dynamic>? m) {
    if (m == null) return defaults;
    return ReliabilityWeights(
      payment: (m['paymentWeight'] as num?)?.toDouble() ?? defaults.payment,
      pickup: (m['pickupWeight'] as num?)?.toDouble() ?? defaults.pickup,
    );
  }
}

/// A member's track record across completed pool cycles in which they
/// actually ordered something.
class ReliabilityScore {
  final int cycles; // completed orders they took part in
  final int paid; // of those, how many they paid for
  final int pickedUp; // of those, how many they collected
  final ReliabilityWeights weights;

  const ReliabilityScore({
    required this.cycles,
    required this.paid,
    required this.pickedUp,
    required this.weights,
  });

  double? get paymentRate => cycles == 0 ? null : paid / cycles;
  double? get pickupRate => cycles == 0 ? null : pickedUp / cycles;

  /// 0-100, or null until they have at least one completed order.
  int? get score {
    if (cycles == 0) return null;
    final total = weights.payment + weights.pickup;
    if (total <= 0) return null;
    final weighted = weights.payment * paymentRate! + weights.pickup * pickupRate!;
    return (weighted / total * 100).round();
  }

  String get label {
    final s = score;
    if (s == null) return 'No history yet';
    if (s >= 90) return 'Excellent';
    if (s >= 75) return 'Good';
    if (s >= 50) return 'Fair';
    return 'Needs improvement';
  }
}
