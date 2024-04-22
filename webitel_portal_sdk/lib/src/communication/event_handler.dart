import 'dart:async';

import 'package:webitel_portal_sdk/src/domain/entities/connect_status.dart';
import 'package:webitel_portal_sdk/src/domain/entities/dialog_message.dart';
import 'package:webitel_portal_sdk/src/domain/usecase/chat/listen_to_messages_usecase.dart';
import 'package:webitel_portal_sdk/src/domain/usecase/connect_status_listener/listen_connect_status_usecase.dart';
import 'package:webitel_portal_sdk/src/injection/injection.dart';

class EventHandler {
  late ListenToMessagesUsecase _listenToMessagesUsecase;
  late ListenConnectStatusUseCase _listenConnectStatusUseCase;

  EventHandler() {
    _listenToMessagesUsecase = getIt.get<ListenToMessagesUsecase>();
    _listenConnectStatusUseCase = getIt.get<ListenConnectStatusUseCase>();
  }

  Future<StreamController<DialogMessageEntity>> listenToMessages() async {
    return await _listenToMessagesUsecase();
  }

  Future<StreamController<ConnectStreamStatus>> listenConnectStatus() async {
    final connectStreamStatusListener = await _listenConnectStatusUseCase();
    return connectStreamStatusListener;
  }
}
