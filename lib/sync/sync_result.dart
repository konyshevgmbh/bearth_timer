class SyncResult {
  final String peerDeviceId;
  final String peerDisplayName;
  final int sessionsReceived;
  final int sessionsSent;
  final DateTime completedAt;

  const SyncResult({
    required this.peerDeviceId,
    required this.peerDisplayName,
    required this.sessionsReceived,
    required this.sessionsSent,
    required this.completedAt,
  });
}
