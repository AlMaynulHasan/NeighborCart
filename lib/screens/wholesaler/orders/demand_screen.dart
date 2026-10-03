import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../services/wholesaler_mock_data_service.dart';
import '../../../widgets/wholesaler/demand_order_card.dart';

/// Order/Demand View — aggregated demand coming from NeighborCart pools
/// (Master Prompt section 17, Community Demand Aggregation).
class DemandScreen extends StatelessWidget {
  const DemandScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = WholesalerMockDataService.demandOrders;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Orders / Demand', style: AppTextStyles.heading2.copyWith(fontSize: 24)),
          const SizedBox(height: 4),
          const Text('Aggregated demand from active pools.', style: AppTextStyles.bodySecondary),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                for (final order in orders) DemandOrderCard(order: order),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
