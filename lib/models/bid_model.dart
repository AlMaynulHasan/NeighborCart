import 'package:cloud_firestore/cloud_firestore.dart';

/// A wholesaler's offer to supply one pool: an extra discount on top of the
/// pool's tier discount. Stored at `pools/{poolId}/bids/{wholesalerUid}` (and
/// copied to `users/{uid}/bids/{poolId}` so the wholesaler can list their bids).
class BidModel {
  final String poolId;
  final String poolName;
  final String wholesalerUid;
  final String wholesalerName;
  final String licenseNumber;
  final double extraPercent;
  final String note;

  const BidModel({
    required this.poolId,
    required this.poolName,
    required this.wholesalerUid,
    required this.wholesalerName,
    required this.licenseNumber,
    required this.extraPercent,
    required this.note,
  });

  factory BidModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? <String, dynamic>{};
    return BidModel(
      poolId: (d['poolId'] as String?) ?? '',
      poolName: (d['poolName'] as String?) ?? '',
      wholesalerUid: (d['wholesalerUid'] as String?) ?? doc.id,
      wholesalerName: (d['wholesalerName'] as String?) ?? 'Wholesaler',
      licenseNumber: (d['licenseNumber'] as String?) ?? '',
      extraPercent: (d['extraPercent'] as num?)?.toDouble() ?? 0,
      note: (d['note'] as String?) ?? '',
    );
  }
}
