import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/trusted_device.dart';
import '../services/device_info_service.dart';
import '../services/discovery_service.dart';
import '../services/local_sync_service.dart';
import '../services/pairing_service.dart';
import '../sync/local_ip.dart';
import '../sync/qr_payload.dart';
import '../sync/sync_server.dart';
import '../widgets/qr_scan_page.dart';

class TrustedDevicesPage extends StatefulWidget {
  const TrustedDevicesPage({super.key});

  @override
  State<TrustedDevicesPage> createState() => _TrustedDevicesPageState();
}

class _TrustedDevicesPageState extends State<TrustedDevicesPage> {
  List<TrustedDevice> _devices = [];
  String? _qrData;
  String? _qrError;
  final _codeController = TextEditingController();
  bool _connecting = false;
  String? _connectStatus;

  @override
  void initState() {
    super.initState();
    _reload();
    _buildQr();
  }

  @override
  void dispose() {
    PairingService().clearQrToken();
    _codeController.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() => _devices = PairingService().getTrustedDevices());
  }

  Future<void> _remove(TrustedDevice device) async {
    await PairingService().removeTrust(device.deviceId);
    _reload();
  }

  Future<void> _buildQr() async {
    final ip = await getLocalIp();
    if (!mounted) return;
    if (ip == null) {
      setState(() => _qrError = 'Wi-Fi not connected');
      return;
    }
    final port = SyncServer().port;
    if (port == 0) {
      setState(() => _qrError = 'Sync not ready — try again');
      return;
    }
    final info = DeviceInfoService();
    final token = PairingService().generateQrToken();
    final payload = QrPayload(
      deviceId: info.deviceId,
      displayName: info.displayName,
      host: ip,
      port: port,
      token: token,
    );
    if (mounted) setState(() => _qrData = payload.encode());
  }

  Future<void> _connectFromCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;
    setState(() {
      _connecting = true;
      _connectStatus = null;
    });

    final payload = QrPayload.decode(code);
    if (payload == null) {
      setState(() {
        _connecting = false;
        _connectStatus = 'Invalid code';
      });
      return;
    }

    if (payload.deviceId == DeviceInfoService().deviceId) {
      setState(() {
        _connecting = false;
        _connectStatus = 'This is your own device';
      });
      return;
    }

    await PairingService().trustDevice(payload.deviceId, payload.displayName);

    if (!kIsWeb) {
      final result = await LocalSyncService().syncWithQrPayload(payload);
      if (!mounted) return;
      setState(() {
        _connecting = false;
        _connectStatus = result != null
            ? 'Synced with ${payload.displayName} (+${result.sessionsReceived} received)'
            : 'Paired with ${payload.displayName}. Sync failed.';
      });
    } else {
      if (mounted) {
        setState(() {
          _connecting = false;
          _connectStatus = 'Paired with ${payload.displayName}';
        });
      }
    }
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Sync')),
      body: Column(
        children: [
          _SyncStatusBanner(),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              children: [
                if (_devices.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'No trusted devices yet',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  ..._devices.map((d) => _DeviceTile(
                        device: d,
                        onRemove: () => _remove(d),
                      )),

                const Divider(height: 32),

                // ── QR code ────────────────────────────────────────────────
                Text('Add device',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                Center(
                  child: _qrError != null
                      ? Text(_qrError!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error))
                      : _qrData == null
                          ? const CircularProgressIndicator()
                          : QrImageView(
                              data: _qrData!,
                              version: QrVersions.auto,
                              size: 200,
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.all(8),
                            ),
                ),

                // ── Payload text ──────────────────────────────────────────
                if (_qrData != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SelectableText(
                            _qrData!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontFamily: 'monospace'),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        tooltip: 'Copy',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _qrData!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Code copied'),
                                duration: Duration(seconds: 1)),
                          );
                        },
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),

                // ── Text input ────────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _codeController,
                        decoration: const InputDecoration(
                          labelText: 'Paste code from other device',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        maxLines: 3,
                        minLines: 1,
                        onSubmitted: (_) => _connectFromCode(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _connecting ? null : _connectFromCode,
                      child: _connecting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Connect'),
                    ),
                  ],
                ),
                if (_connectStatus != null) ...[
                  const SizedBox(height: 6),
                  Text(_connectStatus!,
                      style: Theme.of(context).textTheme.bodySmall),
                ],

                // ── Scan QR (mobile with camera) ──────────────────────────
                if (QrScanPage.isSupported) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan QR'),
                      onPressed: () => QrScanPage.push(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final TrustedDevice device;
  final VoidCallback onRemove;

  const _DeviceTile({required this.device, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([DiscoveryService(), LocalSyncService()]),
      builder: (context, _) {
        final peer = DiscoveryService()
            .peers
            .where((p) => p.deviceId == device.deviceId)
            .toList()
            .firstOrNull;
        final isOnline = peer != null;
        final syncing = LocalSyncService().state == SyncState.syncing;

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(isOnline ? Icons.wifi : Icons.wifi_off,
              color: isOnline ? Colors.green : null),
          title: Text(device.displayName),
          subtitle: Text(
            device.lastSyncedAt != null
                ? 'Last synced: ${_formatDate(device.lastSyncedAt!)}'
                : 'Never synced',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isOnline)
                IconButton(
                  icon: syncing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.sync),
                  onPressed:
                      syncing ? null : () => LocalSyncService().syncWithPeer(peer),
                ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmRemove(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmRemove(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove device'),
        content: Text('Remove ${device.displayName} from trusted devices?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remove')),
        ],
      ),
    );
    if (ok == true) onRemove();
  }

  String _formatDate(DateTime d) {
    return '${d.day}.${d.month}.${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
  }
}

class _SyncStatusBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocalSyncService(),
      builder: (_, __) {
        final svc = LocalSyncService();
        if (svc.state == SyncState.syncing) {
          return const LinearProgressIndicator();
        }
        if (svc.state == SyncState.done && svc.lastResult != null) {
          final r = svc.lastResult!;
          return Container(
            color: Theme.of(context).colorScheme.primaryContainer,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Synced with ${r.peerDisplayName} '
                  '(+${r.sessionsReceived} received, ${r.sessionsSent} sent)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        }
        if (svc.state == SyncState.error) {
          return Container(
            color: Theme.of(context).colorScheme.errorContainer,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Sync error: ${svc.lastError}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
