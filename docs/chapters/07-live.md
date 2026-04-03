# Chapter 7: "Dynamic Content & Live Regions"

> *"The app talks to you now, in a good way"*

## What You'll Learn

- How to announce dynamic content changes with `SemanticsService.announce()`
- How to use `Semantics(liveRegion: true)` for elements that update automatically
- How to make loading states and spinners accessible
- How to make snackbars reliably accessible across platforms
- How to announce route changes with a `NavigatorObserver`

## Prerequisites

- Chapter 6 complete

## Concepts Covered

### SemanticsService.announce

When content changes in response to a user action — a filter applies, a form submits, a calculation completes — sighted users see the change immediately. Screen reader users miss it unless the app announces it. `SemanticsService.announce(message, textDirection)` inserts a spoken message into the platform's accessibility queue without requiring a focus change. It works like an ARIA live region polite announcement on the web.

Use it for: filter result counts, success/error messages, completion confirmations. Avoid using it on every keystroke or every state change — too many announcements create noise.

### Live Regions

`Semantics(liveRegion: true)` tells the accessibility service to proactively announce any change in that node's label without user action. This is ideal for values that update automatically — like an account balance that refreshes after a transfer completes, or a balance widget that polls in the background.

The difference from `SemanticsService.announce()` is that `liveRegion: true` ties the announcement to the widget's own content, while `announce()` fires a one-off message that may not be connected to any widget.

### Loading States

A `CircularProgressIndicator` is visually obvious to sighted users but completely silent to screen reader users. Wrap it in `Semantics(liveRegion: true, label: 'Loading transactions, please wait')` so the screen reader announces the loading state when it appears. When loading completes, announce "Transactions loaded" via `SemanticsService.announce()`.

### Route Announcements

When the user navigates to a new screen, the OS usually announces the new screen's title — but this behaviour is inconsistent across Flutter, Android, and iOS versions. For reliable cross-platform announcements, implement a `NavigatorObserver` that calls `SemanticsService.announce()` on `didPush`.

## Code Examples

### Before (Inaccessible)

```dart
// Filter result count is never announced
void _applyFilter(String filter) {
  setState(() {
    _selectedFilter = filter;
    _filteredTransactions = _getFiltered(filter);
  });
}

// Balance updates silently — screen reader users miss the change
Text(
  formattedBalance,
  style: Theme.of(context).textTheme.headlineMedium,
)

// Spinner shows with no announcement
if (_isLoading) {
  return const Center(child: CircularProgressIndicator());
}
```

### After (Accessible)

```dart
// Filter result count is announced to screen reader users
void _applyFilter(String filter) {
  setState(() {
    _selectedFilter = filter;
    _filteredTransactions = _getFiltered(filter);
  });
  final count = _filteredTransactions.length;
  final label = filter == 'All' ? 'all' : filter.toLowerCase();
  SemanticsService.announce(
    'Showing $count $label transaction${count == 1 ? '' : 's'}',
    TextDirection.ltr,
  );
}

// Balance change is automatically announced as a live region
Semantics(
  liveRegion: true,
  label: 'Account balance: $formattedBalance',
  child: Text(
    formattedBalance,
    style: Theme.of(context).textTheme.headlineMedium,
  ),
)

// Spinner announces loading state; completion is announced via SemanticsService
if (_isLoading) {
  return Semantics(
    liveRegion: true,
    label: 'Loading transactions, please wait',
    child: const Center(child: CircularProgressIndicator()),
  );
}

// NavigatorObserver for reliable route announcements
class AccessibilityObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final name = route.settings.name ?? 'New screen';
    SemanticsService.announce(name, TextDirection.ltr);
    super.didPush(route, previousRoute);
  }
}
// Register: navigatorObservers: [AccessibilityObserver()]
```

## Key Takeaways

- `SemanticsService.announce()` fires a one-off spoken message; use it for event-driven updates.
- `Semantics(liveRegion: true)` announces the widget's own content changes automatically; use it for values that update without direct user action.
- Always announce loading states and their completion.
- A `NavigatorObserver` gives consistent, cross-platform route announcements.
- Do not over-announce — only meaningful events warrant a `SemanticsService.announce()` call.

## Deep Dive

- [SemanticsFlag.isLiveRegion API](https://api.flutter.dev/flutter/semantics/SemanticsFlag.html)
- [WCAG 4.1.3 Status Messages](https://www.w3.org/WAI/WCAG21/Understanding/status-messages.html)
- [SemanticsService API](https://api.flutter.dev/flutter/semantics/SemanticsService-class.html)

## What's Next

Chapter 8 moves from building to verifying: writing widget tests that assert on the semantics tree with `matchesSemantics`, building a manual testing checklist, and wiring accessibility tests into CI so regressions are caught automatically.
