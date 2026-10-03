import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/wholesaler_order_model.dart';
import '../../../services/wholesaler_mock_data_service.dart';
import '../../../widgets/wholesaler/alert_tile.dart';

/// Low Stock / MOQ Alerts — derived from the same mock product and demand
/// data used elsewhere in the module, so the counts stay consistent.
class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lowStock = WholesalerMockDataService.products.where((p) => p.isLowStock).toList();
    final moqNotReached = WholesalerMockDataService.demandOrders
        .where((o) => o.moqStatus == MoqStatus.notReached)
        .toList();
    final moqReached = WholesalerMockDataService.demandOrders
        .where((o) => o.moqStatus == MoqStatus.reached)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: const Text('Alerts')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (lowStock.isNotEmpty) ...[
              const Text('Low Stock', style: AppTextStyles.title),
              const SizedBox(height: 10),
              for (final product in lowStock)
                AlertTile(
                  icon: Icons.inventory_2_outlined,
                  title: product.name,
                  subtitle: '${product.availableQuantity} left • MOQ is ${product.moq}',
                ),
              const SizedBox(height: 20),
            ],
            if (moqNotReached.isNotEmpty) ...[
              const Text('MOQ Not Reached', style: AppTextStyles.title),
              const SizedBox(height: 10),
              for (final order in moqNotReached)
                AlertTile(
                  icon: Icons.error_outline_rounded,
                  title: order.poolName,
                  subtitle: 'Needs more orders to reach minimum order quantity',
                ),
              const SizedBox(height: 20),
            ],
            if (moqReached.isNotEmpty) ...[
              const Text('MOQ Reached', style: AppTextStyles.title),
              const SizedBox(height: 10),
              for (final order in moqReached)
                AlertTile(
                  icon: Icons.check_circle_outline_rounded,
                  title: order.poolName,
                  subtitle: 'Ready to fulfill • ৳${order.estimatedValue.toStringAsFixed(0)}',
                  severity: AlertSeverity.success,
                ),
              const SizedBox(height: 20),
            ],
            const Text('High-Demand Products', style: AppTextStyles.title),
            const SizedBox(height: 10),
            for (final name in WholesalerMockDataService.topRequestedProducts)
              AlertTile(
                icon: Icons.trending_up_rounded,
                title: name,
                subtitle: 'Frequently requested across active pools',
                severity: AlertSeverity.info,
              ),
            const SizedBox(height: 20),
            const Text('Pending Orders', style: AppTextStyles.title),
            const SizedBox(height: 10),
            const AlertTile(
              icon: Icons.hourglass_top_rounded,
              title: '${WholesalerMockDataService.pendingOrders} orders pending',
              subtitle: 'Awaiting confirmation or MOQ threshold',
            ),
          ],
        ),
      ),
    );
  }
}
