import 'dart:async';
import 'dart:io';

import 'package:webitel_sdk/domain/entity/dialog_message_entity.dart';
import 'package:webitel_sdk/domain/entity/media_file.dart';
import 'package:webitel_sdk/domain/entity/response_entity.dart';

abstract interface class ChatService {
  Future<ResponseEntity> sendDialogMessage(
      {required DialogMessageEntity dialogMessageEntity});

  Future<Stream<DialogMessageEntity>> listenToMessages();

  Future<List<DialogMessageEntity>> fetchMessages();

  Future<File?> pickFile();

  Future<MediaFileEntity> uploadMedia({required File file});
}
