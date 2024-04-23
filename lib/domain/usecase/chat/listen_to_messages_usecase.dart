import 'package:webitel_sdk/domain/entity/dialog_message_entity.dart';
import 'package:webitel_sdk/domain/service/chat_service.dart';

abstract interface class ListenToMessagesUseCase {
  Future<Stream<DialogMessageEntity>> call();
}

class ListenToMessagesImplUseCase implements ListenToMessagesUseCase {
  final ChatService _chatService;

  ListenToMessagesImplUseCase(this._chatService);

  @override
  Future<Stream<DialogMessageEntity>> call() => _chatService.listenToMessages();
}
