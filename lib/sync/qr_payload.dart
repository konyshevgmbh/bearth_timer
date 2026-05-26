import 'dart:convert';

class QrPayload {
  static const _version = 1;

  final String deviceId;
  final String displayName;
  final String host;
  final int port;
  final String token;

  const QrPayload({
    required this.deviceId,
    required this.displayName,
    required this.host,
    required this.port,
    required this.token,
  });

  String encode() => jsonEncode({
        'v': _version,
        'deviceId': deviceId,
        'displayName': displayName,
        'host': host,
        'port': port,
        'token': token,
      });

  static QrPayload? decode(String raw) {
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      if (m['v'] != _version) return null;
      return QrPayload(
        deviceId: m['deviceId'] as String,
        displayName: m['displayName'] as String,
        host: m['host'] as String,
        port: m['port'] as int,
        token: m['token'] as String,
      );
    } catch (_) {
      return null;
    }
  }
}
