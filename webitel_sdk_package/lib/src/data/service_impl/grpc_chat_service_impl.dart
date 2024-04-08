import 'dart:async';

import 'package:grpc/grpc.dart';
import 'package:grpc/grpc_or_grpcweb.dart';
import 'package:uuid/uuid.dart';
import 'package:webitel_sdk_package/src/data/gateway/grpc_gateway.dart';
import 'package:webitel_sdk_package/src/domain/entities/dialog_message.dart';
import 'package:webitel_sdk_package/src/domain/services/grpc_chat/grpc_chat_service.dart';
import 'package:webitel_sdk_package/src/exceptions/grpc_exception.dart';
import 'package:webitel_sdk_package/src/generated/chat/messages/peer.pb.dart';
import 'package:webitel_sdk_package/src/generated/google/protobuf/any.pb.dart';
import 'package:webitel_sdk_package/src/generated/portal/connect.pb.dart'
    as portal;
import 'package:webitel_sdk_package/src/generated/portal/messages.pb.dart';

class GrpcChatServiceImpl implements GrpcChatService {
  final GrpcGateway _grpcGateway;

  GrpcChatServiceImpl(this._grpcGateway);

  final requestStreamController = StreamController<portal.Request>();
  ResponseStream<portal.Update>? responseStream;
  final uuid = Uuid();

  @override
  Future<String> connectToGrpcChannel({
    required String deviceId,
    required String clientToken,
    required String accessToken,
  }) async {
    await _grpcGateway.init();
    final pingEcho = portal.Echo(data: [1, 2, 3, 4]);
    final pingRequest = portal.Request(
      path: '/webitel.portal.Customer/Ping',
      data: Any.pack(pingEcho),
    );
    requestStreamController.add(pingRequest);

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

      final pingRequest = portal.Request(
        path: '/webitel.portal.Customer/Ping',
        data: Any.pack(pingEcho),
      );
      requestStreamController.add(pingRequest);
      portal.Echo? echoResponse;

      if (responseStream != null) {
        responseStream?.forEach((res) {
          final canUnpackIntoResponse =
              res.data.canUnpackInto(portal.Response());
          if (canUnpackIntoResponse == true) {
            final response = res.data.unpackInto(portal.Response());
            final canUnpackIntoEcho =
                response.data.canUnpackInto(portal.Echo());
            if (canUnpackIntoEcho == true) {
              echoResponse = response.data.unpackInto(portal.Echo());
              print('Echo response: ${echoResponse!.data}');
            } else {
              throw GrpcException(message: 'Can not unpack into Echo');
            }
          } else {
            throw GrpcException(message: 'Can not unpack into response');
          }
        });
        if (echoResponse != null) {
          return echoResponse!.data;
        } else {
          return [];
        }
      } else {
        throw GrpcException(message: 'Grpc stream is null');
      }
    } catch (error, _) {
      return [];
    }
  }

  @override
  Future<DialogMessageEntity> sendDialogMessage(
      {required DialogMessageEntity message}) async {
    try {
      final newMessageRequest = SendMessageRequest(
        text: 'Test message',
        peer: Peer(id: '', type: '', name: ''),
      );
      final id = uuid.v4();
      final request = portal.Request(
        path: '/webitel.portal.Customer/SendMessage',
        data: Any.pack(newMessageRequest),
        id: id,
      );

      final completer = Completer<DialogMessageEntity>();
      if (responseStream != null) {
        responseStream?.forEach((response) {
          final canUnpackIntoResponse =
              response.data.canUnpackInto(portal.Response());
          if (canUnpackIntoResponse == true) {
            final decodedResponse = response.data.unpackInto(portal.Response());
            final canUnpackIntoUpdateNewMessage =
                decodedResponse.data.canUnpackInto(UpdateNewMessage());
            if (canUnpackIntoUpdateNewMessage == true) {
              final decodedUpdateNewMessage =
                  decodedResponse.data.unpackInto(UpdateNewMessage());
              if (decodedUpdateNewMessage.message.id.toString() == id) {
                completer.complete(
                  DialogMessageEntity(
                    id: decodedUpdateNewMessage.message.id.toString(),
                    timestamp: decodedUpdateNewMessage.message.date.toInt(),
                  ),
                );
              } else {
                throw GrpcException(message: 'Ids are not equal');
              }
            } else {
              throw GrpcException(
                  message: 'Can not unpack into New Message Update');
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
