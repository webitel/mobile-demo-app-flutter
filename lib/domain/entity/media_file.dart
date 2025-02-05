import 'dart:io';

class MediaFileEntity {
  final String name;
  final String type;
  final List<int>? bytes;
  final File? file;
  final int size;
  final String id;
  final String? path;

  MediaFileEntity({
    this.bytes,
    this.file,
    this.path,
    required this.id,
    required this.size,
    required this.name,
    required this.type,
  });
}
