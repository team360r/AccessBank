# Design: Interactive Tutorial Features
**Date:** 2026-04-05  
**Project:** AccessBank — Flutter Accessibility Tutorial (Docusaurus 3.9.2 / React 19 / MDX 3)

---

## Overview

Four features that transform the tutorial from static reading into an interactive, resumable learning experience:

1. **Interactive quiz** — clickable card options replacing plain bold text
2. **Batch reveal** — student answers all questions then reveals results in one go
3. **Chapter splitting** — long chapters broken into sub-pages with sidebar navigation
4. **Progress persistence** — localStorage-backed resume banner and sidebar checkmarks

---

## 1. Quiz Component

### Components

Two new React components in `docs-site/src/components/Quiz/`:

**`QuizQuestion`**
- Props: `question: string`, `options: string[]`, `correctIndex: number`, `explanation: string`, `questionIndex: number`
- Callbacks: `onAnswer(questionIndex: number, selectedIndex: number)`
- Additional props (passed from parent): `revealed: boolean`, `selectedIndex: number | null`
- Renders A/B/C/D as full-width clickable cards
- When `revealed` is false: selected card shows a blue highlight border, unselected cards are neutral
- When `revealed` is true:
  - Correct card → green border + background
  - Student's wrong selection (if any) → red border + background + "(your answer)" label
  - Unselected cards → greyed out
  - Explanation panel slides in below the options

**`Quiz`**
- Props: `chapterId: string`, `children: ReactNode`
- Owns all answer state: `answers: (number | null)[]`, `revealed: boolean`
- Passes `revealed`, `selectedIndex`, and `onAnswer` down to each `QuizQuestion` child via `React.Children.map`
- "Check Answers" button: disabled until all questions have a selection; clicking sets `revealed = true` and saves to localStorage via `useProgress`
- When `revealed`: renders score card above questions — `"X / N correct"` in green if all correct, amber if partial, red if all wrong
- Persists and restores state on mount via `useProgress(chapterId)`

### MDX Authoring

```mdx
import { Quiz, QuizQuestion } from '@site/src/components/Quiz';

<Quiz chapterId="ch03">
  <QuizQuestion
    question="What widget defines an independent focus traversal group?"
    options={[
      "FocusScope",
      "FocusTraversalGroup",
      "Focus",
      "FocusNode"
    ]}
    correctIndex={1}
    explanation="FocusTraversalGroup defines a region with its own traversal policy. Widgets inside are ordered relative to each other, independently of widgets outside."
  />
  <QuizQuestion
    question="Why is a focus trap important in modal dialogs?"
    options={[
      "To prevent accidental dialog dismissal",
      "To stop keyboard users interacting with content behind the dialog",
      "To improve animation performance",
      "To ensure the dialog is announced by the screen reader"
    ]}
    correctIndex={1}
    explanation="Without a focus trap, keyboard users can Tab past the dialog and trigger elements in the obscured background."
  />
</Quiz>
```

---

## 2. Chapter Splitting

### Which Chapters Split

| Chapter | Sections | Split into | Result |
|---------|----------|-----------|--------|
| Ch 0: Toolkit | 4 | No split | 2 pages (content + quiz) |
| Ch 1: Welcome | 4 | No split | 2 pages |
| Ch 2: Semantics | 6 | Sections 1–3 / Sections 4–6 | 3 pages + quiz = 4 pages |
| Ch 3: Navigation | 7 | Sections 1–3 / Sections 4–6 / Section 7 | 3 pages + quiz = 4 pages |
| Ch 4: Visual | 5 | Sections 1–3 / Sections 4–5 | 2 pages + quiz = 3 pages |
| Ch 5: Forms | 5 | Sections 1–3 / Sections 4–5 | 2 pages + quiz = 3 pages |
| Ch 6–9 | 3–4 | No split | 2 pages each (content + quiz) |

The "Check Your Understanding" section is **always its own final page** for every chapter, whether or not the rest is split.

### File Structure

```
docs-site/docs/chapters/
  00-toolkit/
    index.mdx                   sidebar_position: 1, title: "Your Accessibility Toolkit"
    00-toolkit-quiz.mdx         sidebar_position: 2, title: "Quiz"
  01-welcome/
    index.mdx                   title: "Welcome to AccessBank"
    01-welcome-quiz.mdx         title: "Quiz"
  02-semantics/
    index.mdx                   title: "Speaking the Language"
    02-semantics-2.mdx          title: "Speaking the Language — Part 2"
    02-semantics-quiz.mdx       title: "Quiz"
  03-navigation/
    index.mdx                   title: "Finding Your Way"
    03-navigation-2.mdx         title: "Finding Your Way — Part 2"
    03-navigation-3.mdx         title: "Finding Your Way — Part 3"
    03-navigation-quiz.mdx      title: "Quiz"
  04-visual/
    index.mdx                   title: "See Clearly"
    04-visual-2.mdx             title: "See Clearly — Part 2"
    04-visual-quiz.mdx          title: "Quiz"
  05-forms/
    index.mdx                   title: "Forms That Work for Everyone"
    05-forms-2.mdx              title: "Forms That Work — Part 2"
    05-forms-quiz.mdx           title: "Quiz"
  06-motion/
    index.mdx                   title: "Motion & Interaction"
    06-motion-quiz.mdx          title: "Quiz"
  07-live-regions/
    index.mdx                   title: "Dynamic Content & Live Regions"
    07-live-regions-quiz.mdx    title: "Quiz"
  08-testing/
    index.mdx                   title: "Testing Your Work"
    08-testing-quiz.mdx         title: "Quiz"
  09-polish/
    index.mdx                   title: "The Polished App"
    09-polish-quiz.mdx          title: "Quiz"
```

Docusaurus treats each folder as a sidebar category, collapsible, with sub-items listed. The existing `sidebars.ts` uses `autogenerated` — this continues to work with the folder structure.

Each `index.mdx` retains the current frontmatter `sidebar_position` and `title`. Split pages and quiz pages add their own frontmatter.

---

## 3. Progress Persistence

### localStorage Schema

Single key: `accessbank_progress`

```typescript
interface Progress {
  lastPage: string;                    // last visited path, e.g. "/chapters/03-navigation/03-navigation-2"
  visitedPages: string[];              // all visited paths (used for sidebar checkmarks)
  quizAnswers: {
    [chapterId: string]: {
      answers: (number | null)[];      // index of selected option per question, null if unanswered
      revealed: boolean;               // whether "Check Answers" was clicked
    }
  }
}
```

### `useProgress` Hook

Location: `docs-site/src/hooks/useProgress.ts`

```typescript
function useProgress(): {
  progress: Progress;
  markVisited: (path: string) => void;
  saveQuiz: (chapterId: string, answers: (number | null)[], revealed: boolean) => void;
  clearProgress: () => void;
}
```

- Reads from localStorage on first call, writes on every mutation
- Safe to call server-side (Docusaurus SSR) — guards all `localStorage` access with `typeof window !== 'undefined'`

### Swizzled Components

Three Docusaurus components are swizzled (wrapped, not ejected) to inject progress behaviour:

**`@theme/DocPage` wrapper** — calls `markVisited(location.pathname)` on every page render.

**`@theme/DocSidebarItem` wrapper** — reads `visitedPages` and appends a `✓` to the label of any sidebar item whose `href` is in the visited set. Uses a CSS class `sidebar-item--visited` for styling (green tint).

**`@theme/DocRootLayout` wrapper** — on mount, reads `lastPage`. If `lastPage` is set and differs from the current path, renders a dismissible banner:
> *"Welcome back! You were on: [page title]"* — **Continue →** button

Banner is dismissed on click (or on navigating away). Dismissed state stored in `sessionStorage` so it only shows once per browser session, not on every page change.

---

## 4. Component File Layout

```
docs-site/src/
  components/
    Quiz/
      index.ts              re-exports Quiz and QuizQuestion
      Quiz.tsx              wrapper with Check Answers button + score card
      QuizQuestion.tsx      individual question with card options
      Quiz.module.css       styles for cards, states, score card
  hooks/
    useProgress.ts          localStorage read/write hook
  theme/                    swizzled Docusaurus components
    DocPage/
      index.tsx             wraps original, adds markVisited side effect
    DocSidebarItem/
      index.tsx             wraps original, injects ✓ for visited pages
    DocRootLayout/
      index.tsx             wraps original, renders resume banner
```

---

## 5. Constraints & Non-Goals

- No server, no login — localStorage only
- No analytics or cross-device sync
- Progress is per-browser — clearing localStorage resets everything
- Chapter split filenames do not change existing URLs for ch 0–1, 6–9 (they become `index.mdx` in a folder, which Docusaurus resolves to the same path)
- The `Deep Dive` and `What's Next` sections remain on the last content page of each chapter (not the quiz page)
