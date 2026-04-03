# AccessBank — Flutter Accessibility Tutorial

**Learn Flutter accessibility by building a real banking app.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## What is this?

AccessBank is a hands-on Flutter tutorial where you fix accessibility issues in a realistic banking app — one chapter at a time. You will learn how screen readers work, how Flutter's semantics tree is structured, and how to write and test accessible code across iOS, Android, and the web.

The tutorial is delivered through **AccessGuide**, an in-app panel that guides you through 10 progressive chapters with explanations, before/after code diffs, and interactive exercises. A **before/after toggle** lets you compare the inaccessible original with each accessible improvement as you build it. No prior accessibility knowledge is needed — that's what we're here for!

---

## Prerequisites

- [ ] Flutter SDK 3.x+ — [Install Flutter](https://docs.flutter.dev/get-started/install)
- [ ] A code editor (VS Code recommended) — [Set up VS Code for Flutter](https://docs.flutter.dev/tools/vs-code)
- [ ] An iOS simulator, Android emulator, or Chrome
- [ ] Basic Flutter knowledge (built at least one app)
- [ ] No accessibility experience needed!

---

## Quick Start

```bash
# 1. Clone the repo
git clone <repo-url>

# 2. Enter the project directory
cd accessible

# 3. Install dependencies
flutter pub get

# 4. Run the app
flutter run

# 5. Tap the guide icon (📖) to open the tutorial panel
```

Also run this once to enable branch protection hooks:

```bash
git config core.hooksPath .githooks
```

---

## How This Tutorial Works

### The In-App Tutorial Panel (AccessGuide)

The tutorial lives inside the app itself. On desktop it opens as a side panel; on mobile it opens as a bottom sheet. Tap the guide icon (📖) in the top-right corner of any screen to open it.

Each chapter walks you through concepts with written explanations, runnable code diffs, and a short quiz to confirm your understanding.

### Chapter Branches

Each chapter has a corresponding Git branch that contains the completed, accessible version of that chapter's code. Use them as reference material:

```bash
git checkout chapter-2-semantics
```

> **WARNING:** Chapter branches are read-only reference material. Create your own branch to experiment.

```bash
git checkout -b my-accessibility-work
```

### Before/After Toggle

Every screen in AccessBank has two modes — the original inaccessible version and the accessible version you build chapter by chapter. The toggle at the top of the tutorial panel switches between them so you can compare with a screen reader running.

---

## Chapter Overview

| # | Chapter | Branch | Concepts | Time |
|---|---------|--------|----------|------|
| 0 | Your Accessibility Toolkit | `chapter-0-toolkit` | Screen readers, DevTools, inspector | ~15 min |
| 1 | Welcome to AccessBank | `chapter-1-setup` | App tour, semantics tree, identifying issues | ~20 min |
| 2 | Speaking the Language | `chapter-2-semantics` | Semantics, MergeSemantics, ExcludeSemantics | ~25 min |
| 3 | Finding Your Way | `chapter-3-navigation` | Focus traversal, keyboard nav, focus traps | ~20 min |
| 4 | See Clearly | `chapter-4-visual` | Contrast, text scaling, dark mode, color-blind | ~20 min |
| 5 | Forms That Work for Everyone | `chapter-5-forms` | Labels, error announce, validation, autofill | ~25 min |
| 6 | Motion & Interaction | `chapter-6-motion` | Reduce motion, touch targets, swipe alt | ~20 min |
| 7 | Dynamic Content & Live Regions | `chapter-7-live` | Live regions, announcements, loading | ~20 min |
| 8 | Testing Your Work | `chapter-8-testing` | Widget tests, semantics matchers, CI | ~25 min |
| 9 | The Polished App | `chapter-9-polish` | Full audit, platform tweaks, celebration | ~25 min |

---

## Useful Resources

### Flutter Accessibility

- [Accessibility Overview](https://docs.flutter.dev/accessibility-and-localization/accessibility)
- [Semantics class](https://api.flutter.dev/flutter/widgets/Semantics-class.html)
- [SemanticsService](https://api.flutter.dev/flutter/semantics/SemanticsService-class.html)
- [Accessibility Testing](https://docs.flutter.dev/testing/accessibility)

### WCAG & Standards

- [WCAG 2.1 Quick Reference](https://www.w3.org/WAI/WCAG21/quickref/)
- [What's New in WCAG 2.2](https://www.w3.org/WAI/standards-guidelines/wcag/new-in-22/)
- [Mobile Accessibility (W3C)](https://www.w3.org/WAI/standards-guidelines/mobile/)

### Screen Reader Guides

- [VoiceOver User Guide (Apple)](https://support.apple.com/guide/voiceover/welcome/mac)
- [TalkBack Guide (Android)](https://support.google.com/accessibility/android/answer/6283677)

### Tools

- [Flutter DevTools](https://docs.flutter.dev/tools/devtools/overview)
- [Contrast Checker (WebAIM)](https://webaim.org/resources/contrastchecker/)

---

## Troubleshooting

**"Screen reader isn't reading anything"**
Add `showSemanticsDebugger: true` to your `MaterialApp` to check whether semantics nodes are being built at all.

**"App looks different from the chapter branch"**
Make sure you have checked out the correct branch (`git branch` to confirm) and run `flutter pub get` after switching.

**"Tutorial progress reset"**
Progress is stored in `shared_preferences`. Clearing app data (or reinstalling the app) resets it — this is expected behaviour.

**"Tests failing"**
Run `flutter clean` then `flutter pub get` and try again. If tests still fail, check that you are on the right branch.

---

## Contributing & License

This project is licensed under the [MIT License](LICENSE). Contributions are welcome — please open an issue first to discuss any significant changes.
