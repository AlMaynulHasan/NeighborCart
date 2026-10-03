import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/pool_model.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/product_card.dart';
import '../cart/weekly_cart_screen.dart';
import '../orders/orders_screen.dart';
import '../pools/nearby_pools_screen.dart';
import '../pools/pool_details_screen.dart';
import '../profile/profile_screen.dart';

/// Matches Figma screen 2 ("Home"). Hosts the bottom nav and switches
/// between the 5 tab screens (Master Prompt section 8).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppTab _currentTab = AppTab.home;

  Widget _buildTabBody() {
    switch (_currentTab) {
      case AppTab.home:
        return const _HomeTabContent();
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
    return Scaffold(
      body: SafeArea(child: _buildTabBody()),
      bottomNavigationBar: BottomNavBar(
        currentTab: _currentTab,
        onTabSelected: (tab) => setState(() => _currentTab = tab),
      ),
    );
  }
}

class _HomeTabContent extends StatelessWidget {
  const _HomeTabContent();

  @override
  Widget build(BuildContext context) {
    const user = MockDataService.currentUser;
    final pool = MockDataService.activePool;

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
                    const Text('Welcome back', style: AppTextStyles.subtitle),
                    const SizedBox(height: 2),
                    Text('Good morning, ${user.name} 👋', style: AppTextStyles.heading2),
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
          _ActivePoolCard(pool: pool),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recommended Items', style: AppTextStyles.title),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                child: const Text('View All', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: MockDataService.recommendedItems.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return ProductCard(product: MockDataService.recommendedItems[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivePoolCard extends StatelessWidget {
  final PoolModel pool;
  const _ActivePoolCard({required this.pool});

  @override
  Widget build(BuildContext context) {
    final progress =
        (pool.collectedTowardNextTier / pool.targetForNextTier).clamp(0.0, 1.0);
    final unlockedTier = pool.tiers.lastWhere((t) => t.unlocked, orElse: () => pool.tiers.first);
    final nextTier = pool.tiers.firstWhere(
      (t) => !t.unlocked,
      orElse: () => pool.tiers.last,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 14, offset: Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
              // Simple stacked-avatar placeholder for "+9 members".
              Text('+${pool.memberCount - 3 < 0 ? 0 : pool.memberCount - 3}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
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
                    const Text('DISCOUNT', style: AppTextStyles.caption),
                    const SizedBox(height: 4),
                    Text('${pool.discountPercent.toStringAsFixed(0)}% Off (${unlockedTier.label})',
                        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('YOUR SAVINGS', style: AppTextStyles.caption),
                    const SizedBox(height: 4),
                    Text('৳${MockDataService.currentUserSavings.toStringAsFixed(0)}',
                        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${unlockedTier.label} (${unlockedTier.discountPercent.toStringAsFixed(0)}% off)',
                  style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
              Text('Next: ${nextTier.label} (${nextTier.discountPercent.toStringAsFixed(0)}% off)',
                  style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('৳${pool.collectedTowardNextTier.toStringAsFixed(0)} collected', style: AppTextStyles.caption),
              Text('৳${pool.targetForNextTier.toStringAsFixed(0)} target',
                  style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PoolDetailsScreen()),
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
