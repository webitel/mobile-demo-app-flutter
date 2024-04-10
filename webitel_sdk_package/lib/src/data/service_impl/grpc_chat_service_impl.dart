import 'dart:async';

import 'package:grpc/grpc.dart';
import 'package:grpc/grpc_or_grpcweb.dart';
import 'package:uuid/uuid.dart';
import 'package:webitel_sdk_package/src/data/gateway/grpc_gateway.dart';
import 'package:webitel_sdk_package/src/domain/entities/dialog_message.dart';
import 'package:webitel_sdk_package/src/domain/services/grpc_chat/grpc_chat_service.dart';
import 'package:webitel_sdk_package/src/generated/chat/messages/history.pb.dart';
import 'package:webitel_sdk_package/src/generated/chat/messages/peer.pb.dart';
import 'package:webitel_sdk_package/src/generated/google/protobuf/any.pb.dart';
import 'package:webitel_sdk_package/src/generated/portal/connect.pb.dart'
    as portal;
import 'package:webitel_sdk_package/src/generated/portal/messages.pb.dart';

class GrpcChatServiceImpl implements GrpcChatService {
  final GrpcGateway _grpcGateway;
  final requestStreamController = StreamController<portal.Request>();
  late final StreamController<portal.Response> _responseStreamController;
  late final StreamController<UpdateNewMessage> _updateStreamController;
  Timer? _pingTimer;
  final uuid = Uuid();

  GrpcChatServiceImpl(this._grpcGateway) {
    _responseStreamController = StreamController<portal.Response>.broadcast();
    _updateStreamController = StreamController<UpdateNewMessage>.broadcast();
    startPingTimer(Duration(seconds: 10));
  }

  void startPingTimer(Duration period) {
    _pingTimer = Timer.periodic(period, (Timer timer) {
      pingServer();
    });
  }

  void stopPingTimer() {
    _pingTimer?.cancel();
  }

  Future<void> pingServer() async {
    final echoData = [1, 2, 3, 4, 5];
    final pingEcho = portal.Echo(data: echoData);

    final pingRequest = portal.Request(
      path: '/webitel.portal.Customer/Ping',
      data: Any.pack(pingEcho),
      id: '',
    );
    requestStreamController.add(pingRequest);
  }

  @override
  Future<String> connectToGrpcChannel({
    required String deviceId,
    required String clientToken,
    required String accessToken,
  }) async {
    try {
      CallOptions options = CallOptions(
        metadata: {
          'x-portal-device': deviceId,
          'x-portal-client': clientToken,
          'x-portal-access': accessToken,
        },
      );

      _grpcGateway.customerClient
          .connect(
        requestStreamController.stream,
        options: options,
      )
          .listen((response) {
        final canUnpackIntoResponse =
            response.data.canUnpackInto(portal.Response());
        final canUnpackIntoUpdateNewMessage =
            response.data.canUnpackInto(UpdateNewMessage());
        if (canUnpackIntoResponse == true) {
          final decodedResponse = response.data.unpackInto(portal.Response());
          _responseStreamController.add(decodedResponse);
        } else if (canUnpackIntoUpdateNewMessage == true) {
          final decodedResponse = response.data.unpackInto(UpdateNewMessage());
          _updateStreamController.add(decodedResponse);
        }
      }, onError: (error) {
        _responseStreamController.addError(error);
        _updateStreamController.addError(error);
      }, onDone: () {
        print('Stream was closed');
      });
    } catch (error) {
      print('SocketException occurred: $error');
    }
    return '';
  }

  @override
  Future<Stream<DialogMessageEntity>> listenToOperatorMessages() async {
    final operatorMessagesController = StreamController<DialogMessageEntity>();
    _updateStreamController.stream.listen(
      (update) {
        operatorMessagesController.add(
          DialogMessageEntity(
            dialogMessageContent: update.message.text,
            peer: PeerInfo(
              id: update.message.chat.peer.id,
              name: update.message.chat.peer.name,
              type: update.message.chat.peer.type,
            ),
          ),
        );
      },
    );

    return operatorMessagesController.stream;
  }

  @override
  Future<DialogMessageEntity> sendDialogMessage(
      {required DialogMessageEntity message}) async {
    final completer = Completer<DialogMessageEntity>();
    final maxRetries = 5;
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
  Future<List<DialogMessageEntity>> fetchDialogs() async {
    final maxRetries = 5;
    var attempt = 0;
    var consecutiveErrors = 0;
    final completer = Completer<List<DialogMessageEntity>>();
    final messages = [];

    while (!completer.isCompleted && attempt < maxRetries) {
      try {
        final id = uuid.v4();

        final fetchDialogsRequest = ChatMessagesRequest(chatId: '');
        final request = portal.Request(
          path: '/webitel.portal.ChatMessages/ChatHistory',
          data: Any.pack(fetchDialogsRequest),
          id: id,
        );

        requestStreamController.add(request);

        StreamSubscription<portal.Response>? subscription;
        subscription = _responseStreamController.stream.listen((response) {
          if (response.id == id) {
            final canUnpackIntoDialogMessages =
                response.data.canUnpackInto(ChatMessages());
            if (canUnpackIntoDialogMessages == true) {
              final unpackedDialogMessages =
                  response.data.unpackInto(ChatMessages());

              for (var unpackedMessage in unpackedDialogMessages.messages) {
                messages.add(
                  DialogMessageEntity(
                    dialogMessageContent: unpackedMessage.text,
                    peer: PeerInfo(
                      name: unpackedMessage.chat.peer.name,
                      type: unpackedMessage.chat.peer.type,
                      id: unpackedMessage.chat.peer.id,
                    ),
                  ),
                );
              }
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
              return [];
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
    return [];
  }

  @override
  Future<List<DialogMessageEntity>> fetchUpdates() async {
    final maxRetries = 5;
    var attempt = 0;
    var consecutiveErrors = 0;
    final completer = Completer<List<DialogMessageEntity>>();
    final messages = [];

    while (!completer.isCompleted && attempt < maxRetries) {
      try {
        final id = uuid.v4();

        final fetchUpdatesRequest = ChatMessagesRequest(chatId: '');
        final request = portal.Request(
          path: '/webitel.portal.ChatMessages/ChatUpdates',
          data: Any.pack(fetchUpdatesRequest),
          id: id,
        );

        requestStreamController.add(request);

        StreamSubscription<portal.Response>? subscription;
        subscription = _responseStreamController.stream.listen((response) {
          if (response.id == id) {
            final canUnpackIntoDialogMessages =
                response.data.canUnpackInto(ChatMessages());
            if (canUnpackIntoDialogMessages == true) {
              final unpackedDialogMessages =
                  response.data.unpackInto(ChatMessages());

              for (var unpackedMessage in unpackedDialogMessages.messages) {
                messages.add(
                  DialogMessageEntity(
                    dialogMessageContent: unpackedMessage.text,
                    peer: PeerInfo(
                      name: unpackedMessage.chat.peer.name,
                      type: unpackedMessage.chat.peer.type,
                      id: unpackedMessage.chat.peer.id,
                    ),
                  ),
                );
              }
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
              return [];
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
    return [];
  }

  void dispose() {
    requestStreamController.close();
    _responseStreamController.close();
    _updateStreamController.close();
    stopPingTimer();
  }
}
