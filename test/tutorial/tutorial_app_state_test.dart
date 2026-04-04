import 'package:flutter_test/flutter_test.dart';
import 'package:accessible/tutorial/tutorial_app_state.dart';

void main() {
  test('update notifies listeners and sets fields', () {
    final state = TutorialAppState();
    var notified = false;
    state.addListener(() => notified = true);

    state.update(chapterIndex: 3, stepIndex: 2, isConnected: true);

    expect(notified, isTrue);
    expect(state.chapterIndex, 3);
    expect(state.stepIndex, 2);
    expect(state.isConnected, isTrue);
  });

  test('allowedTabIndex can be set to null via update', () {
    final state = TutorialAppState()..allowedTabIndex = 2;
    state.update(allowedTabIndex: null);
    expect(state.allowedTabIndex, isNull);
  });

  test('update without allowedTabIndex leaves it unchanged', () {
    final state = TutorialAppState()..allowedTabIndex = 1;
    state.update(chapterIndex: 5);
    expect(state.allowedTabIndex, 1);
  });
}
