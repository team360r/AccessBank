import 'package:flutter_test/flutter_test.dart';
import 'package:accessbank/tutorial/tutorial_app_state.dart';

void main() {
  test('update notifies listeners and sets fields', () {
    final state = TutorialAppState();
    var notified = false;
    state.addListener(() => notified = true);

    state.update(isConnected: true, showInspector: true);

    expect(notified, isTrue);
    expect(state.isConnected, isTrue);
    expect(state.showInspector, isTrue);
  });

  test('allowedTabIndex can be set to null via update', () {
    final state = TutorialAppState()..allowedTabIndex = 2;
    state.update(allowedTabIndex: null);
    expect(state.allowedTabIndex, isNull);
  });

  test('update without allowedTabIndex leaves it unchanged', () {
    final state = TutorialAppState()..allowedTabIndex = 1;
    state.update(isConnected: true);
    expect(state.allowedTabIndex, 1);
  });
}
