import 'package:flutter/material.dart';
import '../core/constants/auth_mode.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Two-segment "Customer / Wholesaler" switcher shown at the top of the
/// merged Login and Sign Up screens.
class AuthModeToggle extends StatelessWidget {
  final AuthMode mode;
  final ValueChanged<AuthMode> onChanged;

  const AuthModeToggle({super.key, required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(child: _segment(context, AuthMode.customer, 'Customer', Icons.person_rounded)),
          Expanded(child: _segment(context, AuthMode.wholesaler, 'Wholesaler', Icons.storefront_rounded)),
        ],
      ),
    );
  }

  Widget _segment(BuildContext context, AuthMode value, String label, IconData icon) {
    final selected = mode == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: selected ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
