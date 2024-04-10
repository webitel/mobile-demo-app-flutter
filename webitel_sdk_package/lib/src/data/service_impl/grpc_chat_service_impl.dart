import 'dart:async';

import 'package:grpc/grpc.dart';
import 'package:grpc/grpc_or_grpcweb.dart';
import 'package:uuid/uuid.dart';
import 'package:webitel_sdk_package/src/data/gateway/grpc_gateway.dart';
import 'package:webitel_sdk_package/src/domain/entities/dialog_message.dart';
import 'package:webitel_sdk_package/src/domain/services/grpc_chat/grpc_chat_service.dart';
import 'package:webitel_sdk_package/src/generated/chat/messages/peer.pb.dart';
import 'package:webitel_sdk_package/src/generated/google/protobuf/any.pb.dart';
import 'package:webitel_sdk_package/src/generated/portal/connect.pb.dart'
    as portal;
import 'package:webitel_sdk_package/src/generated/portal/messages.pb.dart';

class GrpcChatServiceImpl implements GrpcChatService {
  final GrpcGateway _grpcGateway;

  final requestStreamController = StreamController<portal.Request>();
  late final StreamController<portal.Response> _responseStreamController;
  late final StreamController<portal.Update> _updateStreamController;
  final uuid = Uuid();

  GrpcChatServiceImpl(this._grpcGateway) {
    _responseStreamController = StreamController<portal.Response>.broadcast();
    _updateStreamController = StreamController<portal.Update>.broadcast();
  }

  @override
  Future<String> connectToGrpcChannel({
    required String deviceId,
    required String clientToken,
    required String accessToken,
  }) async {
    try {
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
          final canUnpackIntoResponse =
              response.data.canUnpackInto(portal.Response());
          final canUnpackIntoUpdate =
              response.data.canUnpackInto(portal.Update());
          if (canUnpackIntoResponse == true) {
            final decodedResponse = response.data.unpackInto(portal.Response());
            _responseStreamController.add(decodedResponse);
          } else if (canUnpackIntoUpdate == true) {
            final decodedResponse = response.data.unpackInto(portal.Update());
            _updateStreamController.add(decodedResponse);
          }
        }, onError: (error) {
          _responseStreamController.addError(error);
          _updateStreamController.addError(error);
        });
      });
    } catch (error) {
      print('SocketException occurred: $error');
    }
    return '';
  }

  @override
  Future<DialogMessageEntity> sendDialogMessage(
      {required DialogMessageEntity message}) async {
    final maxRetries = 5;
    final completer = Completer<DialogMessageEntity>();
    var attempt = 0;
    var consecutiveErrors = 0;

    while (!completer.isCompleted && attempt < maxRetries) {
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

        StreamSubscription<portal.Response>? subscription;
        subscription = _responseStreamController.stream.listen((response) {
          if (response.id == id) {
            final canUnpackIntoUpdateNewMessage =
                response.data.canUnpackInto(UpdateNewMessage());
            if (canUnpackIntoUpdateNewMessage == true) {
              final unpackedMessage =
                  response.data.unpackInto(UpdateNewMessage());

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
              subscription?.cancel();
            }
          }
        }, onError: (error) {
          if (error is GrpcError) {
            print(error);
            subscription?.cancel();
            consecutiveErrors++;
            if (consecutiveErrors == maxRetries) {
              completer.complete(
                DialogMessageEntity(
                  dialogMessageContent: error.toString(),
                  peer: PeerInfo(
                    name: 'ERROR',
                    type: 'Unknown',
                    id: '',
                  ),
                ),
              );
            }
          }
        }, onDone: () {});
        await completer.future.timeout(Duration(seconds: 1));
        if (completer.isCompleted) {
          consecutiveErrors = 0;
          attempt = 0;
          return completer.future;
        }
      } catch (error) {
        print(error);
      }
      attempt++;
    }
    return DialogMessageEntity(
      dialogMessageContent: 'Unknown Error',
      peer: PeerInfo(
        name: 'ERROR',
        type: 'Unknown',
        id: '',
      ),
    );
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
