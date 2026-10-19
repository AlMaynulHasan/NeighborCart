import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../services/demand_service.dart';
import '../../../widgets/stream_view.dart';
import '../../../widgets/wholesaler/demand_order_card.dart';

/// Order/Demand View — aggregated demand from NeighborCart pools for this
/// wholesaler's products (Community Demand Aggregation).
class DemandScreen extends StatelessWidget {
  const DemandScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Orders / Demand', style: AppTextStyles.heading2.copyWith(fontSize: 24)),
          const SizedBox(height: 4),
          Text('Aggregated demand from active pools.', style: AppTextStyles.bodySecondary),
          const SizedBox(height: 16),
          Expanded(
            child: StreamView<WholesalerOverview>(
              create: () => DemandService.instance.watchOverview(),
              builder: (context, overview) {
                if (overview.orders.isEmpty) {
                  return Center(
                    child: Text(
                      'No demand for your products yet.',
                      style: AppTextStyles.bodySecondary,
                    ),
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
