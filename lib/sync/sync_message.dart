import 'dart:convert';
import '../models/training_result.dart';

sealed class SyncMessage {
  Map<String, dynamic> toJson();

  String encode() => jsonEncode(toJson());

  static SyncMessage decode(String line) {
    final map = jsonDecode(line) as Map<String, dynamic>;
    return switch (map['type'] as String) {
      'hello' => HelloMessage.fromJson(map),
      'hello_ack' => HelloAckMessage.fromJson(map),
      'session' => SessionMessage.fromJson(map),
      'done' => DoneMessage(),
      'ack' => AckMessage.fromJson(map),
      _ => throw FormatException('Unknown sync message type: ${map['type']}'),
    };
  }
}

class HelloMessage extends SyncMessage {
  final String deviceId;
  final String displayName;
  final DateTime? lastSyncedAt;
  final String? qrToken;

  HelloMessage({
    required this.deviceId,
    required this.displayName,
    this.lastSyncedAt,
    this.qrToken,
  });

  factory HelloMessage.fromJson(Map<String, dynamic> j) => HelloMessage(
        deviceId: j['deviceId'] as String,
        displayName: j['displayName'] as String,
        lastSyncedAt: j['lastSyncedAt'] != null
            ? DateTime.parse(j['lastSyncedAt'] as String)
            : null,
        qrToken: j['qrToken'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': 'hello',
        'deviceId': deviceId,
        'displayName': displayName,
        'lastSyncedAt': lastSyncedAt?.toUtc().toIso8601String(),
        if (qrToken != null) 'qrToken': qrToken,
      };
}

class HelloAckMessage extends SyncMessage {
  final String deviceId;
  final String displayName;
  final DateTime? lastSyncedAt;

  HelloAckMessage({
    required this.deviceId,
    required this.displayName,
    this.lastSyncedAt,
  });

  factory HelloAckMessage.fromJson(Map<String, dynamic> j) => HelloAckMessage(
        deviceId: j['deviceId'] as String,
        displayName: j['displayName'] as String,
        lastSyncedAt: j['lastSyncedAt'] != null
            ? DateTime.parse(j['lastSyncedAt'] as String)
            : null,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': 'hello_ack',
        'deviceId': deviceId,
        'displayName': displayName,
        'lastSyncedAt': lastSyncedAt?.toUtc().toIso8601String(),
      };
}

class SessionMessage extends SyncMessage {
  final TrainingResult result;

  SessionMessage(this.result);

  factory SessionMessage.fromJson(Map<String, dynamic> j) =>
      SessionMessage(TrainingResult.fromJson(j['payload'] as Map<String, dynamic>));

  @override
  Map<String, dynamic> toJson() => {
        'type': 'session',
        'payload': result.toJson(),
      };
}

class DoneMessage extends SyncMessage {
  @override
  Map<String, dynamic> toJson() => {'type': 'done'};
}

class AckMessage extends SyncMessage {
  final int count;

  AckMessage(this.count);

  factory AckMessage.fromJson(Map<String, dynamic> j) =>
      AckMessage(j['count'] as int);

  @override
  Map<String, dynamic> toJson() => {'type': 'ack', 'count': count};
}
