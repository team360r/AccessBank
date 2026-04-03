# Chapter 3: "Finding Your Way"

> *"I never thought about Tab order before"*

## What You'll Learn

- How to fix broken tab/focus order with `FocusTraversalGroup`
- How to set an explicit traversal order with `OrderedTraversalPolicy`
- How to trap focus inside modal dialogs
- How to add skip-navigation links for keyboard users

## Prerequisites

- Chapter 2 complete — you should be comfortable with the `Semantics` widget
- A physical keyboard or keyboard shortcut emulator for full testing

## Concepts Covered

### Focus Traversal Order

By default Flutter traverses widgets in the order they appear in the widget tree, which usually matches paint order. Problems arise when widgets are placed early in the tree for z-order reasons (like a floating action button) but should be visited later by the screen reader.

`FocusTraversalGroup` defines an independent traversal scope. Widgets inside a group are ordered relative to each other, independently of widgets outside it. Wrapping `LoginForm` in a `FocusTraversalGroup` with `ReadingOrderTraversalPolicy` ensures focus stays within the form fields before jumping to the FAB.

For complex non-linear layouts, `OrderedTraversalPolicy` with `FocusTraversalOrder(order: NumericFocusOrder(n))` lets you set an explicit numeric sequence on individual widgets.

### Focus Traps in Modal Dialogs

When a modal dialog opens, keyboard focus must stay inside it. Otherwise a keyboard user can Tab behind the dialog and interact with (or accidentally trigger) actions on the obscured screen. Flutter's `Dialog` widget requests focus when it opens, but you still need a `FocusTraversalGroup` inside the dialog content to prevent Tab from escaping. Setting `autofocus: true` on the first interactive element in the dialog places the user in the right starting position immediately.

### Skip Navigation

A navigation bar with six tabs means a keyboard user must press Tab six times before reaching the main content — on every single screen. Skip links let users jump straight to the main content region. In Flutter, implement this with a `FocusNode` that calls `requestFocus()` on the first element of the main content when the user activates the skip link. Make the link visible only when it receives keyboard focus so it does not clutter the visual layout.

## Code Examples

### Before (Inaccessible)

```dart
// Focus order: FAB → Email → Password → Sign In
// The FAB sits early in the widget tree for z-order reasons.
Scaffold(
  body: LoginForm(),
  floatingActionButton: HelpFab(),
)
```

### After (Accessible)

```dart
// Focus stays within LoginForm before reaching the FAB.
Scaffold(
  body: FocusTraversalGroup(
    policy: ReadingOrderTraversalPolicy(),
    child: LoginForm(),
  ),
  floatingActionButton: HelpFab(),
)

// Inside LoginForm, explicit order where reading order alone is not enough:
FocusTraversalGroup(
  policy: OrderedTraversalPolicy(),
  child: Column(
    children: [
      FocusTraversalOrder(
        order: const NumericFocusOrder(1),
        child: EmailField(),
      ),
      FocusTraversalOrder(
        order: const NumericFocusOrder(2),
        child: PasswordField(),
      ),
      FocusTraversalOrder(
        order: const NumericFocusOrder(3),
        child: SignInButton(),
      ),
    ],
  ),
)
```

## Key Takeaways

- Default Flutter traversal follows widget-tree order — this can diverge from visual order for z-layered elements.
- `FocusTraversalGroup` creates an independent focus scope; `OrderedTraversalPolicy` allows explicit numeric ordering.
- Dialogs require a `FocusTraversalGroup` + `autofocus: true` on the first action to trap and land focus correctly.
- Skip links are essential for keyboard users on screens with long navigation headers.
- Test the complete login flow using only Tab and Enter — if you get stuck, that's a bug.

## Deep Dive

- [FocusTraversalGroup API](https://api.flutter.dev/flutter/widgets/FocusTraversalGroup-class.html)
- [FocusNode API](https://api.flutter.dev/flutter/widgets/FocusNode-class.html)
- [WCAG 2.4 Navigable](https://www.w3.org/WAI/WCAG21/Understanding/navigable)

## What's Next

Chapter 4 shifts to visual accessibility: fixing contrast ratios, removing hardcoded text scale overrides, ensuring layouts survive large text, and stopping colour from being used as the only way to communicate meaning.
