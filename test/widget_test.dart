import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accessbank/app.dart';
import 'package:accessbank/screens/login/login_screen.dart';

void main() {
  testWidgets('AccessBank app smoke test — login screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const AccessBankApp());
    // The app starts showing the login screen (isLoggedIn is false by default)
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Welcome to AccessBank'), findsOneWidget);

    // Dispose the widget and pump through the TutorialBridge reconnect timer
    // (3-second timer is created when the WebSocket connection fails in tests).
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 4));
  });
}
