import 'package:webitel_portal_sdk/src/domain/entities/media_file.dart';

abstract interface class MediaService {
  Future<MediaFileEntity> uploadMedia({
    required String type,
    required String name,
    required Stream<List<int>> data,
    int? compress,
  });

  Future<Stream<MediaFileEntity>> fetchMedia({required String id});
}
