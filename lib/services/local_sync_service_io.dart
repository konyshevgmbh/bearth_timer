import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'discovery_service_io.dart';
import 'pairing_service.dart';
import '../sync/qr_payload.dart';
import '../sync/sync_client.dart';
import '../sync/sync_result.dart';
import '../sync/sync_server.dart';

enum SyncState { idle, syncing, done, error }

class LocalSyncService extends ChangeNotifier {
  static final LocalSyncService _instance = LocalSyncService._internal();
  factory LocalSyncService() => _instance;
  LocalSyncService._internal();

  SyncState _state = SyncState.idle;
  SyncState get state => _state;

  SyncResult? _lastResult;
  SyncResult? get lastResult => _lastResult;

  String? _lastError;
  String? get lastError => _lastError;

  final Set<String> _syncing = {};
  StreamSubscription<DiscoveredPeer>? _peerSub;

  Future<void> start() async {
    await SyncServer().start();
    _peerSub = DiscoveryService().peerAppeared.listen(_onPeerAppeared);
    debugPrint('LocalSyncService: started');
  }

  Future<void> stop() async {
    await _peerSub?.cancel();
    _peerSub = null;
    await SyncServer().stop();
  }

  Future<void> _onPeerAppeared(DiscoveredPeer peer) async {
    if (!PairingService().isTrusted(peer.deviceId)) return;
    if (_syncing.contains(peer.deviceId)) return;

    await Future.delayed(const Duration(seconds: 2));

    if (!DiscoveryService().peers.any((p) => p.deviceId == peer.deviceId)) return;

    _syncing.add(peer.deviceId);
    _setState(SyncState.syncing);

    try {
      final result = await SyncClient().syncWith(peer);
      _lastResult = result;
      _lastError = null;
      _setState(SyncState.done);
    } on SocketException catch (e) {
      _lastError = e.message;
      _setState(SyncState.error);
      debugPrint('LocalSyncService: socket error — ${e.message}');
    } catch (e) {
      _lastError = e.toString();
      _setState(SyncState.error);
      debugPrint('LocalSyncService: error — $e');
    } finally {
      _syncing.remove(peer.deviceId);
    }
  }

  Future<SyncResult?> syncWithQrPayload(QrPayload payload) async {
    final peer = DiscoveredPeer(
      deviceId: payload.deviceId,
      displayName: payload.displayName,
      host: payload.host,
      port: payload.port,
    );
    return syncWithPeer(peer);
  }

  Future<SyncResult?> syncWithPeer(DiscoveredPeer peer) async {
    if (_syncing.contains(peer.deviceId)) return null;
    _syncing.add(peer.deviceId);
    _setState(SyncState.syncing);

    try {
      final result = await SyncClient().syncWith(peer);
      _lastResult = result;
      _lastError = null;
      _setState(SyncState.done);
      return result;
    } on SocketException catch (e) {
      _lastError = e.message;
      _setState(SyncState.error);
      return null;
    } catch (e) {
      _lastError = e.toString();
      _setState(SyncState.error);
      return null;
    } finally {
      _syncing.remove(peer.deviceId);
    }
  }

  void _setState(SyncState s) {
    _state = s;
    notifyListeners();
  }
}
