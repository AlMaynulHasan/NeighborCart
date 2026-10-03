enum PaymentStatus { paid, pending }

/// One member's line in a Settlement breakdown.
class OrderMember {
  final String name;
  final double share;
  final int itemsOrdered;
  final PaymentStatus status;
  final String? avatarUrl;
  final bool isCurrentUser;

  const OrderMember({
    required this.name,
    required this.share,
    required this.itemsOrdered,
    required this.status,
    this.avatarUrl,
    this.isCurrentUser = false,
  });
}

/// Represents a settled/settling weekly pool order.
class OrderModel {
  final String id; // e.g. "#204"
  final String poolId;
  final String poolName;
  final double totalAmount;
  final double memberShare;
  final int membersPaid;
  final int membersTotal;
  final List<OrderMember> members;

  const OrderModel({
    required this.id,
    required this.poolId,
    required this.poolName,
    required this.totalAmount,
    required this.memberShare,
    required this.membersPaid,
    required this.membersTotal,
    required this.members,
  });
}
