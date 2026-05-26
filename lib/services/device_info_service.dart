import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';

class DeviceInfoService {
  static final DeviceInfoService _instance = DeviceInfoService._internal();
  factory DeviceInfoService() => _instance;
  DeviceInfoService._internal();

  late String _deviceId;
  late String _displayName;

  String get deviceId => _deviceId;
  String get displayName => _displayName;

  Future<void> initialize() async {
    _deviceId = await StorageService().getDeviceId();
    _displayName = await _resolveDisplayName();
    debugPrint('DeviceInfoService: id=$_deviceId name=$_displayName');
  }

  Future<String> _resolveDisplayName() async {
    try {
      final info = DeviceInfoPlugin();
      if (kIsWeb) {
        final d = await info.webBrowserInfo;
        return d.browserName.name;
      }
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          return (await info.androidInfo).model;
        case TargetPlatform.iOS:
          return (await info.iosInfo).name;
        case TargetPlatform.macOS:
          return (await info.macOsInfo).computerName;
        case TargetPlatform.windows:
          return (await info.windowsInfo).computerName;
        case TargetPlatform.linux:
          return (await info.linuxInfo).prettyName;
        case TargetPlatform.fuchsia:
          return 'Fuchsia Device';
      }
    } catch (e) {
      debugPrint('DeviceInfoService: could not resolve display name: $e');
    }
    return 'Unknown Device';
  }
}
