# Chapter 8: "Testing Your Work"

> *"I can prove this works, not just hope"*

## What You'll Learn

- How to enable semantics in Flutter widget tests with `tester.ensureSemantics()`
- How to assert on semantic labels, roles, states, and actions with `matchesSemantics`
- How to build a manual testing checklist that catches what automated tests miss
- How to add semantics assertions to integration tests
- How to run accessibility tests in CI on every pull request

## Prerequisites

- Chapter 7 complete
- Familiarity with Flutter's widget testing framework (`flutter_test`)

## Concepts Covered

### Widget Tests with Semantics

Flutter widget tests can inspect the live semantics tree. Call `tester.ensureSemantics()` at the start of the test to activate the semantics system and receive a `SemanticsHandle`. Then use `tester.getSemantics(finder)` to retrieve the `SemanticsNode` for a specific widget. Always call `semantics.dispose()` at the end of the test to clean up.

Without `ensureSemantics()`, the semantics tree is not built during tests and `getSemantics` will throw.

### The matchesSemantics Matcher

`matchesSemantics` is a rich matcher that lets you assert on many properties of a `SemanticsNode` in one readable assertion:

| Property | What it checks |
|----------|----------------|
| `label` | The announced text |
| `hint` | The activation hint |
| `value` | The current state value |
| `isButton` | The button role |
| `isHeader` | The heading role |
| `isEnabled` | Whether the element is interactive |
| `hasTapAction` | Whether the element can be tapped |
| `isChecked` | Checkbox/toggle state |

This is far more thorough than `find.text()`, which only checks visible widget content and says nothing about whether the element is correctly labelled for assistive technology.

### Manual Testing Checklist

Automated tests catch missing labels but cannot catch misleading or confusing ones. A label can exist and still describe the wrong thing — only a human ear catches that. Run this checklist on each screen:

- Every interactive element announces its purpose clearly
- Focus order is logical (left-to-right, top-to-bottom for most languages)
- No unlabelled interactive elements (red nodes in the inspector)
- Decorative images are hidden from the semantics tree
- Form errors are announced when they appear
- Dialogs trap focus until dismissed
- Route changes are announced
- Loading states are announced
- Test on a real device, not just the simulator

## Code Examples

### Before (Inaccessible)

```dart
// Only checks visual content — says nothing about accessibility
testWidgets('account card shows balance', (tester) async {
  await tester.pumpWidget(
    const MaterialApp(home: AccountCard(account: testAccount)),
  );
  expect(find.text('\$4,285.50'), findsOneWidget);
});
```

### After (Accessible)

```dart
// Checks the semantic label that TalkBack/VoiceOver will announce
testWidgets('account card has accessible label', (tester) async {
  final semantics = tester.ensureSemantics();

  await tester.pumpWidget(
    const MaterialApp(home: AccountCard(account: testAccount)),
  );

  expect(
    tester.getSemantics(find.byType(AccountCard)),
    matchesSemantics(
      label: 'Everyday Checking account, '
             'balance four thousand two hundred '
             'eighty-five dollars and fifty cents',
    ),
  );

  semantics.dispose();
});

// Check role, label, and available actions together
testWidgets('delete button is accessible', (tester) async {
  final semantics = tester.ensureSemantics();
  await tester.pumpWidget(/* ... */);

  expect(
    tester.getSemantics(find.byTooltip('Delete transaction')),
    matchesSemantics(
      label: 'Delete transaction',
      isButton: true,
      isEnabled: true,
      hasTapAction: true,
    ),
  );

  semantics.dispose();
});
```

## Key Takeaways

- `tester.ensureSemantics()` must be called before any semantics assertions; dispose the handle after.
- `matchesSemantics` checks roles, states, and actions — not just text content.
- Automated tests and manual checklist testing are complementary — both are required.
- Integration tests on real devices catch issues that widget tests running in a headless environment can miss.
- Running accessibility tests in CI makes them a required gate on every pull request.

## Deep Dive

- [Flutter Testing documentation](https://docs.flutter.dev/testing)
- [matchesSemantics API](https://api.flutter.dev/flutter/flutter_test/matchesSemantics.html)
- [Accessibility Testing in Flutter](https://docs.flutter.dev/testing/accessibility)

## What's Next

Chapter 9, the final chapter: a full end-to-end audit of AccessBank, platform-specific quirks on Android / iOS / web, custom semantics actions for the VoiceOver rotor and TalkBack context menu, and keeping the semantics tree lean for performance.
