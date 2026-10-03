import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

enum AppTab { home, pools, cart, orders, profile }

/// Bottom navigation bar shared by Home, Nearby Pools, Weekly Cart,
/// Settlement/Orders and Profile (Master Prompt sections 4 & 8).
class BottomNavBar extends StatelessWidget {
  final AppTab currentTab;
  final ValueChanged<AppTab> onTabSelected;

  const BottomNavBar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  static const _items = [
    (tab: AppTab.home, icon: Icons.home_rounded, label: 'Home'),
    (tab: AppTab.pools, icon: Icons.groups_rounded, label: 'Pools'),
    (tab: AppTab.cart, icon: Icons.shopping_cart_rounded, label: 'Cart'),
    (tab: AppTab.orders, icon: Icons.receipt_long_rounded, label: 'Orders'),
    (tab: AppTab.profile, icon: Icons.person_rounded, label: 'Profile'),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon, color: color, size: 24),
                    const SizedBox(height: 4),
                    Text(item.label, style: AppTextStyles.caption.copyWith(color: color)),
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
