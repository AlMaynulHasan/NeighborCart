import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/format.dart';
import '../../core/utils/stream_utils.dart';
import '../../models/product_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/cart_service.dart';
import '../../services/pool_service.dart';
import '../../services/product_service.dart';
import '../../services/user_service.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/cart_actions.dart';
import '../../widgets/product_card.dart';
import '../../widgets/stream_view.dart';
import '../auth/login_screen.dart';
import '../cart/weekly_cart_screen.dart';
import '../orders/orders_screen.dart';
import '../pools/nearby_pools_screen.dart';
import '../pools/pool_details_screen.dart';
import '../profile/profile_screen.dart';
import 'all_products_screen.dart';

/// Matches Figma screen 2 ("Home"). Hosts the bottom nav and switches
/// between the 5 tab screens (Master Prompt section 8).
class HomeScreen extends StatefulWidget {
  final AppTab initialTab;
  const HomeScreen({super.key, this.initialTab = AppTab.home});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AppTab _currentTab;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  Widget _buildTabBody() {
    switch (_currentTab) {
      case AppTab.home:
        return _HomeTabContent(
            onFindPool: () => setState(() => _currentTab = AppTab.pools));
      case AppTab.pools:
        return const NearbyPoolsScreen();
      case AppTab.cart:
        return const WeeklyCartScreen();
      case AppTab.orders:
        return const OrdersScreen();
      case AppTab.profile:
        return const ProfileScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safety net: without a signed-in user every tab would fail.
    if (AuthService.instance.currentUser == null) return const LoginScreen();
    return Scaffold(
      body: SafeArea(child: _buildTabBody()),
      bottomNavigationBar: BottomNavBar(
        currentTab: _currentTab,
        onTabSelected: (tab) => setState(() => _currentTab = tab),
      ),
    );
  }
}

typedef _HomeData = (UserModel, PoolView?, double);

class _HomeTabContent extends StatelessWidget {
  final VoidCallback onFindPool;
  const _HomeTabContent({required this.onFindPool});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Stream<_HomeData> _createStream() {
    final uid = AuthService.instance.currentUser!.uid;
    return switchMap<UserModel, _HomeData>(
      UserService.instance.watchCurrentUser(),
      (user) {
        final poolId = user.activePoolId;
        if (poolId == null) return Stream<_HomeData>.value((user, null, 0.0));
        return combineLatest2<PoolView?, double, _HomeData>(
          PoolService.instance.watchPoolView(poolId),
          CartService.instance.watchSubtotal(poolId, uid),
          (pv, subtotal) => (user, pv, subtotal),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamView<_HomeData>(
      create: _createStream,
      builder: (context, data) {
        final user = data.$1;
        final poolView = data.$2;
        final subtotal = data.$3;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome back', style: AppTextStyles.subtitle),
                        const SizedBox(height: 2),
                        Text('${_greeting()}, ${user.firstName} 👋',
                            style: AppTextStyles.heading2),
                      ],
                    ),
                  ),
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primarySoft,
                    child: Icon(Icons.person_rounded, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (poolView == null)
                _NoPoolCard(onFindPool: onFindPool)
              else
                _ActivePoolCard(
                  poolView: poolView,
                  savings:
                      subtotal - poolView.priceBreak.applyDiscount(subtotal),
                ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recommended Items', style: AppTextStyles.title),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const AllProductsScreen()),
                    ),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary),
                    child: const Text('View All',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 200,
                child: StreamView<List<ProductModel>>(
                  create: () => ProductService.instance.watchActiveProducts(),
                  builder: (context, products) {
                    if (products.isEmpty) {
                      return Center(
                        child: Text('No products available yet.',
                            style: AppTextStyles.bodySecondary),
                      );
                    }
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: products.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ProductCard(
                          product: product,
                          onAdd: () => addProductToCart(context, product),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NoPoolCard extends StatelessWidget {
  final VoidCallback onFindPool;
  const _NoPoolCard({required this.onFindPool});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: AppColors.shadow, blurRadius: 14, offset: Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('No active pool yet',
              style: AppTextStyles.title.copyWith(fontSize: 19)),
          const SizedBox(height: 6),
          Text('Join a nearby pool to start saving on your groceries.',
              style: AppTextStyles.bodySecondary),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: onFindPool, child: const Text('Find a Pool')),
        ],
      ),
    );
  }
}

class _ActivePoolCard extends StatelessWidget {
  final PoolView poolView;
  final double savings;
  const _ActivePoolCard({required this.poolView, required this.savings});

  @override
  Widget build(BuildContext context) {
    final pool = poolView.pool;
    final pb = poolView.priceBreak;
    final unlocked = pb.unlockedTier;
    final next = pb.nextTier;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: AppColors.shadow, blurRadius: 14, offset: Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'ACTIVE POOL',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const Spacer(),
              if (pool.extraMembers > 0)
                Text('+${pool.extraMembers}',
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          Text(pool.name, style: AppTextStyles.title.copyWith(fontSize: 19)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DISCOUNT', style: AppTextStyles.caption),
                    const SizedBox(height: 4),
                    Text(
                      unlocked == null
                          ? 'No discount yet'
                          : '${pb.discountPercent.round()}% Off (${unlocked.label})',
                      style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('YOUR SAVINGS', style: AppTextStyles.caption),
                    const SizedBox(height: 4),
                    Text(formatTaka(savings),
                        style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                unlocked == null
                    ? 'No tier unlocked'
                    : '${unlocked.label} (${unlocked.discountPercent.round()}% off)',
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w700),
              ),
              Text(
                next == null
                    ? 'All tiers unlocked'
                    : 'Next: ${next.label} (${next.discountPercent.round()}% off)',
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pb.progressToNext,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${formatTaka(pb.collected, commas: false)} collected',
                  style: AppTextStyles.caption),
              Text('${formatTaka(pb.progressTarget, commas: false)} target',
                  style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => PoolDetailsScreen(poolId: pool.id)),
                );
              },
              child: const Text('View Pool'),
            ),
          ),
        ],
      ),
    );
  }
}
