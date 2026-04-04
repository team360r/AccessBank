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
