import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:synchronized/synchronized.dart';
import 'package:webitel_sdk_package/src/data/gateway/channel_status_listener.dart';
import 'package:webitel_sdk_package/src/data/gateway/grpc_gateway.dart';
import 'package:webitel_sdk_package/src/domain/entities/connect_status.dart';
import 'package:webitel_sdk_package/src/domain/entities/error.dart';
import 'package:webitel_sdk_package/src/generated/portal/connect.pb.dart'
    as portal;
import 'package:webitel_sdk_package/src/generated/portal/connect.pb.dart';
import 'package:webitel_sdk_package/src/generated/portal/messages.pb.dart';

@LazySingleton()
class ConnectListenerGateway {
  final GrpcGateway _grpcGateway;
  final ChannelStatusListener _channelStatusListener;
  late final StreamController<portal.Response> _responseStreamController;
  late final StreamController<ConnectStreamStatus> _connectController;
  late final StreamController<UpdateNewMessage> _updateStreamController;
  late final StreamController<portal.Request> _requestStreamController;
  late final StreamController<ErrorEntity> _errorStreamController;
  bool connectClosed = true;
  final Lock _lock = Lock();
  StreamSubscription<Update>? stream;

  ConnectListenerGateway(
    this._grpcGateway,
    this._channelStatusListener,
  ) {
    _responseStreamController = StreamController<portal.Response>.broadcast();
    _connectController = StreamController<ConnectStreamStatus>.broadcast();
    _updateStreamController = StreamController<UpdateNewMessage>.broadcast();
    _requestStreamController = StreamController<portal.Request>.broadcast();
    _errorStreamController = StreamController<ErrorEntity>.broadcast();
  }

  Future<void> _connect() async {
    connectClosed = false;

    _grpcGateway.stub.connect(_requestStreamController.stream).listen(
      (update) {
        _connectController
            .add(ConnectStreamStatus(status: ConnectStatus.opened));
        final canUnpackIntoResponse =
            update.data.canUnpackInto(portal.Response());
        final canUnpackIntoUpdateNewMessage =
            update.data.canUnpackInto(UpdateNewMessage());
        if (canUnpackIntoResponse == true) {
          final decodedResponse = update.data.unpackInto(portal.Response());
          if (decodedResponse.err.hasMessage()) {
            _errorStreamController.add(ErrorEntity(
                statusCode: decodedResponse.err.code.toString(),
                errorMessage: decodedResponse.err.message));
          }
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
    await reconnect();
    _requestStreamController.add(request);
  }

  Future<void> reconnect() async {
    await _lock.synchronized(() async {
      if (connectClosed == true) {
        await _connect();
        await Future.delayed(Duration(seconds: 1));
        print('connect');
      }
    });
  }

  Stream<portal.Response> get responseStream =>
      _responseStreamController.stream;

  Stream<UpdateNewMessage> get updateStream => _updateStreamController.stream;

  Stream<ErrorEntity> get errorStream => _errorStreamController.stream;

  StreamController<ConnectStreamStatus> get connectStatusStream =>
      _connectController;

  void dispose() {
    _requestStreamController.close();
    _responseStreamController.close();
    _connectController.close();
    _updateStreamController.close();
  }
}
