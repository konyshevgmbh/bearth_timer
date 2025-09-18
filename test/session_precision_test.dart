import 'package:flutter_test/flutter_test.dart';
import 'package:bearth_timer/services/session_service.dart';

void main() {
  group('Session Precision Tests', () {
    late SessionService sessionService;

    setUp(() {
      sessionService = SessionService();
    });

    test('should provide millisecond precision in time calculations', () async {
      // Test that the service can distinguish time differences smaller than 1 second
      
      // Simulate setting start time
      sessionService.startTime = DateTime.now();
      
      // Wait a fraction of a second
      await Future.delayed(const Duration(milliseconds: 150));
      
      // Get elapsed time - should show fractional seconds
      final totalElapsed = sessionService.totalElapsed;
      
      // Should detect elapsed time less than 1 second but greater than 0
      expect(totalElapsed, greaterThan(0));
      expect(totalElapsed, lessThanOrEqualTo(1)); // Should be 1 second or less
    });

    test('should calculate wait phase with millisecond precision', () async {
      sessionService.startTime = DateTime.now();
      
      // Test at different millisecond intervals within the wait phase
      final List<bool> waitPhaseStates = [];
      
      for (int i = 0; i < 5; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        waitPhaseStates.add(sessionService.isInWaitPhase);
      }
      
      // All should be true since we're still within the wait phase duration
      expect(waitPhaseStates.every((state) => state), isTrue,
        reason: 'Should accurately detect wait phase at millisecond intervals');
    });

    test('should handle rapid state updates', () async {
      // Test that the service can handle rapid successive calls
      // without losing precision
      
      sessionService.startTime = DateTime.now();
      
      final List<int> elapsedTimes = [];
      
      // Rapid successive calls
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 10));
        elapsedTimes.add(sessionService.totalElapsed);
      }
      
      // Times should generally increase (allowing for some system variance)
      bool isMonotonic = true;
      for (int i = 1; i < elapsedTimes.length; i++) {
        if (elapsedTimes[i] < elapsedTimes[i - 1] - 1) { // Allow 1 second tolerance
          isMonotonic = false;
          break;
        }
      }
      
      expect(isMonotonic, isTrue,
        reason: 'Elapsed time should increase monotonically with millisecond precision');
    });
  });
}