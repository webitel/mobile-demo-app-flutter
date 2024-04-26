import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:webitel_portal_sdk/src/domain/entities/media_file.dart';
import 'package:webitel_portal_sdk/src/domain/services/media_service.dart';

abstract interface class FetchMediaUseCase {
  Future<Stream<MediaFileEntity>> call({
    required String id,
  });
}

@LazySingleton(as: FetchMediaUseCase)
class FetchMediaImplUseCase implements FetchMediaUseCase {
  final MediaService _mediaService;

  FetchMediaImplUseCase(this._mediaService);

  @override
  Future<Stream<MediaFileEntity>> call({required String id}) =>
      _mediaService.fetchMedia(id: id);
}
