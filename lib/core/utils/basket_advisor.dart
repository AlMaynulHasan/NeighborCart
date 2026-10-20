import '../../models/product_model.dart';

class BasketSuggestion {
  final ProductModel product;
  final int recommended; // units worth buying for the household
  final int inCart;
  final int coverDays; // how many days the recommended amount covers

  const BasketSuggestion({
    required this.product,
    required this.recommended,
    required this.inCart,
    required this.coverDays,
  });

  int get toAdd => recommended > inCart ? recommended - inCart : 0;
}

/// Rule-based, shelf-life-aware basket suggestions (no AI involved).
///
/// Inputs per product: `unitLastsDays` (how long ONE unit lasts for ONE
/// person) and `shelfLifeDays`. For a household of H people:
///  - target cover = min(30 days, shelf life)
///  - recommended units = ceil(H x cover / unitLastsDays)
///  - never more than the household can use before it expires:
///    floor(H x shelfLifeDays / unitLastsDays)
class BasketAdvisor {
  BasketAdvisor._();

  static const int maxCoverDays = 30;

  /// Most units a household can use before the product expires (null = unknown).
  static int? maxUsableUnits(ProductModel p, int household) {
    final shelf = p.shelfLifeDays;
    final lasts = p.unitLastsDays;
    if (shelf == null || lasts == null || lasts <= 0) return null;
    return (household * shelf / lasts).floor();
  }

  static BasketSuggestion? suggest(ProductModel p, int household, int inCart) {
    final lasts = p.unitLastsDays;
    if (lasts == null || lasts <= 0 || household <= 0) return null;
    final shelf = p.shelfLifeDays;
    final cover = (shelf == null || shelf > maxCoverDays) ? maxCoverDays : shelf;

    var units = (household * cover / lasts).ceil();
    if (units < 1) units = 1;
    final cap = maxUsableUnits(p, household);
    if (cap != null && units > cap) units = cap < 1 ? 1 : cap;

    return BasketSuggestion(product: p, recommended: units, inCart: inCart, coverDays: cover);
  }

  /// Suggestions for every product that has usage data, most needed first.
  static List<BasketSuggestion> suggestAll(
    List<ProductModel> catalog,
    List<ProductModel> cartItems,
    int household,
  ) {
    final inCart = {for (final i in cartItems) i.id: i.quantity};
    final list = <BasketSuggestion>[];
    for (final p in catalog) {
      final s = suggest(p, household, inCart[p.id] ?? 0);
      if (s != null) list.add(s);
    }
    list.sort((a, b) {
      final byNeed = b.toAdd.compareTo(a.toAdd);
      return byNeed != 0 ? byNeed : a.product.name.compareTo(b.product.name);
    });
    return list;
  }

  /// productId -> warning, for cart lines that exceed what the household can
  /// use before the product expires.
  static Map<String, String> warnings(
    List<ProductModel> cartItems,
    List<ProductModel> catalog,
    int household,
  ) {
    final byId = {for (final p in catalog) p.id: p};
    final result = <String, String>{};
    for (final item in cartItems) {
      final product = byId[item.id];
      if (product == null) continue;
      final cap = maxUsableUnits(product, household);
      if (cap != null && item.quantity > cap) {
        result[item.id] =
            'More than $household ${household == 1 ? 'person' : 'people'} can use before it expires (about $cap at most).';
      }
    }
    return result;
  }
}
