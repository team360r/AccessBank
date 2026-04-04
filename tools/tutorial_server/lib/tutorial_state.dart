import 'dart:convert';
import 'dart:io';

/// Owns all tutorial progress state for the relay server.
/// This is the single source of truth — both IDE and phone read from it.
class TutorialState {
  int chapterIndex;
  int stepIndex;
  final Set<int> completedChapters;
  final Map<int, int> quizScores;
  bool showAccessible;
  bool showInspector;

  /// Which bottom-nav tab is allowed on the phone. null = all tabs free.
  int? allowedTabIndex;

  TutorialState({
    this.chapterIndex = 0,
    this.stepIndex = 0,
    Set<int>? completedChapters,
    Map<int, int>? quizScores,
    this.showAccessible = false,
    this.showInspector = false,
    this.allowedTabIndex,
  })  : completedChapters = completedChapters ?? {},
        quizScores = quizScores ?? {};

  Map<String, dynamic> toJson() => {
        'chapterIndex': chapterIndex,
        'stepIndex': stepIndex,
        'completed': completedChapters.toList()..sort(),
        'quizScores':
            quizScores.map((k, v) => MapEntry(k.toString(), v)),
        'showAccessible': showAccessible,
        'showInspector': showInspector,
        'allowedTabIndex': allowedTabIndex,
      };

  factory TutorialState.fromJson(Map<String, dynamic> json) => TutorialState(
        chapterIndex: (json['chapterIndex'] as num?)?.toInt() ?? 0,
        stepIndex: (json['stepIndex'] as num?)?.toInt() ?? 0,
        completedChapters: Set<int>.from(
            ((json['completed'] as List?) ?? []).cast<int>()),
        quizScores: ((json['quizScores'] as Map<String, dynamic>?) ?? {})
            .map((k, v) => MapEntry(int.parse(k), (v as num).toInt())),
        showAccessible: (json['showAccessible'] as bool?) ?? false,
        showInspector: (json['showInspector'] as bool?) ?? false,
        allowedTabIndex: (json['allowedTabIndex'] as num?)?.toInt(),
      );

  void save(String path) {
    File(path).writeAsStringSync(jsonEncode(toJson()));
  }

  static TutorialState load(String path) {
    final file = File(path);
    if (!file.existsSync()) return TutorialState();
    try {
      return TutorialState.fromJson(
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>);
    } catch (_) {
      return TutorialState();
    }
  }

  /// Advance one step. [totalSteps] is the step count of the CURRENT chapter.
  void nextStep(int totalSteps, int totalChapters) {
    if (stepIndex < totalSteps - 1) {
      stepIndex++;
    } else if (chapterIndex < totalChapters - 1) {
      completedChapters.add(chapterIndex);
      chapterIndex++;
      stepIndex = 0;
    }
    // At last step of last chapter: stay, no-op.
  }

  /// Go back one step. [stepsInPrevChapter] is only used when crossing a
  /// chapter boundary.
  void previousStep(int stepsInPrevChapter) {
    if (stepIndex > 0) {
      stepIndex--;
    } else if (chapterIndex > 0) {
      chapterIndex--;
      stepIndex = stepsInPrevChapter > 0 ? stepsInPrevChapter - 1 : 0;
    }
  }

  void goToChapter(int index) {
    chapterIndex = index;
    stepIndex = 0;
  }

  void completeChapter(int id) => completedChapters.add(id);

  void submitQuiz(int chapterId, int score) => quizScores[chapterId] = score;
}
