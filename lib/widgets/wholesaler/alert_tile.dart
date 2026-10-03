import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum AlertSeverity { warning, info, success }

/// A single row on the Low Stock / MOQ Alerts screen.
class AlertTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final AlertSeverity severity;

  const AlertTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.severity = AlertSeverity.warning,
  });

  Color get _color {
    switch (severity) {
      case AlertSeverity.warning:
        return AppColors.warning;
      case AlertSeverity.info:
        return AppColors.textSecondary;
      case AlertSeverity.success:
        return AppColors.primary;
    }
  }

  Color get _bg {
    switch (severity) {
      case AlertSeverity.warning:
        return AppColors.warningSoft;
      case AlertSeverity.info:
        return AppColors.border;
      case AlertSeverity.success:
        return AppColors.primarySoft;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: _color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
