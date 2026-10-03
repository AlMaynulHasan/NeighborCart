import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/order_model.dart';

/// A single member row inside the Settlement screen's "Member Breakdown".
class MemberPaymentCard extends StatelessWidget {
  final OrderMember member;

  const MemberPaymentCard({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final paid = member.status == PaymentStatus.paid;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: member.isCurrentUser ? Border.all(color: AppColors.primary, width: 1.2) : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primarySoft,
            child: Text(
              member.name[0],
              style: AppTextStyles.body.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('${member.itemsOrdered} items ordered', style: AppTextStyles.caption),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('৳${member.share.toStringAsFixed(0)}',
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
    );
  }
}
