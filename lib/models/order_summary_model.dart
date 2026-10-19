import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_model.dart';

/// Lightweight summary of a past/active order for the Orders tab —
/// one doc per user per pool at `users/{uid}/orders/{poolId}`.
class OrderSummary {
  final String id; // display label, e.g. "#204"
  final String poolId;
  final String poolName;
  final DateTime date;
  final double totalAmount;
  final double memberShare;
  final PaymentStatus status;

  const OrderSummary({
    required this.id,
    required this.poolId,
    required this.poolName,
    required this.date,
    required this.totalAmount,
    required this.memberShare,
    required this.status,
  });

  factory OrderSummary.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? <String, dynamic>{};
    return OrderSummary(
      id: '#${d['orderNumber'] ?? ''}',
      poolId: (d['poolId'] as String?) ?? doc.id,
      poolName: (d['poolName'] as String?) ?? '',
      date: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalAmount: (d['poolTotal'] as num?)?.toDouble() ?? 0,
      memberShare: (d['amount'] as num?)?.toDouble() ?? 0,
      status: d['status'] == 'paid' ? PaymentStatus.paid : PaymentStatus.pending,
    );
  }
}
