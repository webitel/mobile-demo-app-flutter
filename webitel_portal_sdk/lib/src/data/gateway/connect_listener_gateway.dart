import 'dart:async';

import 'package:grpc/grpc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:synchronized/synchronized.dart';
import 'package:webitel_portal_sdk/src/backbone/logger.dart';
import 'package:webitel_portal_sdk/src/data/gateway/grpc_gateway.dart';
import 'package:webitel_portal_sdk/src/database/database.dart';
import 'package:webitel_portal_sdk/src/domain/entities/connect_status.dart';
import 'package:webitel_portal_sdk/src/domain/entities/error.dart';
import 'package:webitel_portal_sdk/src/generated/google/protobuf/any.pb.dart';
import 'package:webitel_portal_sdk/src/generated/portal/connect.pb.dart'
    as portal;
import 'package:webitel_portal_sdk/src/generated/portal/messages.pb.dart';

@LazySingleton()
class ConnectListenerGateway {
  final GrpcGateway _grpcGateway;
  final DatabaseProvider _databaseProvider;

  final StreamController<portal.Response> _responseStreamController =
      StreamController<portal.Response>.broadcast();
  final StreamController<ConnectStreamStatus> _connectController =
      StreamController<ConnectStreamStatus>.broadcast();
  final StreamController<UpdateNewMessage> _updateStreamController =
      StreamController<UpdateNewMessage>.broadcast();
  final StreamController<portal.Request> _requestStreamController =
      StreamController<portal.Request>.broadcast();
  final StreamController<ErrorEntity> _errorStreamController =
      StreamController<ErrorEntity>.broadcast();

  bool connectClosed = true;
  final Lock _lock = Lock();
  Logger logger = CustomLogger.getLogger();
  ConnectionState? connectionState;

  ConnectListenerGateway(
    this._databaseProvider,
    this._grpcGateway,
  ) {
    listenToChannelStatus();
  }

  Future<void> _connect() async {
    try {
      final completer = Completer<void>();
      _grpcGateway.stub.connect(_requestStreamController.stream).listen(
        (update) async {
          if (!completer.isCompleted) {
            completer.complete();
            logger.t('Update received');
          }
          _handleUpdate(update);
        },
        onError: _handleError,
        onDone: _handleStreamDone,
        cancelOnError: true,
      );

      await completer.future;
    } catch (error, stackTrace) {
      _handleError(error, stackTrace);
    }
  }

  void _handleUpdate(portal.Update update) {
    connectClosed = false;
    _connectController.add(ConnectStreamStatus(status: ConnectStatus.opened));

    if (update.data.canUnpackInto(portal.Response())) {
      final decodedResponse = update.data.unpackInto(portal.Response());
      _handleResponse(decodedResponse);
    } else if (update.data.canUnpackInto(UpdateNewMessage())) {
      final decodedUpdate = update.data.unpackInto(UpdateNewMessage());
      _handleNewMessageUpdate(decodedUpdate);
    }
  }

  void _handleResponse(portal.Response decodedResponse) {
    _databaseProvider.deleteRequest(requestId: decodedResponse.id);
    logger.t('Received response message in stream: ${decodedResponse.id}');
    if (decodedResponse.err.hasMessage()) {
      _errorStreamController.add(ErrorEntity(
          statusCode: decodedResponse.err.code.toString(),
          errorMessage: decodedResponse.err.message));
    }
    _responseStreamController.add(decodedResponse);
  }

  void _handleNewMessageUpdate(UpdateNewMessage decodedUpdate) {
    logger.t('Received update message in stream: ${decodedUpdate.message}');
    _databaseProvider.deleteRequest(requestId: decodedUpdate.id);
    _updateStreamController.add(decodedUpdate);
    logger.t(decodedUpdate.message.text);
  }

  void _handleError(error, StackTrace stackTrace) {
    logger.e(error, error: error, stackTrace: stackTrace);
    if (error is! GrpcError) {
      connectClosed = true;
      _connectController.add(ConnectStreamStatus(
        status: ConnectStatus.closed,
        errorMessage: error.toString(),
      ));
    }
  }

  void _handleStreamDone() {
    logger.e('Stream is done');
    connectClosed = true;
    _connectController.add(ConnectStreamStatus(
      status: ConnectStatus.closed,
      errorMessage: 'Stream was closed',
    ));
  }

  Future<void> sendPingMessage() async {
    final echoData = [1, 2, 3];
    final echo = portal.Echo(data: echoData);
    final request = portal.Request(
      path: '/webitel.portal.Customer/Ping',
      data: Any.pack(echo),
    );

    _requestStreamController.add(request);
  }

  Future<void> sendRequest(portal.Request request) async {
    await reconnect(request);
    _requestStreamController.add(request);

    logger.t('Request added: ${request.path}');
  }

  Future<void> reconnect(portal.Request request) async {
    if (connectionState == ConnectionState.shutdown) {
      logger.t('ConnectionState.shutdown');
      final user = await _databaseProvider.readUser();
      await _grpcGateway.setAccessToken(user.accessToken);
      logger.t('Re-init gRPC Channel');
    }
    await _lock.synchronized(() async {
      if (connectClosed) {
        final timer = Timer.periodic(Duration(seconds: 1), (timer) {
          sendPingMessage();
          logger.t('Ping sent');
        });
        await _connect();
        timer.cancel();
        logger.t('Connected to gRPC Stream');
      }
    });
  }

  Future<void> listenToChannelStatus() async {
    _grpcGateway.stateStream.stream.listen((state) {
      connectionState = state;
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
    _errorStreamController.close();
  }
}
