import 'package:flutter_test/flutter_test.dart';
import 'package:accessible/app.dart';

void main() {
  testWidgets('AccessBank app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AccessBankApp());
    expect(find.text('AccessBank'), findsOneWidget);
  });
}
