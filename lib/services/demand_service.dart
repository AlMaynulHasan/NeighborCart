import '../core/utils/stream_utils.dart';
import '../models/pool_model.dart';
import '../models/wholesaler_order_model.dart';
import '../models/wholesaler_product_model.dart';
import 'auth_service.dart';
import 'pool_service.dart';
import 'product_service.dart';

/// Everything the wholesaler dashboard/orders/alerts screens need, derived
/// from this wholesaler's products plus the demand recorded on each pool.
class WholesalerOverview {
  final List<WholesalerProductModel> products;
  final List<WholesalerOrderModel> orders; // newest first
  final Map<String, int> productDemand; // product name -> total requested qty

  const WholesalerOverview({
    required this.products,
    required this.orders,
    required this.productDemand,
  });

  int get totalProducts => products.length;
  int get activeProducts => products.where((p) => p.isActive).length;

  List<WholesalerOrderModel> get moqReachedOrders =>
      orders.where((o) => o.moqStatus == MoqStatus.reached).toList();
  List<WholesalerOrderModel> get moqNotReachedOrders =>
      orders.where((o) => o.moqStatus == MoqStatus.notReached).toList();

  int get activeOrders => moqReachedOrders.length;
  int get pendingOrders => moqNotReachedOrders.length;
  int get activeCommunities => orders.length;

  double get totalSalesValue =>
      moqReachedOrders.fold<double>(0, (s, o) => s + o.estimatedValue);
  double get currentDemandValue =>
      orders.fold<double>(0, (s, o) => s + o.estimatedValue);

  List<WholesalerProductModel> get lowStockProducts =>
      products.where((p) => p.isLowStock).toList();

  List<String> get topRequested {
    final entries = productDemand.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(3).map((e) => e.key).toList();
  }
}

class DemandService {
  DemandService._();
  static final DemandService instance = DemandService._();

  Stream<WholesalerOverview> watchOverview() {
    final uid = AuthService.instance.currentUser!.uid;
    return combineLatest2<List<WholesalerProductModel>, List<PoolModel>, WholesalerOverview>(
      ProductService.instance.watchWholesalerProducts(uid),
      PoolService.instance.watchPools(),
      _build,
    );
  }

  static WholesalerOverview _build(
    List<WholesalerProductModel> products,
    List<PoolModel> pools,
  ) {
    final byId = {for (final p in products) p.id: p};
    final orders = <WholesalerOrderModel>[];
    final productDemand = <String, int>{};

    for (final pool in pools) {
      // Only demand for this wholesaler's own products counts.
      final relevant = pool.demand.values
          .where((d) => d.quantity > 0 && byId.containsKey(d.productId))
          .toList()
        ..sort((a, b) => b.quantity.compareTo(a.quantity));
      if (relevant.isEmpty) continue;

      final moqReached = relevant.every((d) => d.quantity >= byId[d.productId]!.moq);
      for (final d in relevant) {
        productDemand[d.name] = (productDemand[d.name] ?? 0) + d.quantity;
      }

      orders.add(WholesalerOrderModel(
        poolName: pool.name,
        orderDate: pool.updatedAt ?? pool.deadline,
        productsRequested: relevant.map((d) => d.name).toList(),
        totalQuantity: relevant.fold<int>(0, (s, d) => s + d.quantity),
        estimatedValue: pool.collectiveValue,
        moqStatus: moqReached ? MoqStatus.reached : MoqStatus.notReached,
        status: !moqReached
            ? DemandOrderStatus.awaitingMoq
            : (pool.status == 'open' ? DemandOrderStatus.ready : DemandOrderStatus.processing),
      ));
    }

    orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
    return WholesalerOverview(products: products, orders: orders, productDemand: productDemand);
  }
}
