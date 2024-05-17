import 'dart:async';
import 'dart:io';

import 'package:webitel_portal_sdk/webitel_portal_sdk.dart';
import 'package:webitel_sdk/domain/entity/dialog_message_entity.dart';

abstract interface class ChatService {
  Future<PortalResponse> sendDialogMessage({
    required DialogMessageEntity dialogMessageEntity,
    required Dialog dialog,
  });

  Future<Stream<DialogMessageEntity>> listenToMessages({
    required Dialog dialog,
  });

  Future<List<DialogMessageEntity>> fetchMessages({
    required Dialog dialog,
  });

  Future<List<DialogMessageEntity>> fetchPaginationMessages({
    required Dialog dialog,
    required int limit,
    required int offset,
  });

  Future<File?> pickFile();

  Future<File?> pickImage();
}
