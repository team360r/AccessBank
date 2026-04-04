import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:tutorial_server/relay.dart';
import 'package:tutorial_server/tutorial_state.dart';

// Maps Chapter.screenFocus → bottom-nav tabIndex (null = no nav lock, -1 = logout to login screen).
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

// screenFocus for each chapter by index (chapters 0-9).
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
