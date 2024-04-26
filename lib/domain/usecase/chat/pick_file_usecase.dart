import 'dart:async';
import 'dart:io';

import 'package:webitel_sdk/domain/service/chat_service.dart';

abstract interface class PickFileUseCase {
  Future<File?> call();
}

class PickFileImplUseCase implements PickFileUseCase {
  final ChatService _chatService;

  PickFileImplUseCase(this._chatService);

  @override
  Future<File?> call() => _chatService.pickFile();
}
