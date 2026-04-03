# Chapter 2: "Speaking the Language"

> *"That was easier than I thought!"*

## What You'll Learn

- How to add meaningful labels, hints, and values to widgets
- When and how to use `MergeSemantics` to collapse compound elements
- When and how to use `ExcludeSemantics` to silence decorative noise
- How to compare the before/after experience with a screen reader

## Prerequisites

- Chapter 1 complete — you should understand the semantics tree concept and have spotted the red nodes on the Account Overview screen

## Concepts Covered

### Labels, Hints, and Values

The `Semantics` widget is the primary API for adding information to the semantics tree. Its three most-used text properties are:

- **`label`** — what the element *is*. This is what the screen reader announces when the user focuses on the node.
- **`hint`** — what will happen when the user activates the element ("double tap to view transaction history"). Announced after a brief pause or on demand.
- **`value`** — the current state of a variable element, such as a toggle's "on/off" or a slider's current position.

One important detail: screen readers read formatted numbers oddly. `$4,285.50` is read as "four comma two eight five point five zero". Always spell out dollar amounts in the label: "four thousand two hundred eighty-five dollars and fifty cents".

### MergeSemantics

`MergeSemantics` combines all descendant semantics nodes into a single node. Without it, a typical account card creates five or six focus stops: the card icon, the account name text, the balance text, and each action button. With `MergeSemantics`, the whole card is one stop and the user hears the complete picture in one announcement.

Use `MergeSemantics` on any compound element where reading the parts individually would be confusing or inefficient.

### ExcludeSemantics

`ExcludeSemantics` hides an entire subtree from the semantics tree. Use it for purely decorative elements: background patterns, separator lines, repeated illustrative icons. Without it, a row of three decorative wallet icons produces three "Image" announcements that add noise without adding information.

## Code Examples

### Before (Inaccessible)

```dart
// Screen reader visits: icon → account name → balance → 3 buttons = 6 stops per card
// TalkBack announces each as a separate, unlabelled element
Stack(
  children: [
    Positioned.fill(
      child: Icon(
        Icons.account_balance_wallet,
        size: 80,
        color: Colors.white12,
      ),
    ),
    Row(
      children: [
        Icon(Icons.account_balance),
        Column(
          children: [
            Text('Everyday Checking'),
            Text('\$4,285.50'),
          ],
        ),
      ],
    ),
  ],
)
```

### After (Accessible)

```dart
// Decorative icon excluded; content merged into one node with a proper label
Stack(
  children: [
    Positioned.fill(
      child: ExcludeSemantics(
        child: Icon(
          Icons.account_balance_wallet,
          size: 80,
          color: Colors.white12,
        ),
      ),
    ),
    Semantics(
      label: 'Everyday Checking account, '
             'balance four thousand two hundred '
             'eighty-five dollars and fifty cents',
      child: MergeSemantics(
        child: Row(
          children: [
            Icon(Icons.account_balance),
            Column(
              children: [
                Text('Everyday Checking'),
                Text('\$4,285.50'),
              ],
            ),
          ],
        ),
      ),
    ),
  ],
)
```

## Key Takeaways

- `label` is the primary text a screen reader announces — spell out numbers in words.
- `hint` provides activation guidance; `value` describes current state.
- `MergeSemantics` reduces the number of focus stops for compound elements.
- `ExcludeSemantics` removes decorative noise without changing the visual layout.
- After fixing labels, use the before/after toggle with a screen reader to confirm the improvement.

## Deep Dive

- [Semantics class API](https://api.flutter.dev/flutter/widgets/Semantics-class.html)
- [MergeSemantics API](https://api.flutter.dev/flutter/widgets/MergeSemantics-class.html)
- [ExcludeSemantics API](https://api.flutter.dev/flutter/widgets/ExcludeSemantics-class.html)

## What's Next

Chapter 3 tackles navigation: fixing tab order on the login screen, trapping focus inside modal dialogs, and adding skip-navigation so keyboard users aren't forced to traverse the entire header on every screen.
