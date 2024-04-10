import 'package:webitel_sdk/domain/service/chat_service.dart';

abstract interface class ListenIncomingOperatorUseCase {
  Future<Stream<dynamic>> call();
}

class ListenIncomingOperatorImplUseCase
    implements ListenIncomingOperatorUseCase {
  final ChatService _chatService;

  ListenIncomingOperatorImplUseCase(this._chatService);

  @override
  Future<Stream<dynamic>> call() =>
      _chatService.listenIncomingOperatorMessages();
}
