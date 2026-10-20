import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/utils/price_break.dart';
import '../core/utils/stream_utils.dart';
import '../models/pool_model.dart';
import '../models/pricing_tier_model.dart';
import 'auth_service.dart';
import 'pricing_service.dart';

/// A pool plus its live price-break state.
class PoolView {
  final PoolModel pool;
  final PriceBreak priceBreak;
  const PoolView({required this.pool, required this.priceBreak});
}

class PoolService {
  PoolService._();
  static final PoolService instance = PoolService._();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<PoolModel>> watchPools() {
    return _db.collection('pools').snapshots().map((snap) {
      final pools = snap.docs.map(PoolModel.fromDoc).toList();
      pools.sort((a, b) => a.deadline.compareTo(b.deadline));
      return pools;
    });
  }

  Stream<PoolModel?> watchPool(String poolId) {
    return _db
        .collection('pools')
        .doc(poolId)
        .snapshots()
        .map((s) => s.exists ? PoolModel.fromDoc(s) : null);
  }

  /// Null when the pool no longer exists.
  Stream<PoolView?> watchPoolView(String poolId) {
    return combineLatest2<PoolModel?, List<PricingTierModel>, PoolView?>(
      watchPool(poolId),
      PricingService.instance.watchTiers(),
      (pool, tiers) {
        if (pool == null) return null;
        return PoolView(
          pool: pool,
          priceBreak: PriceBreak.compute(tiers, pool.collectiveValue),
        );
      },
    );
  }

  Stream<List<PoolView>> watchPoolViews() {
    return combineLatest2<List<PoolModel>, List<PricingTierModel>, List<PoolView>>(
      watchPools(),
      PricingService.instance.watchTiers(),
      (pools, tiers) => [
        for (final p in pools)
          PoolView(pool: p, priceBreak: PriceBreak.compute(tiers, p.collectiveValue)),
      ],
    );
  }

  /// Creates a pool. The creator becomes its first member and coordinator,
  /// and it becomes their active pool. Returns the new pool id.
  Future<String> createPool({
    required String name,
    required String pickupLocation,
    required DateTime deadline,
  }) async {
    final uid = AuthService.instance.currentUser!.uid;
    final poolRef = _db.collection('pools').doc();
    final userRef = _db.collection('users').doc(uid);
    final memberRef = poolRef.collection('pool_members').doc(uid);

    await _db.runTransaction((tx) async {
      final userSnap = await tx.get(userRef);
      final userName = (userSnap.data()?['name'] as String?) ?? 'Neighbor';
      tx.set(poolRef, {
        'name': name,
        'pickupLocation': pickupLocation,
        'deadline': Timestamp.fromDate(deadline),
        'coordinatorUid': uid,
        'coordinatorName': userName,
        'orderNumber': 100 + Random().nextInt(900),
        'memberCount': 1,
        'collectiveValue': 0,
        'demand': <String, dynamic>{},
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      tx.set(memberRef, {
        'name': userName,
        'role': 'coordinator',
        'joinedAt': FieldValue.serverTimestamp(),
      });
      tx.set(
        userRef,
        {
          'activePoolId': poolRef.id,
          'joinedPoolIds': FieldValue.arrayUnion([poolRef.id]),
        },
        SetOptions(merge: true),
      );
    });
    return poolRef.id;
  }

  /// Joins the pool (once) and makes it the user's active pool.
  Future<void> joinPool(String poolId) async {
    final uid = AuthService.instance.currentUser!.uid;
    final poolRef = _db.collection('pools').doc(poolId);
    final memberRef = poolRef.collection('pool_members').doc(uid);
    final userRef = _db.collection('users').doc(uid);

    await _db.runTransaction((tx) async {
      final memberSnap = await tx.get(memberRef);
      final userSnap = await tx.get(userRef);
      final name = (userSnap.data()?['name'] as String?) ?? 'Neighbor';
      if (!memberSnap.exists) {
        tx.set(memberRef, {
          'name': name,
          'role': 'member',
          'joinedAt': FieldValue.serverTimestamp(),
        });
        tx.update(poolRef, {'memberCount': FieldValue.increment(1)});
      }
      tx.set(
        userRef,
        {
          'activePoolId': poolId,
          'joinedPoolIds': FieldValue.arrayUnion([poolId]),
        },
        SetOptions(merge: true),
      );
    });
  }
}
