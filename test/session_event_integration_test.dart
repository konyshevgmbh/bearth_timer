import 'package:flutter_test/flutter_test.dart';
import 'package:bearth_timer/services/session_service.dart';

void main() {
  group('Session Event Integration Tests', () {
    late SessionService sessionService;

    setUp(() {
      sessionService = SessionService();
    });

    test('should emit session events through stream', () async {
      final List<SessionEventType> receivedEvents = [];
      
      // Subscribe to events
      final subscription = sessionService.events.listen((event) {
        receivedEvents.add(event.type);
      });

      // Manually emit events to test the stream
      sessionService.emitEvent(SessionEventType.sessionStart);
      sessionService.emitEvent(SessionEventType.phaseTransition);
      sessionService.emitEvent(SessionEventType.sessionComplete);

      // Wait for events to propagate
      await Future.delayed(const Duration(milliseconds: 10));

      // Verify events were received
      expect(receivedEvents.length, equals(3));
      expect(receivedEvents[0], equals(SessionEventType.sessionStart));
      expect(receivedEvents[1], equals(SessionEventType.phaseTransition));
      expect(receivedEvents[2], equals(SessionEventType.sessionComplete));

      subscription.cancel();
    });

    test('should handle multiple subscribers', () async {
      final List<SessionEventType> receivedEvents1 = [];
      final List<SessionEventType> receivedEvents2 = [];
      
      // Subscribe with two different listeners
      final subscription1 = sessionService.events.listen((event) {
        receivedEvents1.add(event.type);
      });
      
      final subscription2 = sessionService.events.listen((event) {
        receivedEvents2.add(event.type);
      });

      // Emit event
      sessionService.emitEvent(SessionEventType.sessionStart);

      // Wait for events to propagate
      await Future.delayed(const Duration(milliseconds: 10));

      // Both should receive the event
      expect(receivedEvents1.length, equals(1));
      expect(receivedEvents2.length, equals(1));
      expect(receivedEvents1[0], equals(SessionEventType.sessionStart));
      expect(receivedEvents2[0], equals(SessionEventType.sessionStart));

      subscription1.cancel();
      subscription2.cancel();
    });
  });
}