import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/breathing_exercise.dart';
import '../models/training_result.dart';
import '../models/user_settings.dart';
import 'storage_service.dart';

class ExportImportService {
  static final ExportImportService _instance = ExportImportService._internal();
  factory ExportImportService() => _instance;
  ExportImportService._internal();

  final StorageService _storage = StorageService();
  final Uuid _uuid = const Uuid();

  /// Export all data to JSON format
  Future<Map<String, dynamic>> exportAllData() async {
    final exercises = await _storage.loadExercises();
    final results = await _storage.getResults();
    final settings = await _storage.loadUserSettings();

    return {
      'version': '1.0',
      'exported_at': DateTime.now().toIso8601String(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'training_results': results.map((r) => r.toJson()).toList(),
      'user_settings': settings.toJson(),
    };
  }

  /// Export data to file using platform-specific file picker
  Future<bool> exportToFile() async {
    try {
      final data = await exportAllData();
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      final bytes = Uint8List.fromList(utf8.encode(jsonString));
      
      final fileName = 'bearth_timer_export_${_uuid.v4().substring(0, 8)}.json';
      
      // Use file picker to save the file
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Bearth Timer Export',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: bytes,
      );
      
      return result != null && result.isNotEmpty;
    } catch (e) {
      debugPrint('Error exporting data: $e');
      rethrow;
    }
  }

  /// Import data from JSON string
  Future<ImportResult> importFromJson(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Validate version
      final version = data['version'] as String?;
      if (version != '1.0') {
        return ImportResult(
          success: false,
          error: 'Unsupported export version: $version',
        );
      }

      // Import exercises
      List<BreathingExercise> exercises = [];
      if (data['exercises'] != null) {
        final exercisesData = data['exercises'] as List;
        exercises = exercisesData.map((e) => BreathingExercise.fromJson(e)).toList();
      }

      // Import training results
      List<TrainingResult> results = [];
      if (data['training_results'] != null) {
        final resultsData = data['training_results'] as List;
        results = resultsData.map((r) => TrainingResult.fromJson(r)).toList();
      }

      // Import user settings
      UserSettings? settings;
      if (data['user_settings'] != null) {
        settings = UserSettings.fromJson(data['user_settings']);
      }

      return ImportResult(
        success: true,
        exercises: exercises,
        trainingResults: results,
        userSettings: settings,
      );
    } catch (e) {
      debugPrint('Error importing data: $e');
      return ImportResult(
        success: false,
        error: 'Failed to parse import data: $e',
      );
    }
  }

  /// Import data from file
  Future<ImportResult> importFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true, // Ensure bytes are loaded for web compatibility
      );

      if (result == null || result.files.isEmpty) {
        return ImportResult(
          success: false,
          error: 'No file selected',
        );
      }

      final file = result.files.first;
      String jsonString;
      
      if (file.bytes != null) {
        // Web and mobile platforms - use bytes
        jsonString = utf8.decode(file.bytes!);
      } else {
        // Fallback for platforms that don't support bytes
        return ImportResult(
          success: false,
          error: 'Could not read file',
        );
      }

      return await importFromJson(jsonString);
    } catch (e) {
      debugPrint('Error importing from file: $e');
      return ImportResult(
        success: false,
        error: 'Failed to import file: $e',
      );
    }
  }

  /// Apply imported data to storage
  Future<void> applyImportedData(ImportResult importResult) async {
    if (!importResult.success) return;

    try {
      // Import exercises
      if (importResult.exercises.isNotEmpty) {
        await _storage.saveExercises(importResult.exercises);
      }

      // Import training results
      if (importResult.trainingResults.isNotEmpty) {
        await _storage.saveResultsDirectly(importResult.trainingResults);
      }

      // Import user settings
      if (importResult.userSettings != null) {
        await _storage.saveUserSettings(importResult.userSettings!);
      }
    } catch (e) {
      debugPrint('Error applying imported data: $e');
      rethrow;
    }
  }

  /// Import data from file and apply it
  Future<ImportResult> importAndApply() async {
    final result = await importFromFile();
    if (result.success) {
      await applyImportedData(result);
    }
    return result;
  }

  /// Export single exercise to JSON format
  Map<String, dynamic> exportExercise(BreathingExercise exercise) {
    return {
      'version': '1.0',
      'type': 'single_exercise',
      'exported_at': DateTime.now().toIso8601String(),
      'exercise': exercise.toJson(),
    };
  }

  /// Export single exercise to file using platform-specific file picker
  Future<bool> exportExerciseToFile(BreathingExercise exercise) async {
    try {
      final data = exportExercise(exercise);
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      final bytes = Uint8List.fromList(utf8.encode(jsonString));
      
      final fileName = 'exercise_${exercise.name.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_')}_${_uuid.v4().substring(0, 8)}.json';
      
      // Use file picker to save the file
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Exercise',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: bytes,
      );
      
      return result != null && result.isNotEmpty;
    } catch (e) {
      debugPrint('Error exporting exercise: $e');
      rethrow;
    }
  }

  /// Import exercise from JSON string
  Future<ExerciseImportResult> importExerciseFromJson(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Validate version
      final version = data['version'] as String?;
      if (version != '1.0') {
        return ExerciseImportResult(
          success: false,
          error: 'Unsupported export version: $version',
        );
      }

      // Validate type
      final type = data['type'] as String?;
      if (type != 'single_exercise') {
        return ExerciseImportResult(
          success: false,
          error: 'Invalid file type. Expected single exercise export.',
        );
      }

      // Import exercise
      if (data['exercise'] == null) {
        return ExerciseImportResult(
          success: false,
          error: 'No exercise data found in file',
        );
      }

      final exerciseData = data['exercise'] as Map<String, dynamic>;
      final exercise = BreathingExercise.fromJson(exerciseData);

      return ExerciseImportResult(
        success: true,
        exercise: exercise,
      );
    } catch (e) {
      debugPrint('Error importing exercise: $e');
      return ExerciseImportResult(
        success: false,
        error: 'Failed to parse exercise data: $e',
      );
    }
  }

  /// Import exercise from file
  Future<ExerciseImportResult> importExerciseFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true, // Ensure bytes are loaded for web compatibility
      );

      if (result == null || result.files.isEmpty) {
        return ExerciseImportResult(
          success: false,
          error: 'No file selected',
        );
      }

      final file = result.files.first;
      String jsonString;
      
      if (file.bytes != null) {
        // Web and mobile platforms - use bytes
        jsonString = utf8.decode(file.bytes!);
      } else {
        // Fallback for platforms that don't support bytes
        return ExerciseImportResult(
          success: false,
          error: 'Could not read file',
        );
      }

      return await importExerciseFromJson(jsonString);
    } catch (e) {
      debugPrint('Error importing exercise from file: $e');
      return ExerciseImportResult(
        success: false,
        error: 'Failed to import file: $e',
      );
    }
  }

  /// Add imported exercise to storage with new ID to avoid conflicts
  Future<BreathingExercise> addImportedExercise(BreathingExercise exercise) async {
    try {
      // Generate new ID to avoid conflicts
      final newExercise = exercise.copyWith(
        id: _uuid.v4(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Load existing exercises
      final existingExercises = await _storage.loadExercises();
      
      // Check for name conflicts and adjust if necessary
      String newName = newExercise.name;
      int suffix = 1;
      while (existingExercises.any((e) => e.name == newName)) {
        newName = '${newExercise.name} (${suffix++})';
      }
      
      final finalExercise = newName != newExercise.name 
          ? newExercise.copyWith(name: newName)
          : newExercise;

      // Add to existing exercises
      final updatedExercises = [...existingExercises, finalExercise];
      await _storage.saveExercises(updatedExercises);

      return finalExercise;
    } catch (e) {
      debugPrint('Error adding imported exercise: $e');
      rethrow;
    }
  }

  /// Import exercise from file and add it to storage
  Future<ExerciseImportResult> importAndAddExercise() async {
    final result = await importExerciseFromFile();
    if (result.success && result.exercise != null) {
      try {
        final addedExercise = await addImportedExercise(result.exercise!);
        return ExerciseImportResult(
          success: true,
          exercise: addedExercise,
        );
      } catch (e) {
        return ExerciseImportResult(
          success: false,
          error: 'Failed to add exercise to storage: $e',
        );
      }
    }
    return result;
  }
}

/// Result of import operation
class ImportResult {
  final bool success;
  final String? error;
  final List<BreathingExercise> exercises;
  final List<TrainingResult> trainingResults;
  final UserSettings? userSettings;

  ImportResult({
    required this.success,
    this.error,
    this.exercises = const [],
    this.trainingResults = const [],
    this.userSettings,
  });

  String get summary {
    if (!success) return error ?? 'Import failed';
    
    final parts = <String>[];
    if (exercises.isNotEmpty) parts.add('${exercises.length} exercises');
    if (trainingResults.isNotEmpty) parts.add('${trainingResults.length} training results');
    if (userSettings != null) parts.add('user settings');
    
    return 'Imported: ${parts.join(', ')}';
  }
}

/// Result of exercise import operation
class ExerciseImportResult {
  final bool success;
  final String? error;
  final BreathingExercise? exercise;

  ExerciseImportResult({
    required this.success,
    this.error,
    this.exercise,
  });

  String get summary {
    if (!success) return error ?? 'Import failed';
    
    return exercise != null 
        ? 'Imported exercise: ${exercise!.name}'
        : 'Import successful';
  }
}