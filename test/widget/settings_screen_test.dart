import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accessible/screens/settings/settings_screen.dart';
import 'package:accessible/app_state.dart';

void main() {
  late AppState appState;

  setUp(() {
    appState = AppState();
  });

  tearDown(() {
    appState.dispose();
  });

  group('SettingsScreen', () {
    testWidgets('inaccessible variant renders without errors', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SettingsScreen(accessible: false, appState: appState),
        ),
      ));
      expect(tester.takeException(), isNull);
    });

    testWidgets('accessible variant renders without errors', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SettingsScreen(accessible: true, appState: appState),
        ),
      ));
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows Profile section heading', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SettingsScreen(accessible: false, appState: appState),
        ),
      ));
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('shows Preferences section heading', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SettingsScreen(accessible: false, appState: appState),
        ),
      ));
      expect(find.text('Preferences'), findsOneWidget);
    });

    testWidgets('shows user name and email', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SettingsScreen(accessible: false, appState: appState),
        ),
      ));
      expect(find.text('Alex Johnson'), findsOneWidget);
      expect(find.text('alex@email.com'), findsOneWidget);
    });

    testWidgets('shows switches for Dark Mode, Notifications, Biometric',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SettingsScreen(accessible: false, appState: appState),
        ),
      ));
      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Biometric Login'), findsOneWidget);
      expect(find.byType(Switch), findsNWidgets(3));
    });

    testWidgets('accessible variant shows switches', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SettingsScreen(accessible: true, appState: appState),
        ),
      ));
      expect(find.byType(Switch), findsNWidgets(3));
    });

    testWidgets('inaccessible Dark Mode switch toggles', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SettingsScreen(accessible: false, appState: appState),
        ),
      ));
      final switchFinder = find.byType(Switch).first;
      final switchWidget = tester.widget<Switch>(switchFinder);
      expect(switchWidget.value, isFalse);
      await tester.tap(switchFinder);
      await tester.pump();
      // After toggle the switch is rebuilt with new value
      final updated = tester.widget<Switch>(switchFinder);
      expect(updated.value, isTrue);
    });

    testWidgets('accessible Dark Mode switch toggles via InkWell', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SettingsScreen(accessible: true, appState: appState),
        ),
      ));
      final switchFinder = find.byType(Switch).first;
      final initial = tester.widget<Switch>(switchFinder);
      expect(initial.value, isFalse);
      await tester.tap(switchFinder);
      await tester.pump();
      final updated = tester.widget<Switch>(switchFinder);
      expect(updated.value, isTrue);
    });

    testWidgets('shows Logout option', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SettingsScreen(accessible: false, appState: appState),
        ),
      ));
      // Logout is at the bottom of the ListView — scroll to find it
      await tester.scrollUntilVisible(find.text('Logout'), 100);
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('shows slider for text size', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SettingsScreen(accessible: false, appState: appState),
        ),
      ));
      expect(find.byType(Slider), findsOneWidget);
    });
  });
}
