import 'dart:async';

import 'package:webitel_sdk_package/src/domain/entities/connect_status.dart';
import 'package:webitel_sdk_package/src/domain/services/connect_status_listener/connect_status_listener_service.dart';

abstract interface class ListenConnectStatusUseCase {
  Future<StreamController<ConnectStreamStatus>> call();
}

class ListenConnectStatusImplUseCase implements ListenConnectStatusUseCase {
  final ConnectStatusListenerService _connectStatusListenerService;

  ListenConnectStatusImplUseCase(this._connectStatusListenerService);

  @override
  Future<StreamController<ConnectStreamStatus>> call() =>
      _connectStatusListenerService.listenConnectStatus();
}
