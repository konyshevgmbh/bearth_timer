import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/device_info_service.dart';
import '../services/local_sync_service.dart';
import '../services/pairing_service.dart';
import '../sync/qr_payload.dart';

/// Full-screen QR scanner. After a valid Bearth-sync QR is detected:
/// - Trusts the device locally
/// - Connects directly (on io platforms) and syncs
/// - Shows result, then pops
class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  /// mobile_scanner has no native plugin on Windows or Linux.
  static bool get isSupported =>
      kIsWeb ||
      (defaultTargetPlatform != TargetPlatform.windows &&
          defaultTargetPlatform != TargetPlatform.linux);

  static Future<void> push(BuildContext context) {
    if (!isSupported) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR scanning is not available on this platform. Use "Show QR" on the other device.')),
      );
      return Future.value();
    }
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const QrScanPage()),
    );
  }

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  final _controller = MobileScannerController();
  bool _processing = false;
  String? _status;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;

    final payload = QrPayload.decode(raw);
    if (payload == null) return; // not a Bearth QR
    if (payload.deviceId == DeviceInfoService().deviceId) return; // own QR

    setState(() {
      _processing = true;
      _status = 'Pairing with ${payload.displayName}…';
    });
    await _controller.stop();

    // 1. Trust the device that showed the QR
    await PairingService().trustDevice(payload.deviceId, payload.displayName);

    if (!kIsWeb) {
      // 2. Connect directly using the host/port from the QR
      //    Build a synthetic DiscoveredPeer and sync
      await _syncDirectly(payload);
    } else {
      setState(() => _status = 'Paired! Open the app on ${payload.displayName} to sync.');
    }
  }

  Future<void> _syncDirectly(QrPayload payload) async {
    // Import is already conditional — on web this code is unreachable
    // because kIsWeb guard above prevents execution.
    // On io platforms, LocalSyncService.syncWithPeer is available.
    setState(() => _status = 'Syncing with ${payload.displayName}…');

    // We need a DiscoveredPeer. Import the io version directly — this file
    // is only reached at runtime on io platforms when !kIsWeb.
    // Use dynamic dispatch via LocalSyncService which accepts DiscoveredPeer.
    // To avoid a dart:io import here, we delegate through a helper.
    await _qrSync(payload);
  }

  // Thin wrapper so the dart:io import is isolated to the io service.
  Future<void> _qrSync(QrPayload payload) async {
    // LocalSyncService.syncWithQrPayload is added below
    final result = await LocalSyncService().syncWithQrPayload(payload);
    if (!mounted) return;
    if (result != null) {
      setState(() => _status =
          'Synced! +${result.sessionsReceived} received, ${result.sessionsSent} sent.');
    } else {
      setState(() => _status = 'Connected but sync failed. You are now paired.');
    }
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR code')),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _processing ? null : _onDetect,
          ),
          // Viewfinder overlay
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (_processing)
            Container(
              color: Colors.black54,
              child: Center(
                child: Card(
                  margin: const EdgeInsets.all(32),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_status?.startsWith('Sync') == true ||
                            _status?.startsWith('Pair') == true)
                          const CircularProgressIndicator(),
                        if (_status != null) ...[
                          const SizedBox(height: 16),
                          Text(_status!, textAlign: TextAlign.center),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Point at the QR code shown on the other device',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
