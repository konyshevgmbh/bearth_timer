import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'breath_phase.g.dart';

/// Represents a single breathing phase with its properties and constraints
@HiveType(typeId: 2)
class BreathPhase extends HiveObject {
  @HiveField(0)
  final String name;
  
  @HiveField(1)
  final int duration;
  
  @HiveField(2)
  final int minDuration;
  
  @HiveField(3)
  final int maxDuration;
  
  @HiveField(4)
  final int colorValue;
  
  
  @HiveField(5)
  final int claps;
  
  Color get color => Color(colorValue);

  BreathPhase({
    required this.name,
    required this.duration,
    required this.minDuration,
    required this.maxDuration,
    Color? color,
    int? colorValue,
    this.claps = 1,
  }) : colorValue = colorValue ?? color?.toARGB32() ?? 0xFF000000;

  BreathPhase copyWith({
    String? name,
    int? duration,
    int? minDuration,
    int? maxDuration,
    Color? color,
    int? claps,
  }) {
    return BreathPhase(
      name: name ?? this.name,
      duration: duration ?? this.duration,
      minDuration: minDuration ?? this.minDuration,
      maxDuration: maxDuration ?? this.maxDuration,
      color: color ?? Color(colorValue),
      claps: claps ?? this.claps,
    );
  }

  bool get isValidDuration => duration >= minDuration && duration <= maxDuration;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'duration': duration,
      'min_duration': minDuration,
      'max_duration': maxDuration,
      'color_value': colorValue,
      'claps': claps,
    };
  }

  Map<String, dynamic> toSupabase({String? exerciseId, String? exerciseUserId, int? phaseOrder}) {
    return {
      'exercise_id': exerciseId,
      'exercise_user_id': exerciseUserId,
      'name': name,
      'duration': duration,
      'min_duration': minDuration,
      'max_duration': maxDuration,
      'color_value': colorValue,
      'claps': claps,
      'phase_order': phaseOrder,
    };
  }

  factory BreathPhase.fromJson(Map<String, dynamic> json) {
    return BreathPhase(
      name: json['name'],
      duration: json['duration'],
      minDuration: json['min_duration'],
      maxDuration: json['max_duration'],
      color: Color(json['color_value']),
      claps: json['claps'] ?? 1,
    );
  }

  @override
  String toString() => 'BreathPhase(name: $name, duration: ${duration}s)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BreathPhase &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          duration == other.duration &&
          minDuration == other.minDuration &&
          maxDuration == other.maxDuration &&
          colorValue == other.colorValue &&
          claps == other.claps;

  @override
  int get hashCode =>
      name.hashCode ^
      duration.hashCode ^
      minDuration.hashCode ^
      maxDuration.hashCode ^
      colorValue.hashCode ^
      claps.hashCode;
}