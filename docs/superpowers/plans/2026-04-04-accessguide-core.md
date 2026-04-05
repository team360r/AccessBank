# AccessGuide Core Infrastructure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Serialize chapter data to JSON, build the Dart WebSocket relay server, and strip the Flutter app down to a status bar + WebSocket bridge that the IDE panel controls.

**Architecture:** A standalone Dart CLI server (`tools/tutorial_server/`) owns tutorial state and relays commands between IDE and phone over WebSocket. The Flutter app connects to it on startup, responds to navigation/toggle commands, and shows only a compact status bar. Chapter content is generated once to `tools/shared/tutorial_content.json` via a Dart script.

**Tech Stack:** Dart (server + content generator), Flutter + `web_socket_channel` (app bridge)

**Deliverable:** At the end of this plan you can run `dart tools/generate_content.dart` to produce the JSON, start the server with `dart run tools/tutorial_server/bin/server.dart`, connect two terminal WebSocket clients, and observe the phone app respond to commands — with no IDE extension yet.

**Depends on:** Nothing. This is the foundation.
**Required before:** Sub-Plan 2 (VS Code extension + HTML panel)

---

## File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `lib/tutorial/chapter_model.dart` | Modify | Add `toJson()` to all 4 model classes |
| `tools/generate_content.dart` | Create | CLI script: imports chapter data, writes `tools/shared/tutorial_content.json` |
| `tools/shared/tutorial_content.json` | Generate | Committed JSON — extensions bundle this |
| `test/tutorial/chapter_model_test.dart` | Modify | Add serialization round-trip tests |
| `tools/tutorial_server/pubspec.yaml` | Create | Standalone Dart package (no Flutter) |
| `tools/tutorial_server/bin/server.dart` | Create | Entry point: HTTP → WebSocket, client registry |
| `tools/tutorial_server/lib/tutorial_state.dart` | Create | State machine: chapter/step nav, progress, persistence |
| `tools/tutorial_server/lib/relay.dart` | Create | WebSocket client registry and message routing |
| `tools/tutorial_server/test/tutorial_state_test.dart` | Create | Unit tests for state machine |
| `tools/tutorial_server/test/relay_test.dart` | Create | Unit tests for relay routing |
| `lib/app_state.dart` | Modify | Add `setAccessible(bool)` and `setLoggedIn(bool)` |
| `lib/tutorial/tutorial_app_state.dart` | Create | Lightweight in-app state: chapter/step/connection/navLock |
| `lib/tutorial/tutorial_bridge.dart` | Create | WebSocket client: connect, dispatch commands, report state |
| `lib/tutorial/widgets/tutorial_status_bar.dart` | Create | Compact bar: chapter/step + connection dot |
| `lib/widgets/access_bank_scaffold.dart` | Modify | Remove guide button; accept `allowedTabIndex` for nav lock |
| `lib/app.dart` | Modify | Strip guide routes; wire `TutorialBridge`; add status bar |
| `lib/tutorial/tutorial_overlay.dart` | Delete | Replaced by IDE panel |
| `lib/tutorial/tutorial_controller.dart` | Delete | Replaced by server + `TutorialAppState` |
| `lib/tutorial/widgets/` (7 files) | Move | To `tools/reference/` — design reference only |
| `pubspec.yaml` | Modify | Add `web_socket_channel: ^3.0.0` |
| `.gitignore` | Modify | Add `.tutorial/` |

---

## Task 1: Add `toJson()` to chapter_model.dart

**Files:**
- Modify: `lib/tutorial/chapter_model.dart`
- Modify: `test/tutorial/chapter_model_test.dart`

- [ ] **Step 1: Write the failing serialization tests**

Open `test/tutorial/chapter_model_test.dart` and add after the existing tests:

```dart
  group('toJson serialization', () {
    test('CodeDiff serializes all fields', () {
      const diff = CodeDiff(
        before: 'Text("hello")',
        after: 'Semantics(label: "greeting", child: Text("hello"))',
        language: 'dart',
        filePath: 'lib/screens/login.dart',
      );
      final json = diff.toJson();
      expect(json['before'], 'Text("hello")');
      expect(json['after'], contains('Semantics'));
      expect(json['language'], 'dart');
      expect(json['filePath'], 'lib/screens/login.dart');
    });

    test('QuizQuestion serializes all fields', () {
      const q = QuizQuestion(
        question: 'What does Semantics do?',
        options: ['A', 'B', 'C'],
        correctIndex: 1,
        explanation: 'It describes widgets to the OS.',
      );
      final json = q.toJson();
      expect(json['question'], 'What does Semantics do?');
      expect(json['options'], ['A', 'B', 'C']);
      expect(json['correctIndex'], 1);
      expect(json['explanation'], isNotEmpty);
    });

    test('TutorialStep serializes with optional fields null', () {
      const step = TutorialStep(id: 1, title: 'Step 1', explanation: 'Explains.');
      final json = step.toJson();
      expect(json['id'], 1);
      expect(json['title'], 'Step 1');
      expect(json['codeDiff'], isNull);
      expect(json['whyItMatters'], isNull);
      expect(json['tryItPrompt'], isNull);
      expect(json['referenceLinks'], isEmpty);
    });

    test('TutorialStep serializes codeDiff when present', () {
      const step = TutorialStep(
        id: 2,
        title: 'Step 2',
        explanation: 'Add a label.',
        codeDiff: CodeDiff(
          before: 'Icon(Icons.home)',
          after: 'Semantics(label: "Home", child: Icon(Icons.home))',
          language: 'dart',
          filePath: 'lib/screens/home.dart',
        ),
      );
      final json = step.toJson();
      expect(json['codeDiff'], isNotNull);
      expect(json['codeDiff']['filePath'], 'lib/screens/home.dart');
    });

    test('Chapter serializes all 10 real chapters without throwing', () {
      for (final chapter in allChapters) {
        expect(() => chapter.toJson(), returnsNormally);
        final json = chapter.toJson();
        expect(json['id'], chapter.id);
        expect(json['title'], chapter.title);
        expect((json['steps'] as List).length, chapter.steps.length);
      }
    });

    test('all 10 chapters produce valid JSON string', () {
      import 'dart:convert'; // add at top of test file
      for (final chapter in allChapters) {
        expect(() => jsonEncode(chapter.toJson()), returnsNormally);
      }
    });
  });
```

Add `import 'dart:convert';` at the top of the test file.

- [ ] **Step 2: Run tests to confirm they fail**

```bash
cd /Users/simon/Documents/tutorial_accessible/accessible
flutter test test/tutorial/chapter_model_test.dart
```

Expected: Failures on `toJson` — method not found.

- [ ] **Step 3: Add `toJson()` to all model classes in chapter_model.dart**

Add the following methods to each class (after the existing fields):

```dart
// Inside CodeDiff:
Map<String, dynamic> toJson() => {
  'before': before,
  'after': after,
  'language': language,
  'filePath': filePath,
};

// Inside QuizQuestion:
Map<String, dynamic> toJson() => {
  'question': question,
  'options': options,
  'correctIndex': correctIndex,
  'explanation': explanation,
};

// Inside Quiz:
Map<String, dynamic> toJson() => {
  'title': title,
  'questions': questions.map((q) => q.toJson()).toList(),
};

// Inside TutorialStep:
Map<String, dynamic> toJson() => {
  'id': id,
  'title': title,
  'explanation': explanation,
  'codeDiff': codeDiff?.toJson(),
  'whyItMatters': whyItMatters,
  'tryItPrompt': tryItPrompt,
  'referenceLinks': referenceLinks,
};

// Inside Chapter:
Map<String, dynamic> toJson() => {
  'id': id,
  'title': title,
  'branchName': branchName,
  'description': description,
  'screenFocus': screenFocus,
  'estimatedMinutes': estimatedMinutes,
  'vibe': vibe,
  'steps': steps.map((s) => s.toJson()).toList(),
  'quiz': quiz?.toJson(),
};
```

- [ ] **Step 4: Run tests to confirm they pass**

```bash
flutter test test/tutorial/chapter_model_test.dart
```

Expected: All tests pass including the new serialization group.

- [ ] **Step 5: Commit**

```bash
git add lib/tutorial/chapter_model.dart test/tutorial/chapter_model_test.dart
git commit -m "feat: add toJson() serialization to all chapter model classes"
```

---

## Task 2: Content generator script

**Files:**
- Create: `tools/generate_content.dart`
- Create: `tools/shared/tutorial_content.json` (generated)

- [ ] **Step 1: Create the generator script**

```dart
// tools/generate_content.dart
import 'dart:convert';
import 'dart:io';

import '../lib/tutorial/chapters/chapter_0.dart';
import '../lib/tutorial/chapters/chapter_1.dart';
import '../lib/tutorial/chapters/chapter_2.dart';
import '../lib/tutorial/chapters/chapter_3.dart';
import '../lib/tutorial/chapters/chapter_4.dart';
import '../lib/tutorial/chapters/chapter_5.dart';
import '../lib/tutorial/chapters/chapter_6.dart';
import '../lib/tutorial/chapters/chapter_7.dart';
import '../lib/tutorial/chapters/chapter_8.dart';
import '../lib/tutorial/chapters/chapter_9.dart';

void main() {
  final chapters = [
    chapter0, chapter1, chapter2, chapter3, chapter4,
    chapter5, chapter6, chapter7, chapter8, chapter9,
  ];

  final json = {
    'version': 1,
    'generatedAt': DateTime.now().toIso8601String(),
    'chapters': chapters.map((c) => c.toJson()).toList(),
  };

  final outDir = Directory('tools/shared');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);

  final outFile = File('tools/shared/tutorial_content.json');
  outFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(json));

  print('✓ Generated ${outFile.path}');
  print('  ${chapters.length} chapters');
  print('  ${chapters.fold(0, (sum, c) => sum + c.steps.length)} steps');
  print('  ${chapters.fold(0, (sum, c) => sum + c.steps.where((s) => s.codeDiff != null).length)} code diffs');
  print('  ${chapters.fold(0, (sum, c) => sum + (c.quiz?.questions.length ?? 0))} quiz questions');
}
```

- [ ] **Step 2: Run the generator**

```bash
cd /Users/simon/Documents/tutorial_accessible/accessible
dart tools/generate_content.dart
```

Expected output:
```
✓ Generated tools/shared/tutorial_content.json
  10 chapters
  54 steps
  35 code diffs
  30 quiz questions
```

- [ ] **Step 3: Verify the JSON is valid and complete**

```bash
dart -e "import 'dart:convert'; import 'dart:io'; void main() { final j = jsonDecode(File('tools/shared/tutorial_content.json').readAsStringSync()); print('chapters: \${(j['chapters'] as List).length}'); }"
```

Expected: `chapters: 10`

- [ ] **Step 4: Commit**

```bash
git add tools/generate_content.dart tools/shared/tutorial_content.json
git commit -m "feat: add content generator and commit tutorial_content.json"
```

---

## Task 3: Tutorial server — `TutorialState`

**Files:**
- Create: `tools/tutorial_server/pubspec.yaml`
- Create: `tools/tutorial_server/lib/tutorial_state.dart`
- Create: `tools/tutorial_server/test/tutorial_state_test.dart`

- [ ] **Step 1: Create the server package**

Create `tools/tutorial_server/pubspec.yaml`:

```yaml
name: tutorial_server
description: AccessGuide WebSocket relay server
publish_to: none
environment:
  sdk: ">=3.0.0 <4.0.0"
dependencies:
  args: ^2.5.0
  path: ^1.9.0
dev_dependencies:
  test: ^1.25.0
  lints: ^4.0.0
```

```bash
cd /Users/simon/Documents/tutorial_accessible/accessible/tools/tutorial_server
dart pub get
```

- [ ] **Step 2: Write failing tests for TutorialState**

Create `tools/tutorial_server/test/tutorial_state_test.dart`:

```dart
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
      final stepCounts = [6, 5, 6, 5, 5, 5, 5, 5, 6, 6]; // from chapter data
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
```

- [ ] **Step 3: Run tests to confirm they fail**

```bash
cd /Users/simon/Documents/tutorial_accessible/accessible/tools/tutorial_server
dart test test/tutorial_state_test.dart
```

Expected: Compilation error — `tutorial_state.dart` doesn't exist yet.

- [ ] **Step 4: Implement `TutorialState`**

Create `tools/tutorial_server/lib/tutorial_state.dart`:

```dart
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
```

Create `tools/tutorial_server/lib/tutorial_server.dart` (library barrel):
```dart
library tutorial_server;
export 'tutorial_state.dart';
export 'relay.dart';
```

- [ ] **Step 5: Run tests to confirm they pass**

```bash
cd /Users/simon/Documents/tutorial_accessible/accessible/tools/tutorial_server
dart test test/tutorial_state_test.dart
```

Expected: All tests pass.

- [ ] **Step 6: Commit**

```bash
cd /Users/simon/Documents/tutorial_accessible/accessible
git add tools/tutorial_server/
git commit -m "feat: add tutorial server package with TutorialState"
```

---

## Task 4: Tutorial server — `Relay`

**Files:**
- Create: `tools/tutorial_server/lib/relay.dart`
- Create: `tools/tutorial_server/test/relay_test.dart`

- [ ] **Step 1: Write failing tests for Relay**

Create `tools/tutorial_server/test/relay_test.dart`:

```dart
import 'package:test/test.dart';
import 'package:tutorial_server/relay.dart';

// A fake WebSocket for testing — collects sent messages.
class FakeSocket implements RelaySocket {
  final List<String> sent = [];
  bool closed = false;
  @override
  void add(String data) => sent.add(data);
  @override
  Future<void> close() async => closed = true;
}

void main() {
  group('Relay client management', () {
    test('addClient returns a ConnectedClient with correct type', () {
      final relay = Relay();
      final socket = FakeSocket();
      final client = relay.addClient(socket, ClientType.ide);
      expect(client.type, ClientType.ide);
    });

    test('removeClient removes the client', () {
      final relay = Relay();
      final s = FakeSocket();
      final c = relay.addClient(s, ClientType.app);
      relay.removeClient(c);
      expect(relay.appClients, isEmpty);
    });

    test('hasIdeClient and hasAppClient reflect connections', () {
      final relay = Relay();
      expect(relay.hasIdeClient, isFalse);
      relay.addClient(FakeSocket(), ClientType.ide);
      expect(relay.hasIdeClient, isTrue);
      expect(relay.hasAppClient, isFalse);
    });
  });

  group('Relay message routing', () {
    test('broadcast to app sends only to app clients', () {
      final relay = Relay();
      final ideSocket = FakeSocket();
      final appSocket = FakeSocket();
      relay.addClient(ideSocket, ClientType.ide);
      relay.addClient(appSocket, ClientType.app);

      relay.broadcast({'action': 'test'}, to: ClientType.app);

      expect(appSocket.sent, hasLength(1));
      expect(ideSocket.sent, isEmpty);
    });

    test('broadcast to ide sends only to ide clients', () {
      final relay = Relay();
      final ideSocket = FakeSocket();
      final appSocket = FakeSocket();
      relay.addClient(ideSocket, ClientType.ide);
      relay.addClient(appSocket, ClientType.app);

      relay.broadcast({'action': 'state'}, to: ClientType.ide);

      expect(ideSocket.sent, hasLength(1));
      expect(appSocket.sent, isEmpty);
    });

    test('broadcast without filter sends to all', () {
      final relay = Relay();
      final s1 = FakeSocket();
      final s2 = FakeSocket();
      relay.addClient(s1, ClientType.ide);
      relay.addClient(s2, ClientType.app);

      relay.broadcast({'action': 'ping'});

      expect(s1.sent, hasLength(1));
      expect(s2.sent, hasLength(1));
    });

    test('broadcast except skips specified client', () {
      final relay = Relay();
      final s1 = FakeSocket();
      final s2 = FakeSocket();
      final c1 = relay.addClient(s1, ClientType.app);
      relay.addClient(s2, ClientType.app);

      relay.broadcast({'action': 'ping'}, except: c1);

      expect(s1.sent, isEmpty);
      expect(s2.sent, hasLength(1));
    });
  });
}
```

- [ ] **Step 2: Run tests to confirm they fail**

```bash
cd /Users/simon/Documents/tutorial_accessible/accessible/tools/tutorial_server
dart test test/relay_test.dart
```

Expected: Compilation error — `relay.dart` doesn't exist.

- [ ] **Step 3: Implement `Relay`**

Create `tools/tutorial_server/lib/relay.dart`:

```dart
import 'dart:convert';

enum ClientType { ide, app }

/// Abstraction over a WebSocket connection — makes relay testable.
abstract interface class RelaySocket {
  void add(String data);
  Future<void> close();
}

class ConnectedClient {
  final RelaySocket socket;
  final ClientType type;
  final String id;

  ConnectedClient(this.socket, this.type, this.id);

  void send(Map<String, dynamic> message) {
    try {
      socket.add(jsonEncode(message));
    } catch (_) {
      // Socket closed mid-send — caller will handle via onDone.
    }
  }
}

class Relay {
  final List<ConnectedClient> _clients = [];
  int _nextId = 0;

  ConnectedClient addClient(RelaySocket socket, ClientType type) {
    final client =
        ConnectedClient(socket, type, '${type.name}-${_nextId++}');
    _clients.add(client);
    return client;
  }

  void removeClient(ConnectedClient client) => _clients.remove(client);

  void broadcast(
    Map<String, dynamic> message, {
    ClientType? to,
    ConnectedClient? except,
  }) {
    for (final client in List.of(_clients)) {
      if (to != null && client.type != to) continue;
      if (except != null && client.id == except.id) continue;
      client.send(message);
    }
  }

  bool get hasIdeClient => _clients.any((c) => c.type == ClientType.ide);
  bool get hasAppClient => _clients.any((c) => c.type == ClientType.app);
  List<ConnectedClient> get ideClients =>
      _clients.where((c) => c.type == ClientType.ide).toList();
  List<ConnectedClient> get appClients =>
      _clients.where((c) => c.type == ClientType.app).toList();
}
```

- [ ] **Step 4: Run tests to confirm they pass**

```bash
dart test test/relay_test.dart
```

Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
cd /Users/simon/Documents/tutorial_accessible/accessible
git add tools/tutorial_server/lib/relay.dart tools/tutorial_server/test/relay_test.dart tools/tutorial_server/lib/tutorial_server.dart
git commit -m "feat: add Relay class for WebSocket client registry and routing"
```

---

## Task 5: Tutorial server — entry point

**Files:**
- Create: `tools/tutorial_server/bin/server.dart`

- [ ] **Step 1: Implement the server entry point**

Create `tools/tutorial_server/bin/server.dart`:

```dart
import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:tutorial_server/relay.dart';
import 'package:tutorial_server/tutorial_state.dart';

// Maps Chapter.screenFocus → bottom-nav tabIndex (null = no nav lock, -1 = no change).
const _screenFocusToTab = {
  'Demo': null,
  'All screens': null,
  'Account Overview': 0,
  'Account Overview + theme': 0,
  'Transaction List': 1,
  'Transactions + Overview': 1,
  'Transfer': 2,
  'Login + Transfer': -1,   // -1 signals: log out to login screen
  'Login + dialogs': -1,
};

// screenFocus for each chapter by index.
const _chapterScreenFocus = [
  'Demo',                    // 0
  'All screens',             // 1
  'Account Overview',        // 2
  'Login + dialogs',         // 3
  'Account Overview + theme',// 4
  'Login + Transfer',        // 5
  'Transaction List',        // 6
  'Transactions + Overview', // 7
  'All screens',             // 8
  'All screens',             // 9
];

// Step counts per chapter (from chapter definitions).
const _stepCounts = [6, 5, 6, 5, 5, 5, 5, 5, 6, 6];

void main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('port', abbr: 'p', defaultsTo: '9274')
    ..addOption('state-dir', defaultsTo: '.tutorial');
  final results = parser.parse(args);
  final port = int.parse(results['port'] as String);
  final stateDir = results['state-dir'] as String;

  // Ensure state dir exists.
  Directory(stateDir).createSync(recursive: true);
  final statePath = p.join(stateDir, 'state.json');
  final portPath = p.join(stateDir, 'port');

  final state = TutorialState.load(statePath);
  final relay = Relay();

  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  File(portPath).writeAsStringSync('$port');
  print('AccessGuide server listening on ws://localhost:$port/ws');

  await for (final request in server) {
    if (request.uri.path == '/ws' &&
        WebSocketTransformer.isUpgradeRequest(request)) {
      final ws = await WebSocketTransformer.upgrade(request);
      _handleClient(ws, relay, state, statePath);
    } else if (request.method == 'GET' && request.uri.path == '/content') {
      final contentFile = File('tools/shared/tutorial_content.json');
      if (contentFile.existsSync()) {
        request.response
          ..headers.contentType = ContentType.json
          ..write(contentFile.readAsStringSync())
          ..close();
      } else {
        request.response
          ..statusCode = HttpStatus.notFound
          ..close();
      }
    } else {
      request.response
        ..statusCode = HttpStatus.notFound
        ..close();
    }
  }
}

void _handleClient(
  WebSocket ws,
  Relay relay,
  TutorialState state,
  String statePath,
) {
  ConnectedClient? client;

  ws.listen(
    (data) {
      final msg = jsonDecode(data as String) as Map<String, dynamic>;
      final action = msg['action'] as String? ?? '';
      final payload = (msg['payload'] as Map<String, dynamic>?) ?? {};
      final source = msg['source'] as String? ?? 'unknown';

      // First message from a new client must identify itself.
      if (client == null) {
        final type =
            source == 'ide' ? ClientType.ide : ClientType.app;
        client = relay.addClient(_WsSocket(ws), type);
        print('${client!.type.name} connected (${client!.id})');

        // Send current state to the new client.
        client!.send({
          'type': 'state',
          'source': 'server',
          'action': 'tutorial_state',
          'payload': state.toJson(),
        });
        return;
      }

      _handleAction(action, payload, client!, relay, state, statePath);
    },
    onDone: () {
      if (client != null) {
        print('${client!.type.name} disconnected (${client!.id})');
        relay.removeClient(client!);
        if (client!.type == ClientType.app) {
          relay.broadcast({
            'type': 'event',
            'source': 'server',
            'action': 'app_disconnected',
            'payload': {},
          }, to: ClientType.ide);
        }
      }
    },
  );
}

void _handleAction(
  String action,
  Map<String, dynamic> payload,
  ConnectedClient sender,
  Relay relay,
  TutorialState state,
  String statePath,
) {
  switch (action) {
    // IDE navigation commands — update state, relay to app.
    case 'next_step':
      state.nextStep(_stepCounts[state.chapterIndex], _stepCounts.length);
      _applyChapterNavLock(state, relay);
      _broadcastState(state, relay);
      state.save(statePath);

    case 'previous_step':
      final prevSteps = state.chapterIndex > 0
          ? _stepCounts[state.chapterIndex - 1]
          : _stepCounts[0];
      state.previousStep(prevSteps);
      _broadcastState(state, relay);
      state.save(statePath);

    case 'go_to_chapter':
      final index = (payload['chapterIndex'] as num).toInt();
      state.goToChapter(index);
      _applyChapterNavLock(state, relay);
      _broadcastState(state, relay);
      state.save(statePath);

    case 'set_accessible':
      state.showAccessible = payload['value'] as bool;
      relay.broadcast({
        'type': 'command',
        'source': 'server',
        'action': 'set_accessible',
        'payload': {'value': state.showAccessible},
      }, to: ClientType.app);
      _broadcastState(state, relay);
      state.save(statePath);

    case 'set_inspector':
      state.showInspector = payload['value'] as bool;
      relay.broadcast({
        'type': 'command',
        'source': 'server',
        'action': 'set_inspector',
        'payload': {'value': state.showInspector},
      }, to: ClientType.app);
      _broadcastState(state, relay);

    case 'complete_chapter':
      final id = (payload['chapterId'] as num).toInt();
      state.completeChapter(id);
      _broadcastState(state, relay);
      state.save(statePath);

    case 'submit_quiz':
      final id = (payload['chapterId'] as num).toInt();
      final score = (payload['score'] as num).toInt();
      state.submitQuiz(id, score);
      _broadcastState(state, relay);
      state.save(statePath);

    // App events — relay to IDE.
    case 'connected':
    case 'state_report':
      relay.broadcast({
        'type': 'event',
        'source': 'app',
        'action': action,
        'payload': payload,
      }, to: ClientType.ide, except: sender);
  }
}

void _applyChapterNavLock(TutorialState state, Relay relay) {
  final focus = _chapterScreenFocus[state.chapterIndex];
  final tabIndex = _screenFocusToTab[focus];

  if (tabIndex == -1) {
    // Special: log the user out to show the login screen.
    relay.broadcast({
      'type': 'command',
      'source': 'server',
      'action': 'set_logged_in',
      'payload': {'value': false},
    }, to: ClientType.app);
    state.allowedTabIndex = null;
  } else {
    state.allowedTabIndex = tabIndex;
  }

  relay.broadcast({
    'type': 'command',
    'source': 'server',
    'action': 'lock_nav',
    'payload': {'allowedTabIndex': state.allowedTabIndex},
  }, to: ClientType.app);
}

void _broadcastState(TutorialState state, Relay relay) {
  relay.broadcast({
    'type': 'state',
    'source': 'server',
    'action': 'tutorial_state',
    'payload': state.toJson(),
  });
}

/// Wraps a `dart:io` WebSocket to satisfy the [RelaySocket] interface.
class _WsSocket implements RelaySocket {
  final WebSocket _ws;
  _WsSocket(this._ws);
  @override
  void add(String data) => _ws.add(data);
  @override
  Future<void> close() => _ws.close();
}
```

- [ ] **Step 2: Start the server and verify it runs**

```bash
cd /Users/simon/Documents/tutorial_accessible/accessible
dart run tools/tutorial_server/bin/server.dart
```

Expected output:
```
AccessGuide server listening on ws://localhost:9274/ws
```

Leave it running. Open a new terminal.

- [ ] **Step 3: Connect a test WebSocket client and verify relay**

```bash
# Install websocat if not present: brew install websocat
# Terminal 2 — connect as IDE client:
echo '{"type":"event","source":"ide","action":"connected","payload":{}}' | websocat ws://localhost:9274/ws

# Terminal 3 — connect as app client, send a next_step:
echo '{"type":"event","source":"app","action":"connected","payload":{}}' | websocat ws://localhost:9274/ws
```

The IDE client should receive the `tutorial_state` broadcast.

- [ ] **Step 4: Stop server, commit**

```bash
git add tools/tutorial_server/bin/server.dart
git commit -m "feat: add tutorial server WebSocket relay entry point"
```

---

## Task 6: Modify `AppState` — add setter methods

**Files:**
- Modify: `lib/app_state.dart`

- [ ] **Step 1: Add `setAccessible` and `setLoggedIn` to AppState**

In `lib/app_state.dart`, add after the existing `toggleAccessible()` method:

```dart
  /// Sets the accessible flag to an explicit value (used by the tutorial bridge).
  void setAccessible(bool value) {
    if (_accessible == value) return;
    _accessible = value;
    notifyListeners();
  }

  /// Sets the logged-in state directly (used by tutorial to show login screen).
  void setLoggedIn(bool value) {
    if (_isLoggedIn == value) return;
    _isLoggedIn = value;
    if (!value) _currentTab = 0;
    notifyListeners();
  }
```

- [ ] **Step 2: Run existing tests to confirm nothing broke**

```bash
flutter test test/
```

Expected: All existing tests pass.

- [ ] **Step 3: Commit**

```bash
git add lib/app_state.dart
git commit -m "feat: add setAccessible and setLoggedIn to AppState for bridge control"
```

---

## Task 7: Create `TutorialAppState`

**Files:**
- Create: `lib/tutorial/tutorial_app_state.dart`

- [ ] **Step 1: Create the in-app state holder**

Create `lib/tutorial/tutorial_app_state.dart`:

```dart
import 'package:flutter/foundation.dart';

/// Lightweight state holder updated by [TutorialBridge] from server broadcasts.
/// Drives [TutorialStatusBar] and the nav lock in [AccessBankScaffold].
class TutorialAppState extends ChangeNotifier {
  int chapterIndex = 0;
  int stepIndex = 0;
  int totalSteps = 1;
  String chapterTitle = '';
  String stepTitle = '';
  bool showInspector = false;
  bool isConnected = false;

  /// Which bottom-nav tab index is currently allowed.
  /// null = all tabs are free.
  int? allowedTabIndex;

  void update({
    int? chapterIndex,
    int? stepIndex,
    int? totalSteps,
    String? chapterTitle,
    String? stepTitle,
    bool? showInspector,
    bool? isConnected,
    Object? allowedTabIndex = _sentinel,
  }) {
    if (chapterIndex != null) this.chapterIndex = chapterIndex;
    if (stepIndex != null) this.stepIndex = stepIndex;
    if (totalSteps != null) this.totalSteps = totalSteps;
    if (chapterTitle != null) this.chapterTitle = chapterTitle;
    if (stepTitle != null) this.stepTitle = stepTitle;
    if (showInspector != null) this.showInspector = showInspector;
    if (isConnected != null) this.isConnected = isConnected;
    if (!identical(allowedTabIndex, _sentinel)) {
      this.allowedTabIndex = allowedTabIndex as int?;
    }
    notifyListeners();
  }
}

/// Sentinel for nullable int update (distinguishes "not set" from "set to null").
const _sentinel = Object();
```

- [ ] **Step 2: Write a widget test for TutorialAppState**

Create `test/tutorial/tutorial_app_state_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:accessible/tutorial/tutorial_app_state.dart';

void main() {
  test('update notifies listeners and sets fields', () {
    final state = TutorialAppState();
    var notified = false;
    state.addListener(() => notified = true);

    state.update(chapterIndex: 3, stepIndex: 2, isConnected: true);

    expect(notified, isTrue);
    expect(state.chapterIndex, 3);
    expect(state.stepIndex, 2);
    expect(state.isConnected, isTrue);
  });

  test('allowedTabIndex can be set to null via update', () {
    final state = TutorialAppState()..allowedTabIndex = 2;
    state.update(allowedTabIndex: null);
    expect(state.allowedTabIndex, isNull);
  });

  test('update without allowedTabIndex leaves it unchanged', () {
    final state = TutorialAppState()..allowedTabIndex = 1;
    state.update(chapterIndex: 5);
    expect(state.allowedTabIndex, 1);
  });
}
```

```bash
flutter test test/tutorial/tutorial_app_state_test.dart
```

Expected: All 3 tests pass.

- [ ] **Step 3: Commit**

```bash
git add lib/tutorial/tutorial_app_state.dart test/tutorial/tutorial_app_state_test.dart
git commit -m "feat: add TutorialAppState in-app state holder"
```

---

## Task 8: Create `TutorialBridge`

**Files:**
- Modify: `pubspec.yaml` (add `web_socket_channel`)
- Create: `lib/tutorial/tutorial_bridge.dart`

- [ ] **Step 1: Add web_socket_channel dependency**

In `pubspec.yaml`, add under `dependencies:`:
```yaml
  web_socket_channel: ^3.0.0
```

```bash
flutter pub get
```

- [ ] **Step 2: Create the bridge**

Create `lib/tutorial/tutorial_bridge.dart`:

```dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../app_state.dart';
import 'tutorial_app_state.dart';

/// Connects the Flutter app to the AccessGuide tutorial server.
///
/// On startup, connects to ws://[host]:9274/ws, identifies itself as an app
/// client, and listens for commands. Dispatches incoming commands to [AppState]
/// and [TutorialAppState]. Reports state changes back to the server.
/// Auto-reconnects on disconnect.
class TutorialBridge extends ChangeNotifier {
  final AppState _appState;
  final TutorialAppState tutorialState;

  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  StreamSubscription? _subscription;

  static const _reconnectDelay = Duration(seconds: 3);

  TutorialBridge(this._appState, this.tutorialState) {
    _connect();
  }

  // The server host. Defaults to localhost (works for Android via adb reverse
  // and for iOS when the server binds 0.0.0.0 on the same LAN).
  static const _host =
      String.fromEnvironment('TUTORIAL_HOST', defaultValue: 'localhost');
  static const _port =
      String.fromEnvironment('TUTORIAL_PORT', defaultValue: '9274');
  static String get _wsUrl => 'ws://$_host:$_port/ws';

  void _connect() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
      _subscription = _channel!.stream.listen(
        _onMessage,
        onDone: _onDisconnected,
        onError: (_) => _onDisconnected(),
      );
      // Identify as app client.
      _send({
        'type': 'event',
        'source': 'app',
        'action': 'connected',
        'payload': {
          'platform': defaultTargetPlatform.name,
        },
      });
      tutorialState.update(isConnected: true);
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic data) {
    final msg = jsonDecode(data as String) as Map<String, dynamic>;
    final action = msg['action'] as String? ?? '';
    final payload = (msg['payload'] as Map<String, dynamic>?) ?? {};

    switch (action) {
      case 'navigate_screen':
        final tabIndex = (payload['tabIndex'] as num?)?.toInt();
        if (tabIndex != null) _appState.setTab(tabIndex);
        _reportState();

      case 'set_accessible':
        _appState.setAccessible(payload['value'] as bool? ?? false);
        _reportState();

      case 'set_inspector':
        tutorialState.update(showInspector: payload['value'] as bool? ?? false);

      case 'set_logged_in':
        _appState.setLoggedIn(payload['value'] as bool? ?? false);
        _reportState();

      case 'lock_nav':
        final allowed = (payload['allowedTabIndex'] as num?)?.toInt();
        tutorialState.update(allowedTabIndex: allowed);

      case 'tutorial_state':
        _applyTutorialState(payload);
    }
  }

  void _applyTutorialState(Map<String, dynamic> payload) {
    tutorialState.update(
      chapterIndex: (payload['chapterIndex'] as num?)?.toInt(),
      stepIndex: (payload['stepIndex'] as num?)?.toInt(),
      allowedTabIndex: (payload['allowedTabIndex'] as num?)?.toInt(),
    );
  }

  void _onDisconnected() {
    _subscription?.cancel();
    _channel = null;
    tutorialState.update(isConnected: false);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, _connect);
  }

  void _send(Map<String, dynamic> message) {
    try {
      _channel?.sink.add(jsonEncode(message));
    } catch (_) {}
  }

  void _reportState() {
    _send({
      'type': 'event',
      'source': 'app',
      'action': 'state_report',
      'payload': {
        'tab': _appState.currentTab,
        'accessible': _appState.accessible,
        'inspector': tutorialState.showInspector,
        'isLoggedIn': _appState.isLoggedIn,
      },
    });
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    super.dispose();
  }
}
```

- [ ] **Step 3: Run Flutter tests to confirm compilation**

```bash
flutter test test/
```

Expected: All existing tests pass. No new failures.

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/tutorial/tutorial_bridge.dart
git commit -m "feat: add TutorialBridge WebSocket client"
```

---

## Task 9: Create `TutorialStatusBar`

**Files:**
- Create: `lib/tutorial/widgets/tutorial_status_bar.dart`

- [ ] **Step 1: Create the status bar widget**

Create `lib/tutorial/widgets/tutorial_status_bar.dart`:

```dart
import 'package:flutter/material.dart';
import '../tutorial_app_state.dart';

/// Compact status bar shown at the top of every screen when the tutorial
/// server is in use. Shows chapter/step position and connection status.
///
/// Tapping opens a small detail overlay with connection info.
class TutorialStatusBar extends StatelessWidget {
  const TutorialStatusBar({super.key, required this.state});

  final TutorialAppState state;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return GestureDetector(
          onTap: () => _showDetails(context),
          child: Container(
            width: double.infinity,
            color: state.isConnected
                ? const Color(0xFF1565C0) // dark blue when connected
                : const Color(0xFF616161), // grey when disconnected
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: state.isConnected ? Colors.greenAccent : Colors.red,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    state.isConnected
                        ? 'Ch ${state.chapterIndex + 1} · Step ${state.stepIndex + 1}/${state.totalSteps}'
                        : 'Connecting to tutorial...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (state.isConnected && state.chapterTitle.isNotEmpty)
                  Text(
                    state.chapterTitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AccessGuide',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(state.isConnected
                ? '● Connected to tutorial server'
                : '○ Not connected — run the tutorial server in your IDE'),
            if (state.isConnected) ...[
              const SizedBox(height(4),
              Text('Chapter ${state.chapterIndex + 1}: ${state.chapterTitle}'),
              Text('Step ${state.stepIndex + 1} of ${state.totalSteps}: ${state.stepTitle}'),
            ],
          ],
        ),
      ),
    );
  }
}
```

Note: fix the syntax error on `const SizedBox(height(4)` → `const SizedBox(height: 4)`.

- [ ] **Step 2: Write a widget test**

Create `test/tutorial/tutorial_status_bar_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accessible/tutorial/tutorial_app_state.dart';
import 'package:accessible/tutorial/widgets/tutorial_status_bar.dart';

void main() {
  testWidgets('shows Connecting when not connected', (tester) async {
    final state = TutorialAppState();
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: TutorialStatusBar(state: state))),
    );
    expect(find.textContaining('Connecting'), findsOneWidget);
  });

  testWidgets('shows chapter and step when connected', (tester) async {
    final state = TutorialAppState()
      ..update(isConnected: true, chapterIndex: 1, stepIndex: 2, totalSteps: 5);
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: TutorialStatusBar(state: state))),
    );
    expect(find.textContaining('Ch 2'), findsOneWidget);
    expect(find.textContaining('Step 3/5'), findsOneWidget);
  });
}
```

```bash
flutter test test/tutorial/tutorial_status_bar_test.dart
```

Expected: Both tests pass.

- [ ] **Step 3: Commit**

```bash
git add lib/tutorial/widgets/tutorial_status_bar.dart test/tutorial/tutorial_status_bar_test.dart
git commit -m "feat: add TutorialStatusBar compact status indicator"
```

---

## Task 10: Modify `AccessBankScaffold` — nav locking

**Files:**
- Modify: `lib/widgets/access_bank_scaffold.dart`

- [ ] **Step 1: Add `allowedTabIndex` parameter and nav lock logic**

Replace the entire content of `lib/widgets/access_bank_scaffold.dart`:

```dart
import 'package:flutter/material.dart';

const List<String> _tabLabels = [
  'Overview', 'Transactions', 'Transfer', 'Settings',
];

const List<IconData> _tabIcons = [
  Icons.account_balance_outlined,
  Icons.receipt_long_outlined,
  Icons.swap_horiz_outlined,
  Icons.settings_outlined,
];

/// App shell with bottom navigation and optional tutorial nav lock.
///
/// When [allowedTabIndex] is non-null, all tabs except that index are
/// disabled and show a tooltip explaining which chapter covers them.
class AccessBankScaffold extends StatelessWidget {
  const AccessBankScaffold({
    super.key,
    required this.accessible,
    required this.currentIndex,
    required this.onTabChanged,
    required this.body,
    this.allowedTabIndex,
  });

  final bool accessible;
  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final Widget body;

  /// Locks bottom nav to a specific tab. null = all tabs navigable.
  final int? allowedTabIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AccessBank')),
      body: body,
      bottomNavigationBar: accessible
          ? _AccessibleNavBar(
              currentIndex: currentIndex,
              onTabChanged: onTabChanged,
              allowedTabIndex: allowedTabIndex,
            )
          : _InaccessibleNavBar(
              currentIndex: currentIndex,
              onTabChanged: onTabChanged,
              allowedTabIndex: allowedTabIndex,
            ),
    );
  }
}

class _AccessibleNavBar extends StatelessWidget {
  const _AccessibleNavBar({
    required this.currentIndex,
    required this.onTabChanged,
    this.allowedTabIndex,
  });

  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final int? allowedTabIndex;

  @override
  Widget build(BuildContext context) {
    final total = _tabLabels.length;

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (i) {
        if (allowedTabIndex != null && i != allowedTabIndex) {
          _showLockedTooltip(context, i);
          return;
        }
        onTabChanged(i);
      },
      destinations: List.generate(total, (i) {
        final isSelected = i == currentIndex;
        final isLocked = allowedTabIndex != null && i != allowedTabIndex;
        final positionLabel =
            '${_tabLabels[i]} tab, ${i + 1} of $total, '
            '${isSelected ? "currently selected" : "not selected"}';

        return NavigationDestination(
          icon: Semantics(
            label: isLocked
                ? '${_tabLabels[i]} — locked during this tutorial step'
                : positionLabel,
            selected: isSelected,
            child: ExcludeSemantics(
              child: Icon(
                _tabIcons[i],
                color: isLocked ? Colors.grey.shade400 : null,
              ),
            ),
          ),
          label: _tabLabels[i],
        );
      }),
    );
  }

  void _showLockedTooltip(BuildContext context, int tabIndex) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_tabLabels[tabIndex]} is covered in a later chapter. '
          'Follow the tutorial to get there.',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _InaccessibleNavBar extends StatelessWidget {
  const _InaccessibleNavBar({
    required this.currentIndex,
    required this.onTabChanged,
    this.allowedTabIndex,
  });

  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final int? allowedTabIndex;

  @override
  Widget build(BuildContext context) {
    const Color background = Color(0xFFF5F5F5);
    const Color iconColor = Color(0xFFBDBDBD);
    const Color selectedColor = Color(0xFF90CAF9);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (i) {
        if (allowedTabIndex != null && i != allowedTabIndex) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_tabLabels[i]} is covered in a later chapter.'),
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }
        onTabChanged(i);
      },
      backgroundColor: background,
      unselectedItemColor: iconColor,
      selectedItemColor: selectedColor,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      items: List.generate(
        _tabLabels.length,
        (i) => BottomNavigationBarItem(
          icon: Icon(_tabIcons[i]),
          label: '',
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Run existing scaffold tests**

```bash
flutter test test/widget/
```

Expected: Pass. (The `showGuideButton` parameter has been removed — if any test used it, update those tests to remove that parameter.)

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/access_bank_scaffold.dart
git commit -m "feat: add allowedTabIndex nav lock to AccessBankScaffold, remove guide button"
```

---

## Task 11: Modify `app.dart` — wire bridge, strip guide routes

**Files:**
- Modify: `lib/app.dart`

- [ ] **Step 1: Rewrite app.dart**

Replace `lib/app.dart` with:

```dart
import 'package:flutter/material.dart';

import 'app_state.dart';
import 'screens/account_overview/account_overview_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/transactions/transactions_screen.dart';
import 'screens/transfer/transfer_screen.dart';
import 'theme/app_theme.dart';
import 'tutorial/tutorial_app_state.dart';
import 'tutorial/tutorial_bridge.dart';
import 'tutorial/widgets/tutorial_status_bar.dart';
import 'widgets/access_bank_scaffold.dart';

class AccessBankApp extends StatefulWidget {
  const AccessBankApp({super.key});

  @override
  State<AccessBankApp> createState() => _AccessBankAppState();
}

class _AccessBankAppState extends State<AccessBankApp> {
  final AppState _appState = AppState();
  final TutorialAppState _tutorialState = TutorialAppState();
  late final TutorialBridge _bridge;

  @override
  void initState() {
    super.initState();
    _bridge = TutorialBridge(_appState, _tutorialState);
  }

  @override
  void dispose() {
    _appState.dispose();
    _bridge.dispose();
    _tutorialState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appState,
      builder: (context, _) {
        return MaterialApp(
          title: 'AccessBank',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: _appState.isLoggedIn
              ? _HomeScreen(appState: _appState, tutorialState: _tutorialState)
              : _LoginScreenWrapper(appState: _appState),
        );
      },
    );
  }
}

class _LoginScreenWrapper extends StatelessWidget {
  const _LoginScreenWrapper({required this.appState});
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return LoginScreen(
      accessible: appState.accessible,
      onLogin: appState.login,
    );
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen({required this.appState, required this.tutorialState});
  final AppState appState;
  final TutorialAppState tutorialState;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([appState, tutorialState]),
      builder: (context, _) {
        return Column(
          children: [
            TutorialStatusBar(state: tutorialState),
            Expanded(
              child: AccessBankScaffold(
                accessible: appState.accessible,
                currentIndex: appState.currentTab,
                onTabChanged: appState.setTab,
                allowedTabIndex: tutorialState.allowedTabIndex,
                body: _TabBody(
                  tab: appState.currentTab,
                  accessible: appState.accessible,
                  appState: appState,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TabBody extends StatelessWidget {
  const _TabBody({
    required this.tab,
    required this.accessible,
    required this.appState,
  });
  final int tab;
  final bool accessible;
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return switch (tab) {
      0 => AccountOverviewScreen(accessible: accessible),
      1 => TransactionsScreen(accessible: accessible),
      2 => TransferScreen(accessible: accessible),
      3 => SettingsScreen(accessible: accessible, appState: appState),
      _ => const SizedBox.shrink(),
    };
  }
}
```

- [ ] **Step 2: Run all tests**

```bash
flutter test test/
```

Expected: All existing tests pass. Fix any that referenced the removed routes or `_GuideScreen`.

- [ ] **Step 3: Run on the phone**

```bash
flutter run
```

Expected: App launches showing the status bar ("Connecting to tutorial...") in dark grey at the top. App navigation works normally. Start the tutorial server in another terminal — the status bar turns blue and shows "Ch 1 · Step 1/6".

- [ ] **Step 4: Commit**

```bash
git add lib/app.dart
git commit -m "feat: wire TutorialBridge and TutorialStatusBar into app, strip guide routes"
```

---

## Task 12: Cleanup — delete dead files, move reference widgets

**Files:**
- Delete: `lib/tutorial/tutorial_overlay.dart`
- Delete: `lib/tutorial/tutorial_controller.dart`
- Move: 7 widget files to `tools/reference/`
- Modify: `.gitignore`

- [ ] **Step 1: Delete the old overlay and controller**

```bash
cd /Users/simon/Documents/tutorial_accessible/accessible
rm lib/tutorial/tutorial_overlay.dart
rm lib/tutorial/tutorial_controller.dart
```

- [ ] **Step 2: Move reference widgets**

```bash
mkdir -p tools/reference/flutter_widgets
mv lib/tutorial/widgets/step_card.dart tools/reference/flutter_widgets/
mv lib/tutorial/widgets/code_diff_viewer.dart tools/reference/flutter_widgets/
mv lib/tutorial/widgets/quiz_card.dart tools/reference/flutter_widgets/
mv lib/tutorial/widgets/why_callout.dart tools/reference/flutter_widgets/
mv lib/tutorial/widgets/try_it_prompt.dart tools/reference/flutter_widgets/
mv lib/tutorial/widgets/chapter_list.dart tools/reference/flutter_widgets/
mv lib/tutorial/widgets/progress_bar.dart tools/reference/flutter_widgets/
```

Add a `tools/reference/README.md`:
```markdown
# Reference Widgets

These Flutter widgets were the original in-app tutorial panel UI. They are kept
here as visual design reference for the HTML tutorial panel in `tools/shared/`.
They are NOT imported by the Flutter app.
```

- [ ] **Step 3: Update .gitignore**

Add to `.gitignore`:
```
.tutorial/
```

- [ ] **Step 4: Run all tests to confirm nothing is broken**

```bash
flutter test test/
```

Expected: All tests pass. Fix any that imported deleted files (update imports or remove the test).

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "chore: delete tutorial overlay/controller, move reference widgets to tools/"
```

---

## Verification

Sub-Plan 1 is complete when all of the following pass:

- [ ] `dart tools/generate_content.dart` outputs: `10 chapters, 54 steps, 35 code diffs, 30 quiz questions`
- [ ] `dart run tools/tutorial_server/bin/server.dart` starts without error
- [ ] `flutter test test/` passes all tests
- [ ] `flutter run` on a physical device shows the status bar: "Connecting to tutorial..."
- [ ] After starting the server, the status bar turns blue and shows "Ch 1 · Step 1/6"
- [ ] Sending `{"type":"event","source":"ide","action":"connected","payload":{}}` then `{"type":"command","source":"ide","action":"next_step","payload":{}}` via websocat updates the status bar to "Ch 1 · Step 2/6"
- [ ] Tapping a locked tab on the phone shows the "covered in a later chapter" SnackBar
- [ ] `dart test` in `tools/tutorial_server/` passes all tests

**Once this checklist passes, proceed to Sub-Plan 2 (VS Code Extension + Tutorial Panel HTML).**
