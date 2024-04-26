import 'dart:async';
import 'dart:io';

import 'package:webitel_sdk/domain/entity/media_file.dart';
import 'package:webitel_sdk/domain/service/chat_service.dart';

abstract interface class UploadMediaUseCase {
  Future<MediaFileEntity> call({required File file});
}

class UploadMediaImplUseCase implements UploadMediaUseCase {
  final ChatService _chatService;

  UploadMediaImplUseCase(this._chatService);

  @override
  Future<MediaFileEntity> call({required File file}) =>
      _chatService.uploadMedia(file: file);
}
