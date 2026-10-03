import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Separate nav for the wholesaler side — same visual style as the
/// customer BottomNavBar, but intentionally its own widget/enum so the
/// two are never mixed (Master Prompt: "Do NOT mix wholesaler navigation
/// with the customer's bottom navigation").
enum WholesalerTab { dashboard, products, orders, pricing, profile }

class WholesalerBottomNav extends StatelessWidget {
  final WholesalerTab currentTab;
  final ValueChanged<WholesalerTab> onTabSelected;

  const WholesalerBottomNav({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  static const _items = [
    (tab: WholesalerTab.dashboard, icon: Icons.space_dashboard_rounded, label: 'Dashboard'),
    (tab: WholesalerTab.products, icon: Icons.inventory_2_rounded, label: 'Products'),
    (tab: WholesalerTab.orders, icon: Icons.local_shipping_rounded, label: 'Orders'),
    (tab: WholesalerTab.pricing, icon: Icons.sell_rounded, label: 'Pricing'),
    (tab: WholesalerTab.profile, icon: Icons.storefront_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _items.map((item) {
            final selected = item.tab == currentTab;
            final color = selected ? AppColors.primary : AppColors.textSecondary;
            return InkWell(
              onTap: () => onTabSelected(item.tab),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon, color: color, size: 23),
                    const SizedBox(height: 4),
                    Text(item.label, style: AppTextStyles.caption.copyWith(color: color, fontSize: 11)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
