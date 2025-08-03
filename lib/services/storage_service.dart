import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/breathing_exercise.dart';
import '../models/training_result.dart';
import '../models/user_settings.dart';
import '../core/constants.dart';
import 'exercise_service.dart';

/// Service for local data storage and persistence
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // UUID generator for creating unique IDs
  static const Uuid _uuid = Uuid();

  // Hive box references with error handling
  Box<TrainingResult> get _resultsBox {
    try {
      if (!Hive.isBoxOpen('results')) {
        throw HiveError('Results box is not open. Initialize app first.');
      }
      return Hive.box<TrainingResult>('results');
    } catch (e) {
      debugPrint('Error accessing results box: $e');
      rethrow;
    }
  }
  
  Box<UserSettings> get _settingsBox {
    try {
      if (!Hive.isBoxOpen('settings')) {
        throw HiveError('Settings box is not open. Initialize app first.');
      }
      return Hive.box<UserSettings>('settings');
    } catch (e) {
      debugPrint('Error accessing settings box: $e');
      rethrow;
    }
  }
  
  Box<BreathingExercise> get _exercisesBox {
    try {
      if (!Hive.isBoxOpen('exercises')) {
        throw HiveError('Exercises box is not open. Initialize app first.');
      }
      return Hive.box<BreathingExercise>('exercises');
    } catch (e) {
      debugPrint('Error accessing exercises box: $e');
      rethrow;
    }
  }

  // Exercise storage methods
  Future<List<BreathingExercise>> loadExercises() async {
    try {
      final exercisesBox = _exercisesBox;
      
      if (exercisesBox.isEmpty) {
        debugPrint('Exercises box is empty, creating default exercises');
        final defaultExercises = ExerciseService().createDefaultExercises();
        await saveExercises(defaultExercises);
        return defaultExercises;
      }

      // Try to read all exercises, filtering out any corrupted ones
      final exercises = <BreathingExercise>[];
      for (final key in exercisesBox.keys) {
        try {
          final exercise = exercisesBox.get(key);
          if (exercise != null) {
            exercises.add(exercise);
          }
        } catch (e) {
          debugPrint('Corrupted exercise data found for key $key: $e');
          // Remove corrupted entry
          try {
            await exercisesBox.delete(key);
          } catch (deleteError) {
            debugPrint('Failed to delete corrupted exercise: $deleteError');
          }
        }
      }
      
      // If no valid exercises remain, create defaults
      if (exercises.isEmpty) {
        debugPrint('No valid exercises found, creating defaults');
        final defaultExercises = ExerciseService().createDefaultExercises();
        await saveExercises(defaultExercises);
        return defaultExercises;
      }
      
      return exercises;
    } catch (e) {
      debugPrint('Critical error loading exercises: $e');
      // As a last resort, return default exercises without saving
      return ExerciseService().createDefaultExercises();
    }
  }

  Future<void> saveExercises(List<BreathingExercise> exercises) async {
    try {
      await _exercisesBox.clear();
      final exerciseMap = <String, BreathingExercise>{};
      for (final exercise in exercises) {
        exerciseMap[exercise.id] = exercise;
      }
      await _exercisesBox.putAll(exerciseMap);
    } catch (e) {
      debugPrint('Error saving exercises: $e');
    }
  }

  Future<void> saveExercise(BreathingExercise exercise) async {
    try {
      // Use exercise ID as key for direct access
      await _exercisesBox.put(exercise.id, exercise);
    } catch (e) {
      debugPrint('Error saving exercise: $e');
    }
  }

  Future<bool> deleteExercise(String exerciseId) async {
    try {
      if (_exercisesBox.containsKey(exerciseId)) {
        await _exercisesBox.delete(exerciseId);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting exercise: $e');
      return false;
    }
  }

  /// Duplicate an existing exercise with a new ID and name
  Future<BreathingExercise?> duplicateExercise(String exerciseId) async {
    try {
      final originalExercise = _exercisesBox.get(exerciseId);
      if (originalExercise == null) {
        debugPrint('Exercise not found for duplication: $exerciseId');
        return null;
      }

      // Generate unique ID for the duplicate
      final newId = _uuid.v4();
      
      // Create unique name for the duplicate
      final baseName = originalExercise.name;
      final duplicateName = await _generateUniqueName(baseName);

      // Create the duplicated exercise
      final duplicatedExercise = originalExercise.copyWith(
        id: newId,
        name: duplicateName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save the duplicated exercise
      await _exercisesBox.put(newId, duplicatedExercise);
      
      debugPrint('Exercise duplicated: $exerciseId -> $newId ($duplicateName)');
      return duplicatedExercise;
    } catch (e) {
      debugPrint('Error duplicating exercise: $e');
      return null;
    }
  }

  /// Generate a unique name for a duplicated exercise
  Future<String> _generateUniqueName(String baseName) async {
    try {
      final existingExercises = _exercisesBox.values.toList();
      final existingNames = existingExercises.map((e) => e.name.toLowerCase()).toSet();
      
      // Try "Name (Copy)"
      String candidateName = '$baseName (Copy)';
      if (!existingNames.contains(candidateName.toLowerCase())) {
        return candidateName;
      }
      
      // Try "Name (Copy 2)", "Name (Copy 3)", etc.
      int counter = 2;
      do {
        candidateName = '$baseName (Copy $counter)';
        counter++;
      } while (existingNames.contains(candidateName.toLowerCase()) && counter < 100);
      
      return candidateName;
    } catch (e) {
      debugPrint('Error generating unique name: $e');
      return '$baseName (Copy)';
    }
  }

  // Training results storage methods
  Future<void> addTrainingResult(TrainingResult result) async {
    try {
      final dateKey = DateFormat('yyyy-MM-dd').format(result.date);
      final key = '${dateKey}_${result.exerciseId}';
      
      // Check if we have an existing result for this date+exerciseId
      final existingResult = _resultsBox.get(key);

      // Keep only the better result for the day+exercise combination
      if (existingResult == null || result.isBetterThan(existingResult)) {
        await _resultsBox.put(key, result);
        await _cleanupOldResults();
      }
    } catch (e) {
      debugPrint('Error saving result: $e');
    }
  }

  Future<List<TrainingResult>> getAllResults() async {
    try {
      final results = _resultsBox.values.toList();
      results.sort((a, b) => b.date.compareTo(a.date));
      return results;
    } catch (e) {
      debugPrint('Error loading results: $e');
      return [];
    }
  }
  
  /// Get a specific training result by date
  TrainingResult? getResultByDate(DateTime date) {
    try {
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      // Find all results for this date across all exercises
      final results = _resultsBox.keys
          .where((key) => key is String && key.startsWith('${dateKey}_'))
          .map((key) => _resultsBox.get(key))
          .where((result) => result != null)
          .cast<TrainingResult>()
          .toList();
      
      if (results.isEmpty) return null;
      
      // Return the best result for this date
      results.sort((a, b) => a.isBetterThan(b) ? -1 : 1);
      return results.first;
    } catch (e) {
      debugPrint('Error loading result for date $date: $e');
      return null;
    }
  }
  
  /// Get a specific exercise by ID
  BreathingExercise? getExerciseById(String exerciseId) {
    try {
      return _exercisesBox.get(exerciseId);
    } catch (e) {
      debugPrint('Error loading exercise $exerciseId: $e');
      return null;
    }
  }
  
  /// Check if an exercise exists by ID
  bool exerciseExists(String exerciseId) {
    try {
      return _exercisesBox.containsKey(exerciseId);
    } catch (e) {
      debugPrint('Error checking exercise existence $exerciseId: $e');
      return false;
    }
  }

  Future<void> _cleanupOldResults() async {
    try {
      final cutoffDate = DateTime.now().subtract(
        Duration(days: StorageConstants.maxDataRetentionDays),
      );
      final cutoffDateKey = DateFormat('yyyy-MM-dd').format(cutoffDate);
      
      final keysToDelete = <String>[];
      for (final key in _resultsBox.keys) {
        if (key is String && key.contains('_')) {
          // Extract date part from key (format: yyyy-MM-dd_exerciseId)
          final dateKey = key.split('_')[0];
          if (dateKey.compareTo(cutoffDateKey) < 0) {
            keysToDelete.add(key);
          }
        }
      }
      
      await _resultsBox.deleteAll(keysToDelete);
    } catch (e) {
      debugPrint('Error cleaning up old results: $e');
    }
  }

  Future<void> saveResultsDirectly(List<TrainingResult> results) async {
    try {
      await _resultsBox.clear();
      final resultMap = <String, TrainingResult>{};
      for (final result in results) {
        final dateKey = DateFormat('yyyy-MM-dd').format(result.date);
        final key = '${dateKey}_${result.exerciseId}';
        // If multiple results for same date+exercise, keep the better one
        final existing = resultMap[key];
        if (existing == null || result.isBetterThan(existing)) {
          resultMap[key] = result;
        }
      }
      await _resultsBox.putAll(resultMap);
    } catch (e) {
      debugPrint('Error saving results directly: $e');
    }
  }

  Future<void> clearResults() async {
    try {
      // Only clear the results box, not all Hive data
      await _resultsBox.clear();
      debugPrint('Successfully cleared all training results');
    } catch (e) {
      debugPrint('Error clearing results: $e');
    }
  }

  /// Completely reset all app data and reinitialize with defaults
  Future<void> resetAllAppData() async {
    try {
      debugPrint('Resetting all app data...');
      
      // Clear all boxes individually first
      await _resultsBox.clear();
      await _settingsBox.clear();
      await _exercisesBox.clear();
      
      // Reset exercises to default
      await resetExercisesToDefault();
      
      debugPrint('Successfully reset all app data');
    } catch (e) {
      debugPrint('Error resetting app data: $e');
      // If individual clearing fails, fall back to the recovery method
      rethrow;
    }
  }

  /// Reset exercises to their initial/default state
  Future<void> resetExercisesToDefault() async {
    try {
      await _exercisesBox.clear();
      final defaultExercises = ExerciseService().createDefaultExercises();
      await saveExercises(defaultExercises);
      debugPrint('Exercises reset to default state');
    } catch (e) {
      debugPrint('Error resetting exercises to default: $e');
    }
  }

  Future<List<MapEntry<DateTime, double?>>> getLast30DaysData() async {
    final data = <MapEntry<DateTime, double?>>[];

    // Generate last 30 days and get scores directly from box
    for (int i = StorageConstants.maxDataRetentionDays - 1; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      
      // Find all results for this date across all exercises
      final results = _resultsBox.keys
          .where((key) => key is String && key.startsWith('${dateKey}_'))
          .map((key) => _resultsBox.get(key))
          .where((result) => result != null)
          .cast<TrainingResult>()
          .toList();
      
      double? bestScore;
      if (results.isNotEmpty) {
        // Get the best score for this date
        results.sort((a, b) => a.isBetterThan(b) ? -1 : 1);
        bestScore = results.first.score;
      }
      
      data.add(MapEntry(date, bestScore));
    }

    return data;
  }

  // User settings storage methods
  Future<UserSettings> loadUserSettings() async {
    try {
      final settings = _settingsBox.get('user_settings');
      if (settings != null) {
        return settings;
      }
      
      // Return default settings if none exist
      final defaultSettings = UserSettings(
        totalCycles: TrainingConstants.defaultTotalCycles,
        cycleDuration: TrainingConstants.defaultCycleDuration,
      );
      await saveUserSettings(defaultSettings);
      return defaultSettings;
    } catch (e) {
      debugPrint('Error loading user settings: $e');
      return UserSettings(
        totalCycles: TrainingConstants.defaultTotalCycles,
        cycleDuration: TrainingConstants.defaultCycleDuration,
      );
    }
  }

  Future<void> saveUserSettings(UserSettings settings) async {
    try {
      await _settingsBox.put('user_settings', settings);
    } catch (e) {
      debugPrint('Error saving user settings: $e');
    }
  }

  // Compatibility methods for existing codebase
  Future<void> saveResult(TrainingResult result) async {
    await addTrainingResult(result);
  }

  Future<List<TrainingResult>> getResults() async {
    return await getAllResults();
  }
}