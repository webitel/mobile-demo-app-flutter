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
  Stream<portal.Update>? _responseStream;

  bool connectClosed = true;
  final Lock _lock = Lock();
  final Logger _logger = CustomLogger.getLogger();
  ConnectionState? _connectionState;
  Timer? _timer;

  ConnectListenerGateway(this._databaseProvider, this._grpcGateway) {
    listenToChannelStatus();
  }

  Future<void> listenToResponses() async {
    try {
      if (_responseStream != null) {
        await for (portal.Update update in _responseStream!) {
          connectClosed = false;
          _connectController
              .add(ConnectStreamStatus(status: ConnectStatus.opened));

          if (update.data.canUnpackInto(portal.Response())) {
            final decodedResponse = update.data.unpackInto(portal.Response());
            if (decodedResponse.err.hasMessage()) {
              _errorStreamController.add(ErrorEntity(
                  statusCode: decodedResponse.err.code.toString(),
                  errorMessage: decodedResponse.err.message));
            }
            _responseStreamController.add(decodedResponse);
          } else if (update.data.canUnpackInto(UpdateNewMessage())) {
            final decodedUpdate = update.data.unpackInto(UpdateNewMessage());
            _updateStreamController.add(decodedUpdate);
            _logger.t(decodedUpdate.message.text);
          }
        }
      } else {
        _logger.e('_response stream is null');
      }
    } on GrpcError catch (err, stackTrace) {
      _logger.e(err, stackTrace: stackTrace);
      connectClosed = true;
      _responseStream = null;
      _connectController.add(ConnectStreamStatus(
        status: ConnectStatus.closed,
        errorMessage: err.toString(),
      ));
    } catch (err, stackTrace) {
      _logger.e(err, stackTrace: stackTrace);
      connectClosed = true;
      _responseStream = null;
      _connectController.add(ConnectStreamStatus(
        status: ConnectStatus.closed,
        errorMessage: err.toString(),
      ));
    }
  }

  Future<void> _connect() async {
    try {
      _responseStream = _grpcGateway.customerStub
          .connect(_requestStreamController.stream)
          .asBroadcastStream();

      await _responseStream?.isEmpty;
      listenToResponses();
    } catch (err, stackTrace) {
      connectClosed = true;
      _responseStream = null;
      _logger.e(err, stackTrace: stackTrace);
    }
  }

  Future<void> sendPingMessage() async {
    final String echoDataString = 'Bind';
    final List<int> echoDataBytes = echoDataString.codeUnits;
    final echo = portal.Echo(data: echoDataBytes);
    final request = portal.Request(
      path: '/webitel.portal.Customer/Ping',
      data: Any.pack(echo),
    );
    _requestStreamController.add(request);
    _logger.t('Request added: ${request.path}');
  }

  Future<void> sendRequest(portal.Request request) async {
    _logger.i('Staring sending request...');
    if (connectClosed == true && _responseStream == null) {
      _logger.i(
          'Connection state is not ready or connection is closed. Attempting to reconnect...');
      await reconnect();
    }
    _requestStreamController.add(request);
    _logger.t('Request added: ${request.path}');
  }

  Future<void> reconnect() async {
    if (_connectionState == ConnectionState.shutdown) {
      _logger.t('Current connection state: $_connectionState');
      final user = await _databaseProvider.readUser();
      await _grpcGateway.setAccessToken(user.accessToken);
      _logger.t('Re-init gRPC Channel');
    }
    await _lock.synchronized(() async {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
        sendPingMessage();
      });
      await _connect();
      _timer?.cancel();
      _logger.t('Connected to gRPC Stream');
    });
  }

  Future<void> listenToChannelStatus() async {
    _grpcGateway.stateStream.stream.listen((state) async {
      if (state == ConnectionState.shutdown) {
        handleStreamCleanup();
        _logger.i('Response stream canceled due to $state');
      } else if (state == ConnectionState.transientFailure) {
        handleStreamCleanup();
        _logger.i('Response stream canceled due to $state');
      }
      _connectionState = state;
    });
  }

  void handleStreamCleanup() {
    _responseStream = null;
    connectClosed = true;
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
