# Chapter 9: "The Polished App"

> *"I actually understand accessibility now"*

## What You'll Learn

- How to conduct a full end-to-end accessibility audit across all five screens
- Platform-specific quirks on TalkBack, VoiceOver, and Flutter Web
- How to add custom semantics actions for the VoiceOver Rotor and TalkBack context menu
- How to keep the semantics tree lean for better performance
- Resources and practices to carry accessibility work forward

## Prerequisites

- Chapters 0–8 complete

## Concepts Covered

### Full Audit

A real accessibility audit is not per-screen — it is per-user-journey. The complete AccessBank workflow is:

1. Log in with email and password
2. Check the balance on the Everyday Checking account
3. Transfer $50 to Savings
4. View the transaction history and confirm the transfer appears
5. Find the notification preference toggle in Settings

Every step should be completable using only swipe-right and double-tap (screen reader) or Tab and Enter (keyboard). If you get stuck at any step, that is a regression to fix before shipping.

### Platform Differences

Each platform's screen reader has its own implementation quirks:

**TalkBack (Android)** uses "explore by touch" by default — swipe navigation is a mode the user enables. The `liveRegion: true` flag is well supported. Long-swipe gestures can be user-customised.

**VoiceOver (iOS)** reads `hint` text after a brief pause, or on demand via the rotor. Announcements from `SemanticsService` are sometimes delayed on older iOS. Triple-click the side button to toggle quickly during testing.

**Flutter Web (Chrome + screen reader)** exposes semantics as ARIA attributes — inspect them in Chrome DevTools' Accessibility pane. Route announcements are less reliable on web; use `SemanticsService` explicitly. Tab/Shift-Tab is the primary keyboard navigation modality.

Always test on all three platforms before shipping. An issue invisible on one platform may be a showstopper on another.

### Custom Semantics Actions

`CustomSemanticsAction` exposes actions in the screen reader's action menu: the VoiceOver Rotor (iOS) and TalkBack local context menu (Android). This is the right tool for actions like "copy account number" or "mark transaction as reviewed" that have no obvious button in the visual layout.

### Semantics Tree Performance

A large semantics tree has a performance cost — Flutter must diff and sync it on every frame that changes. Keep the tree lean:

- Use `ExcludeSemantics` on decorative subtrees
- Use `MergeSemantics` to collapse compound elements
- Avoid wrapping every `Text` in its own `Semantics` wrapper when a parent `MergeSemantics` achieves the same result
- Profile with `showSemanticsDebugger` to spot unexpected node proliferation

## Code Examples

### Before (Inaccessible)

```dart
// 5 separate semantics nodes for one account row — expensive and noisy
Semantics(
  child: Row(
    children: [
      Semantics(child: Icon(Icons.account_balance)),
      Semantics(child: Text(account.name)),
      Semantics(child: Text(account.formattedBalance)),
      Semantics(child: Icon(Icons.chevron_right)),
    ],
  ),
)

// No custom actions — important features only reachable via long press
GestureDetector(
  onTap: () => _openDetails(transaction),
  onLongPress: () => _showMenu(transaction),
  child: TransactionTileContent(transaction: transaction),
)
```

### After (Accessible)

```dart
// 1 merged semantics node; decorative icons excluded
MergeSemantics(
  child: Row(
    children: [
      ExcludeSemantics(child: Icon(Icons.account_balance)),
      Text(account.name),
      Text(account.formattedBalance),
      ExcludeSemantics(child: Icon(Icons.chevron_right)),
    ],
  ),
)

// Custom actions appear in VoiceOver Rotor and TalkBack context menu
Semantics(
  label: '${transaction.description}, ${transaction.formattedAmount}',
  customSemanticsActions: {
    const CustomSemanticsAction(label: 'Copy reference number'):
        () => _copyReference(transaction),
    const CustomSemanticsAction(label: 'Report an issue'):
        () => _reportIssue(transaction),
  },
  child: GestureDetector(
    onTap: () => _openDetails(transaction),
    child: TransactionTileContent(transaction: transaction),
  ),
)
```

## Key Takeaways

- Audit by user journey, not by screen — the flow must be completable end-to-end.
- Platform quirks are real: test TalkBack, VoiceOver, and Flutter Web separately.
- `CustomSemanticsAction` exposes actions in the screen reader action menu without cluttering the visual layout.
- Keep the semantics tree lean with `MergeSemantics` and `ExcludeSemantics` — fewer nodes means better performance.
- Accessibility is a continuous practice, not a one-time checklist.

## Deep Dive

- [iOS Accessibility documentation (Apple)](https://developer.apple.com/accessibility/)
- [Android Accessibility documentation](https://developer.android.com/guide/topics/ui/accessibility)
- [Flutter Web Accessibility](https://docs.flutter.dev/platform-integration/web/web-content-accessibility-guidelines)
- [WCAG 2.1 full specification](https://www.w3.org/TR/WCAG21/)

## What's Next

You are done — and you have built something real. AccessBank is now usable by people with vision impairments, motor impairments, colour blindness, and age-related vision loss. The same patterns you practised here apply to every Flutter app you build from this point forward. Keep learning, keep testing, keep shipping accessible software.
