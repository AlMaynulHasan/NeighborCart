import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Group-order terms shown at sign-up and from Profile.
/// NOTE: demo wording for a university project — have it reviewed before any real launch.
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  static const _sections = [
    ('How group orders work',
        'NeighborCart combines the orders of nearby households into one pool order. Prices are estimates '
            'until the coordinator places the order; the wholesale discount depends on the pool total.'),
    ('Changing or cancelling',
        'You can change your cart until the pool deadline or until you pay. After the order is placed or you '
            'have paid, your items are locked.'),
    ('Payment',
        'You pay only your own share. In this demo, payments are simulated and no money is charged. '
            'A real launch needs a licensed payment provider.'),
    ('Pickup',
        'Goods are collected in one drop at the pool pickup point. The coordinator hands them over and marks '
            'each member as picked up. Please collect on time.'),
    ('Food and suppliers',
        'Suppliers must hold a valid trade/food licence and are responsible for the quality and shelf life of '
            'what they supply. Check expiry dates when you collect.'),
    ('Problems and complaints',
        'Use "Report a Problem" in your Profile for missing items, quality issues, payment problems or '
            'coordinator issues. Reports are reviewed by the NeighborCart team.'),
    ('Your data',
        'Other members only see your name and whether you have paid or collected. Suppliers only see '
            'totals per pool and area, never individual baskets.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: const Text('Group-Order Terms')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            for (final s in _sections) ...[
              Text(s.$1, style: AppTextStyles.title),
              const SizedBox(height: 6),
              Text(s.$2, style: AppTextStyles.body),
              const SizedBox(height: 18),
            ],
          ],
        ),
      ),
    );
  }
}
