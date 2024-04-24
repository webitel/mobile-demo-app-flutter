import 'package:injectable/injectable.dart';
import 'package:webitel_portal_sdk/src/domain/entities/dialog_message.dart';
import 'package:webitel_portal_sdk/src/domain/services/chat_service.dart';

abstract interface class SendMessageUseCase {
  Future<DialogMessageEntity> call({required DialogMessageEntity message});
}

@LazySingleton(as: SendMessageUseCase)
class SendMessageImplUseCase implements SendMessageUseCase {
  final ChatService _chatService;

  SendMessageImplUseCase(this._chatService);

  @override
  Future<DialogMessageEntity> call({required DialogMessageEntity message}) =>
      _chatService.sendMessage(message: message);
}
