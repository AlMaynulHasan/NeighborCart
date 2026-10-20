import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/basket_advisor.dart';
import '../../services/basket_service.dart';
import '../../services/cart_service.dart';
import '../../services/user_service.dart';
import '../../widgets/cart_actions.dart';
import '../../widgets/quantity_stepper.dart';
import '../../widgets/stream_view.dart';

/// ASSUMPTION: smart basket suggestions weren't designed in Figma — a simple
/// screen in the same style. Rule-based (no AI): household size, how long one
/// unit lasts per person, and the product's shelf life.
class BasketSuggestionsScreen extends StatefulWidget {
  const BasketSuggestionsScreen({super.key});

  @override
  State<BasketSuggestionsScreen> createState() => _BasketSuggestionsScreenState();
}

class _BasketSuggestionsScreenState extends State<BasketSuggestionsScreen> {
  bool _busy = false;

  Future<void> _addAll(List<BasketSuggestion> suggestions) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      for (final s in suggestions.where((s) => s.toAdd > 0)) {
        await CartService.instance.addToActivePool(s.product, quantity: s.toAdd);
      }
      messenger.showSnackBar(const SnackBar(content: Text('Suggested items added to your cart.')));
    } on NoActivePoolException {
      messenger.showSnackBar(const SnackBar(content: Text('Join a pool first to start shopping.')));
    } on PoolClosedException {
      messenger.showSnackBar(const SnackBar(content: Text('Ordering is closed for this pool.')));
    } on AlreadyPaidException {
      messenger.showSnackBar(const SnackBar(content: Text('You have already paid for this order.')));
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Could not add the items. Please try again.')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: const Text('Smart Basket')),
      body: SafeArea(
        child: StreamView<BasketData>(
          create: () => BasketService.instance.watch(),
          builder: (context, data) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 3))],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.people_alt_outlined, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Household size', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                            Text('People you buy groceries for', style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                      QuantityStepper(
                        quantity: data.household,
                        onIncrement: () => UserService.instance.setHouseholdSize(data.household + 1),
                        onDecrement: () => UserService.instance.setHouseholdSize(data.household - 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Suggestions cover up to ${BasketAdvisor.maxCoverDays} days and never go beyond what '
                  'your household can use before the product expires.',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 16),
                if (data.suggestions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Text(
                      'No products have usage data yet. Wholesalers add it when they create a product '
                      '("One unit lasts (days, per person)").',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySecondary,
                    ),
                  )
                else ...[
                  for (final s in data.suggestions) _SuggestionRow(suggestion: s, household: data.household),
                  const SizedBox(height: 8),
                  if (data.hasSomethingToAdd)
                    ElevatedButton(
                      onPressed: _busy ? null : () => _addAll(data.suggestions),
                      child: _busy
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                            )
                          : const Text('Add all suggested items'),
                    )
                  else
                    Center(
                      child: Text('Your cart already covers everything. 🎉', style: AppTextStyles.bodySecondary),
                    ),
                  if (!data.hasPool) ...[
                    const SizedBox(height: 10),
                    Text('Join a pool to add items to your cart.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(color: AppColors.warning)),
                  ],
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  final BasketSuggestion suggestion;
  final int household;
  const _SuggestionRow({required this.suggestion, required this.household});

  @override
  Widget build(BuildContext context) {
    final s = suggestion;
    final p = s.product;
    final shelf = p.shelfLifeDays;
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  'Suggested: ${s.recommended} (covers ~${s.coverDays} days for $household '
                  '${household == 1 ? 'person' : 'people'})',
                  style: AppTextStyles.caption,
                ),
                Text(
                  'In your cart: ${s.inCart}${shelf == null ? '' : '  •  shelf life ~$shelf days'}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (s.toAdd > 0)
            ElevatedButton(
              onPressed: () => addProductToCart(context, p, quantity: s.toAdd),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(80, 40),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              child: Text('Add ${s.toAdd}'),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(20)),
              child: Text('Covered ✓',
                  style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }
}
