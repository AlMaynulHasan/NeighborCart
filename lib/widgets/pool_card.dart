import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/pool_model.dart';

/// Pool summary card used on the "Nearby Pools" screen.
class PoolCard extends StatelessWidget {
  final NearbyPoolSummary pool;
  final VoidCallback onJoin;

  const PoolCard({super.key, required this.pool, required this.onJoin});

  @override
  Widget build(BuildContext context) {
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
                  '${pool.discountPercent.toStringAsFixed(0)}% OFF',
                  style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('৳${pool.collectiveOrders.toStringAsFixed(0)} collective orders', style: AppTextStyles.bodySecondary),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(child: Text(pool.pickupLocation, style: AppTextStyles.bodySecondary)),
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('+${pool.extraAvatarCount}',
                          style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 8),
                    Text('${pool.joinedCount} joined', style: AppTextStyles.bodySecondary),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: onJoin,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(120, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                ),
                child: const Text('Join Pool'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
