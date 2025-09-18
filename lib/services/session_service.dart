import 'dart:async';
import 'package:flutter/material.dart';
import '../models/breathing_exercise.dart';
import '../models/breath_phase.dart';
import '../models/training_result.dart';
import '../models/user_settings.dart';
import '../core/constants.dart';
import 'sync_service.dart';
import 'storage_service.dart';
import 'exercise_service.dart';
import 'sound_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../i18n/strings.g.dart';

/// Session events
enum SessionEventType {
  sessionStart,
  sessionStop,
  phaseTransition,
  sessionComplete,
}

/// Session event data
class SessionEvent {
  final SessionEventType type;
  final BreathPhase? phase;

  const SessionEvent(this.type, [this.phase]);
}

/// Service for managing training session state and timer logic
class SessionService extends ChangeNotifier {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  // Core session state - calculated from startTime
  DateTime? _startTime;

  // Constants
  final int _waitPhaseDuration = TrainingConstants.waitPhaseDuration;

  // Current exercise reference
  BreathingExercise? _currentExercise;
  
  // Service dependencies
  final StorageService _storageService = StorageService();
  final ExerciseService _exerciseService = ExerciseService();
  
  // Event stream for session events
  final StreamController<SessionEvent> _eventController = StreamController<SessionEvent>.broadcast();
  
  // Timer for session updates
  Timer? _timer;
  
  // Track last sent phase event to avoid duplicates
  int _lastSentPhaseIndex = -1;
  
  // Initialization state
  bool _isInitialized = false;

  // Getters for current state - calculated from startTime
  int get currentCycle => _calculateCurrentCycle();
  int get currentPhaseIndex => _calculateCurrentPhaseIndex();
  int get secondsLeftInPhase => _calculateSecondsLeftInPhase();
  int get totalElapsed => _calculateTotalElapsed();
  bool get isInWaitPhase => _calculateIsInWaitPhase();
  bool get isRunning => _timer != null && _timer!.isActive;
  bool get isDone => _startTime != null && !isRunning;
  BreathingExercise? get currentExercise => _currentExercise;
  bool get isInitialized => _isInitialized;

  /// Stream of session events
  Stream<SessionEvent> get events => _eventController.stream;

  /// Emit a session event
  void _emitEvent(SessionEventType eventType, [BreathPhase? phase]) {
    _eventController.add(SessionEvent(eventType, phase));
  }

  /// Emit a session event (for testing)
  @visibleForTesting
  void emitEvent(SessionEventType eventType, [BreathPhase? phase]) {
    _emitEvent(eventType, phase);
  }

  /// Set start time (for testing)
  @visibleForTesting
  set startTime(DateTime? time) {
    _startTime = time;
  }

  /// Calculate current cycle from elapsed time
  int _calculateCurrentCycle() {
    if (_currentExercise == null || _startTime == null || isInWaitPhase) return 1;
    
    final elapsedMs = DateTime.now().difference(_startTime!).inMilliseconds - (_waitPhaseDuration * 1000);
    if (elapsedMs <= 0) return 1;
    
    final cycleDurationMs = _currentExercise!.totalPhaseDuration * 1000;
    if (cycleDurationMs <= 0) return 1;
    
    return (elapsedMs / cycleDurationMs).floor() + 1;
  }

  /// Calculate current phase index from elapsed time
  int _calculateCurrentPhaseIndex() {
    if (_currentExercise == null || _startTime == null || isInWaitPhase) return 0;
    
    final elapsedMs = DateTime.now().difference(_startTime!).inMilliseconds - (_waitPhaseDuration * 1000);
    if (elapsedMs <= 0) return 0;
    
    final cycleDurationMs = _currentExercise!.totalPhaseDuration * 1000;
    if (cycleDurationMs <= 0) return 0;
    
    final timeInCurrentCycleMs = elapsedMs % cycleDurationMs;
    int phaseTimeMs = 0;
    
    for (int i = 0; i < _currentExercise!.phases.length; i++) {
      phaseTimeMs += _currentExercise!.phases[i].duration * 1000;
      if (timeInCurrentCycleMs < phaseTimeMs) {
        return i;
      }
    }
    
    return _currentExercise!.phases.length - 1;
  }

  /// Calculate seconds left in current phase from elapsed time
  int _calculateSecondsLeftInPhase() {
    if (_currentExercise == null || _startTime == null) return 0;
    
    final elapsedMs = DateTime.now().difference(_startTime!).inMilliseconds;
    
    if (isInWaitPhase) {
      final remainingMs = (_waitPhaseDuration * 1000) - elapsedMs;
      return (remainingMs / 1000).clamp(0, _waitPhaseDuration).ceil();
    }
    
    final adjustedElapsedMs = elapsedMs - (_waitPhaseDuration * 1000);
    if (adjustedElapsedMs <= 0) return 0;
    
    final cycleDurationMs = _currentExercise!.totalPhaseDuration * 1000;
    if (cycleDurationMs <= 0) return 0;
    
    final timeInCurrentCycleMs = adjustedElapsedMs % cycleDurationMs;
    int phaseTimeMs = 0;
    
    for (int i = 0; i < _currentExercise!.phases.length; i++) {
      final phaseDurationMs = _currentExercise!.phases[i].duration * 1000;
      if (timeInCurrentCycleMs < phaseTimeMs + phaseDurationMs) {
        final remainingMs = phaseTimeMs + phaseDurationMs - timeInCurrentCycleMs;
        return (remainingMs / 1000).clamp(0, _currentExercise!.phases[i].duration).ceil();
      }
      phaseTimeMs += phaseDurationMs;
    }
    
    return 0;
  }

  /// Calculate total elapsed time from start
  int _calculateTotalElapsed() {
    if (_startTime == null) return 0;
    return (DateTime.now().difference(_startTime!).inMilliseconds / 1000).ceil();
  }

  /// Get elapsed time since timer start in milliseconds (for logging purposes)
  int getElapsedTimeMs() {
    if (_startTime == null) return 0;
    return DateTime.now().difference(_startTime!).inMilliseconds;
  }

  /// Calculate if session is in wait phase
  bool _calculateIsInWaitPhase() {
    if (_startTime == null) return false;
    final elapsedMs = DateTime.now().difference(_startTime!).inMilliseconds;
    return elapsedMs < (_waitPhaseDuration * 1000);
  }


  /// Initialize the session service with an exercise
  Future<void> initialize({BreathingExercise? initialExercise}) async {
    if (_isInitialized) return;
    
    try {
      // Initialize sound service to ensure it's ready to receive events
      await SoundService().initialize();
      
      if (initialExercise != null ) {
        setExercise(initialExercise);
      } else if(_currentExercise == null){
        await _loadDefaultExercise();
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing SessionService: $e');
      // Fallback to creating new exercise
      final fallbackExercise = _exerciseService.createNewExercise();
      setExercise(fallbackExercise);
      _isInitialized = true;
    }
  }

  /// Load default exercise from storage with user preferences applied
  Future<void> _loadDefaultExercise() async {
    try {
      final exerciseToUse = await selectDefaultExercise();
      setExercise(exerciseToUse);
    } catch (e) {
      debugPrint('Error loading default exercise: $e');
      rethrow;
    }
  }

  /// Select the most appropriate default exercise based on last result or alphabetical order
  Future<BreathingExercise> selectDefaultExercise() async {
    // Load exercises from storage service
    final exercises = await _storageService.loadExercises();
    
    BreathingExercise exerciseToUse;
    if (exercises.isNotEmpty) {
      // Sort exercises alphabetically by name for consistent selection
      exercises.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      
      // Try to get exercise from last training result
      final lastResult = await _getLastTrainingResult();
      if (lastResult != null) {
        // Find exercise that matches the last result's exerciseId
        try {
          final lastExercise = exercises.firstWhere((ex) => ex.id == lastResult.exerciseId);
          exerciseToUse = lastExercise;
        } catch (e) {
          // Last exercise not found, use first available exercise (alphabetically)
          exerciseToUse = exercises.first;
        }
      } else {
        // No results found, use the first exercise from the sorted list
        exerciseToUse = exercises.first;
      }
      
      // Apply any saved user preferences to the exercise
      exerciseToUse = await _applyUserPreferences(exerciseToUse);
    } else {
      // Create a new exercise if none exist
      exerciseToUse = _exerciseService.createNewExercise();
    }
    
    return exerciseToUse;
  }

  /// Get the most recent training result (skipping deleted results)
  Future<TrainingResult?> _getLastTrainingResult() async {
    try {
      final results = await _storageService.getAllResults();
      // Filter out deleted results and return the most recent non-deleted result
      final activeResults = results.where((result) => result.deletedAt == null).toList();
      return activeResults.isNotEmpty ? activeResults.first : null;
    } catch (e) {
      debugPrint('Error getting last training result: $e');
      return null;
    }
  }

  /// Apply saved user preferences to an exercise
  Future<BreathingExercise> _applyUserPreferences(BreathingExercise exercise) async {
    try {
      final userSettings = await _storageService.loadUserSettings();
      
      BreathingExercise updatedExercise = exercise;
      
      // Only apply saved settings if the exercise allows editing
      if (exercise.canEditCyclesCountCalculated) {
        final updated = _exerciseService.updateCycles(exercise, userSettings.totalCycles);
        if (updated != null) {
          updatedExercise = updated;
        }
      }
      
      if (updatedExercise.canEditCycleDurationCalculated) {
        final updated = _exerciseService.updateCycleDuration(updatedExercise, userSettings.cycleDuration);
        if (updated != null) {
          updatedExercise = updated;
        }
      }
      
      return updatedExercise;
    } catch (e) {
      debugPrint('Error applying user preferences: $e');
      return exercise;
    }
  }

  /// Set the current exercise
  void setExercise(BreathingExercise exercise) {
    _currentExercise = exercise;
    reset();
    notifyListeners();
  }

  /// Save current exercise settings
  Future<void> saveCurrentSettings() async {
    final exercise = _currentExercise;
    if (exercise != null) {
      try {
        // Ensure phases and duration are synced before saving
        final syncedExercise = _exerciseService.updateCycleDuration(exercise, exercise.cycleDuration) ?? exercise;
        _currentExercise = syncedExercise;
        await _storageService.saveExercise(syncedExercise);
      } catch (e) {
        debugPrint('Error saving current settings: $e');
      }
    }
  }

  /// Reset session to initial state
  void reset({bool notify = true}) {
    _startTime = null;
    _timer?.cancel();
    _timer = null;
    _lastSentPhaseIndex = -1;
    if (notify) {
      notifyListeners();
    }
  }

  /// Start a new training session
  Future<void> start() async {
    if (_currentExercise == null) {
      debugPrint(t.services.session.noExerciseSelected);
      return;
    }
    
    debugPrint('Starting new session...');
    reset(notify: false);
    _startTime = DateTime.now();
    
    debugPrint('Session started: isRunning=$isRunning, isDone=$isDone, waitPhase=$isInWaitPhase');
    
    // Enable wakelock to keep screen awake during training
    try {
      await WakelockPlus.enable().timeout(Duration(seconds: 1));
    } catch (e) {
      debugPrint('Wakelock enable error (continuing without wakelock): $e');
    }
    
    // Start the timer
    _timer?.cancel();
    _timer = Timer.periodic(
      Duration(milliseconds: 100),
      (_) {
        try {
          tick();
        } catch (e) {
          debugPrint('Timer tick error: $e');
        }
      },
    );
    
    // Emit session start event
    _emitEvent(SessionEventType.sessionStart);
    
    notifyListeners();
  }

  /// Stop the current session
  Future<void> stop() async {
    debugPrint('Stopping session: wasRunning=$isRunning, isDone=$isDone');
    
    // Check if we should save a partial result before stopping
    await _savePartialResultIfApplicable();
    
    // Stop the timer
    _timer?.cancel();
    _timer = null;
    
    // Disable wakelock when session stops
    try {
      await WakelockPlus.disable();
    } catch (e) {
      debugPrint('Wakelock disable error (ignoring): $e');
    }
    
    reset();
    
    // Emit session stop event
    _emitEvent(SessionEventType.sessionStop);
    
    debugPrint('Session stopped and reset: isRunning=$isRunning, isDone=$isDone');
  }

  /// Process a timer tick and advance the session state
  bool tick() {
    if (!isRunning || isDone || _currentExercise == null || _startTime == null) return false;

    final elapsedMs = DateTime.now().difference(_startTime!).inMilliseconds;
    
    // Check if we should transition from wait phase to breathing phases
    if (isInWaitPhase && elapsedMs >= (_waitPhaseDuration * 1000)) {
      // Get the first breathing phase
      if (_currentExercise!.phases.isNotEmpty) {
        const globalPhaseIndex = 0; // First phase of first cycle
        if (_lastSentPhaseIndex != globalPhaseIndex) {
          _lastSentPhaseIndex = globalPhaseIndex;
          _emitEvent(SessionEventType.phaseTransition, _currentExercise!.phases[0]);
        }
      }
      notifyListeners();
      return false;
    }
    
    // Check for phase transitions within breathing cycles
    if (!isInWaitPhase) {
      _checkPhaseTransitions(elapsedMs);
    }
    
    // Check if session is complete
    if (!isInWaitPhase) {
      final breathingElapsedMs = elapsedMs - (_waitPhaseDuration * 1000);
      final totalSessionDurationMs = _currentExercise!.totalPhaseDuration * _currentExercise!.cycles * 1000;
      
      if (breathingElapsedMs >= totalSessionDurationMs) {
        // Stop the timer immediately to update isRunning state
        _timer?.cancel();
        _timer = null;
        
        completeSession().catchError((e) {
          debugPrint('Error completing session: $e');
          return null;
        });
        _emitEvent(SessionEventType.sessionComplete);
        notifyListeners();
        return true;
      }
    }
    
    notifyListeners();
    return false;
  }

  /// Check for phase transitions and emit events when they occur
  void _checkPhaseTransitions(int elapsedMs) {
    if (_currentExercise == null) return;
    
    // If this is the first call (_lastSentPhaseIndex == -1), compare with wait time
    if (_lastSentPhaseIndex == -1) {
      final waitTime = _waitPhaseDuration * 1000;
      if (elapsedMs >= waitTime) {
        // Emit event for start of first phase
        _lastSentPhaseIndex++;
        if (_currentExercise!.phases.isNotEmpty) {
          _emitEvent(SessionEventType.phaseTransition, _currentExercise!.phases[0]);
        }
      }
      return;
    }
    
    // Calculate the time when the next phase (_lastSentPhaseIndex + 1) should start
    final phasesPerCycle = _currentExercise!.phases.length;
    final nextPhaseGlobalIndex = _lastSentPhaseIndex + 1;
    
    // Calculate time for next phase
    int nextPhaseTime = _waitPhaseDuration * 1000; // Start with wait time
    
    // Add time for completed cycles
    final completedCycles = nextPhaseGlobalIndex ~/ phasesPerCycle;
    final cycleDurationMs = _currentExercise!.totalPhaseDuration * 1000;
    nextPhaseTime += completedCycles * cycleDurationMs;
    
    // Add time for phases within the current cycle
    final phaseIndexInCurrentCycle = nextPhaseGlobalIndex % phasesPerCycle;
    for (int i = 0; i < phaseIndexInCurrentCycle ; i++) {
      nextPhaseTime += _currentExercise!.phases[i].duration * 1000;
    }
    
    // Compare with elapsed time
    if (elapsedMs >= nextPhaseTime) {
      _lastSentPhaseIndex++;
      // Emit next phase event
      final nextPhaseIndex = phaseIndexInCurrentCycle;
      if (nextPhaseIndex < _currentExercise!.phases.length) {
        _emitEvent(SessionEventType.phaseTransition, _currentExercise!.phases[nextPhaseIndex]);
      }
    }
  }

  /// Calculate progress within current cycle (0.0 to 1.0)
  double get currentCycleProgress {
    if (_currentExercise == null || isInWaitPhase || _startTime == null) {
      return 0.0;
    }

    final elapsed = DateTime.now().difference(_startTime!).inMilliseconds/1000 - _waitPhaseDuration;
    if (elapsed <= 0) return 0.0;

    final cycleDuration = _currentExercise!.totalPhaseDuration;
    if (cycleDuration <= 0) return 0.0;

    final timeInCurrentCycle = elapsed % cycleDuration;
    return (timeInCurrentCycle / cycleDuration).clamp(0.0, 1.0);
  }

  /// Format timer display as MM:SS
  String get timerDisplay {
    int secondsLeft = secondsLeftInPhase;
    int min = secondsLeft ~/ 60;
    int sec = secondsLeft % 60;
    return "${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  /// Get current phase label
  String get phaseLabel {
    if (isInWaitPhase) {
      return t.services.session.ready;
    } else if (_currentExercise != null && currentPhaseIndex < _currentExercise!.phases.length) {
      return _currentExercise!.phases[currentPhaseIndex].name;
    } else {
      return t.services.session.go;
    }
  }

  /// Get color for current phase
  Color phaseColor(BuildContext context) {
    if (_currentExercise == null) return Theme.of(context).colorScheme.onSurface;
    
    if (isInWaitPhase) {
      return Theme.of(context).colorScheme.onSurface;
    } else if (currentPhaseIndex < _currentExercise!.phases.length) {
      return _currentExercise!.phases[currentPhaseIndex].color;
    } else {
      return Theme.of(context).colorScheme.onSurface;
    }
  }

  /// Get default timer display when not running
  String get defaultTimerDisplay {
    if (_currentExercise == null) return "00:00";
    return "${_currentExercise!.cycleDuration.toString().padLeft(2, '0')}:00";
  }

  /// Create a training result from the current session
  TrainingResult? createResult() {
    if (_startTime != null && _currentExercise != null) {
      return TrainingResult(
        date: _startTime!,
        duration: _currentExercise!.cycleDuration,
        cycles: _currentExercise!.cycles,
        exerciseId: _currentExercise!.id,
      );
    }
    return null;
  }

  /// Create a partial result based on actual completed cycles
  TrainingResult? createPartialResult() {
    if (_startTime != null && _currentExercise != null) {
      final completedCycles = _getCompletedCycles();
      if (completedCycles > 0) {
        return TrainingResult(
          date: _startTime!,
          duration: _currentExercise!.cycleDuration,
          cycles: completedCycles,
          exerciseId: _currentExercise!.id,
        );
      }
    }
    return null;
  }

  /// Get the number of fully completed cycles (not including current partial cycle)
  int _getCompletedCycles() {
    if (_currentExercise == null || _startTime == null || isInWaitPhase) return 0;
    
    // currentCycle is 1-based and includes the current in-progress cycle
    // So completed cycles = currentCycle - 1
    return (currentCycle - 1).clamp(0, _currentExercise!.cycles);
  }

  /// Save a partial result if at least one cycle has been completed
  Future<void> _savePartialResultIfApplicable() async {
    if (!isRunning || _startTime == null || _currentExercise == null) return;
    
    final completedCycles = _getCompletedCycles();
    debugPrint('Checking for partial result: completedCycles=$completedCycles');
    
    if (completedCycles > 0) {
      final partialResult = createPartialResult();
      if (partialResult != null) {
        try {
          await SyncService().saveTrainingResult(partialResult);
          debugPrint('Saved partial result: ${partialResult.cycles} cycles completed');
        } catch (e) {
          debugPrint('Error saving partial result: $e');
        }
      }
    }
  }

  /// Complete the current session and save the result
  Future<TrainingResult?> completeSession() async {
    final result = createResult();
    if (result != null) {
      try {
        await SyncService().saveTrainingResult(result);
        await stop(); // Stop the session after saving result
        return result;
      } catch (e) {
        debugPrint('Error saving training result: $e');
        await stop(); // Still stop the session even if saving fails
        return result;
      }
    }
    await stop();
    return null;
  }

  /// Update exercise settings and save
  Future<bool> updateExerciseSettings(BreathingExercise updatedExercise) async {
    try {
      // Ensure phases and duration are synced before setting and saving
      final syncedExercise = _exerciseService.updateCycleDuration(updatedExercise, updatedExercise.cycleDuration) ?? updatedExercise;
      setExercise(syncedExercise);
      await saveCurrentSettings();
      await SyncService().saveUserSettings(
        UserSettings(
          totalCycles: syncedExercise.cycles,
          cycleDuration: syncedExercise.cycleDuration,
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Error updating exercise settings: $e');
      return false;
    }
  }

  /// Session-specific can methods that work with current exercise
  
  /// Checks if cycles can be increased in current session
  bool canIncreaseCycles() {
    final exercise = _currentExercise;
    if (exercise == null) return false;
    return exercise.canEditCyclesCountCalculated && exercise.cycles < exercise.maxCycles;
  }

  /// Checks if cycles can be decreased in current session
  bool canDecreaseCycles() {
    final exercise = _currentExercise;
    if (exercise == null) return false;
    return exercise.canEditCyclesCountCalculated && exercise.cycles > exercise.minCycles;
  }

  /// Checks if cycle duration can be increased in current session
  bool canIncreaseCycleDuration() {
    final exercise = _currentExercise;
    if (exercise == null) return false;
    return exercise.canEditCycleDurationCalculated && 
           exercise.cycleDuration < exercise.maxCycleDuration;
  }

  /// Checks if cycle duration can be decreased in current session
  bool canDecreaseCycleDuration() {
    final exercise = _currentExercise;
    if (exercise == null) return false;
    return exercise.canEditCycleDurationCalculated && 
           exercise.cycleDuration > exercise.minCycleDuration;
  }

  /// Session-specific increment/decrement methods
  
  /// Increases cycles by one if possible in current session
  Future<bool> increaseCycles() async {
    final exercise = _currentExercise;
    if (exercise == null || !canIncreaseCycles()) return false;
    
    final updated = ExerciseService().updateCycles(exercise, exercise.cycles + 1);
    if (updated != null) {
      return await updateExerciseSettings(updated);
    }
    return false;
  }

  /// Decreases cycles by one if possible in current session
  Future<bool> decreaseCycles() async {
    final exercise = _currentExercise;
    if (exercise == null || !canDecreaseCycles()) return false;
    
    final updated = ExerciseService().updateCycles(exercise, exercise.cycles - 1);
    if (updated != null) {
      return await updateExerciseSettings(updated);
    }
    return false;
  }

  /// Increases cycle duration by step if possible in current session
  Future<bool> increaseCycleDuration() async {
    final exercise = _currentExercise;
    if (exercise == null || !canIncreaseCycleDuration()) return false;
    
    final updated = ExerciseService().updateCycleDuration(exercise, exercise.cycleDuration + exercise.cycleDurationStep);
    if (updated != null) {
      return await updateExerciseSettings(updated);
    }
    return false;
  }

  /// Decreases cycle duration by step if possible in current session
  Future<bool> decreaseCycleDuration() async {
    final exercise = _currentExercise;
    if (exercise == null || !canDecreaseCycleDuration()) return false;
    
    final updated = ExerciseService().updateCycleDuration(exercise, exercise.cycleDuration - exercise.cycleDurationStep);
    if (updated != null) {
      return await updateExerciseSettings(updated);
    }
    return false;
  }

  @override
  String toString() {
    return 'SessionService(cycle: $currentCycle/${_currentExercise?.cycles ?? 0}, phase: $currentPhaseIndex, running: $isRunning, done: $isDone)';
  }
}