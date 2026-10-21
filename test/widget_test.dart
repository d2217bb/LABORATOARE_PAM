import 'package:flutter_test/flutter_test.dart';
import 'package:pam_ll1/main.dart';

void main() {
  testWidgets('DiscountApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DiscountApp());

    expect(find.text('Calculator Reducere'), findsOneWidget);
  });
}