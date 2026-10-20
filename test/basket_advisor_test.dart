import 'package:flutter_test/flutter_test.dart';
import 'package:neighbor_cart/core/utils/basket_advisor.dart';
import 'package:neighbor_cart/core/utils/shelf_life.dart';
import 'package:neighbor_cart/models/product_model.dart';

ProductModel product({int? shelf, int? lasts, String id = 'p'}) => ProductModel(
      id: id,
      name: 'Rice',
      description: '',
      price: 380,
      shelfLifeDays: shelf,
      unitLastsDays: lasts,
    );

void main() {
  test('shelf life text is turned into days', () {
    expect(parseShelfLifeDays('12 months'), 360);
    expect(parseShelfLifeDays('2 weeks'), 14);
    expect(parseShelfLifeDays('1 year'), 365);
    expect(parseShelfLifeDays('10 days'), 10);
    expect(parseShelfLifeDays('soon'), isNull);
    expect(parseShelfLifeDays(''), isNull);
  });

  test('long shelf life: covers 30 days', () {
    final s = BasketAdvisor.suggest(product(shelf: 360, lasts: 25), 4, 0)!;
    expect(s.coverDays, 30);
    expect(s.recommended, 5); // ceil(4 * 30 / 25)
    expect(s.toAdd, 5);
  });

  test('short shelf life: never more than can be used in time', () {
    final s = BasketAdvisor.suggest(product(shelf: 10, lasts: 3), 1, 0)!;
    expect(s.coverDays, 10);
    expect(s.recommended, 3); // ceil(3.33) = 4, capped at floor(3.33) = 3
  });

  test('units already in the cart reduce what to add', () {
    final s = BasketAdvisor.suggest(product(shelf: 360, lasts: 25), 4, 3)!;
    expect(s.toAdd, 2);
    final covered = BasketAdvisor.suggest(product(shelf: 360, lasts: 25), 4, 9)!;
    expect(covered.toAdd, 0);
  });

  test('no usage data means no suggestion', () {
    expect(BasketAdvisor.suggest(product(shelf: 360), 4, 0), isNull);
  });

  test('warns when the cart holds more than can be used before expiry', () {
    final catalog = [product(shelf: 10, lasts: 5)]; // household 2 -> at most 4
    final tooMany = [product(shelf: 10, lasts: 5).copyWith(quantity: 6)];
    final fine = [product(shelf: 10, lasts: 5).copyWith(quantity: 4)];
    expect(BasketAdvisor.warnings(tooMany, catalog, 2).containsKey('p'), isTrue);
    expect(BasketAdvisor.warnings(fine, catalog, 2), isEmpty);
  });
}
