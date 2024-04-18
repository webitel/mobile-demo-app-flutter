import 'dart:async';

import 'package:webitel_sdk_package/src/domain/entities/dialog_message.dart';
import 'package:webitel_sdk_package/src/domain/services/chat/grpc_chat_service.dart';

abstract interface class ListenToMessagesUsecase {
  Future<StreamController<DialogMessageEntity>> call();
}

class ListenToMessagesImplUseCase implements ListenToMessagesUsecase {
  final ChatService _chatService;

  ListenToMessagesImplUseCase(this._chatService);

  @override
  Future<StreamController<DialogMessageEntity>> call() =>
      _chatService.listenToMessages();
}
