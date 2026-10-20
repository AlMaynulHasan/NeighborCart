import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/format.dart';
import '../../models/product_model.dart';
import '../../services/cart_service.dart';
import '../../services/order_service.dart';
import '../../services/pool_service.dart';
import '../../widgets/quantity_stepper.dart';
import '../../widgets/stream_view.dart';
import '../home/all_products_screen.dart';
import '../settlement/settlement_screen.dart';
import 'basket_suggestions_screen.dart';

/// Matches Figma screen 5 ("Weekly Cart").
class WeeklyCartScreen extends StatelessWidget {
  const WeeklyCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamView<CartView>(
      create: () => CartService.instance.watchCartView(),
      builder: (context, cart) {
        final poolView = cart.poolView;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Weekly Cart', style: AppTextStyles.heading2.copyWith(fontSize: 24)),
              const SizedBox(height: 4),
              Text(
                poolView == null
                    ? 'You are not in a pool yet'
                    : 'Sharing order with ${poolView.pool.name}',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: 14),
              Expanded(
                child: poolView == null
                    ? Center(
                        child: Text(
                          'Join a pool from the Pools tab to start shopping.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySecondary,
                        ),
                      )
                    : cart.items.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Your cart is empty.', style: AppTextStyles.bodySecondary),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const AllProductsScreen()),
                                  ),
                                  style: ElevatedButton.styleFrom(minimumSize: const Size(180, 46)),
                                  child: const Text('Browse Products'),
                                ),
                                const SizedBox(height: 8),
                                OutlinedButton(
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const BasketSuggestionsScreen()),
                                  ),
                                  style: OutlinedButton.styleFrom(minimumSize: const Size(180, 46)),
                                  child: const Text('Get basket suggestions'),
                                ),
                              ],
                            ),
                          )
                        : ListView(
                            children: [
                              if (!cart.isLocked) const _SuggestionsEntry(),
                              if (cart.lockMessage != null) _LockedBanner(message: cart.lockMessage!),
                              for (final item in cart.items)
                                _CartItemRow(
                                  item: item,
                                  poolId: poolView.pool.id,
                                  locked: cart.isLocked,
                                  warning: cart.warnings[item.id],
                                ),
                              const SizedBox(height: 4),
                              _CartSummaryCard(cart: cart, poolView: poolView),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () async {
                                  try {
                                    await OrderService.instance
                                        .upsertPending(pool: poolView.pool, share: cart.estimatedCost);
                                  } catch (_) {
                                    // Not fatal — settlement is computed live anyway.
                                  }
                                  if (!context.mounted) return;
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
      },
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final ProductModel item;
  final String poolId;
  final bool locked;
  final String? warning;
  const _CartItemRow({
    required this.item,
    required this.poolId,
    required this.locked,
    this.warning,
  });

  void _change(BuildContext context, int delta) {
    CartService.instance
        .changeQuantity(poolId: poolId, product: item, delta: delta)
        .catchError((_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update your cart. Please try again.')),
        );
      }
    });
  }

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
                Text('${formatTaka(item.price)} • ${item.description}',
                    style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(formatTaka(item.subtotal), style: AppTextStyles.priceSmall),
                if (warning != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(warning!,
                            style: AppTextStyles.caption.copyWith(color: AppColors.warning, fontSize: 11)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (locked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.scaffoldBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('Qty: ${item.quantity}',
                  style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700)),
            )
          else
            QuantityStepper(
              quantity: item.quantity,
              onIncrement: () => _change(context, 1),
              onDecrement: () => _change(context, -1),
            ),
        ],
      ),
    );
  }
}

class _CartSummaryCard extends StatelessWidget {
  final CartView cart;
  final PoolView poolView;
  const _CartSummaryCard({required this.cart, required this.poolView});

  @override
  Widget build(BuildContext context) {
    final pb = poolView.priceBreak;
    final unlocked = pb.unlockedTier != null;
    final next = pb.nextTier;

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
              Text('Shared Cart Total', style: AppTextStyles.body),
              Text(formatTaka(poolView.pool.collectiveValue),
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Your Estimated Cost', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
              Text(formatTaka(cart.estimatedCost),
                  style: AppTextStyles.body
                      .copyWith(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (unlocked)
                Text(
                  'Retail Price: ${formatTaka(cart.subtotal)}',
                  style: AppTextStyles.caption.copyWith(decoration: TextDecoration.lineThrough),
                )
              else
                Text('Retail Price: ${formatTaka(cart.subtotal)}', style: AppTextStyles.caption),
              if (unlocked)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('Wholesale Unlocked',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12)),
                    SizedBox(width: 4),
                    Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 16),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: unlocked ? AppColors.primarySoft : AppColors.warningSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              unlocked
                  ? 'You save ${formatTaka(cart.savings)} on this weekly order!'
                  : next == null
                      ? 'No wholesale tiers are active yet.'
                      : 'Add ${formatTaka(pb.amountToNext)} more to the pool to unlock ${next.discountPercent.round()}% off.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: unlocked ? AppColors.primary : AppColors.warning,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedBanner extends StatelessWidget {
  final String message;
  const _LockedBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warningSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: AppTextStyles.caption.copyWith(color: AppColors.warning, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _SuggestionsEntry extends StatelessWidget {
  const _SuggestionsEntry();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BasketSuggestionsScreen()),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Smart basket suggestions',
                        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
                    Text('How much your household needs, based on shelf life.', style: AppTextStyles.caption),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
