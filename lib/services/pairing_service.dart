import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/trusted_device.dart';

class _PinRecord {
  final String pin;
  final DateTime expiresAt;
  int attempts;

  _PinRecord({required this.pin, required this.expiresAt}) : attempts = 0;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  Duration get remaining => expiresAt.difference(DateTime.now());
}

class PairingService {
  static final PairingService _instance = PairingService._internal();
  factory PairingService() => _instance;
  PairingService._internal();

  static const _pinTtl = Duration(seconds: 120);
  static const _maxAttempts = 3;
  static const _uuid = Uuid();

  _PinRecord? _activePin;
  final Map<String, int> _failedAttempts = {};

  // ── QR mode ───────────────────────────────────────────────────────────────

  String? _qrToken;
  DateTime? _qrExpiresAt;

  /// Generates a one-time token for QR pairing. Valid for 120 s.
  String generateQrToken() {
    _qrToken = _uuid.v4();
    _qrExpiresAt = DateTime.now().add(_pinTtl);
    debugPrint('PairingService: QR token generated');
    return _qrToken!;
  }

  bool get isQrModeActive =>
      _qrToken != null && DateTime.now().isBefore(_qrExpiresAt!);

  /// Returns true if [token] matches the active QR token (and it hasn't expired).
  bool validateQrToken(String token) {
    if (!isQrModeActive) return false;
    return _qrToken == token;
  }

  void clearQrToken() {
    _qrToken = null;
    _qrExpiresAt = null;
  }

  Duration get qrRemaining =>
      _qrExpiresAt != null ? _qrExpiresAt!.difference(DateTime.now()) : Duration.zero;

  Box<TrustedDevice> get _box => Hive.box<TrustedDevice>('trusted_devices');

  // ── PIN generation ────────────────────────────────────────────────────────

  String generatePin() {
    final pin = (Random.secure().nextInt(9000) + 1000).toString();
    _activePin = _PinRecord(
      pin: pin,
      expiresAt: DateTime.now().add(_pinTtl),
    );
    debugPrint('PairingService: generated PIN $pin (expires in $_pinTtl)');
    return pin;
  }

  String? get activePin => (_activePin?.isExpired == false) ? _activePin!.pin : null;
  Duration get pinRemaining => _activePin?.remaining ?? Duration.zero;
  bool get hasPinExpired => _activePin != null && _activePin!.isExpired;

  void clearPin() => _activePin = null;

  // ── PIN validation ────────────────────────────────────────────────────────

  /// Returns true if [pin] matches and is within TTL + attempt limit.
  bool validatePin(String fromDeviceId, String pin) {
    final record = _activePin;
    if (record == null) return false;
    if (record.isExpired) return false;

    final failures = _failedAttempts[fromDeviceId] ?? 0;
    if (failures >= _maxAttempts) {
      debugPrint('PairingService: $fromDeviceId is rate-limited');
      return false;
    }

    if (record.pin != pin) {
      _failedAttempts[fromDeviceId] = failures + 1;
      debugPrint('PairingService: wrong PIN from $fromDeviceId (attempt ${failures + 1})');
      return false;
    }

    _failedAttempts.remove(fromDeviceId);
    return true;
  }

  bool isRateLimited(String deviceId) =>
      (_failedAttempts[deviceId] ?? 0) >= _maxAttempts;

  // ── Trusted device store ──────────────────────────────────────────────────

  Future<void> trustDevice(String deviceId, String displayName) async {
    final device = TrustedDevice(
      deviceId: deviceId,
      displayName: displayName,
      pairedAt: DateTime.now(),
    );
    await _box.put(deviceId, device);
    debugPrint('PairingService: trusted $displayName ($deviceId)');
  }

  bool isTrusted(String deviceId) => _box.containsKey(deviceId);

  Future<void> removeTrust(String deviceId) async {
    await _box.delete(deviceId);
  }

  List<TrustedDevice> getTrustedDevices() => _box.values.toList();

  Future<void> updateLastSynced(String deviceId, DateTime when) async {
    final device = _box.get(deviceId);
    if (device == null) return;
    await _box.put(deviceId, device.copyWith(lastSyncedAt: when));
  }

  DateTime? lastSyncedAt(String deviceId) => _box.get(deviceId)?.lastSyncedAt;
}
