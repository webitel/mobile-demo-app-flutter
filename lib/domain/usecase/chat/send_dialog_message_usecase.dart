import 'package:webitel_sdk/domain/entity/dialog_message_entity.dart';
import 'package:webitel_sdk/domain/entity/response_entity.dart';
import 'package:webitel_sdk/domain/service/chat_service.dart';

abstract interface class SendDialogMessageUseCase {
  Future<ResponseEntity> call(
      {required DialogMessageEntity dialogMessageEntity});
}

class SendDialogMessageImplUseCase implements SendDialogMessageUseCase {
  final ChatService _chatService;

  SendDialogMessageImplUseCase(this._chatService);

  @override
  Future<ResponseEntity> call(
          {required DialogMessageEntity dialogMessageEntity}) =>
      _chatService.sendDialogMessage(dialogMessageEntity: dialogMessageEntity);
}