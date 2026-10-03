/// Placeholder for Phase 2 (Firebase) payment records.
/// Kept minimal now so `orders` collection design isn't blocked later.
class PaymentModel {
  final String id;
  final String orderId;
  final String memberId;
  final double amount;
  final DateTime? paidAt;

  const PaymentModel({
    required this.id,
    required this.orderId,
    required this.memberId,
    required this.amount,
    this.paidAt,
  });
}
