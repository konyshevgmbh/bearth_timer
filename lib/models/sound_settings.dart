import 'package:hive/hive.dart';

part 'sound_settings.g.dart';

/// Sound settings model for audio preferences
@HiveType(typeId: 4)
class SoundSettings extends HiveObject {
  @HiveField(0)
  final bool soundEnabled;
  
  @HiveField(1)
  final double volume;
  

  SoundSettings({
    this.soundEnabled = true,
    this.volume = 1.0,
  });

  SoundSettings copyWith({
    bool? soundEnabled,
    double? volume,
  }) {
    return SoundSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      volume: volume ?? this.volume,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sound_enabled': soundEnabled,
      'volume': volume,
    };
  }

  factory SoundSettings.fromJson(Map<String, dynamic> json) {
    return SoundSettings(
      soundEnabled: json['sound_enabled'] ?? true,
      volume: json['volume'] ?? 1.0,
    );
  }

  @override
  String toString() => 'SoundSettings(soundEnabled: $soundEnabled, volume: $volume)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SoundSettings &&
          runtimeType == other.runtimeType &&
          soundEnabled == other.soundEnabled &&
          volume == other.volume;

  @override
  int get hashCode => soundEnabled.hashCode ^ volume.hashCode;
}