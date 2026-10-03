/// Represents the signed-in wholesaler/supplier account.
class WholesalerModel {
  final String id;
  final String businessName;
  final String contactName;
  final String emailOrPhone;

  const WholesalerModel({
    required this.id,
    required this.businessName,
    required this.contactName,
    required this.emailOrPhone,
  });
}
