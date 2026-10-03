import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../services/wholesaler_mock_data_service.dart';
import '../../../widgets/wholesaler/demand_order_card.dart';
import '../../../widgets/wholesaler/stat_card.dart';
import '../../../widgets/wholesaler/wholesaler_bottom_nav.dart';
import '../alerts/alerts_screen.dart';
import '../orders/demand_screen.dart';
import '../pricing/pricing_management_screen.dart';
import '../products/product_management_screen.dart';
import '../profile/wholesaler_profile_screen.dart';

/// Hosts the wholesaler bottom nav and switches between its 5 tabs —
/// mirrors the customer HomeScreen's shell pattern but with its own,
/// separate navigation (WholesalerTab, not AppTab).
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

  @override
  Widget build(BuildContext context) {
    const wholesaler = WholesalerMockDataService.currentWholesaler;

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
                    Text(wholesaler.businessName, style: AppTextStyles.heading2.copyWith(fontSize: 20)),
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
              const StatCard(label: 'Total Products', value: '${WholesalerMockDataService.totalProducts}', icon: Icons.inventory_2_rounded),
              const StatCard(label: 'Active Products', value: '${WholesalerMockDataService.activeProducts}', icon: Icons.check_circle_rounded),
              const StatCard(label: 'Active Orders', value: '${WholesalerMockDataService.activeOrders}', icon: Icons.local_shipping_rounded),
              const StatCard(label: 'Pending Orders', value: '${WholesalerMockDataService.pendingOrders}', icon: Icons.hourglass_top_rounded, accentColor: AppColors.warning),
              StatCard(label: 'Total Sales Value', value: '৳${WholesalerMockDataService.totalSalesValue.toStringAsFixed(0)}', icon: Icons.payments_rounded),
              const StatCard(label: 'Active Communities', value: '${WholesalerMockDataService.activeCommunities}', icon: Icons.groups_rounded),
            ],
          ),
          const SizedBox(height: 10),
          StatCard(
            label: 'Current Demand (aggregated across active pools)',
            value: '৳${WholesalerMockDataService.currentDemandValue.toStringAsFixed(0)}',
            icon: Icons.trending_up_rounded,
          ),
          const SizedBox(height: 28),
          const Text('Recent Orders', style: AppTextStyles.title),
          const SizedBox(height: 12),
          for (final order in WholesalerMockDataService.demandOrders.take(3)) DemandOrderCard(order: order),
          const SizedBox(height: 16),
          const Text('Top Requested Products', style: AppTextStyles.title),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final name in WholesalerMockDataService.topRequestedProducts)
                Chip(
                  label: Text(name, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
                  backgroundColor: AppColors.primarySoft,
                  side: BorderSide.none,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
