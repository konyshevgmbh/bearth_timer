import 'package:flutter_test/flutter_test.dart';
import 'package:bearth_timer/models/breathing_exercise.dart';
import 'package:bearth_timer/models/breath_phase.dart';
import 'package:bearth_timer/services/exercise_service.dart';
import 'package:flutter/material.dart';

void main() {
  group('Exercise Duration Sync Tests', () {
    late ExerciseService exerciseService;
    late BreathingExercise testExercise;

    setUp(() {
      exerciseService = ExerciseService();
      testExercise = BreathingExercise(
        id: 'test-id',
        name: 'Test Exercise',
        description: 'Test exercise for duration sync',
        createdAt: DateTime.now(),
        minCycles: 1,
        maxCycles: 10,
        cycleDurationStep: 5,
        cycles: 5,
        cycleDuration: 20, // Initial cycle duration
        phases: [
          BreathPhase(
            name: 'Inhale',
            duration: 5,
            minDuration: 2,
            maxDuration: 10,
            color: Colors.blue,
            claps: 1,
          ),
          BreathPhase(
            name: 'Hold',
            duration: 5,
            minDuration: 2,
            maxDuration: 10,
            color: Colors.green,
            claps: 1,
          ),
          BreathPhase(
            name: 'Exhale',
            duration: 10,
            minDuration: 5,
            maxDuration: 15,
            color: Colors.red,
            claps: 1,
          ),
        ],
      );
      exerciseService.setCurrentExercise(testExercise);
    });

    tearDown(() {
      exerciseService.clearCurrentExercise();
    });

    test('cycleDuration should update when removing a phase', () {
      // Initial state: 3 phases with durations 5+5+10 = 20 seconds
      expect(exerciseService.currentExercise!.cycleDuration, equals(20));
      expect(exerciseService.currentExercise!.totalPhaseDuration, equals(20));
      expect(exerciseService.currentExercise!.phases.length, equals(3));

      // Remove the last phase (10 seconds)
      exerciseService.removePhase(2);

      // Now should have 2 phases with durations 5+5 = 10 seconds
      expect(exerciseService.currentExercise!.cycleDuration, equals(10));
      expect(exerciseService.currentExercise!.totalPhaseDuration, equals(10));
      expect(exerciseService.currentExercise!.phases.length, equals(2));
    });

    test('cycleDuration should update when adding a phase', () {
      // Initial state: 3 phases with durations 5+5+10 = 20 seconds
      expect(exerciseService.currentExercise!.cycleDuration, equals(20));
      expect(exerciseService.currentExercise!.totalPhaseDuration, equals(20));
      expect(exerciseService.currentExercise!.phases.length, equals(3));

      // Add a new phase (default duration is 5 seconds)
      exerciseService.addPhase();

      // Now should have 4 phases with durations 5+5+10+5 = 25 seconds
      expect(exerciseService.currentExercise!.cycleDuration, equals(25));
      expect(exerciseService.currentExercise!.totalPhaseDuration, equals(25));
      expect(exerciseService.currentExercise!.phases.length, equals(4));
    });

    test('cycleDuration should update when duplicating a phase', () {
      // Initial state: 3 phases with durations 5+5+10 = 20 seconds
      expect(exerciseService.currentExercise!.cycleDuration, equals(20));
      expect(exerciseService.currentExercise!.totalPhaseDuration, equals(20));
      expect(exerciseService.currentExercise!.phases.length, equals(3));

      // Duplicate the first phase (5 seconds)
      exerciseService.duplicatePhase(0);

      // Now should have 4 phases with durations 5+5+5+10 = 25 seconds
      expect(exerciseService.currentExercise!.cycleDuration, equals(25));
      expect(exerciseService.currentExercise!.totalPhaseDuration, equals(25));
      expect(exerciseService.currentExercise!.phases.length, equals(4));
    });

    test('cycleDuration should update when changing phase min/max duration', () {
      // Initial state: 3 phases with durations 5+5+10 = 20 seconds
      expect(exerciseService.currentExercise!.cycleDuration, equals(20));
      expect(exerciseService.currentExercise!.totalPhaseDuration, equals(20));

      // Update min/max durations shouldn't change current phase durations
      // but should update cycleDuration to match totalPhaseDuration
      exerciseService.updatePhaseMinDuration(0, 3);
      exerciseService.updatePhaseMaxDuration(0, 8);

      // Durations should still be the same since we only changed min/max
      expect(exerciseService.currentExercise!.cycleDuration, equals(20));
      expect(exerciseService.currentExercise!.totalPhaseDuration, equals(20));
    });

    test('cycleDuration and totalPhaseDuration should always be in sync', () {
      final initialExercise = exerciseService.currentExercise!;
      
      // Both should start equal
      expect(initialExercise.cycleDuration, equals(initialExercise.totalPhaseDuration));

      // After removing a phase
      exerciseService.removePhase(1);
      var updatedExercise = exerciseService.currentExercise!;
      expect(updatedExercise.cycleDuration, equals(updatedExercise.totalPhaseDuration));

      // After adding a phase
      exerciseService.addPhase();
      updatedExercise = exerciseService.currentExercise!;
      expect(updatedExercise.cycleDuration, equals(updatedExercise.totalPhaseDuration));

      // After duplicating a phase
      exerciseService.duplicatePhase(0);
      updatedExercise = exerciseService.currentExercise!;
      expect(updatedExercise.cycleDuration, equals(updatedExercise.totalPhaseDuration));
    });
  });
}