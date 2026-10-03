import '../models/cart_model.dart';
import '../models/order_model.dart';
import '../models/order_summary_model.dart';
import '../models/pool_model.dart';
import '../models/pool_tier_model.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';

/// PHASE 1 ONLY.
/// Provides static mock data so screens can be built and navigated before
/// Firebase integration (Master Prompt section 9/10). This class will be
/// replaced by real service classes (pool_service.dart, cart_service.dart,
/// etc.) once Firebase integration begins — screens should already be
/// calling data through a single access point like this so that swap is
/// mechanical.
///
/// All values below are copied directly from the NeighborCart Figma
/// export (Master Prompt section 5) so Phase 1 screens are pixel/content
/// accurate, not just visually similar.
class MockDataService {
  MockDataService._();

  static const UserModel currentUser = UserModel(
    id: 'u1',
    name: 'Maynul',
    emailOrPhone: 'maynulhasan625@gmail.com',
  );

  static final PoolModel activePool = PoolModel(
    id: 'p1',
    name: 'Saidpur Block-C Pool',
    collectiveValue: 12400,
    memberCount: 12,
    discountPercent: 15,
    pickupLocation: 'Saidpur Community Center, Gate 2',
    deadline: DateTime.now().add(const Duration(days: 2, hours: 4)),
    coordinatorName: 'Zahid Hasan',
    targetForNextTier: 5000,
    collectedTowardNextTier: 3200,
    tiers: const [
      PoolTier(label: 'Tier 1', threshold: 5000, discountPercent: 10, unlocked: true),
      PoolTier(label: 'Tier 2', threshold: 10000, discountPercent: 15, unlocked: true),
      PoolTier(label: 'Tier 3', threshold: 15000, discountPercent: 20, unlocked: false),
    ],
  );

  static const double currentUserSavings = 1240;
  static const double tier3AmountNeeded = 2600;
  static const String orderDeadlineLabel = 'Thursday, 8:00 PM';

  static const List<ProductModel> recommendedItems = [
    ProductModel(id: 'prod1', name: 'Miniket Rice 5kg', description: 'Premium polished grains', price: 380),
    ProductModel(id: 'prod2', name: 'Red Lentils 2kg', description: 'Deshi moshur dal', price: 260),
    ProductModel(id: 'prod3', name: 'Soybean Oil 5L', description: 'Rupchanda premium oil', price: 820),
  ];

  static const List<NearbyPoolSummary> nearbyPools = [
    NearbyPoolSummary(
      id: 'p2',
      name: 'Nilphamari Road Pool',
      discountPercent: 12,
      collectiveOrders: 4500,
      pickupLocation: 'Saidpur Govt College Gate',
      closesLabel: 'Closes Thu 8 PM',
      joinedCount: 8,
      extraAvatarCount: 5,
    ),
    NearbyPoolSummary(
      id: 'p3',
      name: 'University Quarter Pool',
      discountPercent: 15,
      collectiveOrders: 11200,
      pickupLocation: 'Unicourt Community Gate 1',
      closesLabel: 'Closes Wed 6 PM',
      joinedCount: 15,
      extraAvatarCount: 12,
    ),
    NearbyPoolSummary(
      id: 'p4',
      name: 'East Saidpur Block-A Pool',
      discountPercent: 10,
      collectiveOrders: 3100,
      pickupLocation: 'Al-Falah Jame Mosque Complex',
      closesLabel: 'Closes Fri 4 PM',
      joinedCount: 6,
      extraAvatarCount: 3,
    ),
  ];

  static const CartModel weeklyCart = CartModel(
    poolId: 'p1',
    poolName: 'Saidpur Block-C Pool',
    items: [
      ProductModel(id: 'prod1', name: 'Miniket Rice 5kg', description: 'Premium polished grains', price: 380, quantity: 1),
      ProductModel(id: 'prod2', name: 'Red Lentils 2kg', description: 'Deshi moshur dal', price: 260, quantity: 2),
      ProductModel(id: 'prod3', name: 'Soybean Oil 5L', description: 'Rupchanda brand', price: 820, quantity: 1),
      ProductModel(id: 'prod4', name: 'Onion 3kg', description: 'Local organic red onions', price: 220, quantity: 1),
    ],
    sharedCartTotal: 8450,
    retailPrice: 2100,
    estimatedCost: 1680,
    savings: 420,
    wholesaleUnlocked: true,
  );

  static const OrderModel settlementOrder = OrderModel(
    id: '#204',
    poolId: 'p1',
    poolName: 'Saidpur Block-C Pool',
    totalAmount: 12400,
    memberShare: 1680,
    membersPaid: 9,
    membersTotal: 12,
    members: [
      OrderMember(name: 'Maynul Islam (You)', share: 1680, itemsOrdered: 4, status: PaymentStatus.paid, isCurrentUser: true),
      OrderMember(name: 'Tanvir Ahmed', share: 2150, itemsOrdered: 5, status: PaymentStatus.pending),
      OrderMember(name: 'Sadia Rahman', share: 1420, itemsOrdered: 3, status: PaymentStatus.paid),
      OrderMember(name: 'Jubayer Al-Mahmud', share: 3100, itemsOrdered: 7, status: PaymentStatus.paid),
    ],
  );

  static final List<OrderSummary> orderHistory = [
    OrderSummary(
      id: '#204',
      poolName: 'Saidpur Block-C Pool',
      date: DateTime.now().subtract(const Duration(days: 1)),
      totalAmount: 12400,
      memberShare: 1680,
      status: PaymentStatus.pending,
    ),
    OrderSummary(
      id: '#198',
      poolName: 'Saidpur Block-C Pool',
      date: DateTime.now().subtract(const Duration(days: 8)),
      totalAmount: 9800,
      memberShare: 1240,
      status: PaymentStatus.paid,
    ),
    OrderSummary(
      id: '#187',
      poolName: 'Nilphamari Road Pool',
      date: DateTime.now().subtract(const Duration(days: 22)),
      totalAmount: 4500,
      memberShare: 620,
      status: PaymentStatus.paid,
    ),
  ];
}
