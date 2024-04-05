import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc/grpc_or_grpcweb.dart';
import 'package:webitel_sdk_package/src/data/gateway/grpc_gateway.dart';
import 'package:webitel_sdk_package/src/domain/entities/message.dart';
import 'package:webitel_sdk_package/src/domain/services/grpc_chat/grpc_chat_service.dart';
import 'package:webitel_sdk_package/src/exceptions/grpc_exception.dart';
import 'package:webitel_sdk_package/src/generated/chat/messages/message.pb.dart';
import 'package:webitel_sdk_package/src/generated/portal/connect.pb.dart'
    as portal;

import '../../generated/google/protobuf/any.pb.dart';

class GrpcChatServiceImpl implements GrpcChatService {
  final GrpcGateway _grpcGateway;

  GrpcChatServiceImpl(this._grpcGateway);

  final requestStreamController = StreamController<portal.Request>();
  ResponseStream<portal.Update>? responseStream;

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
        responseStream = _grpcGateway.customerClient.connect(
          Stream<portal.Request>.fromIterable([request]),
          options: options,
        );
      } catch (error) {
        print('Error connecting to gRPC channel: $error');
      }
    });

    return 'Connected successfully';
  }

  @override
  Future<List<int>> ping({required List<int> echo}) async {
    try {
      final echoData = echo;
      final pingEcho = portal.Echo(data: echoData);
      final request = portal.Request(
        path: '/webitel.portal.Customer/Ping',
        data: Any.pack(pingEcho),
      );
      requestStreamController.add(request);
      portal.Response? messageResponse;
      bool? canUnpackIntoResponse;

      if (responseStream != null) {
        responseStream?.forEach((res) {
          canUnpackIntoResponse = res.data.canUnpackInto(portal.Response());
          if (canUnpackIntoResponse == true) {
            messageResponse = res.data.unpackInto(portal.Response());
            messageResponse?.data.unpackInto(portal.Echo());
          } else {
            throw GrpcException(message: 'Can not unpack into response');
          }
        });
        return messageResponse!.data.value;
      }
      return [];
    } catch (error, _) {
      return [];
    }
  }

  @override
  Future<MessageEntity> sendMessage({required MessageEntity message}) async {
    try {
      final messageData = Message(
        id: Int64.tryParseInt(message.id),
      );

      final request = portal.Request(
        path: '/webitel.portal.Customer/SendMessage',
        data: Any.pack(messageData),
      );

      final completer = Completer<MessageEntity>();
      if (responseStream != null) {
        responseStream?.forEach((response) {
          final canUnpack = response.data.canUnpackInto(portal.Response());
          if (canUnpack == true) {
            final decodedResponse = response.data.unpackInto(portal.Response());
            if (decodedResponse.id == message.id) {
              final responseMessage = MessageEntity(
                id: decodedResponse.id,
                timestamp: decodedResponse.data.value.first,
              );
              completer.complete(responseMessage);
            } else {
              throw GrpcException(message: 'Ids are not equal');
            }
          } else {
            throw GrpcException(message: 'Can not unpack into response');
          }
        });
      }

      requestStreamController.add(request);

      final response = await completer.future;
      return response;
    } catch (error) {
      return Future.error(GrpcException(message: error.toString()).message);
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
}
