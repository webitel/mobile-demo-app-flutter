import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:webitel_portal_sdk/src/domain/entities/dialog_message.dart';
import 'package:webitel_portal_sdk/src/domain/services/chat_service.dart';

abstract interface class ListenToMessagesUsecase {
  Future<StreamController<DialogMessageEntity>> call();
}

@LazySingleton(as: ListenToMessagesUsecase)
class ListenToMessagesImplUseCase implements ListenToMessagesUsecase {
  final ChatService _chatService;

  ListenToMessagesImplUseCase(this._chatService);

  @override
  Future<StreamController<DialogMessageEntity>> call() =>
      _chatService.listenToMessages();
}
