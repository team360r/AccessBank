import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chapter_model.dart';
import 'chapters/chapter_0.dart';
import 'chapters/chapter_1.dart';
import 'chapters/chapter_2.dart';
import 'chapters/chapter_3.dart';
import 'chapters/chapter_4.dart';
import 'chapters/chapter_5.dart';
import 'chapters/chapter_6.dart';
import 'chapters/chapter_7.dart';
import 'chapters/chapter_8.dart';
import 'chapters/chapter_9.dart';

/// Manages tutorial state: which chapter/step is active, the before/after
/// toggle, the accessibility inspector toggle, and persisted progress.
///
/// Consumers should listen via [ListenableBuilder] or [ChangeNotifierProvider].
class TutorialController extends ChangeNotifier {
  TutorialController() {
    loadProgress();
  }

  // ---------------------------------------------------------------------------
  // Chapter registry
  // ---------------------------------------------------------------------------

  /// The full ordered list of chapters.
  ///
  /// All 10 chapters of the AccessBank accessibility tutorial, in order.
  List<Chapter> chapters = [
    chapter0,
    chapter1,
    chapter2,
    chapter3,
    chapter4,
    chapter5,
    chapter6,
    chapter7,
    chapter8,
    chapter9,
  ];

  // ---------------------------------------------------------------------------
  // Navigation state
  // ---------------------------------------------------------------------------

  int _currentChapterIndex = 0;
  int _currentStepIndex = 0;

  int get currentChapterIndex => _currentChapterIndex;
  int get currentStepIndex => _currentStepIndex;

  // ---------------------------------------------------------------------------
  // UI toggle state
  // ---------------------------------------------------------------------------

  bool _showAccessible = false;
  bool _showInspector = false;

  /// Whether the "after" (accessible) version of the banking screen is shown.
  bool get showAccessible => _showAccessible;

  /// Whether the accessibility inspector overlay is active.
  bool get showInspector => _showInspector;

  // ---------------------------------------------------------------------------
  // Progress state
  // ---------------------------------------------------------------------------

  final Map<int, bool> chapterCompleted = {};
  final Map<int, int> quizScores = {};

  // ---------------------------------------------------------------------------
  // Computed getters
  // ---------------------------------------------------------------------------

  /// The chapter currently being viewed.
  ///
  /// Returns a default empty chapter if [chapters] has not been loaded yet.
  Chapter get currentChapter {
    if (chapters.isEmpty) {
      return const Chapter(
        id: 0,
        title: '',
        branchName: '',
        description: '',
        screenFocus: '',
        estimatedMinutes: 0,
        vibe: '',
        steps: [],
      );
    }
    final idx = _currentChapterIndex.clamp(0, chapters.length - 1);
    return chapters[idx];
  }

  /// The step currently being viewed within [currentChapter].
  ///
  /// Returns a default empty step when the chapter has no steps yet.
  TutorialStep get currentStep {
    final ch = currentChapter;
    if (ch.steps.isEmpty) {
      return const TutorialStep(
        id: 0,
        title: '',
        explanation: '',
      );
    }
    final idx = _currentStepIndex.clamp(0, ch.steps.length - 1);
    return ch.steps[idx];
  }

  /// Progress from 0.0 to 1.0 across all chapters.
  ///
  /// Counts each completed chapter as a full unit.
  double get overallProgress {
    if (chapters.isEmpty) return 0.0;
    final done = chapterCompleted.values.where((v) => v).length;
    return done / chapters.length;
  }

  /// Whether the chapter at [index] can be navigated to.
  ///
  /// Chapter 0 is always unlocked.  All others require the preceding chapter
  /// to be marked complete (or an explicit override via [unlockAll]).
  bool isChapterUnlocked(int index) {
    if (index == 0) return true;
    if (_unlockAll) return true;
    return chapterCompleted[index - 1] == true;
  }

  bool _unlockAll = false;

  /// Temporarily unlocks all chapters (useful for demo / testing).
  void unlockAllChapters() {
    _unlockAll = true;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Navigation methods
  // ---------------------------------------------------------------------------

  /// Jump directly to [chapterIndex], resetting the step to 0.
  void goToChapter(int chapterIndex) {
    if (chapters.isEmpty) return;
    final clamped = chapterIndex.clamp(0, chapters.length - 1);
    if (!isChapterUnlocked(clamped)) return;
    _currentChapterIndex = clamped;
    _currentStepIndex = 0;
    notifyListeners();
  }

  /// Advance to the next step in the current chapter.
  ///
  /// When stepping past the last step the chapter is automatically completed
  /// and the controller advances to the first step of the next chapter (if
  /// one exists).
  void nextStep() {
    final ch = currentChapter;
    if (ch.steps.isEmpty) return;

    if (_currentStepIndex < ch.steps.length - 1) {
      _currentStepIndex++;
      notifyListeners();
      return;
    }

    // Past the last step — complete this chapter.
    completeChapter(ch.id);

    // Advance to next chapter if available.
    if (_currentChapterIndex < chapters.length - 1) {
      _currentChapterIndex++;
      _currentStepIndex = 0;
      notifyListeners();
    }
    // Otherwise stay on the last step of the last chapter (already notified
    // by completeChapter).
  }

  /// Go back to the previous step.
  ///
  /// When stepping before step 0, navigates to the last step of the previous
  /// chapter (if one exists).
  void previousStep() {
    if (_currentStepIndex > 0) {
      _currentStepIndex--;
      notifyListeners();
      return;
    }

    // Already on step 0 — try to go to previous chapter's last step.
    if (_currentChapterIndex > 0) {
      _currentChapterIndex--;
      final prevCh = currentChapter;
      _currentStepIndex =
          prevCh.steps.isEmpty ? 0 : prevCh.steps.length - 1;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Toggle methods
  // ---------------------------------------------------------------------------

  /// Toggles between the inaccessible ("before") and accessible ("after")
  /// banking screen.
  void toggleAccessible() {
    _showAccessible = !_showAccessible;
    notifyListeners();
  }

  /// Shows or hides the accessibility inspector overlay.
  void toggleInspector() {
    _showInspector = !_showInspector;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Progress methods
  // ---------------------------------------------------------------------------

  /// Marks chapter [chapterId] as complete and persists progress.
  void completeChapter(int chapterId) {
    chapterCompleted[chapterId] = true;
    notifyListeners();
    saveProgress();
  }

  /// Records a quiz score for [chapterId] and persists progress.
  void submitQuiz(int chapterId, int score) {
    quizScores[chapterId] = score;
    notifyListeners();
    saveProgress();
  }

  // ---------------------------------------------------------------------------
  // Persistence
  // ---------------------------------------------------------------------------

  static const _kCompletedKey = 'tutorial_chapters_completed';
  static const _kScoresKey = 'tutorial_quiz_scores';
  static const _kChapterIndexKey = 'tutorial_chapter_index';
  static const _kStepIndexKey = 'tutorial_step_index';

  /// Loads progress from [SharedPreferences].
  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();

    // Restore navigation position.
    _currentChapterIndex = prefs.getInt(_kChapterIndexKey) ?? 0;
    _currentStepIndex = prefs.getInt(_kStepIndexKey) ?? 0;

    // Restore completed chapters — stored as comma-separated ints.
    final completedRaw = prefs.getString(_kCompletedKey) ?? '';
    if (completedRaw.isNotEmpty) {
      for (final part in completedRaw.split(',')) {
        final id = int.tryParse(part.trim());
        if (id != null) chapterCompleted[id] = true;
      }
    }

    // Restore quiz scores — stored as "chapterId:score,chapterId:score".
    final scoresRaw = prefs.getString(_kScoresKey) ?? '';
    if (scoresRaw.isNotEmpty) {
      for (final pair in scoresRaw.split(',')) {
        final parts = pair.split(':');
        if (parts.length == 2) {
          final id = int.tryParse(parts[0].trim());
          final score = int.tryParse(parts[1].trim());
          if (id != null && score != null) quizScores[id] = score;
        }
      }
    }

    notifyListeners();
  }

  /// Persists current progress to [SharedPreferences].
  Future<void> saveProgress() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_kChapterIndexKey, _currentChapterIndex);
    await prefs.setInt(_kStepIndexKey, _currentStepIndex);

    final completedStr =
        chapterCompleted.entries.where((e) => e.value).map((e) => '${e.key}').join(',');
    await prefs.setString(_kCompletedKey, completedStr);

    final scoresStr =
        quizScores.entries.map((e) => '${e.key}:${e.value}').join(',');
    await prefs.setString(_kScoresKey, scoresStr);
  }
}
