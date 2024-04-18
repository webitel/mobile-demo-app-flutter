import 'dart:async';

import 'package:webitel_sdk_package/src/data/gateway/grpc_gateway.dart';
import 'package:webitel_sdk_package/src/domain/entities/connect_status.dart';
import 'package:webitel_sdk_package/src/generated/portal/connect.pb.dart'
    as portal;
import 'package:webitel_sdk_package/src/generated/portal/messages.pb.dart';

class ConnectListenerGateway {
  final GrpcGateway _grpcGateway;
  late final StreamController<portal.Response> _responseStreamController;
  late final StreamController<ConnectStreamStatus> _connectController;
  late final StreamController<UpdateNewMessage> _updateStreamController;
  late final StreamController<portal.Request> _requestStreamController;
  bool connectClosed = true;

  ConnectListenerGateway(this._grpcGateway) {
    _responseStreamController = StreamController<portal.Response>.broadcast();
    _connectController = StreamController<ConnectStreamStatus>.broadcast();
    _updateStreamController = StreamController<UpdateNewMessage>.broadcast();
    _requestStreamController = StreamController<portal.Request>.broadcast();
  }

  Future<void> _connect() async {
    _grpcGateway.stub.connect(_requestStreamController.stream).listen(
      (update) {
        connectClosed = false;
        _connectController
            .add(ConnectStreamStatus(status: ConnectStatus.opened));
        final canUnpackIntoResponse =
            update.data.canUnpackInto(portal.Response());
        final canUnpackIntoUpdateNewMessage =
            update.data.canUnpackInto(UpdateNewMessage());
        if (canUnpackIntoResponse == true) {
          final decodedResponse = update.data.unpackInto(portal.Response());
          _responseStreamController.add(decodedResponse);
        } else if (canUnpackIntoUpdateNewMessage == true) {
          final decodedResponse = update.data.unpackInto(UpdateNewMessage());
          _updateStreamController.add(decodedResponse);
        }
      },
      onError: (error) {
        connectClosed = true;
        _connectController.add(ConnectStreamStatus(
          status: ConnectStatus.closed,
          errorMessage: error.toString(),
        ));
      },
      onDone: () {
        connectClosed = true;
        _connectController.add(ConnectStreamStatus(
          status: ConnectStatus.closed,
          errorMessage: 'Stream was closed',
        ));
      },
      cancelOnError: true,
    );
  }

  Future<void> sendRequest(portal.Request request) async {
    if (connectClosed == true) {
      await _connect();
      await Future.delayed(Duration(seconds: 1));
    }

    _requestStreamController.add(request);
  }

  Stream<portal.Response> get responseStream =>
      _responseStreamController.stream;

  Stream<UpdateNewMessage> get updateStream => _updateStreamController.stream;

  StreamController<ConnectStreamStatus> get connectStatusStream =>
      _connectController;

  void dispose() {
    _requestStreamController.close();
    _responseStreamController.close();
    _connectController.close();
    _updateStreamController.close();
  }
}
