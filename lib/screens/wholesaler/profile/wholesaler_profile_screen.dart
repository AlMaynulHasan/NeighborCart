import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/seed_service.dart';
import '../../../services/user_service.dart';
import '../../../widgets/stream_view.dart';
import '../../auth/login_screen.dart';
import '../../profile/edit_profile_screen.dart';

/// Simple wholesaler account screen — same option-list pattern as the
/// customer ProfileScreen, kept separate per the "do not mix" rule.
class WholesalerProfileScreen extends StatelessWidget {
  const WholesalerProfileScreen({super.key});

  static const _options = [
    (icon: Icons.storefront_outlined, label: 'Business Information'),
    (icon: Icons.local_shipping_outlined, label: 'Pickup & Delivery Settings'),
    (icon: Icons.account_balance_wallet_outlined, label: 'Payout Methods'),
    (icon: Icons.notifications_outlined, label: 'Notifications'),
    (icon: Icons.settings_outlined, label: 'Settings'),
  ];

  Future<void> _loadDemoCatalog(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final uid = AuthService.instance.currentUser!.uid;
      final created = await SeedService.instance.seedWholesalerCatalog(uid);
      messenger.showSnackBar(SnackBar(
        content: Text(created == 0
            ? 'Demo products are already loaded.'
            : 'Loaded $created demo products and default tiers.'),
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Could not load demo products: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamView<UserModel>(
      create: () => UserService.instance.watchCurrentUser(),
      builder: (context, user) {
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
              Text(user.displayName,
                  style: AppTextStyles.heading2.copyWith(fontSize: 19), textAlign: TextAlign.center),
              const SizedBox(height: 4),
              if (user.contactName != null) Text(user.contactName!, style: AppTextStyles.bodySecondary),
              Text(user.emailOrPhone, style: AppTextStyles.bodySecondary),
              const SizedBox(height: 28),
              for (final option in _options)
                _OptionTile(
                  icon: option.icon,
                  label: option.label,
                  onTap: option.label == 'Business Information'
                      ? () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => EditProfileScreen(user: user)),
                          )
                      : null,
                ),
              const SizedBox(height: 6),
              _OptionTile(
                icon: Icons.logout_rounded,
                label: 'Log Out',
                isDestructive: true,
                onTap: () async {
                  await AuthService.instance.signOut();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 24),
              Text('Developer tools', style: AppTextStyles.caption),
              const SizedBox(height: 8),
              _OptionTile(
                icon: Icons.build_outlined,
                label: 'Load demo products & tiers',
                onTap: () => _loadDemoCatalog(context),
              ),
            ],
          ),
        );
      },
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
