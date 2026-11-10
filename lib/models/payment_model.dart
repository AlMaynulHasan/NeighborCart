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

/// What the member chose in the (simulated) checkout.
class PaymentDetails {
  final String method; // bKash | Nagad | Card (demo)
  final String? phoneLast4; // never the full number
  final String txnId;

  const PaymentDetails({required this.method, this.phoneLast4, required this.txnId});
}
