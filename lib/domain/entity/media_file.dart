class MediaFileEntity {
  final String name;
  final String type;
  final List<int>? bytes;
  final Stream<List<int>>? data;
  final int size;
  final String id;
  final String? path;

  MediaFileEntity({
    this.bytes,
    this.data,
    this.path,
    required this.id,
    required this.size,
    required this.name,
    required this.type,
  });
}
