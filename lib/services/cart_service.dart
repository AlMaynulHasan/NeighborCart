import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/utils/stream_utils.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import 'auth_service.dart';
import 'pool_service.dart';
import 'user_service.dart';

class NoActivePoolException implements Exception {}

/// The signed-in member's cart in their active pool, with live totals.
class CartView {
  final PoolView? poolView;
  final List<ProductModel> items;

  const CartView({this.poolView, this.items = const []});

  double get subtotal => items.fold<double>(0, (sum, i) => sum + i.subtotal);

  double get estimatedCost =>
      poolView == null ? subtotal : poolView!.priceBreak.applyDiscount(subtotal);

  double get savings => subtotal - estimatedCost;
}

class CartService {
  CartService._();
  static final CartService instance = CartService._();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _cartRef(String poolId, String uid) =>
      _db.collection('pools').doc(poolId).collection('carts').doc(uid);

  Stream<List<ProductModel>> watchItems(String poolId, String uid) {
    return _cartRef(poolId, uid).snapshots().map((snap) {
      final raw = (snap.data()?['items'] as List<dynamic>?) ?? const [];
      return raw
          .map((e) => ProductModel.fromCartItem(Map<String, dynamic>.from(e as Map)))
          .toList();
    });
  }

  Stream<double> watchSubtotal(String poolId, String uid) {
    return _cartRef(poolId, uid)
        .snapshots()
        .map((snap) => (snap.data()?['subtotal'] as num?)?.toDouble() ?? 0);
  }

  Stream<CartView> watchCartView() {
    final uid = AuthService.instance.currentUser!.uid;
    return switchMap<UserModel, CartView>(
      UserService.instance.watchCurrentUser(),
      (user) {
        final poolId = user.activePoolId;
        if (poolId == null) return Stream<CartView>.value(const CartView());
        return combineLatest2<PoolView?, List<ProductModel>, CartView>(
          PoolService.instance.watchPoolView(poolId),
          watchItems(poolId, uid),
          (pv, items) => CartView(poolView: pv, items: items),
        );
      },
    );
  }

  Future<void> addToActivePool(ProductModel product) async {
    final uid = AuthService.instance.currentUser!.uid;
    final userSnap = await _db.collection('users').doc(uid).get();
    final poolId = userSnap.data()?['activePoolId'] as String?;
    if (poolId == null) throw NoActivePoolException();
    await changeQuantity(poolId: poolId, product: product, delta: 1);
  }

  /// Adds/removes units of a product in the member's cart and keeps the
  /// pool's `collectiveValue` and `demand` totals in sync, atomically.
  Future<void> changeQuantity({
    required String poolId,
    required ProductModel product,
    required int delta,
  }) async {
    final uid = AuthService.instance.currentUser!.uid;
    final poolRef = _db.collection('pools').doc(poolId);
    final cartRef = _cartRef(poolId, uid);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(cartRef);
      final items = ((snap.data()?['items'] as List<dynamic>?) ?? const [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      final index = items.indexWhere((m) => m['productId'] == product.id);
      final oldQty = index == -1 ? 0 : (items[index]['quantity'] as num).toInt();
      final unitPrice =
          index == -1 ? product.price : (items[index]['price'] as num).toDouble();
      final newQty = (oldQty + delta).clamp(0, 999).toInt();
      final applied = newQty - oldQty;
      if (applied == 0) return;

      if (newQty == 0) {
        items.removeAt(index);
      } else if (index == -1) {
        items.add({...product.toCartItem(), 'quantity': newQty});
      } else {
        items[index]['quantity'] = newQty;
      }

      final subtotal = items.fold<double>(
        0,
        (sum, m) => sum + (m['price'] as num).toDouble() * (m['quantity'] as num).toInt(),
      );

      tx.set(cartRef, {
        'items': items,
        'subtotal': subtotal,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      tx.update(poolRef, {
        'collectiveValue': FieldValue.increment(applied * unitPrice),
        'demand.${product.id}.qty': FieldValue.increment(applied),
        'demand.${product.id}.name': product.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
