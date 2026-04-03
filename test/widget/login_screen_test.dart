import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accessible/screens/login/login_screen.dart';

void main() {
  group('LoginScreen', () {
    testWidgets('inaccessible variant renders without errors', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: LoginScreen(accessible: false, onLogin: () {}),
      ));
      expect(tester.takeException(), isNull);
    });

    testWidgets('accessible variant renders without errors', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: LoginScreen(accessible: true, onLogin: () {}),
      ));
      expect(tester.takeException(), isNull);
    });

    testWidgets('inaccessible variant shows bank icon and welcome text',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: LoginScreen(accessible: false, onLogin: () {}),
      ));
      expect(find.byIcon(Icons.account_balance), findsOneWidget);
      expect(find.text('Welcome to AccessBank'), findsOneWidget);
    });

    testWidgets('accessible variant shows bank icon and welcome text',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: LoginScreen(accessible: true, onLogin: () {}),
      ));
      expect(find.byIcon(Icons.account_balance), findsOneWidget);
      expect(find.text('Welcome to AccessBank'), findsOneWidget);
    });

    testWidgets('inaccessible variant has TextFields and Go button',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: LoginScreen(accessible: false, onLogin: () {}),
      ));
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Go'), findsOneWidget);
    });

    testWidgets('accessible variant has TextFields and Sign In button',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: LoginScreen(accessible: true, onLogin: () {}),
      ));
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('tapping Go with empty fields shows error (inaccessible)',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: LoginScreen(accessible: false, onLogin: () {}),
      ));
      await tester.tap(find.text('Go'));
      await tester.pump();
      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('tapping Sign In with empty fields shows error (accessible)',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: LoginScreen(accessible: true, onLogin: () {}),
      ));
      await tester.tap(find.text('Sign In'));
      await tester.pump();
      expect(
        find.text('Sign in failed. Please enter your email and password.'),
        findsOneWidget,
      );
    });

    testWidgets('onLogin called after filling credentials (inaccessible)',
        (tester) async {
      bool called = false;
      await tester.pumpWidget(MaterialApp(
        home: LoginScreen(accessible: false, onLogin: () => called = true),
      ));
      await tester.enterText(find.byType(TextField).first, 'user@test.com');
      await tester.enterText(find.byType(TextField).last, 'password123');
      await tester.tap(find.text('Go'));
      await tester.pump();
      expect(called, isTrue);
    });

    testWidgets('onLogin called after filling credentials (accessible)',
        (tester) async {
      bool called = false;
      await tester.pumpWidget(MaterialApp(
        home: LoginScreen(accessible: true, onLogin: () => called = true),
      ));
      await tester.enterText(find.byType(TextField).first, 'user@test.com');
      await tester.enterText(find.byType(TextField).last, 'password123');
      await tester.tap(find.text('Sign In'));
      await tester.pump();
      expect(called, isTrue);
    });

    testWidgets('accessible variant has biometric button with 48x48 target',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: LoginScreen(accessible: true, onLogin: () {}),
      ));
      // Find the biometric SizedBox wrapper — must be at least 48x48
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      final biometricBox = sizedBoxes.firstWhere(
        (b) => b.width == 48 && b.height == 48,
        orElse: () => throw TestFailure('No 48x48 SizedBox found for biometric button'),
      );
      expect(biometricBox.width, 48);
      expect(biometricBox.height, 48);
    });
  });
}
