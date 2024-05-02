class MediaFileResponseEntity {
  final String name;
  final String type;
  final String id;
  final int size;
  final List<int> bytes;

  MediaFileResponseEntity({
    required this.size,
    required this.bytes,
    required this.name,
    required this.type,
    required this.id,
  });
}
