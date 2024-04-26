import 'dart:async';

import 'package:webitel_sdk/domain/entity/dialog_message_entity.dart';
import 'package:webitel_sdk/domain/entity/response_entity.dart';

abstract interface class ChatService {
  Future<ResponseEntity> sendDialogMessage(
      {required DialogMessageEntity dialogMessageEntity});

  Future<Stream<DialogMessageEntity>> listenToMessages();

  Future<List<DialogMessageEntity>> fetchMessages();

  Future<void> uploadMedia();
}
