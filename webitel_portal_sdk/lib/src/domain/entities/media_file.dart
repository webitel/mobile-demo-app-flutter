class MediaFileEntity {
  final String name;
  final String type;
  final String id;
  final List<int>? bytes;

  MediaFileEntity({
    this.bytes,
    required this.name,
    required this.type,
    required this.id,
  });
}
