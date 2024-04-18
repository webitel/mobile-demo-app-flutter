import 'package:webitel_sdk_package/src/domain/entities/dialog_message.dart';
import 'package:webitel_sdk_package/src/domain/services/chat/grpc_chat_service.dart';

abstract interface class SendDialogMessageUseCase {
  Future<void> call({required DialogMessageEntity message});
}

class SendDialogMessageImplUseCase implements SendDialogMessageUseCase {
  final ChatService _chatService;

  SendDialogMessageImplUseCase(this._chatService);

  @override
  Future<void> call({required DialogMessageEntity message}) =>
      _chatService.sendDialogMessage(message: message);
}
