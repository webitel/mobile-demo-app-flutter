import 'dart:async';

import 'package:webitel_sdk_package/src/domain/entities/connect_status.dart';

abstract interface class ConnectStatusListenerService {
  Future<StreamController<ConnectStreamStatus>> listenConnectStatus();
}
