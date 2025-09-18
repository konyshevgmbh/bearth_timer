import 'package:flutter/material.dart';
import '../models/breathing_exercise.dart';
import '../models/training_result.dart';
import 'storage_service.dart';

enum HistoryDisplayMode {
  bestPerDay,
  allResults,
}

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
  HistoryDisplayMode _displayMode = HistoryDisplayMode.bestPerDay;

  // Getters
  List<TrainingResult> get results => List.unmodifiable(_results);
  Map<String, List<TrainingResult>> get resultsByExercise => Map.unmodifiable(_resultsByExercise);
  Map<String, BreathingExercise> get exercises => Map.unmodifiable(_exercises);
  bool get isLoading => _isLoading;
  bool get hasResults => _results.isNotEmpty;
  HistoryDisplayMode get displayMode => _displayMode;

  /// Set display mode and reload results
  Future<void> setDisplayMode(HistoryDisplayMode mode) async {
    if (_displayMode != mode) {
      _displayMode = mode;
      await _processResults();
      notifyListeners();
    }
  }

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
      
      // Process results based on display mode
      for (final exerciseId in resultsByExercise.keys) {
        final exerciseResults = resultsByExercise[exerciseId]!;
        
        if (_displayMode == HistoryDisplayMode.bestPerDay) {
          // Group by date (yyyy-MM-dd)
          final resultsByDate = <String, List<TrainingResult>>{};
          for (final result in exerciseResults) {
            final dateKey = '${result.date.year}-${result.date.month.toString().padLeft(2, '0')}-${result.date.day.toString().padLeft(2, '0')}';
            if (!resultsByDate.containsKey(dateKey)) {
              resultsByDate[dateKey] = [];
            }
            resultsByDate[dateKey]!.add(result);
          }
          
          // Keep only the best result for each date
          final bestResults = <TrainingResult>[];
          for (final dateResults in resultsByDate.values) {
            // Sort by score (cycles * duration) descending, then by date descending
            dateResults.sort((a, b) {
              final scoreComparison = b.score.compareTo(a.score);
              if (scoreComparison != 0) return scoreComparison;
              return b.date.compareTo(a.date);
            });
            bestResults.add(dateResults.first);
          }
          
          // Sort results by date (most recent first)
          bestResults.sort((a, b) => b.date.compareTo(a.date));
          resultsByExercise[exerciseId] = bestResults;
        } else {
          // Show all results, sorted by date (most recent first)
          exerciseResults.sort((a, b) => b.date.compareTo(a.date));
          resultsByExercise[exerciseId] = exerciseResults;
        }
      }
      
      _results = results;
      _resultsByExercise = resultsByExercise;
      _exercises = exerciseMap;
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

  /// Process results based on current display mode
  Future<void> _processResults() async {
    if (_results.isEmpty) return;
    
    // Load exercises to match exercise IDs
    final exercises = await _storageService.loadExercises();
    final exerciseMap = <String, BreathingExercise>{};
    for (final exercise in exercises) {
      exerciseMap[exercise.id] = exercise;
    }
    
    // Group results by exercise ID
    final resultsByExercise = <String, List<TrainingResult>>{};
    for (final result in _results) {
      final exerciseId = result.exerciseId.isEmpty ? 'unknown' : result.exerciseId;
      if (!resultsByExercise.containsKey(exerciseId)) {
        resultsByExercise[exerciseId] = [];
      }
      resultsByExercise[exerciseId]!.add(result);
    }
    
    // Process results based on display mode
    for (final exerciseId in resultsByExercise.keys) {
      final exerciseResults = resultsByExercise[exerciseId]!;
      
      if (_displayMode == HistoryDisplayMode.bestPerDay) {
        // Group by date (yyyy-MM-dd)
        final resultsByDate = <String, List<TrainingResult>>{};
        for (final result in exerciseResults) {
          final dateKey = '${result.date.year}-${result.date.month.toString().padLeft(2, '0')}-${result.date.day.toString().padLeft(2, '0')}';
          if (!resultsByDate.containsKey(dateKey)) {
            resultsByDate[dateKey] = [];
          }
          resultsByDate[dateKey]!.add(result);
        }
        
        // Keep only the best result for each date
        final bestResults = <TrainingResult>[];
        for (final dateResults in resultsByDate.values) {
          // Sort by score (cycles * duration) descending, then by date descending
          dateResults.sort((a, b) {
            final scoreComparison = b.score.compareTo(a.score);
            if (scoreComparison != 0) return scoreComparison;
            return b.date.compareTo(a.date);
          });
          bestResults.add(dateResults.first);
        }
        
        // Sort results by date (most recent first)
        bestResults.sort((a, b) => b.date.compareTo(a.date));
        resultsByExercise[exerciseId] = bestResults;
      } else {
        // Show all results, sorted by date (most recent first)
        exerciseResults.sort((a, b) => b.date.compareTo(a.date));
        resultsByExercise[exerciseId] = exerciseResults;
      }
    }
    
    _resultsByExercise = resultsByExercise;
    _exercises = exerciseMap;
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

  /// Calculate average daily change from the last 2 results
  double _calculateAverageDailyChange(List<TrainingResult> results, int Function(TrainingResult) getValue) {
    if (results.length < 2) return 0.0;
    
    // Sort results by date and take only the last 2
    final sortedResults = List<TrainingResult>.from(results)
      ..sort((a, b) => a.date.compareTo(b.date));
    
    final last2Results = sortedResults.skip(sortedResults.length - 2).toList();
    final values = last2Results.map(getValue).toList();
    final days = last2Results.map((r) => r.date.millisecondsSinceEpoch ~/ (1000 * 60 * 60 * 24)).toList();
    
    final daysDiff = days[1] - days[0];
    if (daysDiff > 0) {
      return (values[1] - values[0]) / daysDiff;
    }
    return 0.0;
  }

  /// Calculate statistics for a specific exercise
  HistoryStats calculateStatsForExercise(String exerciseId) {
    final exerciseResults = getResultsForExercise(exerciseId);
    if (exerciseResults.isEmpty) {
      return HistoryStats.empty();
    }

    final totalSessions = exerciseResults.length;
    final totalScore = exerciseResults.fold<int>(0, (sum, result) => sum + result.score.toInt());
    
    // Calculate average daily duration change
    final dailyDurationDiff = _calculateAverageDailyChange(exerciseResults, (r) => r.duration);
    
    // Calculate average daily cycle change
    final dailyCycleDiff = _calculateAverageDailyChange(exerciseResults, (r) => r.cycles);
    
    // Calculate best score (highest score in a single session)
    final bestScore = exerciseResults.isEmpty ? 0 : exerciseResults.map((r) => r.score).reduce((a, b) => a > b ? a : b).toInt();

    return HistoryStats(
      totalSessions: totalSessions,
      totalScore: totalScore,
      dailyDurationDiff: dailyDurationDiff,
      dailyCycleDiff: dailyCycleDiff,
      bestScore: bestScore,
    );
  }

  /// Calculate total statistics
  HistoryStats calculateStats() {
    if (_results.isEmpty) {
      return HistoryStats.empty();
    }

    final totalSessions = _results.length;
    final totalScore = _results.fold<int>(0, (sum, result) => sum + result.score.toInt());
    
    // Calculate average daily duration change
    final dailyDurationDiff = _calculateAverageDailyChange(_results, (r) => r.duration);
    
    // Calculate average daily cycle change
    final dailyCycleDiff = _calculateAverageDailyChange(_results, (r) => r.cycles);
    
    // Calculate best score (highest cycles in a single session)
    final bestScore = _results.isEmpty ? 0 : _results.map((r) => r.cycles).reduce((a, b) => a > b ? a : b);

    return HistoryStats(
      totalSessions: totalSessions,
      totalScore: totalScore,
      dailyDurationDiff: dailyDurationDiff,
      dailyCycleDiff: dailyCycleDiff,
      bestScore: bestScore,
    );
  }

  /// Get the next timestamp that's guaranteed to be after the existing result timestamp
  DateTime _getNextTimestamp(TrainingResult result) {
    final now = DateTime.now().toUtc();
    final maxExisting = [result.date, result.deletedAt]
        .where((date) => date != null)
        .cast<DateTime>()
        .fold<DateTime?>(null, (max, date) => max == null || date.isAfter(max) ? date : max);
    
    if (maxExisting == null) return now;
    
    // Return either now or maxExisting + 1 millisecond, whichever is later
    final nextTimestamp = maxExisting.add(Duration(milliseconds: 1));
    return nextTimestamp.isAfter(now) ? nextTimestamp : now;
  }

  /// Remove all training results for the same day and exercise as the given result
  Future<bool> removeResult(TrainingResult result) async {
    try {
      // Remove all results for the same day and exercise
      final success = await _storageService.removeAllResultsForDayAndExercise(
        result.date, 
        result.exerciseId
      );
      
      if (success) {
        // Refresh the data to update UI
        await refresh();
      }
      
      return success;
    } catch (e) {
      debugPrint('Error removing results: $e');
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

/// Statistics data class
class HistoryStats {
  final int totalSessions;
  final int totalScore;
  final double dailyDurationDiff;
  final double dailyCycleDiff;
  final int bestScore;

  const HistoryStats({
    required this.totalSessions,
    required this.totalScore,
    required this.dailyDurationDiff,
    required this.dailyCycleDiff,
    required this.bestScore,
  });

  factory HistoryStats.empty() {
    return const HistoryStats(
      totalSessions: 0,
      totalScore: 0,
      dailyDurationDiff: 0.0,
      dailyCycleDiff: 0.0,
      bestScore: 0,
    );
  }
}