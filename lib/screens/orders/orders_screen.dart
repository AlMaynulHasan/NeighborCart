import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/order_summary_card.dart';
import '../settlement/settlement_screen.dart';

/// ASSUMPTION: Orders wasn't one of the 6 Figma screens — this is a simple
/// design in the same visual language, listing past/active pool orders
/// (Master Prompt section 23).
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = MockDataService.orderHistory;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Orders', style: AppTextStyles.heading2.copyWith(fontSize: 24)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = orders[index];
                return OrderSummaryCard(
                  order: order,
                  onTap: () {
                    // Only the newest order (#204) has full settlement
                    // detail wired up in mock data right now.
                    if (order.id == MockDataService.settlementOrder.id) {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SettlementScreen()),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
