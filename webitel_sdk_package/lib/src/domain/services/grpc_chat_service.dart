import 'dart:async';

import 'package:webitel_sdk_package/src/domain/entities/dialog_message.dart';

abstract interface class ChatService {
  Future<List<DialogMessageEntity>> fetchMessages({int? limit, String? offset});

  Future<List<DialogMessageEntity>> fetchMessageUpdates(
      {int? limit, String? offset});

  Future<DialogMessageEntity> sendDialogMessage(
      {required DialogMessageEntity message});

  Future<StreamController<DialogMessageEntity>> listenToMessages();
}
