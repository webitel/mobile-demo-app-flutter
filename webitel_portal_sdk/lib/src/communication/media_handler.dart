import 'package:webitel_portal_sdk/src/domain/entities/media_file.dart';
import 'package:webitel_portal_sdk/src/domain/usecase/media/upload_file_usecase.dart';
import 'package:webitel_portal_sdk/src/injection/injection.dart';

class MediaHandler {
  late UploadMediaUseCase _uploadMediaUseCase;

  MediaHandler() {
    _uploadMediaUseCase = getIt.get<UploadMediaUseCase>();
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
