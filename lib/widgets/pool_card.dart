import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/format.dart';
import '../services/pool_service.dart';

/// Pool summary card used on the "Nearby Pools" screen.
class PoolCard extends StatelessWidget {
  final PoolView poolView;
  final bool isMember;
  final VoidCallback onPressed;

  const PoolCard({
    super.key,
    required this.poolView,
    required this.isMember,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final pool = poolView.pool;
    final discount = poolView.priceBreak.discountPercent;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(pool.name, style: AppTextStyles.title.copyWith(fontSize: 17)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  discount > 0 ? '${discount.round()}% OFF' : 'NEW POOL',
                  style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('${formatTaka(pool.collectiveValue, commas: false)} collective orders',
              style: AppTextStyles.bodySecondary),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(child: Text('Pickup: ${pool.pickupLocation}', style: AppTextStyles.bodySecondary)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.alarm_rounded, size: 16, color: AppColors.warning),
              const SizedBox(width: 6),
              Text(pool.closesLabel,
                  style: AppTextStyles.bodySecondary.copyWith(color: AppColors.warning, fontWeight: FontWeight.w600)),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    if (pool.extraMembers > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('+${pool.extraMembers}',
                            style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text('${pool.memberCount} joined', style: AppTextStyles.bodySecondary),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(120, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                ),
                child: Text(isMember ? 'View Pool' : 'Join Pool'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
