enum CachedFileStatus { sent, error }

class CachedFileEntity {
  final String requestId;
  final String type;
  final String path;
  final CachedFileStatus status;

  CachedFileEntity({
    required this.requestId,
    required this.type,
    required this.path,
    required this.status,
  });

  factory CachedFileEntity.fromMap(Map<String, dynamic> map) {
    return CachedFileEntity(
      requestId: map['requestId'] as String,
      type: map['type'] as String,
      path: map['path'] as String,
      status: CachedFileStatus.values.firstWhere(
        (s) => s.toString().split('.').last == map['status'],
        orElse: () => CachedFileStatus.error,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'type': type,
      'path': path,
      'status': status.toString().split('.').last,
    };
  }
}
