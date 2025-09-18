import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:uuid/uuid.dart';

/// Console utility to generate exercise result files in JSON format
/// Usage: dart run bin/generate_exercise_results.dart [exercise_name] [days_count] [step_between_days]
void main(List<String> arguments) async {
  // Parse command line arguments with defaults
  final exerciseName = arguments.isNotEmpty ? arguments[0] : 'test';
  final daysCount = arguments.length > 1 ? int.tryParse(arguments[1]) ?? 10 : 10;
  final stepBetweenDays = arguments.length > 2 ? int.tryParse(arguments[2]) ?? 1 : 1;

  print('Generating exercise results...');
  print('Exercise name: $exerciseName');
  print('Days count: $daysCount');
  print('Step between days: $stepBetweenDays');

  final generator = ExerciseResultGenerator(
    exerciseName: exerciseName,
    daysCount: daysCount,
    stepBetweenDays: stepBetweenDays,
  );

  await generator.generateAndSave();
}

class ExerciseResultGenerator {
  final String exerciseName;
  final int daysCount;
  final int stepBetweenDays;
  final Random _random = Random();
  final Uuid _uuid = const Uuid();

  ExerciseResultGenerator({
    required this.exerciseName,
    required this.daysCount,
    required this.stepBetweenDays,
  });

  /// Generate training results for the specified period
  List<Map<String, dynamic>> generateTrainingResults(String exerciseId) {
    final results = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (int i = 0; i < daysCount; i++) {
      final date = now.subtract(Duration(days: i * stepBetweenDays));
      
      // Generate realistic training data
      final cycles = _random.nextInt(10) + 5; // 5-14 cycles
      final duration = _random.nextInt(180) + 60; // 60-240 seconds
      
      final result = {
        'date': date.toIso8601String(),
        'duration': duration,
        'cycles': cycles,
        'exerciseId': exerciseId,
      };
      
      results.add(result);
    }

    return results;
  }

  /// Generate a breathing exercise
  Map<String, dynamic> generateBreathingExercise() {
    final exerciseId = _uuid.v4();
    final now = DateTime.now();

    // Generate phases for the exercise
    final phases = [
      {
        'name': 'Inhale',
        'duration': 4,
        'min_duration': 3,
        'max_duration': 6,
        'color_value': 0xFF4CAF50, // Green
        'claps': 1,
      },
      {
        'name': 'Hold',
        'duration': 2,
        'min_duration': 1,
        'max_duration': 4,
        'color_value': 0xFF2196F3, // Blue
        'claps': 1,
      },
      {
        'name': 'Exhale',
        'duration': 6,
        'min_duration': 4,
        'max_duration': 8,
        'color_value': 0xFFF44336, // Red
        'claps': 1,
      },
    ];

    return {
      'id': exerciseId,
      'name': exerciseName,
      'description': 'Generated breathing exercise for testing',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
      'can_edit_cycles_count': true,
      'can_edit_cycle_duration': true,
      'min_cycles': 5,
      'max_cycles': 20,
      'min_cycle_duration': 8,
      'max_cycle_duration': 18,
      'cycle_duration_step': 1,
      'cycles': 10,
      'cycle_duration': 12,
      'phases': phases,
    };
  }

  /// Generate the complete export data structure
  Map<String, dynamic> generateExportData() {
    final exercise = generateBreathingExercise();
    final exerciseId = exercise['id'] as String;
    final trainingResults = generateTrainingResults(exerciseId);

    return {
      'version': '1.0',
      'exported_at': DateTime.now().toIso8601String(),
      'exercises': [exercise],
      'training_results': trainingResults,
      'user_settings': {
        'theme_mode': 'system',
        'language': 'en',
        'sound_enabled': true,
        'vibration_enabled': true,
        'keep_screen_on': true,
      },
    };
  }

  /// Generate and save the exercise results to a JSON file
  Future<void> generateAndSave() async {
    try {
      final data = generateExportData();
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      
      // Create output directory if it doesn't exist
      final outputDir = Directory('generated_exercises');
      if (!await outputDir.exists()) {
        await outputDir.create();
      }
      
      // Generate filename with timestamp and parameters
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final sanitizedName = exerciseName.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
      final filename = 'exercise_${sanitizedName}_${daysCount}days_step${stepBetweenDays}_$timestamp.json';
      
      final file = File('generated_exercises/$filename');
      await file.writeAsString(jsonString);
      
      print('✅ Generated exercise results saved to: ${file.path}');
      print('📊 Generated ${data['training_results'].length} training results');
      print('🏃 Exercise: ${data['exercises'][0]['name']}');
      print('📅 Date range: ${daysCount} days with ${stepBetweenDays}-day steps');
      
    } catch (e) {
      print('❌ Error generating exercise results: $e');
      exit(1);
    }
  }
}