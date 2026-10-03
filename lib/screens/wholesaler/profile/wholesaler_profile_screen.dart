import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../services/wholesaler_mock_data_service.dart';

/// Simple wholesaler account screen — same option-list pattern as the
/// customer ProfileScreen, kept separate as its own widget per the
/// module's "do not mix" navigation rule.
class WholesalerProfileScreen extends StatelessWidget {
  const WholesalerProfileScreen({super.key});

  static const _options = [
    (icon: Icons.storefront_outlined, label: 'Business Information'),
    (icon: Icons.local_shipping_outlined, label: 'Pickup & Delivery Settings'),
    (icon: Icons.account_balance_wallet_outlined, label: 'Payout Methods'),
    (icon: Icons.notifications_outlined, label: 'Notifications'),
    (icon: Icons.settings_outlined, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    const wholesaler = WholesalerMockDataService.currentWholesaler;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.primarySoft,
            child: Icon(Icons.storefront_rounded, size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 14),
          Text(wholesaler.businessName, style: AppTextStyles.heading2.copyWith(fontSize: 19), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(wholesaler.contactName, style: AppTextStyles.bodySecondary),
          Text(wholesaler.emailOrPhone, style: AppTextStyles.bodySecondary),
          const SizedBox(height: 28),
          for (final option in _options) _OptionTile(icon: option.icon, label: option.label),
          const SizedBox(height: 6),
          _OptionTile(
            icon: Icons.logout_rounded,
            label: 'Log Out',
            isDestructive: true,
            onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDestructive;
  final VoidCallback? onTap;

  const _OptionTile({required this.icon, required this.label, this.isDestructive = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.warning : AppColors.primary;
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 3))],
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDestructive ? AppColors.warning : AppColors.textPrimary,
                ),
              ),
            ),
            if (!isDestructive) const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
