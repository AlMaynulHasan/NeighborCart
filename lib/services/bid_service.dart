import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bid_model.dart';
import '../models/pool_model.dart';
import 'auth_service.dart';
import 'pickup_service.dart' show NotCoordinatorException;

/// The wholesaler must save a trade/food licence number before bidding.
class LicenceRequiredException implements Exception {}

class BidService {
  BidService._();
  static final BidService instance = BidService._();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _poolRef(String poolId) => _db.collection('pools').doc(poolId);

  /// All bids on a pool, biggest extra discount first.
  Stream<List<BidModel>> watchPoolBids(String poolId) {
    return _poolRef(poolId).collection('bids').snapshots().map((snap) {
      final list = snap.docs.map(BidModel.fromDoc).toList();
      list.sort((a, b) => b.extraPercent.compareTo(a.extraPercent));
      return list;
    });
  }

  /// The signed-in wholesaler's own bids, by pool id.
  Stream<Map<String, BidModel>> watchMyBids() {
    final uid = AuthService.instance.currentUser!.uid;
    return _db.collection('users').doc(uid).collection('bids').snapshots().map(
          (snap) => {for (final d in snap.docs) d.id: BidModel.fromDoc(d)},
        );
  }

  Future<void> placeBid({
    required PoolModel pool,
    required double extraPercent,
    required String note,
  }) async {
    final uid = AuthService.instance.currentUser!.uid;
    final userSnap = await _db.collection('users').doc(uid).get();
    final data = userSnap.data() ?? <String, dynamic>{};
    final licence = ((data['licenseNumber'] as String?) ?? '').trim();
    if (licence.isEmpty) throw LicenceRequiredException();
    final name = (data['businessName'] as String?) ?? (data['contactName'] as String?) ?? 'Wholesaler';

    final bid = <String, dynamic>{
      'poolId': pool.id,
      'poolName': pool.name,
      'wholesalerUid': uid,
      'wholesalerName': name,
      'licenseNumber': licence,
      'extraPercent': extraPercent,
      'note': note.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    };
    final batch = _db.batch();
    batch.set(_poolRef(pool.id).collection('bids').doc(uid), bid);
    batch.set(_db.collection('users').doc(uid).collection('bids').doc(pool.id), bid);
    await batch.commit();
  }

  Future<void> withdrawBid(String poolId) async {
    final uid = AuthService.instance.currentUser!.uid;
    final batch = _db.batch();
    batch.delete(_poolRef(poolId).collection('bids').doc(uid));
    batch.delete(_db.collection('users').doc(uid).collection('bids').doc(poolId));
    await batch.commit();
  }

  Future<void> _requireCoordinator(String poolId) async {
    final uid = AuthService.instance.currentUser!.uid;
    final snap = await _poolRef(poolId).get();
    if (!snap.exists || snap.data()?['coordinatorUid'] != uid) throw NotCoordinatorException();
  }

  /// Coordinator picks the winning bid; its extra discount then applies to
  /// every member's price in this pool.
  Future<void> chooseSupplier(String poolId, BidModel bid) async {
    await _requireCoordinator(poolId);
    await _poolRef(poolId).update({
      'supplierUid': bid.wholesalerUid,
      'supplierName': bid.wholesalerName,
      'supplierExtraPercent': bid.extraPercent,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> clearSupplier(String poolId) async {
    await _requireCoordinator(poolId);
    await _poolRef(poolId).update({
      'supplierUid': FieldValue.delete(),
      'supplierName': FieldValue.delete(),
      'supplierExtraPercent': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
