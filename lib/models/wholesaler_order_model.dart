enum MoqStatus { reached, notReached }
enum DemandOrderStatus { ready, processing, awaitingMoq }

/// Aggregated demand coming from one NeighborCart pool, as seen by the
/// wholesaler (Master Prompt section 17 — Community Demand Aggregation,
/// and section 7 — Order/Demand View).
class WholesalerOrderModel {
  final String poolName;
  final DateTime orderDate;
  final List<String> productsRequested;
  final int totalQuantity;
  final double estimatedValue;
  final MoqStatus moqStatus;
  final DemandOrderStatus status;

  const WholesalerOrderModel({
    required this.poolName,
    required this.orderDate,
    required this.productsRequested,
    required this.totalQuantity,
    required this.estimatedValue,
    required this.moqStatus,
    required this.status,
  });
}
