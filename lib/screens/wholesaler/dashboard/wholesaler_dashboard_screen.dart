import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/format.dart';
import '../../../core/utils/stream_utils.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/demand_service.dart';
import '../../../services/user_service.dart';
import '../../../widgets/stream_view.dart';
import '../../../widgets/wholesaler/demand_order_card.dart';
import '../../../widgets/wholesaler/stat_card.dart';
import '../../../widgets/wholesaler/wholesaler_bottom_nav.dart';
import '../../auth/login_screen.dart';
import '../alerts/alerts_screen.dart';
import '../orders/demand_screen.dart';
import '../pricing/pricing_management_screen.dart';
import '../products/product_management_screen.dart';
import '../profile/wholesaler_profile_screen.dart';

/// Hosts the wholesaler bottom nav and switches between its 5 tabs —
/// separate from the customer navigation (WholesalerTab, not AppTab).
class WholesalerDashboardScreen extends StatefulWidget {
  const WholesalerDashboardScreen({super.key});

  @override
  State<WholesalerDashboardScreen> createState() => _WholesalerDashboardScreenState();
}

class _WholesalerDashboardScreenState extends State<WholesalerDashboardScreen> {
  WholesalerTab _currentTab = WholesalerTab.dashboard;

  Widget _buildTabBody() {
    switch (_currentTab) {
      case WholesalerTab.dashboard:
        return const _DashboardTabContent();
      case WholesalerTab.products:
        return const ProductManagementScreen();
      case WholesalerTab.orders:
        return const DemandScreen();
      case WholesalerTab.pricing:
        return const PricingManagementScreen();
      case WholesalerTab.profile:
        return const WholesalerProfileScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safety net: without a signed-in user every tab would fail.
    if (AuthService.instance.currentUser == null) return const LoginScreen();
    return Scaffold(
      body: SafeArea(child: _buildTabBody()),
      bottomNavigationBar: WholesalerBottomNav(
        currentTab: _currentTab,
        onTabSelected: (tab) => setState(() => _currentTab = tab),
      ),
    );
  }
}

class _DashboardTabContent extends StatelessWidget {
  const _DashboardTabContent();

  Stream<(WholesalerOverview, UserModel)> _createStream() {
    return combineLatest2<WholesalerOverview, UserModel, (WholesalerOverview, UserModel)>(
      DemandService.instance.watchOverview(),
      UserService.instance.watchCurrentUser(),
      (overview, user) => (overview, user),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamView<(WholesalerOverview, UserModel)>(
      create: _createStream,
      builder: (context, data) {
        final overview = data.$1;
        final user = data.$2;

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
                        Text(user.displayName, style: AppTextStyles.heading2.copyWith(fontSize: 20)),
                      ],
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AlertsScreen()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
                      child: const Icon(Icons.notifications_rounded, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  StatCard(label: 'Total Products', value: '${overview.totalProducts}', icon: Icons.inventory_2_rounded),
                  StatCard(label: 'Active Products', value: '${overview.activeProducts}', icon: Icons.check_circle_rounded),
                  StatCard(label: 'Active Orders', value: '${overview.activeOrders}', icon: Icons.local_shipping_rounded),
                  StatCard(
                    label: 'Pending Orders',
                    value: '${overview.pendingOrders}',
                    icon: Icons.hourglass_top_rounded,
                    accentColor: AppColors.warning,
                  ),
                  StatCard(label: 'Total Sales Value', value: formatTaka(overview.totalSalesValue), icon: Icons.payments_rounded),
                  StatCard(label: 'Active Communities', value: '${overview.activeCommunities}', icon: Icons.groups_rounded),
                ],
              ),
              const SizedBox(height: 10),
              StatCard(
                label: 'Current Demand (aggregated across active pools)',
                value: formatTaka(overview.currentDemandValue),
                icon: Icons.trending_up_rounded,
              ),
              const SizedBox(height: 28),
              Text('Recent Orders', style: AppTextStyles.title),
              const SizedBox(height: 12),
              if (overview.orders.isEmpty)
                Text('No demand from pools yet.', style: AppTextStyles.bodySecondary)
              else
                for (final order in overview.orders.take(3)) DemandOrderCard(order: order),
              const SizedBox(height: 16),
              Text('Top Requested Products', style: AppTextStyles.title),
              const SizedBox(height: 10),
              if (overview.topRequested.isEmpty)
                Text('Nothing requested yet.', style: AppTextStyles.bodySecondary)
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final name in overview.topRequested)
                      Chip(
                        label: Text(name,
                            style: AppTextStyles.caption
                                .copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
                        backgroundColor: AppColors.primarySoft,
                        side: BorderSide.none,
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
