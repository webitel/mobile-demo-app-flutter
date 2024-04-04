import 'dart:async';

import 'package:grpc/grpc.dart';
import 'package:webitel_sdk_package/src/data/gateway/grpc_gateway.dart';
import 'package:webitel_sdk_package/src/domain/services/grpc_chat/grpc_chat_service.dart';
import 'package:webitel_sdk_package/src/exceptions/auth_exception.dart';
import 'package:webitel_sdk_package/src/generated/portal/connect.pb.dart';

import '../../generated/google/protobuf/any.pb.dart';

class GrpcChatServiceImpl implements GrpcChatService {
  final GrpcGateway _grpcGateway;

  GrpcChatServiceImpl(this._grpcGateway);

  final requestStreamController = StreamController<Request>();

  @override
  Future<String> connectToGrpcChannel({
    required String deviceId,
    required String clientToken,
    required String accessToken,
  }) async {
    await _grpcGateway.init();

    requestStreamController.stream.listen((request) {
      CallOptions options = CallOptions(
        metadata: {
          'x-portal-device': deviceId,
          'x-portal-client': clientToken,
          'x-portal-access': accessToken,
        },
        timeout: Duration(seconds: 60),
      );

      try {
        final responseStream = _grpcGateway.customerClient.connect(
          Stream<Request>.fromIterable([request]),
          options: options,
        );
        responseStream.forEach((res) {
          print(res);
        });
      } catch (error) {
        print('Error connecting to gRPC channel: $error');
      }
    });

    return 'Connected successfully';
  }

  @override
  Future<String> ping({required List<int> echo}) async {
    try {
      final echoData = echo;
      final pingEcho = Echo(data: echoData);
      final request = Request(
        path: '/webitel.portal.Customer/Ping',
        data: Any.pack(pingEcho),
      );
      requestStreamController.add(request);
      return 'Ping sent successfully';
    } catch (error, _) {
      print('Error occurred: $error');
      return AuthException(message: error.toString()).message;
    }
  }

  @override
  Future<void> fetchDialogs() {
    // TODO: implement fetchDialogs
    throw UnimplementedError();
  }

  @override
  Future<void> fetchUpdates() {
    // TODO: implement fetchUpdates
    throw UnimplementedError();
  }

  @override
  Future<void> sendMessage() {
    // TODO: implement sendMessage
    throw UnimplementedError();
  }
}
