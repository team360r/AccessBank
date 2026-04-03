/// Data models for the AccessBank tutorial chapter system.
///
/// All classes are immutable with const constructors so they can be used as
/// compile-time constants in chapter definition files.
library;

// ---------------------------------------------------------------------------
// CodeDiff
// ---------------------------------------------------------------------------

/// Represents a before/after code snippet diff within a tutorial step.
class CodeDiff {
  const CodeDiff({
    required this.before,
    required this.after,
    required this.language,
    required this.filePath,
  });

  /// The code as it looked BEFORE the accessibility improvement.
  final String before;

  /// The code as it looks AFTER the accessibility improvement.
  final String after;

  /// Language identifier used for syntax highlighting (e.g. `'dart'`).
  final String language;

  /// Relative path of the file being changed (e.g. `'lib/screens/login.dart'`).
  final String filePath;
}

// ---------------------------------------------------------------------------
// QuizQuestion
// ---------------------------------------------------------------------------

/// A single multiple-choice question within a [Quiz].
class QuizQuestion {
  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  /// The question text shown to the learner.
  final String question;

  /// List of answer options. Must contain at least two items.
  final List<String> options;

  /// Zero-based index into [options] for the correct answer.
  final int correctIndex;

  /// Explanation shown after the learner submits their answer.
  final String explanation;
}

// ---------------------------------------------------------------------------
// Quiz
// ---------------------------------------------------------------------------

/// A quiz shown at the end of a [Chapter].
class Quiz {
  const Quiz({
    required this.title,
    required this.questions,
  });

  /// Display title for the quiz (e.g. `'Check Your Understanding'`).
  final String title;

  /// The questions in this quiz.
  final List<QuizQuestion> questions;
}

// ---------------------------------------------------------------------------
// TutorialStep
// ---------------------------------------------------------------------------

/// A single step within a [Chapter].
class TutorialStep {
  const TutorialStep({
    required this.id,
    required this.title,
    required this.explanation,
    this.codeDiff,
    this.whyItMatters,
    this.tryItPrompt,
    this.referenceLinks = const [],
  });

  /// 1-based step number within its chapter.
  final int id;

  /// Short title displayed in the step header.
  final String title;

  /// Markdown-ish prose explaining what the learner is doing and why.
  final String explanation;

  /// Optional before/after code comparison for this step.
  final CodeDiff? codeDiff;

  /// Optional callout text answering "why does this accessibility fix matter?"
  final String? whyItMatters;

  /// Optional prompt that encourages the learner to try something themselves.
  final String? tryItPrompt;

  /// URLs to WCAG guidelines, Flutter docs, or other reference material.
  final List<String> referenceLinks;
}

// ---------------------------------------------------------------------------
// Chapter
// ---------------------------------------------------------------------------

/// A chapter groups related [TutorialStep]s under a single theme.
class Chapter {
  const Chapter({
    required this.id,
    required this.title,
    required this.branchName,
    required this.description,
    required this.screenFocus,
    required this.estimatedMinutes,
    required this.vibe,
    required this.steps,
    this.quiz,
  });

  /// 0-based chapter index used for navigation and progress tracking.
  final int id;

  /// Short title shown in the chapter list (e.g. `'Semantic Labels'`).
  final String title;

  /// Git branch name where the chapter's code lives.
  final String branchName;

  /// One-paragraph description of what this chapter covers.
  final String description;

  /// Which banking screen is the focus of this chapter
  /// (e.g. `'Login Screen'`).
  final String screenFocus;

  /// Approximate time to complete this chapter, in minutes.
  final int estimatedMinutes;

  /// A short mood/tone descriptor for the chapter
  /// (e.g. `'exploratory'`, `'hands-on'`).
  final String vibe;

  /// The ordered list of steps in this chapter.
  final List<TutorialStep> steps;

  /// Optional quiz shown at the end of the chapter.
  final Quiz? quiz;
}
