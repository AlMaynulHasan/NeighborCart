import 'product_model.dart';

/// Represents the current member's shared Weekly Cart within a pool.
///
/// NOTE: `retailPrice`, `estimatedCost` and `savings` are stored directly
/// (matching the Figma mock numbers) rather than derived from `items`,
/// because the real wholesale-tier calculation is Phase 2 work (Master
/// Prompt section 11/12 — Price-Break Engine / Cost Splitting). For now
/// these are just the numbers shown in the design.
class CartModel {
  final String poolId;
  final String poolName;
  final List<ProductModel> items;
  final double sharedCartTotal; // total across ALL pool members
  final double retailPrice; // pre-discount price for this member's basket
  final double estimatedCost; // this member's actual cost after discount
  final double savings;
  final bool wholesaleUnlocked;

  const CartModel({
    required this.poolId,
    required this.poolName,
    required this.items,
    required this.sharedCartTotal,
    required this.retailPrice,
    required this.estimatedCost,
    required this.savings,
    required this.wholesaleUnlocked,
  });

  double get itemsSubtotal => items.fold(0, (sum, item) => sum + item.subtotal);
}
