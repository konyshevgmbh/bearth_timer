import 'package:flutter_test/flutter_test.dart';
import 'package:bearth_timer/services/initial_training_service.dart';
import 'package:bearth_timer/services/exercise_service.dart';

void main() {
  group('UUID ID Generation Tests', () {
    test('InitialTrainingService should generate UUID-based IDs', () {
      final service = InitialTrainingService();
      final exercise = service.createDefaultExercise();
      
      // UUID v4 format: 8-4-4-4-12 characters with hyphens
      expect(exercise.id, matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')));
      expect(exercise.id.length, equals(36));
    });

    test('Multiple exercises should have unique IDs', () {
      final service = InitialTrainingService();
      final exercise1 = service.createDefaultExercise();
      final exercise2 = service.createDefaultExercise();
      
      expect(exercise1.id, isNot(equals(exercise2.id)));
      expect(exercise1.id, matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')));
      expect(exercise2.id, matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')));
    });

    test('Initial training set should have predefined IDs for default exercises', () {
      final service = InitialTrainingService();
      final exercises = service.createInitialTrainingSet();
      
      expect(exercises.length, equals(3));
      expect(exercises[0].id, equals('molchanov_method'));
      expect(exercises[1].id, equals('478_breathing'));
      expect(exercises[2].id, equals('box_breathing'));
    });

    test('ExerciseService should generate UUID for new exercises', () {
      final service = ExerciseService();
      final exercise = service.createNewExercise();
      
      expect(exercise.id, matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')));
      expect(exercise.id.length, equals(36));
    });
  });
}