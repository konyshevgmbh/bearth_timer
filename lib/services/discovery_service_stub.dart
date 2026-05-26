import 'dart:async';
import 'package:flutter/foundation.dart';

class DiscoveredPeer {
  final String deviceId;
  final String displayName;
  final String host;
  final int port;

  const DiscoveredPeer({
    required this.deviceId,
    required this.displayName,
    required this.host,
    required this.port,
  });

  @override
  String toString() => 'DiscoveredPeer($displayName @ $host:$port)';
}

/// No-op DiscoveryService for platforms without dart:io (Web).
class DiscoveryService extends ChangeNotifier {
  static final DiscoveryService _instance = DiscoveryService._internal();
  factory DiscoveryService() => _instance;
  DiscoveryService._internal();

  List<DiscoveredPeer> get peers => const [];

  final _peerAppearedController = StreamController<DiscoveredPeer>.broadcast();
  final _peerDisappearedController = StreamController<String>.broadcast();

  Stream<DiscoveredPeer> get peerAppeared => _peerAppearedController.stream;
  Stream<String> get peerDisappeared => _peerDisappearedController.stream;

  bool get isRunning => false;

  void setPort(int port) {}
  Future<void> start() async {}
  Future<void> stop() async {}

  @override
  void dispose() {
    _peerAppearedController.close();
    _peerDisappearedController.close();
    super.dispose();
  }
}
