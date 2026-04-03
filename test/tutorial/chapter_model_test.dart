import 'package:flutter_test/flutter_test.dart';
import 'package:accessible/tutorial/chapter_model.dart';
import 'package:accessible/tutorial/chapters/chapter_0.dart';
import 'package:accessible/tutorial/chapters/chapter_1.dart';
import 'package:accessible/tutorial/chapters/chapter_2.dart';
import 'package:accessible/tutorial/chapters/chapter_3.dart';
import 'package:accessible/tutorial/chapters/chapter_4.dart';
import 'package:accessible/tutorial/chapters/chapter_5.dart';
import 'package:accessible/tutorial/chapters/chapter_6.dart';
import 'package:accessible/tutorial/chapters/chapter_7.dart';
import 'package:accessible/tutorial/chapters/chapter_8.dart';
import 'package:accessible/tutorial/chapters/chapter_9.dart';

final List<Chapter> allChapters = [
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

void main() {
  group('Chapter construction', () {
    test('Chapter has required fields', () {
      const chapter = Chapter(
        id: 0,
        title: 'Test Chapter',
        branchName: 'test-branch',
        description: 'A description',
        screenFocus: 'Login',
        estimatedMinutes: 10,
        vibe: 'exploratory',
        steps: [],
      );
      expect(chapter.id, 0);
      expect(chapter.title, 'Test Chapter');
      expect(chapter.branchName, 'test-branch');
      expect(chapter.description, 'A description');
      expect(chapter.screenFocus, 'Login');
      expect(chapter.estimatedMinutes, 10);
      expect(chapter.vibe, 'exploratory');
      expect(chapter.steps, isEmpty);
      expect(chapter.quiz, isNull);
    });

    test('Chapter with quiz stores quiz', () {
      const quiz = Quiz(
        title: 'Test Quiz',
        questions: [],
      );
      const chapter = Chapter(
        id: 1,
        title: 'With Quiz',
        branchName: 'branch',
        description: 'desc',
        screenFocus: 'Overview',
        estimatedMinutes: 5,
        vibe: 'hands-on',
        steps: [],
        quiz: quiz,
      );
      expect(chapter.quiz, isNotNull);
      expect(chapter.quiz!.title, 'Test Quiz');
    });
  });

  group('TutorialStep construction', () {
    test('TutorialStep has required fields and defaults', () {
      const step = TutorialStep(
        id: 1,
        title: 'A Step',
        explanation: 'This is what to do',
      );
      expect(step.id, 1);
      expect(step.title, 'A Step');
      expect(step.explanation, 'This is what to do');
      expect(step.codeDiff, isNull);
      expect(step.whyItMatters, isNull);
      expect(step.tryItPrompt, isNull);
      expect(step.referenceLinks, isEmpty);
    });

    test('TutorialStep with all optional fields', () {
      const step = TutorialStep(
        id: 2,
        title: 'Full Step',
        explanation: 'explanation',
        whyItMatters: 'why',
        tryItPrompt: 'try this',
        referenceLinks: ['https://example.com'],
        codeDiff: CodeDiff(
          before: 'before code',
          after: 'after code',
          language: 'dart',
          filePath: 'lib/main.dart',
        ),
      );
      expect(step.whyItMatters, 'why');
      expect(step.tryItPrompt, 'try this');
      expect(step.referenceLinks, hasLength(1));
      expect(step.codeDiff, isNotNull);
      expect(step.codeDiff!.language, 'dart');
    });
  });

  group('Quiz construction', () {
    test('Quiz has title and questions', () {
      const quiz = Quiz(
        title: 'My Quiz',
        questions: [
          QuizQuestion(
            question: 'What is 1+1?',
            options: ['1', '2', '3', '4'],
            correctIndex: 1,
            explanation: '1+1 equals 2',
          ),
        ],
      );
      expect(quiz.title, 'My Quiz');
      expect(quiz.questions, hasLength(1));
    });
  });

  group('QuizQuestion construction', () {
    test('QuizQuestion has required fields', () {
      const q = QuizQuestion(
        question: 'Sample question?',
        options: ['A', 'B', 'C'],
        correctIndex: 0,
        explanation: 'A is correct',
      );
      expect(q.question, 'Sample question?');
      expect(q.options, hasLength(3));
      expect(q.correctIndex, 0);
      expect(q.explanation, 'A is correct');
    });

    test('QuizQuestion correctIndex is within options bounds', () {
      const q = QuizQuestion(
        question: 'Bounds check?',
        options: ['X', 'Y', 'Z'],
        correctIndex: 2,
        explanation: 'Z is correct',
      );
      expect(q.correctIndex, greaterThanOrEqualTo(0));
      expect(q.correctIndex, lessThan(q.options.length));
    });
  });

  group('CodeDiff construction', () {
    test('CodeDiff stores before/after code', () {
      const diff = CodeDiff(
        before: 'old code',
        after: 'new code',
        language: 'dart',
        filePath: 'lib/foo.dart',
      );
      expect(diff.before, 'old code');
      expect(diff.after, 'new code');
      expect(diff.language, 'dart');
      expect(diff.filePath, 'lib/foo.dart');
    });
  });

  group('All 10 chapters — data integrity', () {
    test('there are exactly 10 chapters', () {
      expect(allChapters, hasLength(10));
    });

    test('chapter ids are 0-9 in order', () {
      for (int i = 0; i < allChapters.length; i++) {
        expect(allChapters[i].id, i,
            reason: 'chapter at index $i should have id $i');
      }
    });

    test('every chapter has a non-empty title', () {
      for (final ch in allChapters) {
        expect(ch.title, isNotEmpty,
            reason: 'Chapter ${ch.id} should have a title');
      }
    });

    test('every chapter has a non-empty description', () {
      for (final ch in allChapters) {
        expect(ch.description, isNotEmpty,
            reason: 'Chapter ${ch.id} should have a description');
      }
    });

    test('every chapter has at least one step', () {
      for (final ch in allChapters) {
        expect(ch.steps, isNotEmpty,
            reason: 'Chapter ${ch.id} should have at least one step');
      }
    });

    test('every step has a non-empty title and explanation', () {
      for (final ch in allChapters) {
        for (final step in ch.steps) {
          expect(step.title, isNotEmpty,
              reason:
                  'Chapter ${ch.id}, step ${step.id} should have a title');
          expect(step.explanation, isNotEmpty,
              reason:
                  'Chapter ${ch.id}, step ${step.id} should have an explanation');
        }
      }
    });

    test('every chapter has a positive estimatedMinutes', () {
      for (final ch in allChapters) {
        expect(ch.estimatedMinutes, greaterThan(0),
            reason: 'Chapter ${ch.id} should have estimatedMinutes > 0');
      }
    });

    test('every chapter has a non-empty branchName', () {
      for (final ch in allChapters) {
        expect(ch.branchName, isNotEmpty,
            reason: 'Chapter ${ch.id} should have a branchName');
      }
    });

    test('quiz correctIndex is within bounds for all chapters with quizzes',
        () {
      for (final ch in allChapters) {
        final quiz = ch.quiz;
        if (quiz == null) continue;
        for (final q in quiz.questions) {
          expect(q.correctIndex, greaterThanOrEqualTo(0),
              reason:
                  'Chapter ${ch.id} quiz question "${q.question}" has negative correctIndex');
          expect(q.correctIndex, lessThan(q.options.length),
              reason:
                  'Chapter ${ch.id} quiz question "${q.question}" correctIndex (${q.correctIndex}) '
                  'is out of bounds (${q.options.length} options)');
        }
      }
    });

    test('quiz questions have at least 2 options', () {
      for (final ch in allChapters) {
        final quiz = ch.quiz;
        if (quiz == null) continue;
        for (final q in quiz.questions) {
          expect(q.options.length, greaterThanOrEqualTo(2),
              reason:
                  'Chapter ${ch.id} quiz question should have at least 2 options');
        }
      }
    });
  });
}
