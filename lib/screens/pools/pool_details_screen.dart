import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/tier_card.dart';
import '../cart/weekly_cart_screen.dart';

/// Matches Figma screen 4 ("Pool Details").
class PoolDetailsScreen extends StatelessWidget {
  const PoolDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pool = MockDataService.activePool;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Pool Details'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.ios_share_rounded)),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(pool.name, style: AppTextStyles.heading2.copyWith(fontSize: 24)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('COLLECTIVE VALUE', style: AppTextStyles.caption),
                          const SizedBox(height: 6),
                          Text('৳${pool.collectiveValue.toStringAsFixed(0)}',
                              style: AppTextStyles.body.copyWith(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary)),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 40, color: AppColors.divider),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ACTIVE NEIGHBORS', style: AppTextStyles.caption),
                          const SizedBox(height: 6),
                          Text('${pool.memberCount} Joined',
                              style: AppTextStyles.body.copyWith(fontSize: 18, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primarySoft,
                      child: Icon(Icons.person_rounded, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pool Coordinator', style: AppTextStyles.caption),
                          const SizedBox(height: 2),
                          Text(pool.coordinatorName, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.primarySoft,
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('Chat', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tier Unlocks', style: AppTextStyles.title),
                    const SizedBox(height: 8),
                    for (final tier in pool.tiers)
                      TierRow(
                        tier: tier,
                        amountNeeded: tier.unlocked ? null : MockDataService.tier3AmountNeeded,
                      ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1)),
                    Text(
                      'Add ৳${MockDataService.tier3AmountNeeded.toStringAsFixed(0)} more to unlock Tier 3!',
                      style: AppTextStyles.body.copyWith(color: AppColors.warning, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: AppColors.textSecondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pickup Location', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                        Text(pool.pickupLocation, style: AppTextStyles.bodySecondary),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, color: AppColors.warning),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order Deadline',
                            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, color: AppColors.warning)),
                        const Text(MockDataService.orderDeadlineLabel, style: AppTextStyles.bodySecondary),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const WeeklyCartScreen()),
                  );
                },
                child: const Text('Join Pool & Start Shopping'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
