import 'package:webitel_sdk/domain/entity/dialog_message.dart';
import 'package:webitel_sdk/domain/service/chat_service.dart';

abstract interface class SendDialogMessageUseCase {
  Future<DialogMessageEntity> call({required DialogMessageEntity message});
}

class SendDialogMessageImplUseCase implements SendDialogMessageUseCase {
  final ChatService _chatService;

  SendDialogMessageImplUseCase(this._chatService);

  @override
  Future<DialogMessageEntity> call({required DialogMessageEntity message}) =>
      _chatService.sendDialogMessage(dialogMessageEntity: message);
}
