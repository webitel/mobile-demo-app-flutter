import 'package:webitel_sdk/domain/service/chat_service.dart';

abstract interface class UploadMediaUseCase {
  Future<void> call();
}

class UploadMediaImplUseCase implements UploadMediaUseCase {
  final ChatService _chatService;

  UploadMediaImplUseCase(this._chatService);

  @override
  Future<void> call() => _chatService.uploadMedia();
}
