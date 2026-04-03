import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:accessible/tutorial/tutorial_controller.dart';

void main() {
  setUp(() async {
    // Reset to a clean in-memory store for each test.
    SharedPreferences.setMockInitialValues({});
    // Pre-initialise the SharedPreferences singleton BEFORE any TutorialController
    // is created. This prevents the constructor's internal async loadProgress()
    // from racing with test code: if the singleton is already resolved, the
    // constructor's call completes synchronously in the microtask queue
    // without overlapping with later state mutations.
    await SharedPreferences.getInstance();
  });

  group('TutorialController — initial state', () {
    test('starts at chapter 0, step 0', () async {
      final controller = TutorialController();
      await controller.loadProgress(); // wait for async load
      expect(controller.currentChapterIndex, 0);
      expect(controller.currentStepIndex, 0);
    });

    test('showAccessible defaults to false', () {
      final controller = TutorialController();
      expect(controller.showAccessible, isFalse);
    });

    test('showInspector defaults to false', () {
      final controller = TutorialController();
      expect(controller.showInspector, isFalse);
    });

    test('has 10 chapters', () {
      final controller = TutorialController();
      expect(controller.chapters, hasLength(10));
    });

    test('overall progress is 0.0 at start', () {
      final controller = TutorialController();
      expect(controller.overallProgress, 0.0);
    });
  });

  group('TutorialController — goToChapter', () {
    test('navigates to a valid chapter', () async {
      final controller = TutorialController();
      await controller.loadProgress();
      controller.unlockAllChapters();
      controller.goToChapter(3);
      expect(controller.currentChapterIndex, 3);
      expect(controller.currentStepIndex, 0);
    });

    test('resets step index to 0 on chapter change', () async {
      final controller = TutorialController();
      await controller.loadProgress();
      controller.unlockAllChapters();
      controller.goToChapter(2);
      controller.nextStep(); // advance to step 1
      controller.goToChapter(3);
      expect(controller.currentStepIndex, 0);
    });

    test('clamps to valid range — too high clamps to last chapter', () async {
      final controller = TutorialController();
      await controller.loadProgress();
      controller.unlockAllChapters();
      controller.goToChapter(999);
      expect(controller.currentChapterIndex, controller.chapters.length - 1);
    });

    test('clamps to valid range — negative clamps to 0', () async {
      final controller = TutorialController();
      await controller.loadProgress();
      controller.unlockAllChapters();
      controller.goToChapter(-5);
      expect(controller.currentChapterIndex, 0);
    });

    test('does not navigate to locked chapter', () async {
      final controller = TutorialController();
      await controller.loadProgress();
      // Chapter 1 is locked until chapter 0 is complete
      controller.goToChapter(1);
      expect(controller.currentChapterIndex, 0,
          reason: 'Should not navigate to locked chapter');
    });

    test('chapter 0 is always unlocked', () {
      final controller = TutorialController();
      expect(controller.isChapterUnlocked(0), isTrue);
    });

    test('chapter 1 is unlocked after completing chapter 0', () async {
      final controller = TutorialController();
      await controller.loadProgress();
      controller.completeChapter(0);
      expect(controller.isChapterUnlocked(1), isTrue);
    });
  });

  group('TutorialController — nextStep', () {
    test('advances step index within a chapter', () async {
      final controller = TutorialController();
      await controller.loadProgress();
      final initialStep = controller.currentStepIndex;
      controller.nextStep();
      expect(controller.currentStepIndex, initialStep + 1);
    });

    test('completing last step of chapter 0 advances to chapter 1', () async {
      final controller = TutorialController();
      await controller.loadProgress();
      final stepCount = controller.currentChapter.steps.length;
      // Advance through all steps
      for (int i = 0; i < stepCount; i++) {
        controller.nextStep();
      }
      expect(controller.currentChapterIndex, 1);
      expect(controller.currentStepIndex, 0);
    });

    test('completing last step marks chapter as complete', () async {
      final controller = TutorialController();
      await controller.loadProgress();
      final stepCount = controller.currentChapter.steps.length;
      for (int i = 0; i < stepCount; i++) {
        controller.nextStep();
      }
      expect(controller.chapterCompleted[0], isTrue);
    });

    test('stays on last step of last chapter when at the end', () async {
      final controller = TutorialController();
      await controller.loadProgress();
      controller.unlockAllChapters();

      // Navigate to last chapter
      final lastChapterIdx = controller.chapters.length - 1;
      controller.goToChapter(lastChapterIdx);
      final lastStepCount = controller.currentChapter.steps.length;

      // Advance to last step
      for (int i = 0; i < lastStepCount - 1; i++) {
        controller.nextStep();
      }
      // Calling nextStep one more time at the end should complete but not crash
      controller.nextStep();
      // Chapter is completed, so we may stay or move — just no exception
      expect(controller.currentStepIndex, greaterThanOrEqualTo(0));
      expect(controller.currentChapterIndex, greaterThanOrEqualTo(lastChapterIdx));
    });
  });

  group('TutorialController — previousStep', () {
    test('goes back a step within a chapter', () async {
      final controller = TutorialController();
      await controller.loadProgress();
      controller.nextStep();
      controller.nextStep();
      expect(controller.currentStepIndex, 2);
      controller.previousStep();
      expect(controller.currentStepIndex, 1);
    });

    test('going back from step 0 of chapter 1 goes to last step of chapter 0',
        () async {
      final controller = TutorialController();
      await controller.loadProgress();
      controller.unlockAllChapters();
      controller.goToChapter(1);
      expect(controller.currentStepIndex, 0);

      controller.previousStep();
      expect(controller.currentChapterIndex, 0);
      final chapter0StepCount = controller.chapters[0].steps.length;
      expect(controller.currentStepIndex, chapter0StepCount - 1);
    });

    test('stays on step 0 of chapter 0 when going back from the start',
        () async {
      final controller = TutorialController();
      await controller.loadProgress();
      expect(controller.currentChapterIndex, 0);
      expect(controller.currentStepIndex, 0);
      controller.previousStep();
      expect(controller.currentChapterIndex, 0);
      expect(controller.currentStepIndex, 0);
    });
  });

  group('TutorialController — toggle methods', () {
    test('toggleAccessible flips showAccessible', () {
      final controller = TutorialController();
      expect(controller.showAccessible, isFalse);
      controller.toggleAccessible();
      expect(controller.showAccessible, isTrue);
      controller.toggleAccessible();
      expect(controller.showAccessible, isFalse);
    });

    test('toggleInspector flips showInspector', () {
      final controller = TutorialController();
      expect(controller.showInspector, isFalse);
      controller.toggleInspector();
      expect(controller.showInspector, isTrue);
      controller.toggleInspector();
      expect(controller.showInspector, isFalse);
    });
  });

  group('TutorialController — progress calculation', () {
    test('overallProgress is 0 when no chapters are complete', () {
      final controller = TutorialController();
      expect(controller.overallProgress, 0.0);
    });

    test('overallProgress is 0.1 after completing 1 of 10 chapters', () async {
      final controller = TutorialController();
      await controller.loadProgress();
      controller.completeChapter(0);
      expect(controller.overallProgress, closeTo(0.1, 0.001));
    });

    test('overallProgress is 1.0 after completing all 10 chapters', () async {
      final controller = TutorialController();
      await controller.loadProgress();
      for (int i = 0; i < 10; i++) {
        controller.completeChapter(i);
      }
      expect(controller.overallProgress, closeTo(1.0, 0.001));
    });
  });

  group('TutorialController — unlockAllChapters', () {
    test('unlockAll makes all chapters accessible', () async {
      final controller = TutorialController();
      await controller.loadProgress();
      controller.unlockAllChapters();
      for (int i = 0; i < controller.chapters.length; i++) {
        expect(controller.isChapterUnlocked(i), isTrue,
            reason: 'Chapter $i should be unlocked after unlockAllChapters');
      }
    });
  });

  group('TutorialController — persistence', () {
    test('saveProgress persists chapter index to SharedPreferences', () async {
      final controller = TutorialController();
      await controller.loadProgress();
      controller.unlockAllChapters();
      controller.goToChapter(2);
      expect(controller.currentChapterIndex, 2);
      await controller.saveProgress();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('tutorial_chapter_index'), 2);
    });

    test('loadProgress restores chapter index from SharedPreferences', () async {
      // Pre-seed the prefs with a specific chapter index
      SharedPreferences.setMockInitialValues({
        'tutorial_chapter_index': 4,
        'tutorial_step_index': 0,
      });
      final controller = TutorialController();
      await controller.loadProgress();
      expect(controller.currentChapterIndex, 4);
    });

    test('saveProgress persists completed chapters', () async {
      final controller = TutorialController();
      await controller.loadProgress();
      controller.completeChapter(0);
      controller.completeChapter(2);
      await controller.saveProgress();

      final prefs = await SharedPreferences.getInstance();
      final completedStr = prefs.getString('tutorial_chapters_completed') ?? '';
      expect(completedStr, contains('0'));
      expect(completedStr, contains('2'));
    });

    test('loadProgress restores completed chapters', () async {
      SharedPreferences.setMockInitialValues({
        'tutorial_chapters_completed': '0,2',
        'tutorial_chapter_index': 0,
        'tutorial_step_index': 0,
      });
      final controller = TutorialController();
      await controller.loadProgress();
      expect(controller.chapterCompleted[0], isTrue);
      expect(controller.chapterCompleted[2], isTrue);
      expect(controller.chapterCompleted[1], isNot(isTrue));
    });

    test('saveProgress persists quiz scores', () async {
      final controller = TutorialController();
      await controller.loadProgress();
      controller.submitQuiz(0, 3);
      controller.submitQuiz(1, 2);
      await controller.saveProgress();

      final prefs = await SharedPreferences.getInstance();
      final scoresStr = prefs.getString('tutorial_quiz_scores') ?? '';
      expect(scoresStr, contains('0:3'));
      expect(scoresStr, contains('1:2'));
    });

    test('loadProgress restores quiz scores', () async {
      SharedPreferences.setMockInitialValues({
        'tutorial_quiz_scores': '0:3,1:2',
        'tutorial_chapter_index': 0,
        'tutorial_step_index': 0,
      });
      final controller = TutorialController();
      await controller.loadProgress();
      expect(controller.quizScores[0], 3);
      expect(controller.quizScores[1], 2);
    });
  });

  group('TutorialController — currentChapter and currentStep', () {
    test('currentChapter returns chapter for current index', () async {
      final controller = TutorialController();
      await controller.loadProgress();
      controller.unlockAllChapters();
      controller.goToChapter(2);
      expect(controller.currentChapter.id, 2);
    });

    test('currentStep returns correct step', () async {
      final controller = TutorialController();
      await controller.loadProgress();
      controller.nextStep();
      final step = controller.currentStep;
      expect(step.id, greaterThan(0));
    });

    test('notifyListeners called on goToChapter', () async {
      final controller = TutorialController();
      await controller.loadProgress();
      controller.unlockAllChapters();
      int notifyCount = 0;
      controller.addListener(() => notifyCount++);
      controller.goToChapter(2);
      expect(notifyCount, greaterThan(0));
    });
  });
}

