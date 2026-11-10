import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../services/demand_service.dart';
import '../../../widgets/stream_view.dart';
import '../../../widgets/wholesaler/demand_order_card.dart';
import 'community_demand_view.dart';

/// Orders for this wholesaler's own products, plus community demand by area
/// where they can bid for pools.
class DemandScreen extends StatefulWidget {
  const DemandScreen({super.key});

  @override
  State<DemandScreen> createState() => _DemandScreenState();
}

class _DemandScreenState extends State<DemandScreen> {
  int _view = 0; // 0 = my orders, 1 = community demand

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Orders / Demand', style: AppTextStyles.heading2.copyWith(fontSize: 24)),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final entry in const [(0, 'My Orders'), (1, 'Community Demand')])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(entry.$2),
                    selected: _view == entry.$1,
                    onSelected: (_) => setState(() => _view = entry.$1),
                    selectedColor: AppColors.primarySoft,
                    labelStyle: AppTextStyles.caption.copyWith(
                      color: _view == entry.$1 ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                    side: BorderSide.none,
                    backgroundColor: AppColors.cardBackground,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _view == 1
                ? const CommunityDemandView()
                : StreamView<WholesalerOverview>(
                    create: () => DemandService.instance.watchOverview(),
                    builder: (context, overview) {
                      if (overview.orders.isEmpty) {
                        return const Center(
                          child: const Text('No demand for your products yet.', style: AppTextStyles.bodySecondary),
                        );
                      }
                      return ListView(
                        children: [
                          for (final order in overview.orders) DemandOrderCard(order: order),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
