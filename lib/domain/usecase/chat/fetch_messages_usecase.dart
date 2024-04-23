import 'package:webitel_sdk/domain/entity/dialog_message_entity.dart';
import 'package:webitel_sdk/domain/service/chat_service.dart';

abstract interface class FetchMessagesUseCase {
  Future<List<DialogMessageEntity>> call();
}

class FetchMessagesImplUseCase implements FetchMessagesUseCase {
  final ChatService _chatService;

  FetchMessagesImplUseCase(this._chatService);

  @override
  Future<List<DialogMessageEntity>> call() => _chatService.fetchMessages();
}
