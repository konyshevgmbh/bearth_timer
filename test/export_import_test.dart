import 'package:flutter_test/flutter_test.dart';
import 'package:bearth_timer/services/export_import_service.dart';
import 'package:bearth_timer/models/breathing_exercise.dart';
import 'package:bearth_timer/models/training_result.dart';
import 'package:bearth_timer/models/user_settings.dart';
import 'package:bearth_timer/models/breath_phase.dart';
import 'package:flutter/material.dart';

void main() {
  group('ExportImportService Tests', () {
    late ExportImportService service;

    setUp(() {
      service = ExportImportService();
    });

    test('should export data to JSON format', () async {
      final data = await service.exportAllData();
      
      expect(data, isA<Map<String, dynamic>>());
      expect(data['version'], equals('1.0'));
      expect(data['exported_at'], isNotNull);
      expect(data['exercises'], isA<List>());
      expect(data['training_results'], isA<List>());
      expect(data['user_settings'], isA<Map<String, dynamic>>());
    });

    test('should import valid JSON data', () async {
      final testData = {
        'version': '1.0',
        'exported_at': DateTime.now().toIso8601String(),
        'exercises': [
          {
            'id': 'test-exercise',
            'name': 'Test Exercise',
            'description': 'Test description',
            'created_at': DateTime.now().toIso8601String(),
            'can_edit_cycles_count': true,
            'can_edit_cycle_duration': true,
            'min_cycles': 1,
            'max_cycles': 10,
            'min_cycle_duration': 30,
            'max_cycle_duration': 300,
            'cycle_duration_step': 15,
            'cycles': 3,
            'cycle_duration': 60,
            'phases': [
              {
                'name': 'Breathe In',
                'duration': 4,
                'min_duration': 2,
                'max_duration': 8,
                'color_value': Colors.blue.value,
              },
              {
                'name': 'Hold',
                'duration': 7,
                'min_duration': 4,
                'max_duration': 12,
                'color_value': Colors.green.value,
              },
            ],
          },
        ],
        'training_results': [
          {
            'date': DateTime.now().toIso8601String(),
            'duration': 180,
            'cycles': 3,
            'exerciseId': 'test-exercise',
          },
        ],
        'user_settings': {
          'total_cycles': 5,
          'cycle_duration': 90,
          'sound_enabled': true,
        },
      };

      final jsonString = '{"version":"1.0","exported_at":"2024-01-01T00:00:00.000Z","exercises":[{"id":"test-exercise","name":"Test Exercise","description":"Test description","created_at":"2024-01-01T00:00:00.000Z","can_edit_cycles_count":true,"can_edit_cycle_duration":true,"min_cycles":1,"max_cycles":10,"min_cycle_duration":30,"max_cycle_duration":300,"cycle_duration_step":15,"cycles":3,"cycle_duration":60,"phases":[{"name":"Breathe In","duration":4,"min_duration":2,"max_duration":8,"color_value":4280391411},{"name":"Hold","duration":7,"min_duration":4,"max_duration":12,"color_value":4283215696}]}],"training_results":[{"date":"2024-01-01T00:00:00.000Z","duration":180,"cycles":3,"exerciseId":"test-exercise"}],"user_settings":{"total_cycles":5,"cycle_duration":90,"sound_enabled":true}}';

      final result = await service.importFromJson(jsonString);

      expect(result.success, isTrue);
      expect(result.exercises.length, equals(1));
      expect(result.exercises.first.name, equals('Test Exercise'));
      expect(result.trainingResults.length, equals(1));
      expect(result.trainingResults.first.cycles, equals(3));
      expect(result.userSettings, isNotNull);
      expect(result.userSettings!.totalCycles, equals(5));
    });

    test('should reject invalid version', () async {
      final jsonString = '{"version":"2.0","exercises":[],"training_results":[],"user_settings":{}}';

      final result = await service.importFromJson(jsonString);

      expect(result.success, isFalse);
      expect(result.error, contains('Unsupported export version'));
    });

    test('should handle invalid JSON', () async {
      const jsonString = 'invalid json';

      final result = await service.importFromJson(jsonString);

      expect(result.success, isFalse);
      expect(result.error, contains('Failed to parse import data'));
    });

    test('ImportResult should provide proper summary', () {
      final exercises = [
        BreathingExercise(
          id: 'test-1',
          name: 'Test Exercise 1',
          description: 'Description 1',
          createdAt: DateTime.now(),
          minCycles: 1,
          maxCycles: 10,
          cycleDurationStep: 15,
          cycles: 3,
          cycleDuration: 60,
          phases: [],
        ),
      ];

      final results = [
        TrainingResult(
          date: DateTime.now(),
          duration: 180,
          cycles: 3,
          exerciseId: 'test-1',
        ),
      ];

      final settings = UserSettings(
        totalCycles: 5,
        cycleDuration: 90,
        soundEnabled: true,
      );

      final importResult = ImportResult(
        success: true,
        exercises: exercises,
        trainingResults: results,
        userSettings: settings,
      );

      expect(importResult.summary, equals('Imported: 1 exercises, 1 training results, user settings'));
    });
  });
}