import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:webitel_portal_sdk/src/domain/entities/media_file.dart';
import 'package:webitel_portal_sdk/src/domain/services/media_service.dart';

abstract interface class UploadMediaUseCase {
  Future<Stream<MediaFileEntity>> call({
    required String type,
    required String name,
    required List<int> data,
    int? compress,
  });
}

@LazySingleton(as: UploadMediaUseCase)
class UploadMediaImplUseCase implements UploadMediaUseCase {
  final MediaService _mediaService;

  UploadMediaImplUseCase(this._mediaService);

  @override
  Future<Stream<MediaFileEntity>> call({
    required String type,
    required String name,
    required List<int> data,
    int? compress,
  }) =>
      _mediaService.uploadFile(
        type: type,
        name: name,
        data: data,
        compress: compress,
      );
}
