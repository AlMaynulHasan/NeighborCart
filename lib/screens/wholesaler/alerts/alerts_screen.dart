import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/format.dart';
import '../../../services/demand_service.dart';
import '../../../widgets/stream_view.dart';
import '../../../widgets/wholesaler/alert_tile.dart';

/// Low Stock / MOQ Alerts — derived live from this wholesaler's products
/// and the demand recorded on each pool.
class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: const Text('Alerts')),
      body: SafeArea(
        child: StreamView<WholesalerOverview>(
          create: () => DemandService.instance.watchOverview(),
          builder: (context, overview) {
            final lowStock = overview.lowStockProducts;
            final notReached = overview.moqNotReachedOrders;
            final reached = overview.moqReachedOrders;
            final topRequested = overview.topRequested;

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (lowStock.isNotEmpty) ...[
                  Text('Low Stock', style: AppTextStyles.title),
                  const SizedBox(height: 10),
                  for (final product in lowStock)
                    AlertTile(
                      icon: Icons.inventory_2_outlined,
                      title: product.name,
                      subtitle: '${product.availableQuantity} left • MOQ is ${product.moq}',
                    ),
                  const SizedBox(height: 20),
                ],
                if (notReached.isNotEmpty) ...[
                  Text('MOQ Not Reached', style: AppTextStyles.title),
                  const SizedBox(height: 10),
                  for (final order in notReached)
                    AlertTile(
                      icon: Icons.error_outline_rounded,
                      title: order.poolName,
                      subtitle: 'Needs more orders to reach minimum order quantity',
                    ),
                  const SizedBox(height: 20),
                ],
                if (reached.isNotEmpty) ...[
                  Text('MOQ Reached', style: AppTextStyles.title),
                  const SizedBox(height: 10),
                  for (final order in reached)
                    AlertTile(
                      icon: Icons.check_circle_outline_rounded,
                      title: order.poolName,
                      subtitle: 'Ready to fulfill • ${formatTaka(order.estimatedValue)}',
                      severity: AlertSeverity.success,
                    ),
                  const SizedBox(height: 20),
                ],
                if (topRequested.isNotEmpty) ...[
                  Text('High-Demand Products', style: AppTextStyles.title),
                  const SizedBox(height: 10),
                  for (final name in topRequested)
                    AlertTile(
                      icon: Icons.trending_up_rounded,
                      title: name,
                      subtitle: 'Frequently requested across active pools',
                      severity: AlertSeverity.info,
                    ),
                  const SizedBox(height: 20),
                ],
                Text('Pending Orders', style: AppTextStyles.title),
                const SizedBox(height: 10),
                AlertTile(
                  icon: Icons.hourglass_top_rounded,
                  title: '${overview.pendingOrders} orders pending',
                  subtitle: 'Waiting for the pool to reach MOQ',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
