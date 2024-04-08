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

  final requestStreamController = StreamController<portal.Request>();
  late final StreamController<portal.Update> _responseStreamController;
  final uuid = Uuid();

  GrpcChatServiceImpl(this._grpcGateway) {
    _responseStreamController = StreamController<portal.Update>.broadcast();
  }

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

      _grpcGateway.customerClient
          .connect(
        Stream<portal.Request>.fromIterable([request]),
        options: options,
      )
          .listen((response) {
        _responseStreamController.add(response);
      });
    });

    return 'Connected successfully';
  }

  @override
  Future<List<int>> ping({required List<int> echo}) async {
    try {
      final id = uuid.v4();
      final echoData = echo;
      final pingEcho = portal.Echo(data: echoData);

      final pingRequest = portal.Request(
        path: '/webitel.portal.Customer/Ping',
        data: Any.pack(pingEcho),
        id: id,
      );
      requestStreamController.add(pingRequest);
      portal.Echo? echoResponse;

      _responseStreamController.stream.listen((res) {
        final canUnpackIntoResponse = res.data.canUnpackInto(portal.Response());
        if (canUnpackIntoResponse == true) {
          final response = res.data.unpackInto(portal.Response());
          final canUnpackIntoEcho = response.data.canUnpackInto(portal.Echo());
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
    } catch (error, _) {
      return [];
    }
  }

  @override
  Future<DialogMessageEntity> sendDialogMessage(
      {required DialogMessageEntity message}) async {
    try {
      final id = uuid.v4();

      final newMessageRequest = SendMessageRequest(
        text: message.dialogMessageContent,
        peer: Peer(
          id: message.peer.id,
          type: message.peer.type,
          name: message.peer.name,
        ),
      );

      final request = portal.Request(
        path: '/webitel.portal.ChatMessages/SendMessage',
        data: Any.pack(newMessageRequest),
        id: id,
      );

      requestStreamController.add(request);

      final completer = Completer<DialogMessageEntity>();

      _responseStreamController.stream.listen((response) {
        final canUnpackIntoResponse =
            response.data.canUnpackInto(portal.Response());
        if (canUnpackIntoResponse == true) {
          final decodedResponse = response.data.unpackInto(portal.Response());
          if (decodedResponse.id == id) {
            final canUnpackIntoUpdateNewMessage =
                decodedResponse.data.canUnpackInto(UpdateNewMessage());
            if (canUnpackIntoUpdateNewMessage == true) {
              final unpackedMessage =
                  decodedResponse.data.unpackInto(UpdateNewMessage());

              completer.complete(
                DialogMessageEntity(
                  dialogMessageContent: unpackedMessage.message.text,
                  peer: PeerInfo(
                    name: unpackedMessage.message.chat.peer.name,
                    type: unpackedMessage.message.chat.peer.type,
                    id: unpackedMessage.message.chat.peer.id,
                  ),
                ),
              );
              print('completed');
            } else {
              throw GrpcException(
                  message: 'Can not unpack into Update New Message ');
            }
          } else {
            throw GrpcException(message: 'Ids are not equal');
          }
        } else {
          throw GrpcException(message: 'Can not unpack into response');
        }
      });

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
