# Chapter 5: "Forms That Work for Everyone"

> *"Forms are where accessibility really saves people"*

## What You'll Learn

- Why `labelText` matters more than `hintText` for accessibility
- How to announce form errors through the screen reader with `SemanticsService`
- How to move focus to the first error field automatically
- How to add real-time validation with accessible announcements
- How `keyboardType` and `autofillHints` reduce friction for all users

## Prerequisites

- Chapter 4 complete
- Familiarity with Flutter's `TextField` and `Form` widgets

## Concepts Covered

### Persistent Labels vs Placeholder Hints

`hintText` in `InputDecoration` disappears the moment the user starts typing. This leaves them with no visible label to refer back to while they are editing — a problem for anyone, and a serious barrier for screen reader users who may be typing slowly.

`labelText` creates a floating label that starts inside the field (behaving like a hint) but animates above it when the user focuses the field or types. The label remains visible at all times. Flutter's `TextField` with `labelText` automatically exposes the label to the accessibility service, so the user hears "Email address, text field" instead of just "text field".

### Announcing Errors with SemanticsService

When form validation fails, sighted users see red error text below the field. Screen reader users do not know anything went wrong unless the app tells them. `SemanticsService.announce(message, textDirection)` inserts a live spoken announcement into the platform's accessibility queue — like a live-region update on the web — without requiring the user to move focus. Call it immediately after setting error state.

### Focus to Error

Announcing the error is a good start, but the user still needs to find the field. After validation fails, call `requestFocus()` on the `FocusNode` attached to the first error field. This lands the user directly in the right place to fix the problem.

### Smart Input Types

Setting the correct `keyboardType` shows the most helpful on-screen keyboard. Setting `autofillHints` enables iOS and Android autofill so password managers can populate credentials. Setting `textInputAction` controls the action button label (Next, Done) and the behaviour when the user submits.

## Code Examples

### Before (Inaccessible)

```dart
// Placeholder disappears on input; no label for screen readers
TextField(
  decoration: const InputDecoration(
    hintText: 'Enter your email',
  ),
  controller: _emailController,
)

// Error shows visually but is never announced
void _validateAndSubmit() {
  if (_emailController.text.isEmpty) {
    setState(() {
      _emailError = 'Email is required';
    });
  }
}
```

### After (Accessible)

```dart
// Label floats above the field and is always visible and announced
TextField(
  decoration: InputDecoration(
    labelText: 'Email address',
    hintText: 'e.g. name@example.com',
    errorText: _emailError,
  ),
  controller: _emailController,
  keyboardType: TextInputType.emailAddress,
  textInputAction: TextInputAction.next,
  autofillHints: const [AutofillHints.username, AutofillHints.email],
  focusNode: _emailFocus,
)

// Error is both shown visually and announced; focus jumps to the field
final FocusNode _emailFocus = FocusNode();
final FocusNode _passwordFocus = FocusNode();

void _validateAndSubmit() {
  FocusNode? firstError;

  if (_emailController.text.isEmpty) {
    setState(() => _emailError = 'Email is required');
    firstError ??= _emailFocus;
  }
  if (_passwordController.text.isEmpty) {
    setState(() => _passwordError = 'Password is required');
    firstError ??= _passwordFocus;
  }

  if (firstError != null) {
    firstError.requestFocus();
    SemanticsService.announce(
      'Form has errors. Please review the highlighted fields.',
      TextDirection.ltr,
    );
    return;
  }
  _signIn();
}
```

## Key Takeaways

- Use `labelText` not just `hintText` — the floating label remains visible and provides a semantic label to the accessibility service.
- `SemanticsService.announce()` is the correct way to push error messages to screen reader users.
- Always move focus (`requestFocus()`) to the first error field after validation.
- `keyboardType`, `textInputAction`, and `autofillHints` reduce friction for sighted, screen reader, and motor-impaired users alike.
- Live validation with a short debounce gives immediate feedback without firing on every keystroke.

## Deep Dive

- [SemanticsService.announce API](https://api.flutter.dev/flutter/semantics/SemanticsService-class.html)
- [WCAG 3.3 Input Assistance](https://www.w3.org/WAI/WCAG21/Understanding/input-assistance)
- [TextField API](https://api.flutter.dev/flutter/material/TextField-class.html)

## What's Next

Chapter 6 focuses on motor accessibility: respecting the system Reduce Motion setting, meeting the 48 dp touch target minimum, and providing button alternatives to every swipe or long-press gesture.
