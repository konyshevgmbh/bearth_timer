import 'dart:io';

/// Returns the best local IPv4 address for LAN connections.
/// Prefers private ranges (192.168.x, 10.x, 172.16-31.x).
Future<String?> getLocalIp() async {
  final interfaces = await NetworkInterface.list(
    includeLoopback: false,
    type: InternetAddressType.IPv4,
  );

  // First pass: prefer common private ranges
  for (final iface in interfaces) {
    for (final addr in iface.addresses) {
      final ip = addr.address;
      if (ip.startsWith('192.168.') ||
          ip.startsWith('10.') ||
          RegExp(r'^172\.(1[6-9]|2\d|3[01])\.').hasMatch(ip)) {
        return ip;
      }
    }
  }

  // Second pass: any non-link-local
  for (final iface in interfaces) {
    for (final addr in iface.addresses) {
      if (!addr.address.startsWith('169.254.')) return addr.address;
    }
  }

  return null;
}
