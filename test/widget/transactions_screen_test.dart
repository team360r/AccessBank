import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accessbank/screens/transactions/transactions_screen.dart';

void main() {
  group('TransactionsScreen', () {
    testWidgets('inaccessible variant renders without errors', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: TransactionsScreen(accessible: false)),
      ));
      expect(tester.takeException(), isNull);
    });

    testWidgets('accessible variant renders without errors', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: TransactionsScreen(accessible: true)),
      ));
      expect(tester.takeException(), isNull);
    });

    testWidgets('inaccessible variant shows transaction items', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: TransactionsScreen(accessible: false)),
      ));
      // Should show some transaction tiles in the list
      expect(find.byType(ListView), findsWidgets);
    });

    testWidgets('accessible variant shows transaction items', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: TransactionsScreen(accessible: true)),
      ));
      expect(find.byType(ListView), findsWidgets);
    });

    testWidgets('shows sort button in inaccessible variant', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: TransactionsScreen(accessible: false)),
      ));
      // The filter bar has a sort icon button (arrow_downward = newest first)
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    });

    testWidgets('shows sort button in accessible variant', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: TransactionsScreen(accessible: true)),
      ));
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    });

    testWidgets('tapping sort button does not throw', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: TransactionsScreen(accessible: false)),
      ));
      await tester.tap(find.byIcon(Icons.arrow_downward));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('accessible sort toggle does not throw', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: TransactionsScreen(accessible: true)),
      ));
      await tester.tap(find.byIcon(Icons.arrow_downward));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows a divider between filter bar and list', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: TransactionsScreen(accessible: false)),
      ));
      expect(find.byType(Divider), findsWidgets);
    });
  });
}
