import 'dart:async';
import 'dart:io';

import 'package:webitel_portal_sdk/webitel_portal_sdk.dart';
import 'package:webitel_sdk/domain/entity/dialog_message_entity.dart';
import 'package:webitel_sdk/domain/entity/response_entity.dart';

abstract interface class ChatService {
  Future<ResponseEntity> sendDialogMessage({
    required DialogMessageEntity dialogMessageEntity,
    required Dialog dialog,
  });

  Future<Stream<DialogMessageEntity>> listenToMessages({
    required Dialog dialog,
  });

  Future<List<DialogMessageEntity>> fetchMessages({
    required Dialog dialog,
  });

  Future<File?> pickFile();
}
