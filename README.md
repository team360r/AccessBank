# AccessBank — Flutter Accessibility Tutorial

**Learn Flutter accessibility by building a real banking app.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## What is this?

AccessBank is a hands-on Flutter tutorial where you fix accessibility issues in a realistic banking app — one chapter at a time. You will learn how screen readers work, how Flutter's semantics tree is structured, and how to write and test accessible code across iOS and Android.

The tutorial is delivered through a **browser-based guide** (Docusaurus site) that runs alongside the app. Open the guide in your browser, edit code in your IDE, and see the results instantly on your connected device or simulator. A **before/after toggle** lets you compare the inaccessible original with each accessible improvement as you build it. No prior accessibility knowledge is needed — that's what we're here for!

---

## Prerequisites

- [ ] Flutter SDK 3.x+ — [Install Flutter](https://docs.flutter.dev/get-started/install)
- [ ] Node.js 18+ — [nodejs.org](https://nodejs.org) — for the tutorial guide
- [ ] VS Code — [Set up VS Code for Flutter](https://docs.flutter.dev/tools/vs-code) OR Android Studio — [Set up Android Studio](https://docs.flutter.dev/tools/android-studio)
- [ ] An iOS device/simulator or Android device/emulator
- [ ] Basic Flutter knowledge (built at least one app)
- [ ] No accessibility experience needed!

---

## Quick Start

```bash
git clone <repo-url>
cd accessible
./setup.sh
```

Then start the tutorial with two terminals:

**Terminal 1 — Tutorial Guide:**
```bash
cd docs-site && npm start
# Opens at http://localhost:3000
```

**Terminal 2 — Banking App:**
```bash
flutter run
# Launches on your connected device/simulator
```

Then open the project in your IDE (`code .` for VS Code, or open the `accessible/` folder in Android Studio).

---

## How This Tutorial Works

This tutorial uses a three-panel workflow inspired by Apple's SwiftUI tutorials:

| Panel | What's Here |
|-------|-------------|
| **Browser** | Tutorial guide at `localhost:3000` — step-by-step instructions, explanations, and code diffs |
| **IDE** | VS Code or Android Studio — where you edit the Flutter code |
| **Device** | Your connected iPhone/simulator or Android phone/emulator with hot reload |

### Chapter Branches

Each chapter has a corresponding Git branch containing the completed, accessible version of that chapter's code. Use them as reference material:

```bash
git checkout chapter-2-semantics
```

> **WARNING:** Chapter branches are read-only reference material. Do not commit to them. Create your own branch to experiment:
>
> ```bash
> git checkout -b my-accessibility-work
> ```

### Before/After Toggle

Every screen in AccessBank has two modes — the original inaccessible version and the accessible version you build chapter by chapter. The toggle in the app lets you switch between them with a screen reader running to hear the difference.

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

**"Tutorial site won't start"**
Check that Node.js 18+ is installed (`node --version`). Then run `cd docs-site && npm install` and try `npm start` again.

**"Hot reload not working"**
Make sure `flutter run` is active in a terminal and your device/simulator is connected. Save a file in your IDE to trigger hot reload.

**"Screen reader isn't reading anything"**
Add `showSemanticsDebugger: true` to your `MaterialApp` to check whether semantics nodes are being built at all.

**"App looks different from the chapter branch"**
Check which branch you are on (`git branch`) and run `flutter pub get` after switching branches.

---

## Contributing & License

This project is licensed under the [MIT License](LICENSE). Contributions are welcome — please open an issue first to discuss any significant changes.
