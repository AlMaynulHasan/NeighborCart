import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/utils/stream_utils.dart';
import '../models/pool_model.dart';
import 'auth_service.dart';
import 'pool_service.dart';

typedef _Snap = QuerySnapshot<Map<String, dynamic>>;

class NotCoordinatorException implements Exception {}

class PickupMember {
  final String uid;
  final String name;
  final DateTime? joinedAt;
  final bool paid;
  final bool pickedUp;
  final bool isCoordinator;
  final bool isMe;

  const PickupMember({
    required this.uid,
    required this.name,
    required this.joinedAt,
    required this.paid,
    required this.pickedUp,
    required this.isCoordinator,
    required this.isMe,
  });
}

/// Live state for the pickup / coordinator screen of one pool.
class PickupData {
  final PoolModel? pool;
  final String myUid;
  final List<PickupMember> members; // in join order

  const PickupData({required this.pool, required this.myUid, required this.members});

  bool get iAmCoordinator => pool != null && pool!.coordinatorUid == myUid;
  int get pickedUpCount => members.where((m) => m.pickedUp).length;

  /// Who takes over after this cycle: the next member in join order.
  PickupMember? get nextCoordinator {
    if (members.isEmpty || pool == null) return null;
    final idx = members.indexWhere((m) => m.uid == pool!.coordinatorUid);
    return members[(idx + 1) % members.length];
  }
}

/// Order lifecycle after the deadline: place order -> ready for pickup ->
/// members pick up -> complete the cycle (coordinator rotates, pool resets).
class PickupService {
  PickupService._();
  static final PickupService instance = PickupService._();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _poolRef(String poolId) =>
      _db.collection('pools').doc(poolId);

  Stream<PickupData> watch(String poolId) {
    final uid = AuthService.instance.currentUser!.uid;
    final poolRef = _poolRef(poolId);
    return combineLatest2<PoolModel?, (_Snap, _Snap, _Snap), PickupData>(
      PoolService.instance.watchPool(poolId),
      combineLatest3<_Snap, _Snap, _Snap, (_Snap, _Snap, _Snap)>(
        poolRef.collection('pool_members').snapshots(),
        poolRef.collection('payments').snapshots(),
        poolRef.collection('pickups').snapshots(),
        (m, pay, pick) => (m, pay, pick),
      ),
      (pool, s) => PickupData(
        pool: pool,
        myUid: uid,
        members: _buildMembers(uid, pool?.coordinatorUid ?? '', s.$1, s.$2, s.$3),
      ),
    );
  }

  static List<PickupMember> _buildMembers(
    String myUid,
    String coordinatorUid,
    _Snap members,
    _Snap payments,
    _Snap pickups,
  ) {
    final paid = {for (final d in payments.docs) d.id};
    final picked = {for (final d in pickups.docs) d.id};
    final list = [
      for (final d in members.docs)
        PickupMember(
          uid: d.id,
          name: (d.data()['name'] as String?) ?? 'Neighbor',
          joinedAt: (d.data()['joinedAt'] as Timestamp?)?.toDate(),
          paid: paid.contains(d.id),
          pickedUp: picked.contains(d.id),
          isCoordinator: d.id == coordinatorUid,
          isMe: d.id == myUid,
        ),
    ];
    list.sort((a, b) {
      final ta = a.joinedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final tb = b.joinedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final c = ta.compareTo(tb);
      return c != 0 ? c : a.uid.compareTo(b.uid);
    });
    return list;
  }

  Future<PoolModel> _requireCoordinator(String poolId) async {
    final uid = AuthService.instance.currentUser!.uid;
    final snap = await _poolRef(poolId).get();
    if (!snap.exists) throw NotCoordinatorException();
    final pool = PoolModel.fromDoc(snap);
    if (pool.coordinatorUid != uid) throw NotCoordinatorException();
    return pool;
  }

  /// Closes ordering and marks the order as placed (works before the
  /// deadline too — closes ordering early).
  Future<void> placeOrder(String poolId) async {
    final pool = await _requireCoordinator(poolId);
    if (pool.status != 'open') return;
    final now = DateTime.now();
    await _poolRef(poolId).update({
      'status': 'ordered',
      'orderedAt': FieldValue.serverTimestamp(),
      if (pool.deadline.isAfter(now)) 'deadline': Timestamp.fromDate(now),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markReadyForPickup(String poolId) async {
    final pool = await _requireCoordinator(poolId);
    if (pool.status != 'ordered') return;
    await _poolRef(poolId).update({
      'status': 'ready',
      'readyAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setPickedUp(String poolId, String memberUid, bool pickedUp) async {
    await _requireCoordinator(poolId);
    final ref = _poolRef(poolId).collection('pickups').doc(memberUid);
    if (pickedUp) {
      await ref.set({
        'pickedUp': true,
        'at': FieldValue.serverTimestamp(),
        'markedBy': AuthService.instance.currentUser!.uid,
      });
    } else {
      await ref.delete();
    }
  }

  /// Archives this cycle, hands coordinator duty to the next member, clears
  /// this week's carts/payments/pickups and re-opens the pool for next week.
  Future<void> completeCycle(String poolId) async {
    final pool = await _requireCoordinator(poolId);
    final uid = AuthService.instance.currentUser!.uid;
    final poolRef = _poolRef(poolId);

    final membersSnap = await poolRef.collection('pool_members').get();
    final cartsSnap = await poolRef.collection('carts').get();
    final paymentsSnap = await poolRef.collection('payments').get();
    final pickupsSnap = await poolRef.collection('pickups').get();

    final members = _buildMembers(uid, pool.coordinatorUid, membersSnap, paymentsSnap, pickupsSnap);
    // Members who actually put something in their cart this cycle.
    final orderedUids = {
      for (final d in cartsSnap.docs)
        if (((d.data()['items'] as List<dynamic>?) ?? const []).isNotEmpty) d.id,
    };
    final idx = members.indexWhere((m) => m.uid == pool.coordinatorUid);
    final next = members.isEmpty ? null : members[(idx + 1) % members.length];

    var deadline = pool.deadline;
    while (!deadline.isAfter(DateTime.now())) {
      deadline = deadline.add(const Duration(days: 7));
    }

    final batch = _db.batch();
    batch.set(poolRef.collection('cycles').doc('${pool.orderNumber}'), {
      'orderNumber': pool.orderNumber,
      'coordinatorUid': pool.coordinatorUid,
      'coordinatorName': pool.coordinatorName,
      'collectiveValue': pool.collectiveValue,
      'completedAt': FieldValue.serverTimestamp(),
      'members': [
        for (final m in members)
          {
            'uid': m.uid,
            'name': m.name,
            'ordered': orderedUids.contains(m.uid),
            'paid': m.paid,
            'pickedUp': m.pickedUp,
          },
      ],
    });
    for (final d in [...cartsSnap.docs, ...paymentsSnap.docs, ...pickupsSnap.docs]) {
      batch.delete(d.reference);
    }
    // Reliability record: +1 completed order for everyone who ordered, plus
    // whether they paid and collected. (One batch holds at most 500 writes,
    // which is plenty for pools of up to ~100 members.)
    for (final m in members) {
      if (!orderedUids.contains(m.uid) || m.uid.startsWith('seed_')) continue;
      batch.set(
        _db.collection('users').doc(m.uid).collection('reliability').doc('summary'),
        {
          'cycles': FieldValue.increment(1),
          'paid': FieldValue.increment(m.paid ? 1 : 0),
          'pickedUp': FieldValue.increment(m.pickedUp ? 1 : 0),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }
    batch.update(poolRef, {
      'status': 'open',
      'collectiveValue': 0,
      'demand': <String, dynamic>{},
      'orderNumber': pool.orderNumber + 1,
      'deadline': Timestamp.fromDate(deadline),
      'coordinatorUid': next?.uid ?? pool.coordinatorUid,
      'coordinatorName': next?.name ?? pool.coordinatorName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }
}
