import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/device_info_service.dart';
import '../services/discovery_service_io.dart';
import '../services/pairing_service.dart';
import '../services/storage_service.dart';
import 'sync_message.dart';
import 'sync_result.dart';

class SyncClient {
  static final SyncClient _instance = SyncClient._internal();
  factory SyncClient() => _instance;
  SyncClient._internal();

  Future<SyncResult> syncWith(DiscoveredPeer peer) async {
    debugPrint('SyncClient: connecting to ${peer.host}:${peer.port}');

    final socket = await Socket.connect(
      peer.host,
      peer.port,
      timeout: const Duration(seconds: 5),
    );

    try {
      socket.setOption(SocketOption.tcpNoDelay, true);

      final lines = socket
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      final iter = StreamIterator(lines);
      final myInfo = DeviceInfoService();
      final myLastSync = PairingService().lastSyncedAt(peer.deviceId);

      // 1. Send hello
      _writeLine(socket, HelloMessage(
        deviceId: myInfo.deviceId,
        displayName: myInfo.displayName,
        lastSyncedAt: myLastSync,
      ));

      // 2. Read hello_ack
      if (!await iter.moveNext().timeout(const Duration(seconds: 10))) {
        throw const SocketException('No hello_ack received');
      }
      final ack = SyncMessage.decode(iter.current);
      if (ack is! HelloAckMessage) throw const SocketException('Bad hello_ack');

      // 3. Receive server's delta first
      final incoming = <dynamic>[];
      while (await iter.moveNext().timeout(const Duration(seconds: 30))) {
        final msg = SyncMessage.decode(iter.current);
        if (msg is SessionMessage) {
          incoming.add(msg.result);
        } else if (msg is DoneMessage) {
          break;
        }
      }

      final received = await StorageService().mergeSessions(incoming.cast());

      // 4. Send our delta
      final delta = await _buildDelta(ack.lastSyncedAt);
      for (final r in delta) {
        _writeLine(socket, SessionMessage(r));
      }
      _writeLine(socket, DoneMessage());

      // 5. Read ack (best-effort)
      if (await iter.moveNext().timeout(const Duration(seconds: 10))) {
        final finalAck = SyncMessage.decode(iter.current);
        debugPrint('SyncClient: server acked ${finalAck is AckMessage ? finalAck.count : '?'} sessions');
      }

      await socket.flush();
      await PairingService().updateLastSynced(peer.deviceId, DateTime.now());

      final result = SyncResult(
        peerDeviceId: peer.deviceId,
        peerDisplayName: peer.displayName,
        sessionsReceived: received,
        sessionsSent: delta.length,
        completedAt: DateTime.now(),
      );

      debugPrint('SyncClient: done — sent ${delta.length}, received $received');
      return result;
    } on TimeoutException {
      throw SocketException('Sync timed out with ${peer.displayName}');
    } finally {
      socket.destroy();
    }
  }

  Future<List<dynamic>> _buildDelta(DateTime? peerLastSync) async {
    final all = await StorageService().getAllResultsIncludingDeleted();
    if (peerLastSync == null) return all;
    return all.where((r) => (r.createdAt ?? r.date).isAfter(peerLastSync)).toList();
  }

  void _writeLine(Socket socket, SyncMessage msg) {
    socket.write('${msg.encode()}\n');
  }
}
