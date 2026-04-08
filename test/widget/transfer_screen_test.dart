import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accessbank/screens/transfer/transfer_screen.dart';

void main() {
  group('TransferScreen', () {
    testWidgets('inaccessible variant renders without errors', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: TransferScreen(accessible: false)),
      ));
      expect(tester.takeException(), isNull);
    });

    testWidgets('accessible variant renders without errors', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: TransferScreen(accessible: true)),
      ));
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows Next button on first step', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: TransferScreen(accessible: false)),
      ));
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('does not show Back button on first step', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: TransferScreen(accessible: false)),
      ));
      expect(find.text('Back'), findsNothing);
    });

    testWidgets('tapping Next advances to second step', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: TransferScreen(accessible: false)),
      ));
      await tester.tap(find.text('Next'));
      await tester.pump();
      // Back button should now appear on step 2
      expect(find.text('Back'), findsOneWidget);
    });

    testWidgets('tapping Back goes back to first step', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: TransferScreen(accessible: false)),
      ));
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.tap(find.text('Back'));
      await tester.pump();
      expect(find.text('Back'), findsNothing);
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('last step shows Confirm button', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: TransferScreen(accessible: false)),
      ));
      // Navigate through all 4 steps (0 -> 1 -> 2 -> 3)
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text('Next'));
        await tester.pump();
      }
      expect(find.text('Confirm'), findsOneWidget);
    });

    testWidgets('confirming transfer shows success dialog', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: TransferScreen(accessible: false)),
      ));
      // Navigate to last step
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text('Next'));
        await tester.pump();
      }
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(find.text('Transfer Complete!'), findsOneWidget);
    });

    testWidgets('accessible variant advances steps without error', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: TransferScreen(accessible: true)),
      ));
      await tester.tap(find.text('Next'));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('Back'), findsOneWidget);
    });
  });
}
