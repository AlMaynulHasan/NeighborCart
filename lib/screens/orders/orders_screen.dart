import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/order_summary_model.dart';
import '../../services/order_service.dart';
import '../../widgets/order_summary_card.dart';
import '../../widgets/stream_view.dart';
import '../settlement/settlement_screen.dart';

/// ASSUMPTION: Orders wasn't one of the 6 Figma screens — a simple list in
/// the same visual language: your pending/paid order for each pool.
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Orders', style: AppTextStyles.heading2.copyWith(fontSize: 24)),
          const SizedBox(height: 16),
          Expanded(
            child: StreamView<List<OrderSummary>>(
              create: () => OrderService.instance.watchOrders(),
              builder: (context, orders) {
                if (orders.isEmpty) {
                  return Center(
                    child: Text(
                      'No orders yet. Add items to your cart and\ntap "Proceed to Split details".',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySecondary,
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return OrderSummaryCard(
                      order: order,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SettlementScreen()),
                      ),
                    );
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
