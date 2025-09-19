import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/breathing_exercise.dart';
import '../models/breath_phase.dart';
import 'initial_training_service.dart';

/// Service for managing breathing exercise business logic
class ExerciseService extends ChangeNotifier {
  static final ExerciseService _instance = ExerciseService._internal();
  factory ExerciseService() => _instance;
  ExerciseService._internal();

  // Service dependencies  
  final InitialTrainingService _initialTrainingService = InitialTrainingService();
  final Uuid _uuid = const Uuid();
  
  // Current exercise being edited
  BreathingExercise? _currentExercise;
 
  final Map<int, String> _phaseErrors = {};
  String? _generalError;
  
  // Getters for current state
  BreathingExercise? get currentExercise => _currentExercise;
  List<BreathPhase>? get currentPhases => _currentExercise?.phases != null 
      ? List<BreathPhase>.from(_currentExercise!.phases) 
      : null;
  Map<int, String> get phaseErrors => _phaseErrors;
  String? get generalError => _generalError;

  /// Validates if cycles count is within allowed bounds
  bool isValidCyclesCount(BreathingExercise exercise, int cycles) {
    return cycles >= exercise.minCycles && cycles <= exercise.maxCycles;
  }

  /// Validates if cycle duration is within allowed bounds and step constraints
  bool isValidCycleDuration(BreathingExercise exercise, int duration) {
    if (duration < exercise.minCycleDuration || duration > exercise.maxCycleDuration) {
      return false;
    }
    return true;
  }

  /// Updates the cycles count if valid and editable
  BreathingExercise? updateCycles(BreathingExercise exercise, int newCycles) {
    if (!exercise.canEditCyclesCountCalculated || !isValidCyclesCount(exercise, newCycles)) {
      return null;
    }
    
    final updated = exercise.copyWith(
      cycles: newCycles,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
    return updated;
  }

  /// Updates the cycle duration and recalculates phases
  BreathingExercise? updateCycleDuration(BreathingExercise exercise, int newDuration) {
    newDuration = newDuration.clamp(
      exercise.minCycleDuration,
      exercise.maxCycleDuration,
    );
    if (!exercise.canEditCycleDurationCalculated || !isValidCycleDuration(exercise, newDuration)) {
      return null;
    }

    newDuration =  (newDuration - exercise.minCycleDuration)~/exercise.cycleDurationStep * exercise.cycleDurationStep  + exercise.minCycleDuration;


    final recalculatedPhases = _recalculatePhases(exercise, newDuration);
    final updated = exercise.copyWith(
      cycleDuration: newDuration,
      phases: recalculatedPhases,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
    return updated;
  }


  /// Creates a new exercise with default settings
  BreathingExercise createNewExercise({
    String? name,
    String? description,
    int? cycles,
    int? cycleDuration,
  }) {
    return _initialTrainingService.createDefaultExercise(
      name: name ?? 'New Exercise',
      description: description ?? '',
      cycles: cycles,
      cycleDuration: cycleDuration,
    );
  }

  /// Creates a new custom exercise for the exercise page
  BreathingExercise createCustomExercise(BuildContext context) {
    return BreathingExercise(
      id: _uuid.v4(),
      name: 'New Exercise',
      description: 'Custom breathing exercise',
      createdAt: DateTime.now(),
      minCycles: 1,
      maxCycles: 9,
      cycleDurationStep: 5,
      cycles: 5,
      cycleDuration: 30,
      phases: createDefaultPhases(context),
    );
  }

  /// Creates default phases for custom exercises
  List<BreathPhase> createDefaultPhases(BuildContext context) {
    return [
      BreathPhase(
        name: 'Breathe In',
        duration: 4,
        minDuration: 2,
        maxDuration: 8,
        color: Theme.of(context).colorScheme.primary,
        claps: 1,
      ),
      BreathPhase(
        name: 'Hold',
        duration: 4,
        minDuration: 2,
        maxDuration: 8,
        color: Theme.of(context).colorScheme.secondary,
        claps: 2,
      ),
      BreathPhase(
        name: 'Breathe Out',
        duration: 6,
        minDuration: 3,
        maxDuration: 10,
        color: Theme.of(context).colorScheme.tertiary,
        claps: 3,
      ),
      BreathPhase(
        name: 'Rest',
        duration: 2,
        minDuration: 1,
        maxDuration: 5,
        color: Theme.of(context).colorScheme.secondaryContainer,
        claps: 1,
      ),
    ];
  }


  /// Recalculates phases proportionally based on new total duration
  List<BreathPhase> _recalculatePhases(BreathingExercise exercise, int targetDuration) {
    final phases = exercise.phases;
    if (phases.isEmpty) return phases;


    final minTotal = phases.fold(0, (sum, phase) => sum + phase.minDuration);
    final maxTotal = phases.fold(0, (sum, phase) => sum + phase.maxDuration);
    
    if (maxTotal == minTotal) {
      return phases; // No scaling needed
    }

    final clampedDuration = targetDuration.clamp(minTotal, maxTotal);
    final scale = (clampedDuration - minTotal) / (maxTotal - minTotal);

    double remainingError = 0;
    final recalculatedPhases = <BreathPhase>[];

    for (int i = 0; i < phases.length; i++) {
      final phase = phases[i];
      final targetPhaseDuration = phase.minDuration + 
          (scale * (phase.maxDuration - phase.minDuration)) + remainingError;
      
      final newDuration = targetPhaseDuration.round().clamp(
        phase.minDuration, 
        phase.maxDuration
      );
      
      remainingError = targetPhaseDuration - newDuration;
      
      recalculatedPhases.add(phase.copyWith(duration: newDuration));
    }

    // Final adjustment to match exact target duration
    final totalDuration = recalculatedPhases.fold(0, (sum, phase) => sum + phase.duration);
    final adjustment = clampedDuration - totalDuration;
    
    if (adjustment != 0) {
      // Find the first adjustable phase
      for (int i = 0; i < recalculatedPhases.length; i++) {
        final phase = recalculatedPhases[i];
        if (phase.minDuration == phase.maxDuration) continue;
        
        final newDuration = (phase.duration + adjustment).clamp(
          phase.minDuration, 
          phase.maxDuration
        );
        
        recalculatedPhases[i] = phase.copyWith(duration: newDuration);
        break;
      }
    }

    return recalculatedPhases;
  }

  /// Creates default exercises for new users
  List<BreathingExercise> createDefaultExercises() {
    return _initialTrainingService.createInitialTrainingSet();
  }

  /// Sets the current exercise being edited
  void setCurrentExercise(BreathingExercise exercise) {
    _currentExercise = exercise;
    _phaseErrors.clear();
    _generalError = null;
    notifyListeners();
  }


  /// Clears the current exercise state
  void clearCurrentExercise() {
    _currentExercise = null;
    _phaseErrors.clear();
    _generalError = null;
    notifyListeners();
  }

  /// Updates exercise name
  void updateExerciseName(String name) {
    if (_currentExercise != null) {
      _currentExercise = _currentExercise!.copyWith(name: name);
      notifyListeners();
    }
  }

  /// Updates exercise description
  void updateExerciseDescription(String description) {
    if (_currentExercise != null) {
      _currentExercise = _currentExercise!.copyWith(description: description);
      notifyListeners();
    }
  }

  /// Updates exercise cycles configuration
  void updateExerciseCycles(int minCycles, int? maxCycles) {
    if (_currentExercise != null) {
      _currentExercise = _currentExercise!.copyWith(
        minCycles: minCycles,
        maxCycles: maxCycles ?? minCycles,
      );
      notifyListeners();
    }
  }

  /// Updates cycle duration step
  void updateCycleDurationStep(int step) {
    if (_currentExercise != null) {
      _currentExercise = _currentExercise!.copyWith(cycleDurationStep: step);
      notifyListeners();
    }
  }

  /// Updates cycle duration range - no longer needed as it's calculated from phases
  @Deprecated('Cycle duration range is now calculated from phases')
  void updateCycleDurationRange(int minDuration, int maxDuration) {
    // This method is deprecated - cycle duration range is now calculated from phases
    // No action needed as the range is automatically calculated
  }

  /// Calculates if cycle duration editing should be enabled
  bool canEditCycleDuration() {
    return _currentExercise!.canEditCycleDurationCalculated; 
  }

  /// Validates all phases and returns validation results
  Map<String, dynamic> validatePhases() {
    _phaseErrors.clear();
    _generalError = null;
    
    if (currentPhases == null) {
      _generalError = 'No phases to validate';
      return {'isValid': false, 'errors': _phaseErrors, 'generalError': _generalError};
    }

    final phases = _currentExercise!.phases;
    for (int i = 0; i < phases.length; i++) {
      final phase = phases[i];
      
      if (phase.name.trim().isEmpty) {
        _phaseErrors[i] = 'Phase name cannot be empty';
        continue;
      }
      
      //not checking for duplicate names 
      // for (int j = i + 1; j < phases.length; j++) {
      //   if (phases[j].name.trim().toLowerCase() == phase.name.trim().toLowerCase()) {
      //     _phaseErrors[i] = 'Phase name must be unique';
      //     break;
      //   }
      // }
      
      if (phase.minDuration > phase.maxDuration) {
        _phaseErrors[i] = 'Minimum duration cannot exceed maximum duration';
      }
      
      if (phase.minDuration < 0 || phase.maxDuration < 0) {
        _phaseErrors[i] = 'Duration cannot be negative';
      }
    }

    notifyListeners();
    return {
      'isValid': _phaseErrors.isEmpty && _generalError == null,
      'errors': _phaseErrors,
      'generalError': _generalError
    };
  }

  /// Helper method to update current exercise with new phases and sync cycleDuration
  void _updatePhasesAndSyncDuration(List<BreathPhase> newPhases) {
    final newTotalDuration = newPhases.fold(0, (sum, phase) => sum + phase.duration);
    _currentExercise = _currentExercise!.copyWith(
      phases: newPhases,
      cycleDuration: newTotalDuration,
      updatedAt: DateTime.now(),
    );
  }

  /// Updates a phase name
  void updatePhaseName(int index, String name) {
    if (_currentExercise?.phases != null && index < _currentExercise!.phases.length) {
      final phases = List<BreathPhase>.from(_currentExercise!.phases);
      phases[index] = phases[index].copyWith(name: name);
      _updatePhasesAndSyncDuration(phases);
      validatePhases();
    }
  }

  /// Updates a phase color
  void updatePhaseColor(int index, Color color) {
    if (_currentExercise?.phases != null && index < _currentExercise!.phases.length) {
      final phases = List<BreathPhase>.from(_currentExercise!.phases);
      phases[index] = phases[index].copyWith(color: color);
      _updatePhasesAndSyncDuration(phases);
      notifyListeners();
    }
  }

  /// Updates a phase claps count
  void updatePhaseClaps(int index, int claps) {
    if (_currentExercise?.phases != null && index < _currentExercise!.phases.length && claps >= 1 && claps <= 3) {
      final phases = List<BreathPhase>.from(_currentExercise!.phases);
      phases[index] = phases[index].copyWith(claps: claps);
      _updatePhasesAndSyncDuration(phases);
      notifyListeners();
    }
  }

  /// Updates a phase minimum duration
  void updatePhaseMinDuration(int index, int duration) {
    if (_currentExercise?.phases != null && index < _currentExercise!.phases.length && duration >= 0) {
      final phases = List<BreathPhase>.from(_currentExercise!.phases);
      final currentPhase = phases[index];
      final newDuration = currentPhase.duration < duration ? duration : currentPhase.duration;
      phases[index] = phases[index].copyWith(minDuration: duration, duration: newDuration);
      _updatePhasesAndSyncDuration(phases);
      validatePhases();
    }
  }

  /// Updates a phase maximum duration
  void updatePhaseMaxDuration(int index, int duration) {
    if (_currentExercise?.phases != null && index < _currentExercise!.phases.length && duration >= 0) {
      final phases = List<BreathPhase>.from(_currentExercise!.phases);
      final currentPhase = phases[index];
      final newDuration = currentPhase.duration > duration ? duration : currentPhase.duration;
      phases[index] = phases[index].copyWith(maxDuration: duration, duration: newDuration);
      _updatePhasesAndSyncDuration(phases);
      validatePhases();
    }
  }

  /// Adds a new phase
  void addPhase(BuildContext context) {
    if (_currentExercise?.phases != null && _currentExercise!.phases.length < 8) {
      final phases = List<BreathPhase>.from(_currentExercise!.phases);
      final availableColors = _getAvailableColors(context);
      final newPhase = BreathPhase(
        name: 'Phase ${phases.length + 1}',
        duration: 5,
        minDuration: 1,
        maxDuration: 30,
        color: availableColors[phases.length % availableColors.length],
        claps: 1,
      );
      
      phases.add(newPhase);
      _updatePhasesAndSyncDuration(phases);
      validatePhases();
    }
  }

  /// Removes a phase
  void removePhase(int index) {
    if (_currentExercise?.phases != null && _currentExercise!.phases.length > 1 && index < _currentExercise!.phases.length) {
      final phases = List<BreathPhase>.from(_currentExercise!.phases);
      phases.removeAt(index);
      _phaseErrors.remove(index);
      _updatePhasesAndSyncDuration(phases);
      validatePhases();
    }
  }

  /// Duplicates a phase
  void duplicatePhase(int index) {
    if (_currentExercise?.phases != null && _currentExercise!.phases.length < 8 && index < _currentExercise!.phases.length) {
      final phases = List<BreathPhase>.from(_currentExercise!.phases);
      final originalPhase = phases[index];
      final duplicatedPhase = originalPhase.copyWith(
        name: '${originalPhase.name} Copy',
      );
      
      phases.insert(index + 1, duplicatedPhase);
      _updatePhasesAndSyncDuration(phases);
      validatePhases();
    }
  }

  /// Reorders phases
  void reorderPhases(int oldIndex, int newIndex) {
    if (_currentExercise?.phases != null && oldIndex < _currentExercise!.phases.length && newIndex <= _currentExercise!.phases.length) {
      final phases = List<BreathPhase>.from(_currentExercise!.phases);
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = phases.removeAt(oldIndex);
      phases.insert(newIndex, item);
      _currentExercise = _currentExercise!.copyWith(phases: phases);
      notifyListeners();
    }
  }

 

  /// Gets available colors for phases
  List<Color> _getAvailableColors(BuildContext context) {
    return [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.secondary,
      Theme.of(context).colorScheme.tertiary,
      Theme.of(context).colorScheme.secondaryContainer,
      Theme.of(context).colorScheme.primaryContainer,
      Theme.of(context).colorScheme.tertiaryContainer,
      Theme.of(context).colorScheme.error,
      Theme.of(context).colorScheme.errorContainer,
    ];
  }

  /// Gets available colors for UI
  List<Color> getAvailableColors(BuildContext context) => _getAvailableColors(context);

  /// Helper methods for common UI patterns
  bool canAddPhase() => (currentPhases?.length ?? 0) < 8;
  
  bool canRemovePhase() => (currentPhases?.length ?? 0) > 1;
  
  int get phaseCount => currentPhases?.length ?? 0;
  
  bool get hasValidExercise => _currentExercise != null && currentPhases != null;

  /// Duration calculation methods
  int getMinTotalDuration() {
    if (currentPhases == null) return 0;
    return currentPhases!.fold(0, (sum, phase) => sum + phase.minDuration);
  }

  int getMaxTotalDuration() {
    if (currentPhases == null) return 0;
    return currentPhases!.fold(0, (sum, phase) => sum + phase.maxDuration);
  }

  int getCurrentTotalDuration() {
    if (currentPhases == null) return 0;
    return currentPhases!.fold(0, (sum, phase) => sum + phase.duration);
  }
}