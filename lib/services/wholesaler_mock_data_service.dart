import '../models/pricing_tier_model.dart';
import '../models/wholesaler_model.dart';
import '../models/wholesaler_order_model.dart';
import '../models/wholesaler_product_model.dart';

/// PHASE 1 (wholesaler module) — static mock data only, structured so the
/// swap to real Firestore-backed services is mechanical later (Master
/// Prompt "Technical Requirements": "design the models and services so
/// Firebase Firestore can be connected later").
///
/// Pool/product names intentionally reuse the same ones from the customer
/// side's MockDataService so the two halves of the demo feel like one
/// consistent dataset.
class WholesalerMockDataService {
  WholesalerMockDataService._();

  static const WholesalerModel currentWholesaler = WholesalerModel(
    id: 'w1',
    businessName: 'Rahman Traders & Wholesale',
    contactName: 'Abdur Rahman',
    emailOrPhone: 'rahman.traders@example.com',
  );

  // ---- Dashboard summary ----
  static const int totalProducts = 42;
  static const int activeProducts = 36;
  static const int activeOrders = 18;
  static const int pendingOrders = 7;
  static const double totalSalesValue = 842500;
  static const int activeCommunities = 6;
  static const double currentDemandValue = 186400;

  static const List<String> recentOrderPoolNames = [
    'Saidpur Block-C Pool',
    'University Quarter Pool',
    'Nilphamari Road Pool',
  ];

  static const List<String> topRequestedProducts = [
    'Miniket Rice 5kg',
    'Red Lentils 2kg',
    'Soybean Oil 5L',
  ];

  // ---- Products ----
  static final List<WholesalerProductModel> products = [
    const WholesalerProductModel(
      id: 'wp1', name: 'Miniket Rice 5kg', category: 'Grains',
      wholesalePrice: 340, moq: 50, availableQuantity: 220, shelfLife: '12 months', isActive: true,
    ),
    const WholesalerProductModel(
      id: 'wp2', name: 'Red Lentils 2kg', category: 'Pulses',
      wholesalePrice: 230, moq: 40, availableQuantity: 180, shelfLife: '9 months', isActive: true,
    ),
    const WholesalerProductModel(
      id: 'wp3', name: 'Soybean Oil 5L', category: 'Cooking Oil',
      wholesalePrice: 760, moq: 25, availableQuantity: 30, shelfLife: '18 months', isActive: true,
    ),
    const WholesalerProductModel(
      id: 'wp4', name: 'Onion 3kg', category: 'Vegetables',
      wholesalePrice: 190, moq: 60, availableQuantity: 210, shelfLife: '2 months', isActive: true,
    ),
    const WholesalerProductModel(
      id: 'wp5', name: 'Sugar 2kg', category: 'Grocery',
      wholesalePrice: 150, moq: 40, availableQuantity: 18, shelfLife: '24 months', isActive: true,
    ),
    const WholesalerProductModel(
      id: 'wp6', name: 'Turmeric Powder 500g', category: 'Spices',
      wholesalePrice: 95, moq: 30, availableQuantity: 120, shelfLife: '12 months', isActive: false,
    ),
  ];

  // ---- Pricing tiers (mirrors the customer-side tier UI) ----
  static const List<PricingTierModel> pricingTiers = [
    PricingTierModel(id: 't1', label: 'Tier 1', minimumThreshold: 5000, discountPercent: 10, isActive: true),
    PricingTierModel(id: 't2', label: 'Tier 2', minimumThreshold: 10000, discountPercent: 15, isActive: true),
    PricingTierModel(id: 't3', label: 'Tier 3', minimumThreshold: 15000, discountPercent: 20, isActive: true),
  ];

  // ---- Demand / orders ----
  static final List<WholesalerOrderModel> demandOrders = [
    WholesalerOrderModel(
      poolName: 'Saidpur Block-C Pool',
      orderDate: DateTime.now().subtract(const Duration(hours: 6)),
      productsRequested: const ['Miniket Rice', 'Red Lentils', 'Soybean Oil'],
      totalQuantity: 96,
      estimatedValue: 12400,
      moqStatus: MoqStatus.reached,
      status: DemandOrderStatus.ready,
    ),
    WholesalerOrderModel(
      poolName: 'University Quarter Pool',
      orderDate: DateTime.now().subtract(const Duration(hours: 14)),
      productsRequested: const ['Miniket Rice', 'Onion', 'Sugar'],
      totalQuantity: 140,
      estimatedValue: 11200,
      moqStatus: MoqStatus.reached,
      status: DemandOrderStatus.processing,
    ),
    WholesalerOrderModel(
      poolName: 'Nilphamari Road Pool',
      orderDate: DateTime.now().subtract(const Duration(days: 1)),
      productsRequested: const ['Red Lentils', 'Soybean Oil'],
      totalQuantity: 58,
      estimatedValue: 4500,
      moqStatus: MoqStatus.reached,
      status: DemandOrderStatus.ready,
    ),
    WholesalerOrderModel(
      poolName: 'East Saidpur Block-A Pool',
      orderDate: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      productsRequested: const ['Miniket Rice', 'Turmeric Powder'],
      totalQuantity: 22,
      estimatedValue: 3100,
      moqStatus: MoqStatus.notReached,
      status: DemandOrderStatus.awaitingMoq,
    ),
  ];
}
