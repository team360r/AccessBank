import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accessible/tutorial/tutorial_app_state.dart';
import 'package:accessible/tutorial/widgets/tutorial_status_bar.dart';

void main() {
  testWidgets('shows Connecting when not connected', (tester) async {
    final state = TutorialAppState();
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: TutorialStatusBar(state: state))),
    );
    expect(find.textContaining('Connecting'), findsOneWidget);
  });

  testWidgets('shows chapter and step when connected', (tester) async {
    final state = TutorialAppState()
      ..update(isConnected: true, chapterIndex: 1, stepIndex: 2, totalSteps: 5);
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: TutorialStatusBar(state: state))),
    );
    expect(find.textContaining('Ch 2'), findsOneWidget);
    expect(find.textContaining('Step 3/5'), findsOneWidget);
  });

  testWidgets('shows grey background when disconnected', (tester) async {
    final state = TutorialAppState();
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: TutorialStatusBar(state: state))),
    );
    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(TutorialStatusBar),
        matching: find.byType(Container).first,
      ),
    );
    expect(container.color, const Color(0xFF616161));
  });
}
