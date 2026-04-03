# Chapter 6: "Motion & Interaction"

> *"Not everyone can swipe precisely"*

## What You'll Learn

- How to check and honour the system "Reduce Motion" preference
- How to meet the 48 dp minimum touch target size requirement
- How to provide accessible alternatives to swipe-only gestures
- How to provide alternatives to long-press actions
- How to test motor accessibility with Switch Access and Switch Control

## Prerequisites

- Chapter 5 complete

## Concepts Covered

### Reduce Motion

Users with vestibular disorders can experience nausea, dizziness, or disorientation from excessive screen animation. Both iOS and Android provide a "Reduce Motion" / "Remove animations" setting. Flutter exposes this through `MediaQuery.disableAnimationsOf(context)`, which returns `true` when the user has enabled the preference.

Respond by setting animation durations to `Duration.zero` rather than removing the animation entirely — this keeps transitions functional (content still changes) without the motion.

### Touch Target Sizing

Apple's Human Interface Guidelines require a minimum **44 pt** tappable area; Material Design requires **48 dp**. AccessBank's original transaction list uses 24 dp icon buttons — half the required minimum. This is a common failure for users with tremors, arthritis, or Parkinson's disease.

Wrap small icons in `SizedBox(width: 48, height: 48)`, or use `IconButton` with `constraints: BoxConstraints(minWidth: 48, minHeight: 48)` to expand the tappable area without changing the visual icon size.

### Swipe Alternatives

The `Dismissible` widget lets users swipe to delete. This is a great shortcut but inaccessible to screen reader users (no action is announced), switch-control users, and users who cannot perform the precise gesture reliably. The swipe gesture can remain as a shortcut, but there must always be an equivalent button or menu action.

### Long-Press Alternatives

Long-press actions are invisible to screen reader users, keyboard users, and users who cannot hold their finger steady. Expose the same actions via a `PopupMenuButton` or a visible "More options" button. The long press can remain as a shortcut but must not be the only path.

## Code Examples

### Before (Inaccessible)

```dart
// Always animates — can trigger vestibular issues
AnimatedSwitcher(
  duration: const Duration(milliseconds: 400),
  child: _buildFilteredList(selectedFilter),
)

// 24 dp touch target — too small for many users
GestureDetector(
  onTap: () => _openDetails(transaction),
  child: const Icon(Icons.chevron_right, size: 24),
)

// Swipe-only delete — inaccessible to screen reader and switch-access users
Dismissible(
  key: Key(transaction.id),
  direction: DismissDirection.endToStart,
  onDismissed: (_) => _deleteTransaction(transaction),
  child: TransactionTile(transaction: transaction),
)
```

### After (Accessible)

```dart
// Skips animation when the user prefers reduced motion
Builder(
  builder: (context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return AnimatedSwitcher(
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 400),
      child: _buildFilteredList(selectedFilter),
    );
  },
)

// 48 dp touch target — meets both Material and Apple guidelines
IconButton(
  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
  icon: const Icon(Icons.chevron_right, size: 24),
  tooltip: 'View transaction details',
  onPressed: () => _openDetails(transaction),
)

// Swipe still works AND there is an accessible button alternative
Dismissible(
  key: Key(transaction.id),
  direction: DismissDirection.endToStart,
  background: const DeleteBackground(),
  onDismissed: (_) => _deleteTransaction(transaction),
  child: TransactionTile(
    transaction: transaction,
    trailing: Semantics(
      label: 'Delete transaction',
      button: true,
      child: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () => _confirmDelete(transaction),
      ),
    ),
  ),
)
```

## Key Takeaways

- Check `MediaQuery.disableAnimationsOf(context)` and set `Duration.zero` when true.
- Minimum touch target is 48 dp (Material) / 44 pt (Apple HIG) — use `IconButton` constraints to expand without changing visuals.
- Swipe gestures and long-press actions must always have a button or menu equivalent — they can be shortcuts, never the only path.
- Test with Switch Access (Android) or Switch Control (iOS) to verify every action is reachable with a single switch.

## Deep Dive

- [WCAG 2.3 Seizures and Physical Reactions](https://www.w3.org/WAI/WCAG21/Understanding/seizures-and-physical-reactions)
- [MediaQuery.disableAnimationsOf API](https://api.flutter.dev/flutter/widgets/MediaQuery/disableAnimationsOf.html)
- [Material Design: Touch and click targets](https://m2.material.io/design/usability/accessibility.html#layout-and-typography)

## What's Next

Chapter 7 covers dynamic content: announcing filter results, balance updates via live regions, loading states, accessible snackbars, and route-change announcements — so screen reader users are informed of every meaningful change.
