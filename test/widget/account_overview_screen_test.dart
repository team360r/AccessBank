import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accessible/screens/account_overview/account_overview_screen.dart';

void main() {
  group('AccountOverviewScreen', () {
    testWidgets('inaccessible variant renders without errors', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: AccountOverviewScreen(accessible: false)),
      ));
      expect(tester.takeException(), isNull);
    });

    testWidgets('accessible variant renders without errors', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: AccountOverviewScreen(accessible: true)),
      ));
      expect(tester.takeException(), isNull);
    });

    testWidgets('inaccessible variant shows greeting', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: AccountOverviewScreen(accessible: false)),
      ));
      expect(find.text('Good morning, Alex'), findsOneWidget);
    });

    testWidgets('accessible variant shows greeting', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: AccountOverviewScreen(accessible: true)),
      ));
      expect(find.text('Good morning, Alex'), findsOneWidget);
    });

    testWidgets('shows Quick Actions section in both variants', (tester) async {
      for (final accessible in [false, true]) {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(body: AccountOverviewScreen(accessible: accessible)),
        ));
        expect(find.text('Quick Actions'), findsOneWidget);
      }
    });

    testWidgets('inaccessible shows Recent Transactions section', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: AccountOverviewScreen(accessible: false)),
      ));
      expect(find.text('Recent Transactions'), findsOneWidget);
    });

    testWidgets('accessible shows Recent Transactions with count', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: AccountOverviewScreen(accessible: true)),
      ));
      // The accessible variant includes a count in the heading
      expect(find.textContaining('Recent Transactions'), findsOneWidget);
    });

    testWidgets('account cards are displayed', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: AccountOverviewScreen(accessible: false)),
      ));
      // MockAccounts.all has 3 accounts
      expect(find.text('Everyday Checking'), findsOneWidget);
      expect(find.text('Savings Goal'), findsOneWidget);
      expect(find.text('Credit Card'), findsOneWidget);
    });

    testWidgets('accessible account cards are displayed', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: AccountOverviewScreen(accessible: true)),
      ));
      expect(find.text('Everyday Checking'), findsOneWidget);
      expect(find.text('Savings Goal'), findsOneWidget);
      expect(find.text('Credit Card'), findsOneWidget);
    });
  });
}
