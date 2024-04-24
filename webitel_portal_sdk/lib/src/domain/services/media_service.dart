import 'package:webitel_portal_sdk/src/domain/entities/media_file.dart';

abstract interface class MediaService {
  Future<Stream<MediaFileEntity>> uploadFile({
    required String type,
    required String name,
    required List<int> data,
    int? compress,
  });
}
