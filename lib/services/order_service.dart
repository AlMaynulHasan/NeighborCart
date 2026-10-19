import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_summary_model.dart';
import '../models/pool_model.dart';
import 'auth_service.dart';

class OrderService {
  OrderService._();
  static final OrderService instance = OrderService._();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<OrderSummary>> watchOrders() {
    final uid = AuthService.instance.currentUser!.uid;
    return _db
        .collection('users')
        .doc(uid)
        .collection('orders')
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(OrderSummary.fromDoc).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  /// Records/refreshes this member's order for the pool as "pending"
  /// (never downgrades an already-paid order).
  Future<void> upsertPending({required PoolModel pool, required double share}) async {
    final uid = AuthService.instance.currentUser!.uid;
    final ref = _db.collection('users').doc(uid).collection('orders').doc(pool.id);
    final existing = await ref.get();
    if (existing.data()?['status'] == 'paid') return;
    await ref.set({
      'poolId': pool.id,
      'poolName': pool.name,
      'orderNumber': pool.orderNumber,
      'amount': share,
      'poolTotal': pool.collectiveValue,
      'status': 'pending',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
