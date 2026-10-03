import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/auth_mode.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/mock_data_service.dart';
import '../auth/login_screen.dart';

/// ASSUMPTION: Profile wasn't one of the 6 Figma screens — this is a
/// simple design in the same visual language (avatar, name, account
/// option list) (Master Prompt section 23).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _options = [
    (icon: Icons.person_outline_rounded, label: 'Personal Information'),
    (icon: Icons.location_on_outlined, label: 'Pickup Locations'),
    (icon: Icons.payment_rounded, label: 'Payment Methods'),
    (icon: Icons.notifications_outlined, label: 'Notifications'),
    (icon: Icons.settings_outlined, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    const user = MockDataService.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.primarySoft,
            child: Icon(Icons.person_rounded, size: 44, color: AppColors.primary),
          ),
          const SizedBox(height: 14),
          Text(user.name, style: AppTextStyles.heading2.copyWith(fontSize: 20)),
          const SizedBox(height: 4),
          Text(user.emailOrPhone, style: AppTextStyles.bodySecondary),
          const SizedBox(height: 28),
          for (final option in _options) _ProfileOptionTile(icon: option.icon, label: option.label),
          const SizedBox(height: 6),
          _ProfileOptionTile(
            icon: Icons.logout_rounded,
            label: 'Log Out',
            isDestructive: true,
            onTap: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppConstants.routeLogin,
                (route) => false,
              );
            },
          ),
          const SizedBox(height: 28),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen(initialMode: AuthMode.wholesaler)),
                );
              },
              child: Text(
                'Wholesaler / Supplier? Switch portal',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, decoration: TextDecoration.underline),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDestructive;
  final VoidCallback? onTap;

  const _ProfileOptionTile({
    required this.icon,
    required this.label,
    this.isDestructive = false,
    this.onTap,
  });

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
            if (!isDestructive)
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
