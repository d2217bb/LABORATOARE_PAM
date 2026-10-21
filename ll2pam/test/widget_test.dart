import 'package:flutter_test/flutter_test.dart';
import 'package:pam_ll1/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('GemStoreApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GemStoreApp());
    await tester.pump();

    expect(find.text('GemStore'), findsWidgets);
  });
}
