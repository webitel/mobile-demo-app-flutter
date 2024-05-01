class MediaFileEntity {
  final String name;
  final String type;
  final String requestId;
  final List<int> bytes;
  final Stream<List<int>> data;
  final int size;
  final String id;

  MediaFileEntity({
    required this.id,
    required this.size,
    required this.bytes,
    required this.data,
    required this.name,
    required this.type,
    required this.requestId,
  });
}
