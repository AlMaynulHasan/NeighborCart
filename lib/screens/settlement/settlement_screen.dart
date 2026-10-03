import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/member_payment_card.dart';

/// Matches Figma screen 6 ("Settlement").
class SettlementScreen extends StatelessWidget {
  const SettlementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const order = MockDataService.settlementOrder;
    final progress = order.membersPaid / order.membersTotal;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: const Text('Settlement')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${order.poolName} Weekly Order ${order.id}', style: AppTextStyles.bodySecondary),
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
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('TOTAL POOL ORDER', style: AppTextStyles.caption),
                              const SizedBox(height: 6),
                              Text('৳${order.totalAmount.toStringAsFixed(0)}',
                                  style: AppTextStyles.body.copyWith(fontSize: 20, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('YOUR SHARE', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                              const SizedBox(height: 6),
                              Text('৳${order.memberShare.toStringAsFixed(0)}',
                                  style: AppTextStyles.body.copyWith(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Neighbor payment progress', style: AppTextStyles.bodySecondary),
                        Text('${order.membersPaid} of ${order.membersTotal} paid',
                            style: AppTextStyles.body.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: AppColors.border,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const Text('Member Breakdown', style: AppTextStyles.title),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    for (final member in order.members) MemberPaymentCard(member: member),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Payment flow not implemented yet (Phase 2).')),
                        );
                      },
                      child: Text('Pay Now — ৳${order.memberShare.toStringAsFixed(0)}'),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
