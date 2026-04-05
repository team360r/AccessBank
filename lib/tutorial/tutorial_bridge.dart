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
    }
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
