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

  late final StreamController<portal.Response> _responseStreamController;
  late final StreamController<ConnectStreamStatus> _connectController;
  late final StreamController<UpdateNewMessage> _updateStreamController;
  late final StreamController<portal.Request> _requestStreamController;
  late final StreamController<ErrorEntity> _errorStreamController;
  bool connectClosed = true;
  final Lock _lock = Lock();
  Logger logger = CustomLogger.getLogger();
  ConnectionState? connectionState;

  ConnectListenerGateway(
    this._databaseProvider,
    this._grpcGateway,
  ) {
    _responseStreamController = StreamController<portal.Response>.broadcast();
    _connectController = StreamController<ConnectStreamStatus>.broadcast();
    _updateStreamController = StreamController<UpdateNewMessage>.broadcast();
    _requestStreamController = StreamController<portal.Request>.broadcast();
    _errorStreamController = StreamController<ErrorEntity>.broadcast();
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
          connectClosed = false;
          _connectController
              .add(ConnectStreamStatus(status: ConnectStatus.opened));
          final canUnpackIntoResponse =
              update.data.canUnpackInto(portal.Response());
          final canUnpackIntoUpdateNewMessage =
              update.data.canUnpackInto(UpdateNewMessage());
          if (canUnpackIntoResponse == true) {
            final decodedResponse = update.data.unpackInto(portal.Response());
            _databaseProvider.deleteRequest(requestId: decodedResponse.id);
            if (decodedResponse.err.hasMessage()) {
              _errorStreamController.add(ErrorEntity(
                  statusCode: decodedResponse.err.code.toString(),
                  errorMessage: decodedResponse.err.message));
            }
            _responseStreamController.add(decodedResponse);
          } else if (canUnpackIntoUpdateNewMessage == true) {
            final decodedUpdate = update.data.unpackInto(UpdateNewMessage());
            logger.t(
                'Received update message in stream: ${decodedUpdate.message}');
            _databaseProvider.deleteRequest(requestId: decodedUpdate.id);
            _updateStreamController.add(decodedUpdate);
            logger.t(decodedUpdate.message.text);
          }
        },
        onError: (error, stackTrace) {
          logger.e(error: error, stackTrace);
          if (!completer.isCompleted) {
            completer.complete();
          }
          connectClosed = true;
          _connectController.add(ConnectStreamStatus(
            status: ConnectStatus.closed,
            errorMessage: error.toString(),
          ));
        },
        onDone: () {
          logger.e('Stream is done');
          if (!completer.isCompleted) {
            completer.complete();
          }
          connectClosed = true;
          _connectController.add(ConnectStreamStatus(
            status: ConnectStatus.closed,
            errorMessage: 'Stream was closed',
          ));
        },
        cancelOnError: true,
      );
      await completer.future;
    } catch (error, stackTrace) {
      connectClosed = true;
      logger.e(error: error, stackTrace: stackTrace, error);
    }
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
      if (connectClosed == true) {
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
      switch (state) {
        case ConnectionState.connecting:
          connectionState = ConnectionState.connecting;
        case ConnectionState.ready:
          connectionState = ConnectionState.ready;
        case ConnectionState.transientFailure:
          connectionState = ConnectionState.transientFailure;
        case ConnectionState.idle:
          connectionState = ConnectionState.idle;
        case ConnectionState.shutdown:
          connectionState = ConnectionState.shutdown;
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