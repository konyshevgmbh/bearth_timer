import 'package:hive/hive.dart';

part 'user_settings.g.dart';

/// User settings model for preferences and configuration
@HiveType(typeId: 1)
class UserSettings extends HiveObject {
  @HiveField(0)
  final int totalCycles;
  
  @HiveField(1)
  final int cycleDuration;
  
  @HiveField(2)
  final bool soundEnabled;
  
  @HiveField(3)
  final bool vibrationEnabled;
  
  @HiveField(4)
  final int defaultDuration;
  
  @HiveField(5)
  final String languageCode;

  @HiveField(6)
  final bool limitHistoryDays;

  @HiveField(7)
  final String? deviceId;

  UserSettings({
    required this.totalCycles,
    required this.cycleDuration,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.defaultDuration = 30,
    this.languageCode = 'en',
    this.limitHistoryDays = true,
    this.deviceId,
  });

  UserSettings copyWith({
    int? totalCycles,
    int? cycleDuration,
    bool? soundEnabled,
    bool? vibrationEnabled,
    int? defaultDuration,
    String? languageCode,
    bool? limitHistoryDays,
    String? deviceId,
  }) {
    return UserSettings(
      totalCycles: totalCycles ?? this.totalCycles,
      cycleDuration: cycleDuration ?? this.cycleDuration,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      defaultDuration: defaultDuration ?? this.defaultDuration,
      languageCode: languageCode ?? this.languageCode,
      limitHistoryDays: limitHistoryDays ?? this.limitHistoryDays,
      deviceId: deviceId ?? this.deviceId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_cycles': totalCycles,
      'cycle_duration': cycleDuration,
      'sound_enabled': soundEnabled,
      'vibration_enabled': vibrationEnabled,
      'default_duration': defaultDuration,
      'language_code': languageCode,
      'limit_history_days': limitHistoryDays,
      'device_id': deviceId,
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      totalCycles: json['total_cycles'] ?? 0,
      cycleDuration: json['cycle_duration'] ?? 0,
      soundEnabled: json['sound_enabled'] ?? true,
      vibrationEnabled: json['vibration_enabled'] ?? true,
      defaultDuration: json['default_duration'] ?? 30,
      languageCode: json['language_code'] ?? 'en',
      limitHistoryDays: json['limit_history_days'] ?? true,
      deviceId: json['device_id'] as String?,
    );
  }

  @override
  String toString() => 'UserSettings(cycles: $totalCycles, duration: ${cycleDuration}s, sound: $soundEnabled, vibration: $vibrationEnabled, defaultDuration: $defaultDuration, language: $languageCode, limitHistoryDays: $limitHistoryDays, deviceId: $deviceId)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettings &&
          runtimeType == other.runtimeType &&
          totalCycles == other.totalCycles &&
          cycleDuration == other.cycleDuration &&
          soundEnabled == other.soundEnabled &&
          vibrationEnabled == other.vibrationEnabled &&
          defaultDuration == other.defaultDuration &&
          languageCode == other.languageCode &&
          limitHistoryDays == other.limitHistoryDays &&
          deviceId == other.deviceId;

  @override
  int get hashCode => totalCycles.hashCode ^ cycleDuration.hashCode ^ soundEnabled.hashCode ^ vibrationEnabled.hashCode ^ defaultDuration.hashCode ^ languageCode.hashCode ^ limitHistoryDays.hashCode ^ deviceId.hashCode;
}