import 'dart:async';

import 'package:webitel_sdk_package/src/data/gateway/connect_listener_gateway.dart';
import 'package:webitel_sdk_package/src/domain/entities/connect_status.dart';
import 'package:webitel_sdk_package/src/domain/services/connect_status_listener/connect_status_listener_service.dart';

class ConnectStatusListenerServiceImpl implements ConnectStatusListenerService {
  final ConnectListenerGateway _connectListenerGateway;

  ConnectStatusListenerServiceImpl(this._connectListenerGateway);

  @override
  Future<StreamController<ConnectStreamStatus>> listenConnectStatus() async {
    return _connectListenerGateway.connectStatusStream;
  }
}
