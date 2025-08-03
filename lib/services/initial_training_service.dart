import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/breathing_exercise.dart';
import '../models/breath_phase.dart';
import '../core/constants.dart';

/// Service for managing initial training setup and default exercises
class InitialTrainingService {
  static final InitialTrainingService _instance = InitialTrainingService._internal();
  factory InitialTrainingService() => _instance;
  InitialTrainingService._internal();
  
  final Uuid _uuid = const Uuid();

  // Default phase colors
  static const Color _phaseColorIn = Color(0xFF80DEEA);
  static const Color _phaseColorHold = Color(0xFFCBBBEF);
  static const Color _phaseColorOut = Color(0xFFFFD59E);

  /// Creates Molchanov exercise breathing phases
  List<BreathPhase> createMolchanovPhases( ) {
 
    return [
      BreathPhase(
        name: 'Inhale',
        duration: 5,
        minDuration: 5,
        maxDuration: 7,
        color: _phaseColorIn,
        claps: 1,
      ),
      BreathPhase(
        name: 'Hold',
        duration: 17,
        minDuration: 17,
        maxDuration: 60,
        color: _phaseColorHold,
        claps: 2,
      ),
      BreathPhase(
        name: 'Exhale',
        duration: 5,
        minDuration: 5,
        maxDuration: 8,
        color: _phaseColorOut,
        claps: 1,
      ),
      BreathPhase(
        name: 'Hold',
        duration: 3,
        minDuration: 3,
        maxDuration: 15,
        color: _phaseColorHold,
        claps: 2,
      ),
    ];
  }

  /// Creates 4-7-8 breathing phases
  List<BreathPhase> create478BreathingPhases() {
    return [
      BreathPhase(
        name: 'Inhale',
        duration: 4,
        minDuration: 4,
        maxDuration: 4,
        color: _phaseColorIn,
        claps: 1,
      ),
      BreathPhase(
        name: 'Hold',
        duration: 7,
        minDuration: 7,
        maxDuration: 7,
        color: _phaseColorHold,
        claps: 2,
      ),
      BreathPhase(
        name: 'Exhale',
        duration: 8,
        minDuration: 8,
        maxDuration: 8,
        color: _phaseColorOut,
        claps: 3,
      ),
    ];
  }

  /// Creates box breathing (equal timing) phases
  List<BreathPhase> createBoxBreathingPhases({int duration = 4}) {
    return [
      BreathPhase(
        name: 'Inhale',
        duration: duration,
        minDuration: 3,
        maxDuration: 8,
        color: _phaseColorIn,
        claps: 1,
      ),
      BreathPhase(
        name: 'Hold',
        duration: duration,
        minDuration: 3,
        maxDuration: 8,
        color: _phaseColorHold,
        claps: 2,
      ),
      BreathPhase(
        name: 'Exhale',
        duration: duration,
        minDuration: 3,
        maxDuration: 8,
        color: _phaseColorOut,
        claps: 1,
      ),
      BreathPhase(
        name: 'Hold',
        duration: duration,
        minDuration: 3,
        maxDuration: 8,
        color: _phaseColorHold,
        claps: 2,
      ),
    ];
  }

  /// Creates default breathing phases (uses Molchanov method)
  List<BreathPhase> createDefaultPhases() {
    return createMolchanovPhases();
  }

  /// Creates a basic default exercise for new users (Molchanov method)
  BreathingExercise createDefaultExercise({
    String? name,
    String? description,
    int? cycles,
    int? cycleDuration,
  }) {
    final targetCycleDuration = cycleDuration ?? TrainingConstants.defaultCycleDuration;
    return BreathingExercise(
      id: _uuid.v4(),
      name: name ?? 'Molchanov Method',
      description: description ?? 'Molchanov breath-hold training method for developing CO₂ tolerance',
      createdAt: DateTime.now(),
      minCycles: TrainingConstants.minCycles,
      maxCycles: TrainingConstants.maxCycles,
      cycleDurationStep: TrainingConstants.cycleDurationStep,
      cycles: cycles ?? TrainingConstants.defaultTotalCycles,
      cycleDuration: targetCycleDuration,
      phases: createMolchanovPhases( ),
    );
  }

  /// Creates a complete set of default exercises for new users
  List<BreathingExercise> createInitialTrainingSet() {
    return [
      BreathingExercise(
        id: 'molchanov_method',
        name: 'Molchanov Method',
        description: 'Aleksey Molchanov\'s breath-hold training method. Develops CO₂ tolerance through cycles without rest between them.',
        minCycles: TrainingConstants.minCycles,
        maxCycles: TrainingConstants.maxCycles,
        cycleDurationStep: 5,
        cycles: 4,
        cycleDuration: 30,
        phases: createMolchanovPhases( ),
        createdAt: DateTime.now(),
      ),
      BreathingExercise(
        id: '478_breathing',
        name: '4-7-8 Breathing',
        description: 'Relaxing breathing pattern: inhale for 4, hold for 7, exhale for 8. Great for stress relief and relaxation.',
        minCycles: TrainingConstants.minCycles,
        maxCycles: TrainingConstants.maxCycles,
        cycleDurationStep: 1,
        cycles: 8,
        cycleDuration: 19,
        phases: create478BreathingPhases(),
        createdAt: DateTime.now(),
      ),
      BreathingExercise(
        id: 'box_breathing',
        name: 'Box Breathing',
        description: 'Equal-timing breathing pattern: inhale, hold, exhale, hold - all for the same duration. Perfect for focus and calm.',
        minCycles: TrainingConstants.minCycles,
        maxCycles: TrainingConstants.maxCycles,
        cycleDurationStep: 4, // Must be divisible by 4
        cycles: 8,
        cycleDuration: 16, // 4 seconds each phase
        phases: createBoxBreathingPhases(duration: 4),
        createdAt: DateTime.now(),
      ),
    ];
  }
 
}