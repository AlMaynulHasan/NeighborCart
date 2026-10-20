import '../core/utils/basket_advisor.dart';
import '../core/utils/stream_utils.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import 'auth_service.dart';
import 'cart_service.dart';
import 'product_service.dart';
import 'user_service.dart';

class BasketData {
  final int household;
  final bool hasPool;
  final List<BasketSuggestion> suggestions;

  const BasketData({
    required this.household,
    required this.hasPool,
    required this.suggestions,
  });

  bool get hasSomethingToAdd => suggestions.any((s) => s.toAdd > 0);
}

class BasketService {
  BasketService._();
  static final BasketService instance = BasketService._();

  /// Suggestions for the signed-in member, updating live as their household
  /// size, the catalog or their cart change.
  Stream<BasketData> watch() {
    final uid = AuthService.instance.currentUser!.uid;
    return switchMap<UserModel, BasketData>(
      UserService.instance.watchCurrentUser(),
      (user) {
        final poolId = user.activePoolId;
        final cartStream = poolId == null
            ? Stream<List<ProductModel>>.value(const <ProductModel>[])
            : CartService.instance.watchItems(poolId, uid);
        return combineLatest2<List<ProductModel>, List<ProductModel>, BasketData>(
          ProductService.instance.watchActiveProducts(),
          cartStream,
          (catalog, cart) => BasketData(
            household: user.householdSize,
            hasPool: poolId != null,
            suggestions: BasketAdvisor.suggestAll(catalog, cart, user.householdSize),
          ),
        );
      },
    );
  }
}
