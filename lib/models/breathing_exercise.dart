import 'package:hive/hive.dart';
import 'breath_phase.dart';

part 'breathing_exercise.g.dart';

/// Pure data model for breathing exercises
@HiveType(typeId: 3)
class BreathingExercise extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final DateTime createdAt;
  
  @HiveField(4)
  final DateTime? updatedAt;
  
  @HiveField(5)
  final int minCycles;
  
  @HiveField(6)
  final int maxCycles;
  
  @HiveField(7)
  final int cycleDurationStep;
  
  @HiveField(8)
  final int cycles;
  
  @HiveField(9)
  final int cycleDuration;
  
  @HiveField(10)
  final List<BreathPhase> phases;

  @HiveField(11)
  final DateTime? deletedAt;

  BreathingExercise({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
    required this.minCycles,
    required this.maxCycles,
    required this.cycleDurationStep,
    required this.cycles,
    required this.cycleDuration,
    required this.phases,
  });

  BreathingExercise copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    int? minCycles,
    int? maxCycles,
    int? cycleDurationStep,
    int? cycles,
    int? cycleDuration,
    List<BreathPhase>? phases,
  }) {
    return BreathingExercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      minCycles: minCycles ?? this.minCycles,
      maxCycles: maxCycles ?? this.maxCycles,
      cycleDurationStep: cycleDurationStep ?? this.cycleDurationStep,
      cycles: cycles ?? this.cycles,
      cycleDuration: cycleDuration ?? this.cycleDuration,
      phases: phases ?? this.phases,
    );
  }

  int get totalPhaseDuration => phases.fold(0, (sum, phase) => sum + phase.duration);

  /// Calculate minimum cycle duration based on phase minimum durations
  int get minCycleDuration => phases.fold(0, (sum, phase) => sum + phase.minDuration);

  /// Calculate maximum cycle duration based on phase maximum durations
  int get maxCycleDuration => phases.fold(0, (sum, phase) => sum + phase.maxDuration);

  /// Calculate if cycles count can be edited based on min != max
  bool get canEditCyclesCountCalculated => minCycles != maxCycles;

  /// Calculate if cycle duration can be edited based on min != max and phases variability
  bool get canEditCycleDurationCalculated {
    // Can't edit if min equals max duration
    if (minCycleDuration == maxCycleDuration) return false;
    
    // Can't edit if all phases have fixed duration (min == max for all phases)
    if (phases.every((phase) => phase.minDuration == phase.maxDuration)) {
      return false;
    }
    
    return true;
  }

  String get summary => '$cycles cycles • ${totalPhaseDuration}s per cycle • ${phases.length} phases';

  /// Compare this exercise with another to determine which is more recent
  /// Returns true if this exercise is more recent than the other
  bool isMoreRecentThan(BreathingExercise other) {
    DateTime? maxDate(Iterable<DateTime?> values) {
      DateTime? latest;
      for (final v in values) {
        if (v == null) continue;
        if (latest == null || v.isAfter(latest)) {
          latest = v;
        }
      }
      return latest;
    }

    final thisEffective = maxDate([createdAt, updatedAt, deletedAt]);
    final otherEffective = maxDate([other.createdAt, other.updatedAt, other.deletedAt]);

    if (thisEffective == null && otherEffective == null) return false;
    if (thisEffective == null) return false;
    if (otherEffective == null) return true;

    return thisEffective.isAfter(otherEffective);
  }



  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'can_edit_cycles_count': canEditCyclesCountCalculated,
      'can_edit_cycle_duration': canEditCycleDurationCalculated,
      'min_cycles': minCycles,
      'max_cycles': maxCycles,
      'min_cycle_duration': minCycleDuration,
      'max_cycle_duration': maxCycleDuration,
      'cycle_duration_step': cycleDurationStep,
      'cycles': cycles,
      'cycle_duration': cycleDuration,
      'phases': phases.map((phase) => phase.toJson()).toList(),
    };
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'min_cycles': minCycles,
      'max_cycles': maxCycles,
      'cycle_duration_step': cycleDurationStep,
      'cycles': cycles,
      'cycle_duration': cycleDuration,
    };
  }

  factory BreathingExercise.fromJson(Map<String, dynamic> json) {
    final phasesData = json['phases'] as List;
    final phases = phasesData.map((phaseJson) => BreathPhase.fromJson(phaseJson)).toList();

    return BreathingExercise(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
      minCycles: json['min_cycles'],
      maxCycles: json['max_cycles'],
      cycleDurationStep: json['cycle_duration_step'],
      cycles: json['cycles'],
      cycleDuration: json['cycle_duration'],
      phases: phases,
    );
  }

  @override
  String toString() {
    return 'BreathingExercise(name: $name, cycles: $cycles, duration: ${cycleDuration}s, phases: ${phases.length})';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BreathingExercise &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}