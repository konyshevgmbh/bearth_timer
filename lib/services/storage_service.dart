import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/breathing_exercise.dart';
import '../models/training_result.dart';
import '../models/user_settings.dart';
import '../core/constants.dart';
import 'exercise_service.dart';
import '../i18n/strings.g.dart';
import 'sync_service.dart';

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
        throw HiveError(t.services.storage.boxNotOpen);
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
        throw HiveError(t.services.storage.boxNotOpen);
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
        throw HiveError(t.services.storage.boxNotOpen);
      }
      return Hive.box<BreathingExercise>('exercises');
    } catch (e) {
      debugPrint('Error accessing exercises box: $e');
      rethrow;
    }
  }

  // Exercise storage methods

  /// Get the next timestamp that's guaranteed to be after all existing timestamps
  DateTime _getNextTimestamp(BreathingExercise exercise) {
    final now = DateTime.now().toUtc();
    final maxExisting = [exercise.createdAt, exercise.updatedAt, exercise.deletedAt]
        .where((date) => date != null)
        .cast<DateTime>()
        .fold<DateTime?>(null, (max, date) => max == null || date.isAfter(max) ? date : max);
    
    if (maxExisting == null) return now;
    
    // Return either now or maxExisting + 1 millisecond, whichever is later
    final nextTimestamp = maxExisting.add(Duration(milliseconds: 1));
    return nextTimestamp.isAfter(now) ? nextTimestamp : now;
  }
  
  /// Internal method to load exercises from storage with optional filtering
  Future<List<BreathingExercise>> _loadExercisesInternal({bool includeDeleted = false}) async {
    try {
      final exercisesBox = _exercisesBox;
      
      // If box is empty, create and save defaults once
      if (exercisesBox.isEmpty) {
        debugPrint('Exercises box is empty, creating default exercises');
        return await _ensureDefaultExercises();
      }

      // Read exercises with optional deleted filtering
      final exercises = <BreathingExercise>[];
      for (final key in exercisesBox.keys) {
        try {
          final exercise = exercisesBox.get(key);
          if (exercise != null && (includeDeleted || exercise.deletedAt == null)) {
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
      
      // If no valid exercises remain, ensure we have defaults
      if (exercises.isEmpty) {
        debugPrint('No valid exercises found, ensuring defaults');
        return await _ensureDefaultExercises();
      }
      
      return exercises;
    } catch (e) {
      debugPrint('Critical error loading exercises: $e');
      // As a last resort, return default exercises without saving
      return ExerciseService().createDefaultExercises();
    }
  }

  /// Ensures default exercises exist and returns them
  Future<List<BreathingExercise>> _ensureDefaultExercises() async {
    final defaultExercises = ExerciseService().createDefaultExercises();
    await saveExercises(defaultExercises);
    return defaultExercises;
  }

  /// Load all exercises including deleted ones (for sync purposes)
  Future<List<BreathingExercise>> loadAllExercises() async {
    return _loadExercisesInternal(includeDeleted: true);
  }

  /// Load only active exercises (for UI)
  Future<List<BreathingExercise>> loadExercises() async {
    return _loadExercisesInternal(includeDeleted: false);
  }

  Future<void> saveAllExercises(List<BreathingExercise> exercises) async {
    try {
      await _exercisesBox.clear();
      final exerciseMap = <String, BreathingExercise>{};
      for (final exercise in exercises) {
        exerciseMap[exercise.id] = exercise;
      }
      await _exercisesBox.putAll(exerciseMap);
    } catch (e) {
      debugPrint('Error saving all exercises: $e');
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
      final exercise = _exercisesBox.get(exerciseId);
      if (exercise != null && exercise.deletedAt == null) {
        // Soft delete: set deletedAt timestamp
        final deletedExercise = exercise.copyWith(deletedAt: _getNextTimestamp(exercise));
        await _exercisesBox.put(exerciseId, deletedExercise);
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
        debugPrint(t.services.storage.exerciseNotFound(exerciseId: exerciseId));
        return null;
      }

      // Generate unique ID for the duplicate
      final newId = _uuid.v4();
      
      // Create unique name for the duplicate
      final baseName = originalExercise.name;
      final duplicateName = await _generateUniqueName(baseName);

      // Create the duplicated exercise with incremental timestamps
      final nextTimestamp = _getNextTimestamp(originalExercise);
      final duplicatedExercise = originalExercise.copyWith(
        id: newId,
        name: duplicateName,
        createdAt: nextTimestamp,
        updatedAt: nextTimestamp,
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
      final existingExercises = _exercisesBox.values
          .where((exercise) => exercise.deletedAt == null)
          .toList();
      final existingNames = existingExercises.map((e) => e.name.toLowerCase()).toSet();
      
      // Try "Name (Copy)"
      String candidateName = '$baseName (${t.services.storage.copy})';
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
  Future<void> saveTrainingResult(TrainingResult result) async {
    try {
      // Use unique timestamp-based key to save all results
      final timestamp = result.date.millisecondsSinceEpoch;
      final key = '${timestamp}_${result.exerciseId}';
      
      await _resultsBox.put(key, result);
      await _cleanupOldResults();
      // Auto-sync when training result is added
      _triggerAutoSync();
    } catch (e) {
      debugPrint('Error saving result: $e');
    }
  }

  Future<List<TrainingResult>> getAllResults() async {
    try {
      final results = _resultsBox.values
          .where((result) => result.deletedAt == null)
          .toList();
      results.sort((a, b) => b.date.compareTo(a.date));
      return results;
    } catch (e) {
      debugPrint('Error loading results: $e');
      return [];
    }
  }

  /// Load all training results including deleted ones (for sync purposes)
  Future<List<TrainingResult>> getAllResultsIncludingDeleted() async {
    try {
      final results = _resultsBox.values.toList();
      results.sort((a, b) => b.date.compareTo(a.date));
      return results;
    } catch (e) {
      debugPrint('Error loading all results: $e');
      return [];
    }
  }

  Future<void> saveAllResults(List<TrainingResult> results) async {
    try {
      await _resultsBox.clear();
      final resultMap = <String, TrainingResult>{};
      for (final result in results) {
        // Use unique timestamp-based key to save all results
        final timestamp = result.date.millisecondsSinceEpoch;
        final key = '${timestamp}_${result.exerciseId}';
        resultMap[key] = result;
      }
      await _resultsBox.putAll(resultMap);
    } catch (e) {
      debugPrint('Error saving all results: $e');
    }
  }
  
  /// Get a specific training result by date
  TrainingResult? getResultByDate(DateTime date) {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(Duration(days: 1));
      
      // Find all results for this date across all exercises
      final results = _resultsBox.values
          .where((result) => 
              result.deletedAt == null &&
              result.date.isAfter(startOfDay.subtract(Duration(milliseconds: 1))) &&
              result.date.isBefore(endOfDay))
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
  
  /// Get a specific exercise by ID (only if not deleted)
  BreathingExercise? getExerciseById(String exerciseId) {
    try {
      final exercise = _exercisesBox.get(exerciseId);
      if (exercise != null && exercise.deletedAt == null) {
        return exercise;
      }
      return null;
    } catch (e) {
      debugPrint('Error loading exercise $exerciseId: $e');
      return null;
    }
  }
  
  /// Check if an exercise exists by ID (only if not deleted)
  bool exerciseExists(String exerciseId) {
    try {
      final exercise = _exercisesBox.get(exerciseId);
      return exercise != null && exercise.deletedAt == null;
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
        // Use unique timestamp-based key to save all results
        final timestamp = result.date.millisecondsSinceEpoch;
        final key = '${timestamp}_${result.exerciseId}';
        resultMap[key] = result;
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
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(Duration(days: 1));
      
      // Find all results for this date across all exercises
      final results = _resultsBox.values
          .where((result) => 
              result.deletedAt == null &&
              result.date.isAfter(startOfDay.subtract(Duration(milliseconds: 1))) &&
              result.date.isBefore(endOfDay))
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

  /// Soft delete a training result
  Future<bool> deleteTrainingResult(String resultKey) async {
    try {
      final result = _resultsBox.get(resultKey);
      if (result != null && result.deletedAt == null) {
        // Create a new TrainingResult with deletedAt timestamp
        final deletedResult = TrainingResult(
          date: result.date,
          duration: result.duration,
          cycles: result.cycles,
          exerciseId: result.exerciseId,
          deletedAt: DateTime.now(),
        );
        await _resultsBox.put(resultKey, deletedResult);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting training result: $e');
      return false;
    }
  }

  /// Restore a soft-deleted training result
  Future<bool> restoreTrainingResult(String resultKey) async {
    try {
      final result = _resultsBox.get(resultKey);
      if (result != null && result.deletedAt != null) {
        // Create a new TrainingResult without deletedAt timestamp
        final restoredResult = TrainingResult(
          date: result.date,
          duration: result.duration,
          cycles: result.cycles,
          exerciseId: result.exerciseId,
          deletedAt: null,
        );
        await _resultsBox.put(resultKey, restoredResult);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error restoring training result: $e');
      return false;
    }
  }

  /// Remove all training results for a specific day and exercise
  Future<bool> removeAllResultsForDayAndExercise(DateTime date, String exerciseId) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(Duration(days: 1));
      
      bool anyDeleted = false;
      final keysToUpdate = <String>[];
      final resultsToUpdate = <TrainingResult>[];
      
      // Find all results for this date and exercise
      for (final key in _resultsBox.keys) {
        final result = _resultsBox.get(key);
        if (result != null && 
            result.exerciseId == exerciseId &&
            result.deletedAt == null &&
            result.date.isAfter(startOfDay.subtract(Duration(milliseconds: 1))) &&
            result.date.isBefore(endOfDay)) {
          
          // Create deleted version of the result
          final deletedResult = TrainingResult(
            date: result.date,
            duration: result.duration,
            cycles: result.cycles,
            exerciseId: result.exerciseId,
            deletedAt: DateTime.now(),
          );
          
          keysToUpdate.add(key);
          resultsToUpdate.add(deletedResult);
          anyDeleted = true;
        }
      }
      
      // Update all found results to deleted state
      for (int i = 0; i < keysToUpdate.length; i++) {
        await _resultsBox.put(keysToUpdate[i], resultsToUpdate[i]);
      }
      
      debugPrint('Removed ${keysToUpdate.length} results for ${DateFormat('yyyy-MM-dd').format(date)} and exercise $exerciseId');
      return anyDeleted;
    } catch (e) {
      debugPrint('Error removing results for day and exercise: $e');
      return false;
    }
  }

  /// Get all training results for a specific date (including deleted ones)
  List<TrainingResult> getAllResultsForDate(DateTime date, {bool includeDeleted = false}) {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(Duration(days: 1));
      
      return _resultsBox.values
          .where((result) => 
              (includeDeleted || result.deletedAt == null) &&
              result.date.isAfter(startOfDay.subtract(Duration(milliseconds: 1))) &&
              result.date.isBefore(endOfDay))
          .toList();
    } catch (e) {
      debugPrint('Error loading results for date $date: $e');
      return [];
    }
  }

  /// Get best results per day for display (only non-deleted)
  Future<List<TrainingResult>> getBestResultsPerDay({int? limitDays}) async {
    try {
      final allResults = _resultsBox.values
          .where((result) => result.deletedAt == null)
          .toList();

      // Group results by date
      final resultsByDate = <String, List<TrainingResult>>{};
      for (final result in allResults) {
        final dateKey = DateFormat('yyyy-MM-dd').format(result.date);
        if (!resultsByDate.containsKey(dateKey)) {
          resultsByDate[dateKey] = [];
        }
        resultsByDate[dateKey]!.add(result);
      }

      // Get best result for each date
      final bestResults = <TrainingResult>[];
      for (final results in resultsByDate.values) {
        results.sort((a, b) => a.isBetterThan(b) ? -1 : 1);
        bestResults.add(results.first);
      }

      // Sort by date and limit if specified
      bestResults.sort((a, b) => b.date.compareTo(a.date));
      if (limitDays != null && limitDays > 0) {
        return bestResults.take(limitDays).toList();
      }

      return bestResults;
    } catch (e) {
      debugPrint('Error getting best results per day: $e');
      return [];
    }
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
    await saveTrainingResult(result);
  }

  Future<void> addTrainingResult(TrainingResult result) async {
    await saveTrainingResult(result);
  }

  Future<List<TrainingResult>> getResults() async {
    return await getAllResults();
  }

  /// Triggers auto-sync when data is changed
  void _triggerAutoSync() {
    try {
      final syncService = SyncService();
      if (syncService.isLoggedIn) {
        // Trigger sync in background without awaiting
        syncService.retrySync();
      }
    } catch (e) {
      debugPrint('Auto-sync trigger error: $e');
    }
  }
}