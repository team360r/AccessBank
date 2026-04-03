import 'package:flutter_test/flutter_test.dart';
import 'package:accessible/app.dart';
import 'package:accessible/screens/login/login_screen.dart';

void main() {
  testWidgets('AccessBank app smoke test — login screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const AccessBankApp());
    // The app starts on the login route which shows the welcome text
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Welcome to AccessBank'), findsOneWidget);
  });
}
