import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/utils/format.dart';

/// One product's total requested quantity across a pool (kept on the pool
/// doc as `demand.{productId}.{name,qty}` so the wholesaler side can read
/// aggregated demand without scanning every member's cart).
class PoolDemandItem {
  final String productId;
  final String name;
  final int quantity;

  const PoolDemandItem({
    required this.productId,
    required this.name,
    required this.quantity,
  });
}

class PoolModel {
  final String id;
  final String name;
  final String pickupLocation;
  final String coordinatorName;
  final String coordinatorUid;
  final double collectiveValue;
  final int memberCount;
  final int orderNumber;
  final DateTime deadline;
  final DateTime? updatedAt;
  final Map<String, PoolDemandItem> demand;

  const PoolModel({
    required this.id,
    required this.name,
    required this.pickupLocation,
    required this.coordinatorName,
    required this.coordinatorUid,
    required this.collectiveValue,
    required this.memberCount,
    required this.orderNumber,
    required this.deadline,
    required this.updatedAt,
    required this.demand,
  });

  factory PoolModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? <String, dynamic>{};
    final rawDemand = (d['demand'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final demand = <String, PoolDemandItem>{};
    rawDemand.forEach((key, value) {
      final m = value as Map<String, dynamic>;
      final qty = (m['qty'] as num?)?.toInt() ?? 0;
      if (qty > 0) {
        demand[key] = PoolDemandItem(
          productId: key,
          name: (m['name'] as String?) ?? key,
          quantity: qty,
        );
      }
    });
    return PoolModel(
      id: doc.id,
      name: (d['name'] as String?) ?? 'Pool',
      pickupLocation: (d['pickupLocation'] as String?) ?? '',
      coordinatorName: (d['coordinatorName'] as String?) ?? '',
      coordinatorUid: (d['coordinatorUid'] as String?) ?? '',
      collectiveValue: (d['collectiveValue'] as num?)?.toDouble() ?? 0,
      memberCount: (d['memberCount'] as num?)?.toInt() ?? 0,
      orderNumber: (d['orderNumber'] as num?)?.toInt() ?? 0,
      deadline: (d['deadline'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
      demand: demand,
    );
  }

  bool get isClosed => deadline.isBefore(DateTime.now());
  String get closesLabel => isClosed ? 'Closed' : formatClosesShort(deadline);
  String get deadlineLabel => formatDeadlineLong(deadline);

  /// The "+N" shown next to the avatar stack (3 avatars are drawn).
  int get extraMembers => memberCount > 3 ? memberCount - 3 : 0;
}
