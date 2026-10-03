import 'order_model.dart';

/// Lightweight summary of a past/active order, used on the Orders tab list.
/// Kept separate from OrderModel (which carries the full member breakdown
/// needed by the Settlement screen) so the Orders list doesn't have to
/// load data it won't display.
class OrderSummary {
  final String id;
  final String poolName;
  final DateTime date;
  final double totalAmount;
  final double memberShare;
  final PaymentStatus status;

  const OrderSummary({
    required this.id,
    required this.poolName,
    required this.date,
    required this.totalAmount,
    required this.memberShare,
    required this.status,
  });
}
