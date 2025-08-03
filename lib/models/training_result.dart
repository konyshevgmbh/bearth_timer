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

  TrainingResult({
    required this.date,
    required this.duration,
    required this.cycles,
    required this.exerciseId,
  });

  bool isBetterThan(TrainingResult other) {
    if (cycles != other.cycles) {
      return cycles > other.cycles;
    }
    return duration > other.duration;
  }

  double get score => duration*cycles.toDouble();

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'duration': duration,
      'cycles': cycles,
      'exerciseId': exerciseId,
    };
  }

  factory TrainingResult.fromJson(Map<String, dynamic> json) {
    return TrainingResult(
      date: DateTime.parse(json['date']),
      duration: json['duration'],
      cycles: json['cycles'],
      exerciseId: json['exerciseId'] ?? json['exercise_id'] ?? '',
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'date': date.toIso8601String(),
      'duration': duration,
      'cycles': cycles,
      'exercise_id': exerciseId,
      'score': score,
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