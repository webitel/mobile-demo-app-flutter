import 'dart:async';

import 'package:webitel_sdk_package/src/backbone/injection/dependency_injection.dart';
import 'package:webitel_sdk_package/src/domain/entities/connect_status.dart';
import 'package:webitel_sdk_package/src/domain/entities/dialog_message.dart';
import 'package:webitel_sdk_package/src/domain/usecase/chat/listen_to_messages_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/connect_status_listener/listen_connect_status_usecase.dart';

class EventHandler {
  late ListenToMessagesUsecase _listenToMessagesUsecase;
  late ListenConnectStatusUseCase _listenConnectStatusUseCase;

  EventHandler() {
    _listenToMessagesUsecase = locator.get<ListenToMessagesUsecase>(
        instanceName: "ListenToOperatorMessagesUsecase");
    _listenConnectStatusUseCase = locator.get<ListenConnectStatusUseCase>(
        instanceName: "ListenConnectStatusUseCase");
  }

  Future<StreamController<DialogMessageEntity>> listenToMessages() async {
    return await _listenToMessagesUsecase();
  }

  Future<StreamController<ConnectStreamStatus>> listenConnectStatus() async {
    final connectStreamStatusListener = await _listenConnectStatusUseCase();
    return connectStreamStatusListener;
  }
}
