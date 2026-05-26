import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/device_info_service.dart';
import '../services/discovery_service_io.dart';
import '../services/pairing_service.dart';
import '../services/storage_service.dart';
import 'sync_message.dart';

class SyncServer {
  static final SyncServer _instance = SyncServer._internal();
  factory SyncServer() => _instance;
  SyncServer._internal();

  ServerSocket? _server;
  bool _accepting = false;

  int get port => _server?.port ?? 0;

  Future<void> start() async {
    if (_server != null) return;
    _server = await ServerSocket.bind(InternetAddress.anyIPv4, 0);
    _accepting = true;

    // Tell DiscoveryService which port to advertise.
    DiscoveryService().setPort(_server!.port);
    debugPrint('SyncServer: listening on port ${_server!.port}');

    _server!.listen(
      (socket) {
        if (_accepting) _handleConnection(socket);
      },
      onError: (e) => debugPrint('SyncServer: accept error $e'),
    );
  }

  Future<void> stop() async {
    _accepting = false;
    await _server?.close();
    _server = null;
  }

  Future<void> _handleConnection(Socket socket) async {
    final remote = '${socket.remoteAddress.address}:${socket.remotePort}';
    debugPrint('SyncServer: connection from $remote');

    try {
      socket.setOption(SocketOption.tcpNoDelay, true);

      final lines = socket
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      final iter = StreamIterator(lines);

      // 1. Read hello
      if (!await iter.moveNext().timeout(const Duration(seconds: 10))) return;
      final hello = SyncMessage.decode(iter.current);
      if (hello is! HelloMessage) return;

      final pairing = PairingService();
      if (!pairing.isTrusted(hello.deviceId)) {
        // Allow QR-initiated pairing: scanner sends the one-time token
        if (hello.qrToken != null && pairing.validateQrToken(hello.qrToken!)) {
          await pairing.trustDevice(hello.deviceId, hello.displayName);
          pairing.clearQrToken();
          debugPrint('SyncServer: QR-paired ${hello.deviceId}');
        } else {
          debugPrint('SyncServer: untrusted device ${hello.deviceId}, closing');
          socket.destroy();
          return;
        }
      }

      final myInfo = DeviceInfoService();
      final myLastSync = pairing.lastSyncedAt(hello.deviceId);

      // 2. Send hello_ack
      _writeLine(socket, HelloAckMessage(
        deviceId: myInfo.deviceId,
        displayName: myInfo.displayName,
        lastSyncedAt: myLastSync,
      ));

      // 3. Send our delta (sessions newer than peer's lastSyncedAt)
      final delta = await _buildDelta(hello.lastSyncedAt);
      for (final r in delta) {
        _writeLine(socket, SessionMessage(r));
      }
      _writeLine(socket, DoneMessage());

      // 4. Receive peer's delta
      int received = 0;
      final incoming = <dynamic>[];
      while (await iter.moveNext().timeout(const Duration(seconds: 30))) {
        final msg = SyncMessage.decode(iter.current);
        if (msg is SessionMessage) {
          incoming.add(msg.result);
        } else if (msg is DoneMessage) {
          break;
        }
      }

      received = await StorageService().mergeSessions(
        incoming.cast(),
      );

      // 5. Ack
      _writeLine(socket, AckMessage(received));
      await socket.flush();

      await PairingService().updateLastSynced(hello.deviceId, DateTime.now());
      debugPrint('SyncServer: sync done — sent ${delta.length}, received $received');
    } on TimeoutException {
      debugPrint('SyncServer: timeout with $remote');
    } on SocketException catch (e) {
      debugPrint('SyncServer: socket error with $remote: $e');
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
