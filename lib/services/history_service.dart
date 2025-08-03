import 'package:flutter/material.dart';
import '../models/breathing_exercise.dart';
import '../models/training_result.dart';
import 'storage_service.dart';

/// Service for managing training history data and organization
class HistoryService extends ChangeNotifier {
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();

  final StorageService _storageService = StorageService();

  // History data
  List<TrainingResult> _results = [];
  Map<String, List<TrainingResult>> _resultsByExercise = {};
  Map<String, BreathingExercise> _exercises = {};
  bool _isLoading = false;

  // Getters
  List<TrainingResult> get results => List.unmodifiable(_results);
  Map<String, List<TrainingResult>> get resultsByExercise => Map.unmodifiable(_resultsByExercise);
  Map<String, BreathingExercise> get exercises => Map.unmodifiable(_exercises);
  bool get isLoading => _isLoading;
  bool get hasResults => _results.isNotEmpty;

  /// Load and organize all training results
  Future<void> loadResults() async {
    if (_isLoading) return;
    
    _setLoading(true);
    try {
      // Load results from data manager
      final results = await StorageService().getResults();
      
      // Load exercises to match exercise IDs
      final exercises = await _storageService.loadExercises();
      final exerciseMap = <String, BreathingExercise>{};
      for (final exercise in exercises) {
        exerciseMap[exercise.id] = exercise;
      }
      
      // Group results by exercise ID
      final resultsByExercise = <String, List<TrainingResult>>{};
      for (final result in results) {
        final exerciseId = result.exerciseId.isEmpty ? 'unknown' : result.exerciseId;
        if (!resultsByExercise.containsKey(exerciseId)) {
          resultsByExercise[exerciseId] = [];
        }
        resultsByExercise[exerciseId]!.add(result);
      }
      
      // Sort results by date within each exercise group
      for (final exerciseResults in resultsByExercise.values) {
        exerciseResults.sort((a, b) => b.date.compareTo(a.date));
      }
      
      _results = results;
      _resultsByExercise = resultsByExercise;
      _exercises = exerciseMap;
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading results: $e');
      // Keep existing data on error
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh the history data
  Future<void> refresh() async {
    _results.clear();
    _resultsByExercise.clear();
    _exercises.clear();
    await loadResults();
  }

  /// Get results for a specific exercise
  List<TrainingResult> getResultsForExercise(String exerciseId) {
    return _resultsByExercise[exerciseId] ?? [];
  }

  /// Get exercise by ID
  BreathingExercise? getExerciseById(String exerciseId) {
    return _exercises[exerciseId];
  }

  /// Get exercise name for display
  String getExerciseDisplayName(String exerciseId) {
    final exercise = _exercises[exerciseId];
    if (exercise != null) {
      return exercise.name;
    }
    return exerciseId == 'unknown' ? 'Unknown' : exerciseId;
  }

  /// Get exercise color for display
  Color getExerciseColor(String exerciseId, Color defaultColor) {
    final exercise = _exercises[exerciseId];
    if (exercise?.phases.isNotEmpty == true) {
      return exercise!.phases.first.color;
    }
    return defaultColor;
  }

  /// Calculate total statistics
  HistoryStats calculateStats() {
    if (_results.isEmpty) {
      return HistoryStats.empty();
    }

    final totalSessions = _results.length;
    final totalDuration = _results.fold<int>(0, (sum, result) => sum + result.duration);
    final avgDuration = totalDuration ~/ totalSessions;
    final totalCycles = _results.fold<int>(0, (sum, result) => sum + result.cycles);

    return HistoryStats(
      totalSessions: totalSessions,
      totalDuration: totalDuration,
      avgDuration: avgDuration,
      totalCycles: totalCycles,
    );
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

/// Statistics data class
class HistoryStats {
  final int totalSessions;
  final int totalDuration;
  final int avgDuration;
  final int totalCycles;

  const HistoryStats({
    required this.totalSessions,
    required this.totalDuration,
    required this.avgDuration,
    required this.totalCycles,
  });

  factory HistoryStats.empty() {
    return const HistoryStats(
      totalSessions: 0,
      totalDuration: 0,
      avgDuration: 0,
      totalCycles: 0,
    );
  }
}