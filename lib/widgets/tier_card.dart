import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/pool_tier_model.dart';

/// A single tier row inside the "Tier Unlocks" card on Pool Details.
class TierRow extends StatelessWidget {
  final PoolTier tier;
  final double? amountNeeded; // shown only for the next locked tier

  const TierRow({super.key, required this.tier, this.amountNeeded});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${tier.label} (৳${tier.threshold.toStringAsFixed(0)} — ${tier.discountPercent.toStringAsFixed(0)}% Off)',
            style: AppTextStyles.body.copyWith(
              fontWeight: tier.unlocked ? FontWeight.w600 : FontWeight.w500,
              color: tier.unlocked ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          if (tier.unlocked)
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Unlocked', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                SizedBox(width: 4),
                Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
              ],
            )
          else
            Text(
              '৳${(amountNeeded ?? 0).toStringAsFixed(0)} Needed',
              style: AppTextStyles.body.copyWith(color: AppColors.warning, fontWeight: FontWeight.w700),
            ),
        ],
      ),
    );
  }
}
