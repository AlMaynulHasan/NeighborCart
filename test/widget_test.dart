import 'package:flutter_test/flutter_test.dart';

import 'package:neighbor_cart/main.dart';

void main() {
  testWidgets('shows the NeighborCart login screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const NeighborCartApp());

    expect(find.text('NeighborCart'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
