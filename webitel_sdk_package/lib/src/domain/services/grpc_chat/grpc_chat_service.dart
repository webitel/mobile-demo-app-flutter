import 'dart:async';

import 'package:webitel_sdk_package/src/domain/entities/dialog_message.dart';

abstract interface class GrpcChatService {
  Future<List<DialogMessageEntity>> fetchMessages();

  Future<List<DialogMessageEntity>> fetchMessageUpdates();

  Future<void> sendDialogMessage({required DialogMessageEntity message});

  Future<StreamController<DialogMessageEntity>> listenToMessages();
}
