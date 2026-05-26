import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'device_info_service.dart';

// UDP multicast beacon discovery — replaces bonsoir/mDNS.
// Each device sends to multicast group 224.0.0.251:5297 every 5 s.
// Multicast is more reliable than broadcast on iOS (iOS 14+ blocks 255.255.255.255).
// Peers expire after 15 s of silence (3 missed beacons).
const _beaconPort = 5297;
const _multicastGroup = '224.0.0.251';
const _announceInterval = Duration(seconds: 5);
const _peerExpiry = Duration(seconds: 15);

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

class DiscoveryService extends ChangeNotifier {
  static final DiscoveryService _instance = DiscoveryService._internal();
  factory DiscoveryService() => _instance;
  DiscoveryService._internal();

  RawDatagramSocket? _recvSocket;
  RawDatagramSocket? _sendSocket;
  Timer? _announceTimer;
  final Map<String, Timer> _expiryTimers = {};
  final Map<String, DiscoveredPeer> _peers = {};

  final _peerAppearedController = StreamController<DiscoveredPeer>.broadcast();
  final _peerDisappearedController = StreamController<String>.broadcast();

  Stream<DiscoveredPeer> get peerAppeared => _peerAppearedController.stream;
  Stream<String> get peerDisappeared => _peerDisappearedController.stream;

  List<DiscoveredPeer> get peers => List.unmodifiable(_peers.values);

  bool _running = false;
  bool get isRunning => _running;

  int _port = 0;
  void setPort(int port) => _port = port;

  Future<void> start() async {
    if (_running) return;
    _running = true;

    _recvSocket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      _beaconPort,
      reuseAddress: true,
    );
    _recvSocket!.joinMulticast(InternetAddress(_multicastGroup));
    _recvSocket!.listen(_onEvent);

    _sendSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    _sendSocket!.multicastLoopback = false;

    _sendBeacon();
    _announceTimer = Timer.periodic(_announceInterval, (_) => _sendBeacon());
    debugPrint('DiscoveryService: started (UDP multicast $_multicastGroup:$_beaconPort)');
  }

  Future<void> stop() async {
    if (!_running) return;
    _running = false;
    _announceTimer?.cancel();
    _announceTimer = null;
    for (final t in _expiryTimers.values) {
      t.cancel();
    }
    _expiryTimers.clear();
    _recvSocket?.close();
    _recvSocket = null;
    _sendSocket?.close();
    _sendSocket = null;
    _peers.clear();
    notifyListeners();
    debugPrint('DiscoveryService: stopped');
  }

  void _sendBeacon() {
    if (_sendSocket == null || _port == 0) return;
    final info = DeviceInfoService();
    final payload = utf8.encode(jsonEncode({
      'v': 1,
      'deviceId': info.deviceId,
      'displayName': info.displayName,
      'port': _port,
    }));
    try {
      _sendSocket!.send(
        payload,
        InternetAddress(_multicastGroup),
        _beaconPort,
      );
    } on SocketException catch (e) {
      debugPrint('DiscoveryService: send error — $e');
    }
  }

  void _onEvent(RawSocketEvent event) {
    if (event != RawSocketEvent.read) return;
    final dg = _recvSocket?.receive();
    if (dg == null) return;
    try {
      final map = jsonDecode(utf8.decode(dg.data)) as Map<String, dynamic>;
      if ((map['v'] as int?) != 1) return;
      final deviceId = map['deviceId'] as String? ?? '';
      if (deviceId.isEmpty) return;
      if (deviceId == DeviceInfoService().deviceId) return; // skip self
      final peer = DiscoveredPeer(
        deviceId: deviceId,
        displayName: map['displayName'] as String? ?? deviceId,
        host: dg.address.address, // use actual source IP
        port: map['port'] as int,
      );
      _onPeerSeen(peer);
    } catch (e) {
      debugPrint('DiscoveryService: bad beacon — $e');
    }
  }

  void _onPeerSeen(DiscoveredPeer peer) {
    final isNew = !_peers.containsKey(peer.deviceId);
    _peers[peer.deviceId] = peer;

    _expiryTimers[peer.deviceId]?.cancel();
    _expiryTimers[peer.deviceId] = Timer(_peerExpiry, () {
      _onPeerExpired(peer.deviceId);
    });

    if (isNew) {
      _peerAppearedController.add(peer);
      notifyListeners();
      debugPrint('DiscoveryService: peer appeared — $peer');
    }
  }

  void _onPeerExpired(String deviceId) {
    if (_peers.remove(deviceId) != null) {
      _expiryTimers.remove(deviceId);
      _peerDisappearedController.add(deviceId);
      notifyListeners();
      debugPrint('DiscoveryService: peer expired — $deviceId');
    }
  }

  @override
  void dispose() {
    stop();
    _peerAppearedController.close();
    _peerDisappearedController.close();
    super.dispose();
  }
}
