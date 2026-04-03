# Chapter 4: "See Clearly"

> *"My grandma could actually use this now"*

## What You'll Learn

- How to check and fix contrast ratios to meet WCAG AA
- Why you should never override `textScaleFactor` and how to fix layouts that break at large text sizes
- How to ensure dark mode colours also meet contrast requirements
- How to add non-colour indicators so colour-blind users get the same information

## Prerequisites

- Chapter 3 complete
- A contrast-checking tool (browser extension or [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/))

## Concepts Covered

### Contrast Ratios

WCAG 2.1 Success Criterion 1.4.3 requires a **4.5:1** contrast ratio between text and its background for normal-size text (under 18pt regular or 14pt bold). Large text needs a minimum of 3:1. AccessBank's original balance label uses `Colors.grey[400]` on white — a ratio of roughly 2.9:1, which fails.

The fix is to find a darker shade that passes. `Colors.grey[700]` gives roughly 5.9:1 — comfortable for both WCAG AA (4.5:1) and AAA (7:1) for normal text. Always test your specific hex values with a contrast checker rather than guessing by shade number.

One in three people over 65 has some form of vision impairment. Contrast is one of the cheapest fixes with the widest benefit.

### Text Scaling

iOS and Android both let users increase the system font size. Flutter honours this via `MediaQuery.textScalerOf(context)`. The problem occurs when developers add `textScaleFactor: 1.0` to force text to render at the default size regardless of the user's preference — this directly violates WCAG 1.4.4 ("Resize text"). Remove all `textScaleFactor` overrides.

The second half of the problem is layout: fixed-height containers that worked at 100% scale overflow at 200%. Replace `SizedBox(height: 56)` with `ConstrainedBox(constraints: BoxConstraints(minHeight: 56))` and use `Expanded`/`Flexible` inside rows to let content grow.

### Colour-Only Communication

About 300 million people are colour blind, most commonly with red-green confusion. A green dot for a healthy account and a red dot for an overdrawn account is invisible as a distinction to these users. Always pair colour with a second indicator: an icon, a shape, or a text label.

## Code Examples

### Before (Inaccessible)

```dart
// Contrast ratio ~2.9:1 — fails WCAG AA
Text(
  'Balance',
  style: TextStyle(
    color: Colors.grey[400],
    fontSize: 12,
  ),
)

// Forces default text size — ignores accessibility settings
Text(
  accountName,
  textScaleFactor: 1.0,
  style: const TextStyle(fontSize: 16),
)

// Colour alone — invisible to users with red-green colour blindness
Container(
  width: 8,
  height: 8,
  decoration: BoxDecoration(
    color: isPositive ? Colors.green : Colors.red,
    shape: BoxShape.circle,
  ),
)
```

### After (Accessible)

```dart
// Contrast ratio ~5.9:1 — passes WCAG AA and AAA
Text(
  'Balance',
  style: TextStyle(
    color: Colors.grey[700],
    fontSize: 12,
  ),
)

// Respects the user's font-size preference
Text(
  accountName,
  style: const TextStyle(fontSize: 16),
  // No textScaleFactor override
)

// Colour + icon — works for everyone including colour-blind users
Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Icon(
      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
      color: isPositive ? Colors.green[700] : Colors.red[700],
      size: 14,
      semanticLabel: isPositive ? 'Positive balance' : 'Overdrawn',
    ),
    const SizedBox(width: 4),
    Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isPositive ? Colors.green[700] : Colors.red[700],
        shape: BoxShape.circle,
      ),
    ),
  ],
)
```

## Key Takeaways

- 4.5:1 is the WCAG AA minimum for normal text — use a contrast checker, not your eyes.
- Never add `textScaleFactor: 1.0`; use `ConstrainedBox(minHeight)` instead of `SizedBox(height)` to handle large text.
- Dark mode needs its own contrast-tested colour palette — don't assume light-mode colours work on dark backgrounds.
- Always pair colour with a shape, icon, or text label — never communicate meaning through colour alone.

## Deep Dive

- [WCAG 1.4.3 Contrast (Minimum)](https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html)
- [WCAG 1.4.4 Resize Text](https://www.w3.org/WAI/WCAG21/Understanding/resize-text.html)
- [MediaQuery API](https://api.flutter.dev/flutter/widgets/MediaQuery-class.html)
- [WCAG 1.4.1 Use of Color](https://www.w3.org/WAI/WCAG21/Understanding/use-of-color.html)

## What's Next

Chapter 5 moves to the Login and Transfer screens for form accessibility: persistent labels, announcing errors through the screen reader, moving focus to the first error field, and using smart keyboard types and autofill hints.
