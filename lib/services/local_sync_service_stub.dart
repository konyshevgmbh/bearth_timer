import 'package:flutter/foundation.dart';
import 'discovery_service_stub.dart';
import '../sync/qr_payload.dart';
import '../sync/sync_result.dart';

enum SyncState { idle, syncing, done, error }

/// No-op LocalSyncService for platforms without dart:io (Web).
class LocalSyncService extends ChangeNotifier {
  static final LocalSyncService _instance = LocalSyncService._internal();
  factory LocalSyncService() => _instance;
  LocalSyncService._internal();

  SyncState get state => SyncState.idle;
  SyncResult? get lastResult => null;
  String? get lastError => null;

  Future<void> start() async {}
  Future<void> stop() async {}
  Future<SyncResult?> syncWithPeer(DiscoveredPeer peer) async => null;
  Future<SyncResult?> syncWithQrPayload(QrPayload payload) async => null;
}
