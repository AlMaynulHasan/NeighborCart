import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/utils/stream_utils.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import 'auth_service.dart';
import 'pool_service.dart';
import 'user_service.dart';

typedef _Snap = QuerySnapshot<Map<String, dynamic>>;

/// Live settlement state for the member's active pool.
class SettlementData {
  final PoolView? poolView;
  final List<OrderMember> members;
  final double totalAmount; // sum of every member's discounted share
  final double myShare;
  final bool iHavePaid;

  const SettlementData({
    this.poolView,
    this.members = const [],
    this.totalAmount = 0,
    this.myShare = 0,
    this.iHavePaid = false,
  });

  int get paidCount => members.where((m) => m.status == PaymentStatus.paid).length;
  double get paidProgress => members.isEmpty ? 0 : paidCount / members.length;
}

class SettlementService {
  SettlementService._();
  static final SettlementService instance = SettlementService._();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<SettlementData> watch() {
    final uid = AuthService.instance.currentUser!.uid;
    return switchMap<UserModel, SettlementData>(
      UserService.instance.watchCurrentUser(),
      (user) {
        final poolId = user.activePoolId;
        if (poolId == null) return Stream<SettlementData>.value(const SettlementData());
        final poolRef = _db.collection('pools').doc(poolId);
        return combineLatest2<PoolView?, (_Snap, _Snap, _Snap), SettlementData>(
          PoolService.instance.watchPoolView(poolId),
          combineLatest3<_Snap, _Snap, _Snap, (_Snap, _Snap, _Snap)>(
            poolRef.collection('pool_members').snapshots(),
            poolRef.collection('carts').snapshots(),
            poolRef.collection('payments').snapshots(),
            (m, c, p) => (m, c, p),
          ),
          (pv, snaps) => _build(uid, pv, snaps.$1, snaps.$2, snaps.$3),
        );
      },
    );
  }

  SettlementData _build(String uid, PoolView? pv, _Snap members, _Snap carts, _Snap payments) {
    if (pv == null) return const SettlementData();
    final cartByUid = {for (final d in carts.docs) d.id: d.data()};
    final paidUids = {for (final d in payments.docs) d.id};

    final list = <OrderMember>[];
    var total = 0.0;
    var myShare = 0.0;
    var iHavePaid = false;

    for (final doc in members.docs) {
      final cart = cartByUid[doc.id];
      final items = (cart?['items'] as List<dynamic>?) ?? const [];
      final subtotal = (cart?['subtotal'] as num?)?.toDouble() ?? 0;
      final share = pv.priceBreak.applyDiscount(subtotal);
      final isMe = doc.id == uid;
      final paid = paidUids.contains(doc.id);
      final name = (doc.data()['name'] as String?) ?? 'Neighbor';
      total += share;
      if (isMe) {
        myShare = share;
        iHavePaid = paid;
      }
      list.add(OrderMember(
        name: isMe ? '$name (You)' : name,
        share: share,
        itemsOrdered: items.length,
        status: paid ? PaymentStatus.paid : PaymentStatus.pending,
        isCurrentUser: isMe,
      ));
    }

    list.sort((a, b) {
      if (a.isCurrentUser != b.isCurrentUser) return a.isCurrentUser ? -1 : 1;
      return a.name.compareTo(b.name);
    });

    return SettlementData(
      poolView: pv,
      members: list,
      totalAmount: total,
      myShare: myShare,
      iHavePaid: iHavePaid,
    );
  }

  /// Records the member's payment (no real gateway yet — marks as paid).
  Future<void> payShare(SettlementData data) async {
    final pv = data.poolView;
    if (pv == null) return;
    final uid = AuthService.instance.currentUser!.uid;
    final poolRef = _db.collection('pools').doc(pv.pool.id);
    final batch = _db.batch();
    batch.set(poolRef.collection('payments').doc(uid), {
      'uid': uid,
      'amount': data.myShare,
      'paidAt': FieldValue.serverTimestamp(),
    });
    batch.set(_db.collection('users').doc(uid).collection('orders').doc(pv.pool.id), {
      'poolId': pv.pool.id,
      'poolName': pv.pool.name,
      'orderNumber': pv.pool.orderNumber,
      'amount': data.myShare,
      'poolTotal': data.totalAmount,
      'status': 'paid',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }
}
