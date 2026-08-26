import 'dart:async';

class AuthEventBus {
  // Private constructor
  AuthEventBus._internal();

  // Singleton instance
  static final AuthEventBus instance = AuthEventBus._internal();

  // Stream controller to broadcast session expiration events
  final StreamController<void> _sessionExpiredController = StreamController<void>.broadcast();

  // Expose the stream
  Stream<void> get onSessionExpired => _sessionExpiredController.stream;

  // Method to trigger the event
  void notifySessionExpired() {
    _sessionExpiredController.add(null);
  }

  // Dispose helper (optional, useful for testing)
  void dispose() {
    _sessionExpiredController.close();
  }
}
