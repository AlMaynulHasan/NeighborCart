import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/order_model.dart';
import '../models/order_summary_model.dart';

/// ASSUMPTION: no Figma design was provided for the Orders tab, so this
/// reuses the same card/spacing/color language as the other screens
/// (Master Prompt section 23 — clearly state the assumption when a screen
/// isn't in the design).
class OrderSummaryCard extends StatelessWidget {
  final OrderSummary order;
  final VoidCallback? onTap;

  const OrderSummaryCard({super.key, required this.order, this.onTap});

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final paid = order.status == PaymentStatus.paid;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(order.poolName, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                ),
                Text('Order ${order.id}', style: AppTextStyles.caption),
              ],
            ),
            const SizedBox(height: 2),
            Text(_formatDate(order.date), style: AppTextStyles.caption),
            const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your Share', style: AppTextStyles.caption),
                    const SizedBox(height: 2),
                    Text('৳${order.memberShare.toStringAsFixed(0)}',
                        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: paid ? AppColors.primarySoft : AppColors.warningSoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    paid ? 'Paid' : 'Pending',
                    style: AppTextStyles.caption.copyWith(
                      color: paid ? AppColors.primary : AppColors.warning,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
