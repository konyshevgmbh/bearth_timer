import 'package:hive/hive.dart';

part 'training_result.g.dart';

/// Represents a training result with date, duration, cycles completed, and exercise ID
@HiveType(typeId: 0)
class TrainingResult extends HiveObject {
  @HiveField(0)
  final DateTime date;
  
  @HiveField(1)
  final int duration;
  
  @HiveField(2)
  final int cycles;
  
  @HiveField(3)
  final String exerciseId;

  @HiveField(4)
  final DateTime? deletedAt;

  TrainingResult({
    required this.date,
    required this.duration,
    required this.cycles,
    required this.exerciseId,
    this.deletedAt,
  });

  bool isBetterThan(TrainingResult other) {
    // Deleted results are never better than non-deleted ones
    if (deletedAt != null && other.deletedAt == null) {
      return false;
    }
    // Non-deleted results are always better than deleted ones
    if (deletedAt == null && other.deletedAt != null) {
      return true;
    }
    
    // If both have same deletion status, compare performance
    if (cycles != other.cycles) {
      return cycles > other.cycles;
    }
    return duration > other.duration;
  }

  /// Compare this training result with another to determine which is more recent
  /// Returns true if this training result is more recent than the other
  bool isMoreRecentThan(TrainingResult other) {
    // Get the most recent timestamp for each result (including deletedAt)
    final thisTimestamps = [date, deletedAt].where((t) => t != null).cast<DateTime>();
    final otherTimestamps = [other.date, other.deletedAt].where((t) => t != null).cast<DateTime>();
    
    final thisEffective = thisTimestamps.reduce((a, b) => a.isAfter(b) ? a : b);
    final otherEffective = otherTimestamps.reduce((a, b) => a.isAfter(b) ? a : b);

    // Compare effective times
    return thisEffective.isAfter(otherEffective);
  }

  double get score => duration*cycles.toDouble();

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'duration': duration,
      'cycles': cycles,
      'exerciseId': exerciseId,
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory TrainingResult.fromJson(Map<String, dynamic> json) {
    return TrainingResult(
      date: DateTime.parse(json['date']),
      duration: json['duration'],
      cycles: json['cycles'],
      exerciseId: json['exerciseId'] ?? json['exercise_id'] ?? '',
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'date': date.toIso8601String(),
      'duration': duration,
      'cycles': cycles,
      'exercise_id': exerciseId,
      'score': score,
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  @override
  String toString() => 'TrainingResult(date: $date, cycles: $cycles, duration: ${duration}s, exerciseId: $exerciseId)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingResult &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          duration == other.duration &&
          cycles == other.cycles &&
          exerciseId == other.exerciseId;

  @override
  int get hashCode => date.hashCode ^ duration.hashCode ^ cycles.hashCode ^ exerciseId.hashCode;
}