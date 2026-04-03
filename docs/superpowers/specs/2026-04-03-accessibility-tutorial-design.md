# AccessBank: Flutter Accessibility Tutorial — Design Spec

**Date:** 2026-04-03
**Status:** Draft

## Context

There's a gap in Flutter's learning ecosystem around accessibility. Most tutorials mention `Semantics` in passing but don't teach developers how to think about, implement, and test accessibility holistically. This project fills that gap with a hands-on, progressive tutorial wrapped in a real banking app.

**The problem:** Intermediate Flutter developers know how to build apps, but don't know how to make them accessible — and existing resources are scattered, dry, and hard to apply.

**The solution:** "AccessBank" — a Flutter banking app that IS its own tutorial. An in-app tutorial panel (AccessGuide) walks students through 10 chapters of accessibility concepts, with before/after comparisons, code diffs, interactive exercises, and quizzes. Git branches capture each chapter's completed state for reference.

## Target Audience

Intermediate developers with some Flutter experience. They've built a few apps but haven't explored accessibility. We briefly recap relevant Flutter concepts before introducing accessibility patterns. No need to explain widgets from scratch, but no assumptions about Semantics knowledge.

## Design Principles

- **Concept-driven, not compliance-driven** — teach WHY, not just WCAG criteria numbers
- **Progressive confidence** — each chapter builds on the last, never overwhelming
- **Fun and lighthearted** — banking is serious, learning doesn't have to be
- **Show, don't tell** — before/after toggles, live screen reader testing, visual overlays
- **Real-world patterns** — every example is something devs encounter in production apps

---

## App Architecture

### The Banking App — "AccessBank"

5 core screens, each chosen to teach specific accessibility concepts:

| Screen | Purpose | Key A11y Concepts |
|--------|---------|-------------------|
| **Login** | Email/password + biometric | Form labels, error announcements, focus management |
| **Account Overview** | Balance cards, quick actions | Semantic grouping, meaningful labels, contrast |
| **Transaction List** | Scrollable history with filters | List semantics, sort announcements, custom actions |
| **Transfer Money** | Multi-step form with validation | Form flow, live regions, stepper accessibility |
| **Settings** | Preferences, text size, theme toggle | User preferences, switch semantics, navigation |

**Tech Stack:**
- Flutter 3.x, Material 3
- Simple state management: `StatefulWidget` + `ChangeNotifier` (no Riverpod/Bloc — keep focus on a11y)
- No backend — mock data with realistic banking scenarios
- `shared_preferences` for tutorial progress persistence

### The Before/After Toggle Mechanism

Each screen accepts an `accessible` boolean parameter. When `false`, the screen renders without accessibility enhancements (missing labels, low contrast, no focus management). When `true`, the full accessible version is shown. This is implemented as conditional widget trees — real code for both states — not runtime hacks.

```dart
// Example pattern
class AccountOverviewScreen extends StatelessWidget {
  final bool accessible;
  const AccountOverviewScreen({this.accessible = true});

  @override
  Widget build(BuildContext context) {
    return accessible
        ? _buildAccessibleVersion(context)
        : _buildOriginalVersion(context);
  }
}
```

---

## The Tutorial Layer — "AccessGuide"

### Layout

- **Tablet/Desktop (width >= 800):** Side-by-side — tutorial panel on the left (40%), banking app on the right (60%)
- **Mobile (width < 800):** Bottom sheet (collapsible/expandable) overlaying the banking app
- **Floating chapter navigation FAB** always visible for quick chapter jumping

### Tutorial Panel Contents

1. **Chapter header** — title, progress bar, estimated time ("Chapter 3: Finding Your Way — Task 2 of 5 · ~15 min")
2. **Step-by-step tasks** — numbered instructions with:
   - Explanatory text (friendly, concise)
   - Code diffs (before/after with syntax highlighting)
   - "Why this matters" callout boxes — real-world impact in 1-2 sentences
   - "Try it yourself" interactive prompts (e.g., "Turn on VoiceOver and swipe through the cards")
3. **Before/After toggle** — switch between accessible and original versions of the current screen
4. **"Check your understanding"** quizzes — 2-3 multiple choice questions between chapters
5. **Accessibility inspector overlay** — toggle button that paints semantic bounds, labels, and issues on the banking UI

### Navigation

- Routes: `/guide/chapter-0` through `/guide/chapter-9`
- Soft-locked progression: uncompleted chapters show lock icon but can be overridden
- Progress stored in `shared_preferences`
- Chapter list view with completion status, estimated times, and brief descriptions

---

## Chapter Breakdown

### Chapter 0: "Your Accessibility Toolkit" `chapter-0-toolkit`
*Setting up and learning the tools before you start fixing things*

**Tasks:**
1. Enable TalkBack (Android) / VoiceOver (iOS) / Screen reader (Web)
2. Learn key gestures: swipe to navigate, double-tap to activate, explore by touch
3. Explore Flutter's Semantics Debugger (`showSemanticsDebugger: true`)
4. Tour the Accessibility Inspector in DevTools
5. Meet the built-in AccessGuide inspector overlay
6. Practice: navigate a simple demo screen with screen reader only

**Screen focus:** Demo/practice screen (simple layout for tool learning)
**Vibe:** "Now I know how to hear what my users hear"

---

### Chapter 1: "Welcome to AccessBank" `chapter-1-setup`
*Getting oriented — the app and why accessibility matters*

**Tasks:**
1. Tour the banking app (the "before" state — functional but inaccessible)
2. Try navigating with a screen reader — experience the pain points
3. Identify 5 accessibility problems across the app
4. Introduction to Flutter's Semantics tree — what it is and why it exists
5. Understand the `SemanticsNode` hierarchy using the inspector

**Screen focus:** All screens (overview tour)
**Vibe:** "Oh wow, this is what it's like for some users?"

---

### Chapter 2: "Speaking the Language" `chapter-2-semantics`
*Semantic labels, hints, and the Semantics widget*

**Tasks:**
1. Add `Semantics(label:)` to Account Overview balance cards
2. Use `hint` and `value` for interactive elements
3. Deep dive: the `Semantics` widget and its properties
4. `MergeSemantics` — combine related content into one announcement
5. `ExcludeSemantics` — hide decorative elements from screen readers
6. Before/after: hear the account cards with screen reader

**Screen focus:** Account Overview
**Vibe:** "That was easier than I thought!"

---

### Chapter 3: "Finding Your Way" `chapter-3-navigation`
*Focus management, traversal order, and keyboard navigation*

**Tasks:**
1. Fix the Login screen's tab/focus order
2. Implement `FocusTraversalGroup` and `FocusTraversalOrder`
3. Handle focus traps in modals and dialogs
4. Add skip navigation for repetitive content
5. Test with keyboard-only navigation (no touch/mouse)

**Screen focus:** Login + dialogs
**Vibe:** "I never thought about Tab order before"

---

### Chapter 4: "See Clearly" `chapter-4-visual`
*Color contrast, text scaling, and visual accommodations*

**Tasks:**
1. Audit and fix contrast ratios on Account Overview
2. Support `MediaQuery.textScaleFactorOf` — test at 200% text size
3. Ensure layouts don't break with large text
4. Dark mode accessibility considerations
5. Color-blind friendly design — don't rely on color alone (add icons/patterns)

**Screen focus:** Account Overview + theme system
**Vibe:** "My grandma could actually use this now"

---

### Chapter 5: "Forms That Work for Everyone" `chapter-5-forms`
*Accessible forms, validation, and error handling*

**Tasks:**
1. Add proper labels and descriptions to Login form fields
2. Announce validation errors with `SemanticsService.announce()`
3. Implement accessible error recovery — focus moves to first error
4. Build the Transfer Money form with live validation feedback
5. Auto-fill and input type semantics (`TextInputType`, `autofillHints`)

**Screen focus:** Login + Transfer Money
**Vibe:** "Forms are where accessibility really saves people"

---

### Chapter 6: "Motion & Interaction" `chapter-6-motion`
*Animations, gestures, and motor accessibility*

**Tasks:**
1. Respect `disableAnimations` / `MediaQuery.disableAnimationsOf`
2. Ensure touch targets are 48x48dp minimum
3. Add swipe action alternatives on Transaction List items
4. Implement long-press alternatives with timing accommodations
5. Test with motor accessibility settings enabled

**Screen focus:** Transaction List + system-wide
**Vibe:** "Not everyone can swipe precisely"

---

### Chapter 7: "Dynamic Content & Live Regions" `chapter-7-live`
*Announcing changes, loading states, and real-time updates*

**Tasks:**
1. Announce transaction filter results to screen readers
2. Implement live region for balance updates
3. Build accessible loading states with meaningful progress indicators
4. Make snackbars and toasts screen-reader friendly
5. Handle route change announcements

**Screen focus:** Transaction List + Account Overview
**Vibe:** "The app talks to you now, in a good way"

---

### Chapter 8: "Testing Your Work" `chapter-8-testing`
*Automated testing, manual testing, and CI integration*

**Tasks:**
1. Write widget tests with `SemanticsController`
2. Use accessibility-specific test matchers (`matchesSemantics`)
3. Build a manual testing checklist for TalkBack/VoiceOver
4. Use the AccessGuide inspector overlay for visual debugging
5. Write integration tests that verify accessibility
6. (Bonus) Set up CI checks for semantic label coverage

**Screen focus:** All screens (testing across the app)
**Vibe:** "I can prove this works, not just hope"

---

### Chapter 9: "The Polished App" `chapter-9-polish`
*Putting it all together — audit, fix, and celebrate*

**Tasks:**
1. Full accessibility audit of AccessBank
2. Platform-specific tweaks (iOS VoiceOver vs Android TalkBack vs Web)
3. Custom `SemanticsAction`s for complex interactions
4. Performance: keeping the Semantics tree lean
5. Resources for continued learning
6. Celebration! You've built an accessible banking app

**Screen focus:** All screens (final polish)
**Vibe:** "I actually understand accessibility now"

---

## Project Structure

```
accessible/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── app_colors.dart
│   ├── data/
│   │   ├── mock_accounts.dart
│   │   ├── mock_transactions.dart
│   │   └── models/
│   │       ├── account.dart
│   │       ├── transaction.dart
│   │       └── user.dart
│   ├── screens/
│   │   ├── login/
│   │   │   ├── login_screen.dart
│   │   │   └── widgets/
│   │   ├── account_overview/
│   │   │   ├── account_overview_screen.dart
│   │   │   └── widgets/
│   │   ├── transactions/
│   │   │   ├── transactions_screen.dart
│   │   │   └── widgets/
│   │   ├── transfer/
│   │   │   ├── transfer_screen.dart
│   │   │   └── widgets/
│   │   └── settings/
│   │       ├── settings_screen.dart
│   │       └── widgets/
│   ├── widgets/
│   │   ├── access_bank_scaffold.dart
│   │   └── (shared components)
│   └── tutorial/
│       ├── tutorial_overlay.dart
│       ├── tutorial_controller.dart
│       ├── chapter_model.dart
│       ├── widgets/
│       │   ├── step_card.dart
│       │   ├── code_diff_viewer.dart
│       │   ├── quiz_card.dart
│       │   ├── a11y_inspector_overlay.dart
│       │   ├── progress_bar.dart
│       │   ├── why_callout.dart
│       │   └── try_it_prompt.dart
│       └── chapters/
│           ├── chapter_0.dart
│           ├── chapter_1.dart
│           ├── chapter_2.dart
│           ├── chapter_3.dart
│           ├── chapter_4.dart
│           ├── chapter_5.dart
│           ├── chapter_6.dart
│           ├── chapter_7.dart
│           ├── chapter_8.dart
│           └── chapter_9.dart
├── test/
│   ├── accessibility/
│   │   ├── semantics_test.dart
│   │   ├── navigation_test.dart
│   │   └── contrast_test.dart
│   └── widget/
│       ├── login_screen_test.dart
│       └── (per-screen tests)
├── docs/
│   ├── README.md
│   └── chapters/
│       ├── 00-toolkit.md
│       ├── 01-welcome.md
│       ├── 02-semantics.md
│       ├── 03-navigation.md
│       ├── 04-visual.md
│       ├── 05-forms.md
│       ├── 06-motion.md
│       ├── 07-live-regions.md
│       ├── 08-testing.md
│       └── 09-polish.md
├── assets/
│   └── images/
│       └── (banking app assets)
└── pubspec.yaml
```

## Git Branch Strategy

- `main` — The fully completed, accessible app (Chapter 9 final state)
- `starter` — The initial banking app before any accessibility work
- `chapter-0-toolkit` through `chapter-9-polish` — Each branch = completed state after that chapter
- Branches are linear: each chapter branch is based on the previous chapter's branch
- Students clone, checkout `starter`, work through tutorial, check against chapter branches

```
starter → chapter-0-toolkit → chapter-1-setup → chapter-2-semantics → ... → chapter-9-polish = main
```

### Branch Protection

All chapter branches and `starter` are reference material — they must not be accidentally overwritten or deleted. Once the repo is pushed to GitHub:

- **Protected branches:** `main`, `starter`, and all `chapter-*` branches
- **Rules (via `gh api` / branch protection rulesets):**
  - Prevent force pushes on all protected branches
  - Prevent branch deletion
  - Require pull request before merging (prevents direct pushes by collaborators)
- **Local safety:** A git pre-push hook warns if attempting to push to a chapter branch:
  ```bash
  # .githooks/pre-push — installed during project setup
  # Warns before pushing to protected tutorial branches
  ```
- **README prominently warns:** "Chapter branches are read-only reference material. Create your own branch to experiment."

---

## README.md Design

The root `README.md` is the first thing students see — it must be welcoming, clear, and get them running the app in under 5 minutes. Structure:

### README Sections

1. **Hero banner** — Project name, one-line tagline ("Learn Flutter accessibility by building a banking app"), badges (Flutter version, license)

2. **What is this?** — 3-4 sentences: what they'll learn, what they'll build, who it's for. Link to a screenshot/GIF of the app.

3. **Prerequisites** — Checklist format:
   - Flutter SDK (version) — link to [flutter.dev/get-started](https://flutter.dev/docs/get-started/install)
   - A code editor (VS Code recommended) — link to Flutter VS Code setup
   - An iOS simulator, Android emulator, or Chrome
   - Basic Flutter knowledge (built at least one app)
   - No accessibility experience needed!

4. **Quick Start** — Numbered steps, copy-pasteable commands:
   ```
   1. Clone the repo
   2. cd accessible
   3. flutter pub get
   4. flutter run
   5. Open the tutorial panel (tap the guide icon)
   ```

5. **How This Tutorial Works** — Brief explanation of:
   - The in-app tutorial panel (AccessGuide)
   - Chapter branches for reference (`git checkout chapter-2-semantics`)
   - Before/after toggle
   - Warning: chapter branches are read-only reference — branch off them to experiment

6. **Chapter Overview** — Table with chapter number, title, branch name, concepts covered, and estimated time. Each chapter title links to the companion markdown doc in `docs/chapters/`.

7. **Useful Resources** — Curated links section:
   - **Flutter Accessibility Docs:**
     - [Flutter Accessibility Overview](https://docs.flutter.dev/accessibility-and-localization/accessibility)
     - [Semantics class](https://api.flutter.dev/flutter/widgets/Semantics-class.html)
     - [SemanticsService](https://api.flutter.dev/flutter/semantics/SemanticsService-class.html)
     - [Flutter Accessibility Testing](https://docs.flutter.dev/testing/accessibility)
   - **WCAG & Standards:**
     - [WCAG 2.1 Quick Reference](https://www.w3.org/WAI/WCAG21/quickref/)
     - [WCAG 2.2 What's New](https://www.w3.org/WAI/standards-guidelines/wcag/new-in-22/)
     - [Mobile Accessibility Guidelines (W3C)](https://www.w3.org/WAI/standards-guidelines/mobile/)
   - **Screen Reader Guides:**
     - [VoiceOver User Guide (Apple)](https://support.apple.com/guide/voiceover/)
     - [TalkBack Guide (Android)](https://support.google.com/accessibility/android/answer/6283677)
   - **Tools:**
     - [Flutter DevTools Accessibility Inspector](https://docs.flutter.dev/tools/devtools/inspector)
     - [Contrast Checker (WebAIM)](https://webaim.org/resources/contrastchecker/)

8. **Troubleshooting** — Common issues:
   - "Screen reader isn't reading anything" — check Semantics debugger
   - "App looks different from the chapter branch" — make sure you're on the right branch
   - "Tutorial progress reset" — shared_preferences storage note

9. **Contributing & License**

### README Tone
- Friendly, zero-jargon opening
- Every command is copy-pasteable
- Visual: use a chapter roadmap diagram or table
- Encouraging: "No prior accessibility knowledge needed — that's what we're here for!"

---

## Reference Links in Tutorial Content

Each chapter (both in-app and markdown docs) includes contextual links to official documentation:

| Chapter | Key Reference Links |
|---------|-------------------|
| Ch.0 Toolkit | Flutter Accessibility overview, VoiceOver guide, TalkBack guide, DevTools inspector docs |
| Ch.2 Semantics | `Semantics` class API, `MergeSemantics` API, `ExcludeSemantics` API |
| Ch.3 Navigation | `FocusTraversalGroup` API, `FocusNode` API, WCAG 2.4 (Navigable) |
| Ch.4 Visual | WCAG 1.4.3 (Contrast), WCAG 1.4.4 (Resize Text), `MediaQuery` API |
| Ch.5 Forms | `SemanticsService.announce` API, WCAG 3.3 (Input Assistance), `TextFormField` API |
| Ch.6 Motion | WCAG 2.3 (Seizures/Motion), `MediaQuery.disableAnimationsOf` API |
| Ch.7 Live | `SemanticsFlag.isLiveRegion` API, WCAG 4.1.3 (Status Messages) |
| Ch.8 Testing | Flutter testing docs, `matchesSemantics` API, accessibility test guide |
| Ch.9 Polish | Platform-specific a11y docs (iOS, Android, Web) |

Links appear as:
- **"Learn more"** footnotes after key concepts
- **"Official docs"** sidebar links in the tutorial panel
- **"Deep dive"** optional reading sections in the markdown companions

## Tone & Writing Style

- **Fun, not frivolous** — banking is the domain, but the tutorial voice is warm and encouraging
- **"Vibe" per chapter** — each chapter has an emotional beat (surprise, pride, empowerment)
- **Real-world anchoring** — "Imagine a user with low vision checking their bank balance..."
- **No jargon without explanation** — every technical term is introduced before it's used
- **Celebrate progress** — "You just made this app usable for millions more people!"
- **Inclusive language** — "users who rely on screen readers" not "blind users"

## Verification Plan

1. **Each screen** renders correctly in both accessible and original modes
2. **Screen reader testing** on iOS (VoiceOver), Android (TalkBack), and Chrome (screen reader)
3. **Tutorial flow** — complete all 10 chapters end-to-end
4. **Before/after toggle** works on every screen without crashes
5. **Quiz system** stores and displays results correctly
6. **Progress persistence** survives app restart
7. **Responsive layout** — tutorial panel works on mobile, tablet, and desktop
8. **Git branches** — each chapter branch builds and runs without errors
9. **Widget tests** pass for accessibility matchers (Chapter 8 content)
10. **Docs** — markdown companion docs are accurate and match in-app content
11. **README** — follow Quick Start steps on a clean machine/fresh clone to verify they work
12. **Reference links** — all external URLs in README and chapter docs resolve (no 404s)
13. **Branch protection** — verify force push and deletion are blocked on protected branches
