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
