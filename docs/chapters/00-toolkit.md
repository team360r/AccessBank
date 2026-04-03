# Chapter 0: "Your Accessibility Toolkit"

> *"Now I know how to hear what my users hear"*

## What You'll Learn

- How to enable and use TalkBack (Android) and VoiceOver (iOS)
- The essential screen reader gestures every Flutter developer needs
- How to visualise the semantics tree with `showSemanticsDebugger`
- How to use Flutter DevTools' Accessibility Inspector
- How the in-app AccessGuide inspector overlay works

## Prerequisites

- A physical or virtual iOS or Android device (or Chrome for web)
- Flutter SDK 3.x installed and `flutter run` working

## Concepts Covered

### Screen Readers

A screen reader is an assistive technology that reads the contents of a screen aloud. It uses the accessibility tree — a structured description of the UI — rather than the visual pixels. On **Android** this is **TalkBack** (Settings > Accessibility > TalkBack). On **iOS** it is **VoiceOver** (Settings > Accessibility > VoiceOver, or triple-click the side button if you have set up the Accessibility Shortcut). On **Flutter Web** you can use NVDA or JAWS on Windows, or VoiceOver in Safari/Chrome on macOS.

When a screen reader is active, all touch and keyboard input changes meaning: a single tap moves focus to an element and reads its label aloud, while a double-tap activates it. This is how your users experience the app — and it's why missing or wrong labels are so disruptive.

### Screen Reader Gestures

The core gestures you need every day:

| Gesture | Action |
|---------|--------|
| Swipe right | Move focus to next element |
| Swipe left | Move focus to previous element |
| Double-tap | Activate the focused element |
| Drag finger | Explore by touch (reads whatever is under your fingertip) |
| Three-finger swipe up/down | Scroll |

On VoiceOver with a Bluetooth keyboard, Tab / Shift-Tab navigate and Space or Return activates.

### Flutter's Semantics Debugger

Flutter renders to a canvas — no DOM elements. To make that canvas understandable to assistive technology, Flutter maintains a parallel **semantics tree**: a structured description of every meaningful element (labels, roles, states, actions). `showSemanticsDebugger: true` on `MaterialApp` draws a visual overlay of this tree so you can audit it without a screen reader.

## Code Examples

### Before (Inaccessible)

```dart
MaterialApp(
  title: 'AccessBank',
  theme: theme,
  home: const HomeScreen(),
)
```

### After (Accessible)

```dart
MaterialApp(
  title: 'AccessBank',
  theme: theme,
  // Set to true to visualise the semantics tree.
  showSemanticsDebugger: true,
  home: const HomeScreen(),
)
```

## Key Takeaways

- Screen readers use the semantics tree, not pixels — you must keep that tree accurate.
- Double-tap activates; single tap focuses and announces. Know the difference.
- `showSemanticsDebugger: true` is the fastest way to spot missing or broken labels.
- DevTools' Accessibility tab lets you browse the full tree with all node properties.
- The AccessGuide inspector (built into this app) highlights labelled nodes in green and unlabelled interactive nodes in red.

## Deep Dive

- [Flutter Accessibility Overview](https://docs.flutter.dev/accessibility-and-localization/accessibility)
- [VoiceOver User Guide (Apple)](https://support.apple.com/guide/voiceover/welcome/mac)
- [TalkBack Guide (Android)](https://support.google.com/accessibility/android/answer/6283677)
- [Flutter DevTools Overview](https://docs.flutter.dev/tools/devtools/overview)

## What's Next

Chapter 1 takes you on a guided tour of AccessBank — first as a sighted user, then through a screen reader — so you can feel exactly what problems we are about to solve.
