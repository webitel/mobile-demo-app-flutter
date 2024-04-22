import 'package:grpc/grpc.dart';
import 'package:injectable/injectable.dart';
import 'package:webitel_portal_sdk/src/data/gateway/grpc_gateway.dart';

@LazySingleton()
class ChannelStatusListener {
  final GrpcGateway _grpcGateway;
  ConnectionState? lastState;

  ChannelStatusListener(this._grpcGateway);

  Future<void> listenToChannelStatus() async {
    if (lastState == ConnectionState.shutdown) {
      _grpcGateway.channel.createConnection();
    }
    _grpcGateway.channel.onConnectionStateChanged.listen((status) {
      switch (status) {
        case ConnectionState.connecting:
        case ConnectionState.ready:
        case ConnectionState.transientFailure:
          _grpcGateway.channel.createConnection();
          break;
        case ConnectionState.idle:
        case ConnectionState.shutdown:
          lastState = ConnectionState.shutdown;
          _grpcGateway.channel.createConnection();
          break;
      }
    });
  }
}
