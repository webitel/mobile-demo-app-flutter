import 'package:injectable/injectable.dart';
import 'package:webitel_portal_sdk/src/domain/entities/dialog_message.dart';
import 'package:webitel_portal_sdk/src/domain/services/chat_service.dart';

abstract interface class SendDialogMessageUseCase {
  Future<DialogMessageEntity> call({required DialogMessageEntity message});
}

@LazySingleton(as: SendDialogMessageUseCase)
class SendDialogMessageImplUseCase implements SendDialogMessageUseCase {
  final ChatService _chatService;

  SendDialogMessageImplUseCase(this._chatService);

  @override
  Future<DialogMessageEntity> call({required DialogMessageEntity message}) =>
      _chatService.sendDialogMessage(message: message);
}
