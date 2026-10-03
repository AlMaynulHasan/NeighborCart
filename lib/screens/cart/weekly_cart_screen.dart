import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/cart_model.dart';
import '../../models/product_model.dart';
import '../../services/mock_data_service.dart';
import '../settlement/settlement_screen.dart';

/// Matches Figma screen 5 ("Weekly Cart").
class WeeklyCartScreen extends StatelessWidget {
  const WeeklyCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const cart = MockDataService.weeklyCart;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Cart', style: AppTextStyles.heading2.copyWith(fontSize: 24)),
          const SizedBox(height: 4),
          Text('Sharing order with ${cart.poolName}', style: AppTextStyles.bodySecondary),
          const SizedBox(height: 14),
          Expanded(
            child: ListView(
              children: [
                for (final item in cart.items) _CartItemRow(item: item),
                const SizedBox(height: 4),
                _CartSummaryCard(cart: cart),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettlementScreen()),
                    );
                  },
                  child: const Text('Proceed to Split details'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final ProductModel item;
  const _CartItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shopping_basket_rounded, color: AppColors.primary, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('৳${item.price.toStringAsFixed(0)} • ${item.description}', style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text('৳${item.subtotal.toStringAsFixed(0)}', style: AppTextStyles.priceSmall),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.scaffoldBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('Qty: ${item.quantity}', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _CartSummaryCard extends StatelessWidget {
  final CartModel cart;
  const _CartSummaryCard({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary, width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Shared Cart Total', style: AppTextStyles.body),
              Text('৳${cart.sharedCartTotal.toStringAsFixed(0)}',
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Your Estimated Cost', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
              Text('৳${cart.estimatedCost.toStringAsFixed(0)}',
                  style: AppTextStyles.body.copyWith(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Retail Price: ৳${cart.retailPrice.toStringAsFixed(0)}',
                style: AppTextStyles.caption.copyWith(decoration: TextDecoration.lineThrough),
              ),
              if (cart.wholesaleUnlocked)
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Wholesale Unlocked', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12)),
                    SizedBox(width: 4),
                    Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 16),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'You save ৳${cart.savings.toStringAsFixed(0)} on this weekly order!',
              style: AppTextStyles.body.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
