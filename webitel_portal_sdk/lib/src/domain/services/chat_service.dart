import 'dart:async';

import 'package:webitel_portal_sdk/src/domain/entities/dialog_message.dart';

abstract interface class ChatService {
  Future<List<DialogMessageEntity>> fetchMessages({
    int? limit,
    String? offset,
  });

  Future<List<DialogMessageEntity>> fetchUpdates({
    int? limit,
    String? offset,
  });

  Future<DialogMessageEntity> sendMessage(
      {required DialogMessageEntity message});

  Future<StreamController<DialogMessageEntity>> listenToMessages();

  Future<void> enterChat({required String chatId});

  Future<void> exitChat();
}
