enum CachedFileStatus { sent, error, loading }

class CachedFileEntity {
  final String requestId;
  final String type;
  final String path;
  final CachedFileStatus status;
  final String id;

  CachedFileEntity({
    required this.id,
    required this.requestId,
    required this.type,
    required this.path,
    required this.status,
  });

  factory CachedFileEntity.fromMap(Map<String, dynamic> map) {
    return CachedFileEntity(
      requestId: map['requestId'] as String,
      type: map['type'] as String,
      id: map['id'] as String,
      path: map['path'] as String,
      status: CachedFileStatus.values.firstWhere(
        (s) => s.toString().split('.').last == map['status'],
        orElse: () => CachedFileStatus.error,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'requestId': requestId,
      'type': type,
      'path': path,
      'status': status.toString().split('.').last,
    };
  }
}