import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/wholesaler_order_model.dart';

/// A single pool's aggregated demand, shown on the Order/Demand screen.
class DemandOrderCard extends StatelessWidget {
  final WholesalerOrderModel order;

  const DemandOrderCard({super.key, required this.order});

  (String, Color, Color) _statusStyle() {
    switch (order.status) {
      case DemandOrderStatus.ready:
        return ('Ready', AppColors.primary, AppColors.primarySoft);
      case DemandOrderStatus.processing:
        return ('Processing', AppColors.textPrimary, AppColors.border);
      case DemandOrderStatus.awaitingMoq:
        return ('Awaiting MOQ', AppColors.warning, AppColors.warningSoft);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusColor, statusBg) = _statusStyle();
    final moqReached = order.moqStatus == MoqStatus.reached;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(order.poolName, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
                child: Text(statusLabel, style: AppTextStyles.caption.copyWith(color: statusColor, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Products: ${order.productsRequested.join(", ")}', style: AppTextStyles.bodySecondary),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Qty: ${order.totalQuantity}', style: AppTextStyles.caption),
              Text('৳${order.estimatedValue.toStringAsFixed(0)}',
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                moqReached ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                size: 16,
                color: moqReached ? AppColors.primary : AppColors.warning,
              ),
              const SizedBox(width: 6),
              Text(
                moqReached ? 'MOQ Reached' : 'MOQ Not Reached',
                style: AppTextStyles.caption.copyWith(
                  color: moqReached ? AppColors.primary : AppColors.warning,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
