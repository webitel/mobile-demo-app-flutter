import 'package:webitel_portal_sdk/src/domain/entities/media_file.dart';
import 'package:webitel_portal_sdk/src/domain/usecase/media/fetch_media_usecase.dart';
import 'package:webitel_portal_sdk/src/domain/usecase/media/upload_file_usecase.dart';
import 'package:webitel_portal_sdk/src/injection/injection.dart';

class MediaHandler {
  late FetchMediaUseCase _fetchMediaUseCase;
  late UploadMediaUseCase _uploadMediaUseCase;

  MediaHandler() {
    _fetchMediaUseCase = getIt.get<FetchMediaUseCase>();
    _uploadMediaUseCase = getIt.get<UploadMediaUseCase>();
  }

  Future<Stream<MediaFileEntity>> fetchMedia({required String id}) async {
    return await _fetchMediaUseCase(id: id);
  }

  Future<MediaFileEntity> uploadMedia({
    required String type,
    required String name,
    required Stream<List<int>> data,
    int? compress,
  }) async {
    return await _uploadMediaUseCase(
      type: type,
      name: name,
      data: data,
      compress: compress,
    );
  }
}
