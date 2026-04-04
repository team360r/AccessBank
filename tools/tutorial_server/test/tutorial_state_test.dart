import 'dart:io';
import 'package:test/test.dart';
import 'package:tutorial_server/tutorial_state.dart';

void main() {
  group('TutorialState navigation', () {
    test('starts at chapter 0 step 0', () {
      final state = TutorialState();
      expect(state.chapterIndex, 0);
      expect(state.stepIndex, 0);
    });

    test('nextStep increments stepIndex within chapter', () {
      final state = TutorialState();
      final stepCounts = [6, 5, 6, 5, 5, 5, 5, 5, 6, 6];
      state.nextStep(stepCounts[0], stepCounts.length);
      expect(state.stepIndex, 1);
      expect(state.chapterIndex, 0);
    });

    test('nextStep at last step of chapter advances to next chapter', () {
      final state = TutorialState(chapterIndex: 0, stepIndex: 5);
      final stepCounts = [6, 5, 6, 5, 5, 5, 5, 5, 6, 6];
      state.nextStep(stepCounts[0], stepCounts.length);
      expect(state.chapterIndex, 1);
      expect(state.stepIndex, 0);
      expect(state.completedChapters.contains(0), isTrue);
    });

    test('nextStep at very last step of last chapter does not advance', () {
      final state = TutorialState(chapterIndex: 9, stepIndex: 5);
      final stepCounts = [6, 5, 6, 5, 5, 5, 5, 5, 6, 6];
      state.nextStep(stepCounts[9], stepCounts.length);
      expect(state.chapterIndex, 9);
      expect(state.stepIndex, 5);
    });

    test('previousStep decrements stepIndex', () {
      final state = TutorialState(stepIndex: 3);
      state.previousStep(6);
      expect(state.stepIndex, 2);
    });

    test('previousStep at step 0 goes to last step of previous chapter', () {
      final state = TutorialState(chapterIndex: 2, stepIndex: 0);
      state.previousStep(5); // 5 = step count of chapter 1
      expect(state.chapterIndex, 1);
      expect(state.stepIndex, 4); // last step index of chapter 1 (5 steps → index 4)
    });

    test('goToChapter resets stepIndex', () {
      final state = TutorialState(chapterIndex: 3, stepIndex: 4);
      state.goToChapter(7);
      expect(state.chapterIndex, 7);
      expect(state.stepIndex, 0);
    });
  });

  group('TutorialState serialization', () {
    test('toJson/fromJson round-trips all fields', () {
      final state = TutorialState(
        chapterIndex: 3,
        stepIndex: 2,
        completedChapters: {0, 1, 2},
        quizScores: {0: 3, 1: 2},
        showAccessible: true,
        showInspector: false,
        allowedTabIndex: 1,
      );
      final json = state.toJson();
      final restored = TutorialState.fromJson(json);
      expect(restored.chapterIndex, 3);
      expect(restored.stepIndex, 2);
      expect(restored.completedChapters, {0, 1, 2});
      expect(restored.quizScores[0], 3);
      expect(restored.showAccessible, isTrue);
      expect(restored.allowedTabIndex, 1);
    });
  });

  group('TutorialState persistence', () {
    late Directory tempDir;

    setUp(() => tempDir = Directory.systemTemp.createTempSync('accessguide_test_'));
    tearDown(() => tempDir.deleteSync(recursive: true));

    test('save and load round-trips state', () {
      final path = '${tempDir.path}/state.json';
      final state = TutorialState(chapterIndex: 4, stepIndex: 1);
      state.save(path);
      final loaded = TutorialState.load(path);
      expect(loaded.chapterIndex, 4);
      expect(loaded.stepIndex, 1);
    });

    test('load returns default state when file does not exist', () {
      final state = TutorialState.load('${tempDir.path}/nonexistent.json');
      expect(state.chapterIndex, 0);
      expect(state.stepIndex, 0);
    });
  });
}
