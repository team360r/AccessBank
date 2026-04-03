# Chapter 1: "Welcome to AccessBank"

> *"Oh wow, this is what it's like for some users?"*

## What You'll Learn

- How to tour AccessBank as a sighted user versus a screen reader user
- The five most common categories of accessibility failures
- What Flutter's semantics tree is and how it maps to widgets
- How to identify labelled versus unlabelled nodes with the AccessGuide inspector

## Prerequisites

- Chapter 0 complete — you should have your screen reader enabled and know the core gestures

## Concepts Covered

### The Screen Reader Experience

AccessBank has five screens: Login, Account Overview, Transaction List, Transfer, and Settings. Sighted users can glance at the Account Overview and immediately understand their finances. Screen reader users navigate element by element. In the inaccessible version they hear things like "Image", "Button", and raw number strings like "four comma two eight five point five zero" — not a balance.

About 2.2 billion people worldwide have some form of vision impairment. Even a small fraction of those users represent tens of millions of potential customers who are currently locked out by preventable bugs.

### The Five Common Accessibility Failures

Every major banking app accessibility audit surfaces the same five categories:

1. **Missing labels** — icon buttons with no text alternative, so TalkBack announces "Button" and nothing else.
2. **Meaningless labels** — "Image" for a decorated account icon, or a raw formatted number instead of a spoken amount.
3. **Poor tab/focus order** — the screen reader jumps to a floating action button before the form fields it overlays.
4. **Low contrast** — light-grey balance text on a white card background.
5. **Tiny touch targets** — 24 dp icon buttons that are half the required minimum size.

### Flutter's Semantics Tree

Flutter renders to a canvas. The OS accessibility service cannot read pixels, so Flutter builds a parallel **semantics tree**: a structured description of every meaningful UI element. Each `SemanticsNode` carries a label, a role (button, header, image…), a state (enabled, checked, focused…), and a list of actions (tap, long-press…).

Widgets like `ElevatedButton`, `Checkbox`, and `Slider` add semantics automatically. Plain `Container`, `Row`, `Icon`, and `Text` widgets may or may not contribute semantics depending on their context — and that is where gaps appear.

## Code Examples

### Before (Inaccessible)

```dart
// TalkBack announces "Image" then "4,285.50" as two unrelated elements.
Container(
  child: Row(
    children: [
      Icon(Icons.account_balance),
      Text('\$4,285.50'),
    ],
  ),
)
```

### After (Accessible)

```dart
// Semantics wraps the whole card into one meaningful node.
Semantics(
  label: 'Everyday Checking, balance four thousand two hundred '
         'eighty-five dollars and fifty cents',
  child: Container(
    child: Row(
      children: [
        Icon(Icons.account_balance),
        Text('\$4,285.50'),
      ],
    ),
  ),
)
```

## Key Takeaways

- The screen reader experience of the inaccessible app is disorienting — experiencing it builds the empathy needed to fix it properly.
- The five failure categories (missing labels, meaningless labels, bad focus order, low contrast, small touch targets) cover the majority of real-world audit findings.
- Flutter's semantics tree is separate from the widget tree — you must actively maintain it.
- Green borders in the inspector mean labelled; red borders mean unlabelled interactive elements that need attention.

## Deep Dive

- [Semantics class API](https://api.flutter.dev/flutter/widgets/Semantics-class.html)
- [Flutter Accessibility Overview](https://docs.flutter.dev/accessibility-and-localization/accessibility)
- [WHO: World report on vision](https://www.who.int/publications/i/item/9789241516570)

## What's Next

Chapter 2 dives into the `Semantics` widget API — adding labels, hints, values, merging compound elements, and silencing decorative noise on the Account Overview screen.
