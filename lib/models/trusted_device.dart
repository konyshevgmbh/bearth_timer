import 'package:hive/hive.dart';

part 'trusted_device.g.dart';

@HiveType(typeId: 5)
class TrustedDevice extends HiveObject {
  @HiveField(0)
  final String deviceId;

  @HiveField(1)
  final String displayName;

  @HiveField(2)
  final DateTime pairedAt;

  @HiveField(3)
  final DateTime? lastSyncedAt;

  TrustedDevice({
    required this.deviceId,
    required this.displayName,
    required this.pairedAt,
    this.lastSyncedAt,
  });

  TrustedDevice copyWith({
    String? deviceId,
    String? displayName,
    DateTime? pairedAt,
    DateTime? lastSyncedAt,
  }) {
    return TrustedDevice(
      deviceId: deviceId ?? this.deviceId,
      displayName: displayName ?? this.displayName,
      pairedAt: pairedAt ?? this.pairedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  String toString() =>
      'TrustedDevice(id: $deviceId, name: $displayName, paired: $pairedAt, lastSync: $lastSyncedAt)';
}
