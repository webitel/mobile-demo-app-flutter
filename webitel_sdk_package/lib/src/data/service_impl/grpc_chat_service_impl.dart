import 'dart:async';

import 'package:grpc/grpc.dart';
import 'package:grpc/grpc_or_grpcweb.dart';
import 'package:uuid/uuid.dart';
import 'package:webitel_sdk_package/src/builder/dialog_message_builder.dart';
import 'package:webitel_sdk_package/src/builder/error_message_builder.dart';
import 'package:webitel_sdk_package/src/builder/portal_request_builder.dart';
import 'package:webitel_sdk_package/src/builder/send_message_request_builder.dart';
import 'package:webitel_sdk_package/src/data/gateway/grpc_gateway.dart';
import 'package:webitel_sdk_package/src/data/gateway/shared_preferences_gateway.dart';
import 'package:webitel_sdk_package/src/domain/entities/connect_status.dart';
import 'package:webitel_sdk_package/src/domain/entities/dialog_message.dart';
import 'package:webitel_sdk_package/src/domain/services/grpc_chat/grpc_chat_service.dart';
import 'package:webitel_sdk_package/src/generated/chat/messages/history.pb.dart';
import 'package:webitel_sdk_package/src/generated/chat/messages/message.pb.dart';
import 'package:webitel_sdk_package/src/generated/chat/messages/peer.pb.dart';
import 'package:webitel_sdk_package/src/generated/google/protobuf/any.pb.dart';
import 'package:webitel_sdk_package/src/generated/portal/connect.pb.dart'
    as portal;
import 'package:webitel_sdk_package/src/generated/portal/messages.pb.dart';

class GrpcChatServiceImpl implements GrpcChatService {
  final GrpcGateway _grpcGateway;
  final SharedPreferencesGateway _sharedPreferencesGateway;

  late final StreamController<portal.Request> _requestStreamController;
  late final StreamController<portal.Response> _responseStreamController;
  late final StreamController<UpdateNewMessage> _updateStreamController;
  late final StreamController<DialogMessageEntity> _userMessagesController;
  late final StreamController<ConnectStreamStatus> _connectController;

  final uuid = Uuid();
  bool? connectClosed;

  GrpcChatServiceImpl(
    this._sharedPreferencesGateway,
    this._grpcGateway,
  ) {
    _requestStreamController = StreamController<portal.Request>.broadcast();
    _responseStreamController = StreamController<portal.Response>.broadcast();
    _updateStreamController = StreamController<UpdateNewMessage>.broadcast();
    _userMessagesController = StreamController<DialogMessageEntity>.broadcast();
    _connectController = StreamController<ConnectStreamStatus>.broadcast();
  }

  @override
  Future<Stream<ConnectStreamStatus>> listenConnectStatus() async {
    return _connectController.stream;
  }

  @override
  Future<void> connectToGrpcChannel() async {
    _grpcGateway.stub.connect(_requestStreamController.stream).listen(
      (update) {
        connectClosed = false;
        _connectController
            .add(ConnectStreamStatus(status: ConnectStatus.opened));
        final canUnpackIntoResponse =
            update.data.canUnpackInto(portal.Response());
        final canUnpackIntoUpdateNewMessage =
            update.data.canUnpackInto(UpdateNewMessage());
        if (canUnpackIntoResponse == true) {
          final decodedResponse = update.data.unpackInto(portal.Response());
          _responseStreamController.add(decodedResponse);
        } else if (canUnpackIntoUpdateNewMessage == true) {
          final decodedResponse = update.data.unpackInto(UpdateNewMessage());
          _updateStreamController.add(decodedResponse);
        }
      },
      onError: (error) {
        _connectController.add(
          ConnectStreamStatus(
            status: ConnectStatus.closed,
            errorMessage: error.toString(),
          ),
        );
        connectClosed = true;
      },
      onDone: () {
        _connectController.add(
          ConnectStreamStatus(
            status: ConnectStatus.closed,
            errorMessage: 'Stream was closed',
          ),
        );
        connectClosed = true;
      },
      cancelOnError: true,
    );
  }

  @override
  Future<Stream<DialogMessageEntity>> listenToMessages() async {
    await _sharedPreferencesGateway.init();
    final userId = await _sharedPreferencesGateway.readUserId();
    _updateStreamController.stream.listen((update) {
      if (update.message.from.type == 'Error') {
        final errorMessage =
            ErrorMessageBuilder().setErrorMessage(update.message.text).build();
        _userMessagesController.add(
          errorMessage,
        );
      } else {
        final dialogMessage = DialogMessageBuilder()
            .setDialogMessageContent(update.message.text)
            .setRequestId(update.id)
            .setUserId(userId ?? '')
            .setUpdate(update)
            .build();
        _userMessagesController.add(dialogMessage);
      }
    });
    return _userMessagesController.stream;
  }

  @override
  Future<void> sendDialogMessage({required DialogMessageEntity message}) async {
    final completer = Completer<void>();
    final maxRetries = 5;
    var attempt = 0;

    while (!completer.isCompleted && attempt < maxRetries) {
      try {
        final newMessageRequest = SendMessageRequestBuilder()
            .setText(message.dialogMessageContent)
            .setPeer(Peer(
              id: message.peer.id,
              type: message.peer.type,
              name: message.peer.name,
            ))
            .build();

        final request = PortalRequestBuilder()
            .setPath('/webitel.portal.ChatMessages/SendMessage')
            .setData(Any.pack(newMessageRequest))
            .setId(message.requestId)
            .build();

        if (connectClosed == true) {
          await connectToGrpcChannel();
        }
        _requestStreamController.add(request);
        _responseStreamController.stream.listen((response) {
          if (response.id == message.requestId) {
            final canUnpackIntoUpdateNewMessage =
                response.data.canUnpackInto(UpdateNewMessage());
            if (canUnpackIntoUpdateNewMessage == true) {
              if (!completer.isCompleted) {
                completer.complete();
              }
            }
          }
        });
        await completer.future.timeout(Duration(seconds: 2));
        if (completer.isCompleted) {
          attempt = 0;
        }
      } catch (error) {
        print(error);
      }
      attempt++;
      if (attempt == maxRetries) {
        _updateStreamController.add(
          UpdateNewMessage(
            id: message.requestId,
            message: Message(
              text: 'Failed to send message',
              from: Peer(type: 'Error'),
            ),
          ),
        );
      }
    }
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
        if (connectClosed == true) {
          await connectToGrpcChannel();
        }
        _requestStreamController.add(request);

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
                    requestId: '',
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
        if (connectClosed == true) {
          await connectToGrpcChannel();
        }
        _requestStreamController.add(request);

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
                    requestId: '',
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
    _requestStreamController.close();
    _responseStreamController.close();
    _updateStreamController.close();
    _userMessagesController.close();
  }
}

// _userMessagesController.add(
//   DialogMessageEntity(
//     dialogMessageContent: update.message.text,
//     type: update.message.from.id == userId
//         ? MessageType.user
//         : MessageType.operator,
//     requestId: update.id,
//     peer: PeerInfo(
//       id: update.message.from.id,
//       name: update.message.from.name,
//       type: update.message.from.type,
//     ),
//   ),
// );

// @override
// Future<void> sendDialogMessage({required DialogMessageEntity message}) async {
//   final completer = Completer<void>();
//   void handleResponse(portal.Response response) {
//     if (response.id == message.requestId) {
//       final canUnpackIntoUpdateNewMessage =
//           response.data.canUnpackInto(UpdateNewMessage());
//       if (canUnpackIntoUpdateNewMessage) {
//         completer.complete();
//       }
//     }
//   }
//
//   void handleError(Object error) {
//     if (error is GrpcError) {
//       _updateStreamController.add(
//         UpdateNewMessage(
//           id: message.requestId,
//           message: Message(
//             text: error.toString(),
//             from: Peer(type: 'Error'),
//           ),
//         ),
//       );
//       completer.complete();
//     }
//   }
//
//   _responseStreamController.stream
//       .where((response) => response.id == message.requestId)
//       .listen(handleResponse, onError: handleError)
//       .onDone(() {
//     if (!completer.isCompleted) {
//       _updateStreamController.add(
//         UpdateNewMessage(
//           id: message.requestId,
//           message: Message(
//             from: Peer(type: 'Error'),
//             text: 'Unknown error',
//           ),
//         ),
//       );
//       completer.complete();
//     }
//   });
//
//   final maxRetries = 5;
//   var attempt = 0;
//   while (!completer.isCompleted && attempt < maxRetries) {
//     try {
//       final newMessageRequest = SendMessageRequest(
//         text: message.dialogMessageContent,
//         peer: Peer(
//           id: message.peer.id,
//           type: message.peer.type,
//           name: message.peer.name,
//         ),
//       );
//       final request = portal.Request(
//         path: '/webitel.portal.ChatMessages/SendMessage',
//         data: Any.pack(newMessageRequest),
//         id: message.requestId,
//       );
//       if (connectClosed == true) {
//         await connectToGrpcChannel();
//       }
//       _requestStreamController.add(request);
//       await completer.future.timeout(Duration(seconds: 2));
//     } catch (error) {
//       print(error);
//     }
//     attempt++;
//   }
//   return completer.future;
// }

// @override
// Future<DialogMessageEntity> sendDialogMessage(
//     {required DialogMessageEntity message}) async {
//   final userId = await _sharedPreferencesGateway.getFromDisk('userId');
//   final completer = Completer<DialogMessageEntity>();
//
//   void handleResponse(portal.Response response) {
//     if (response.id == message.requestId) {
//       final canUnpackIntoUpdateNewMessage =
//           response.data.canUnpackInto(UpdateNewMessage());
//       if (canUnpackIntoUpdateNewMessage) {
//         final unpackedMessage = response.data.unpackInto(UpdateNewMessage());
//
//         completer.complete(
//           DialogMessageEntity(
//             dialogMessageContent: unpackedMessage.message.text,
//             type: unpackedMessage.message.from.id == userId
//                 ? MessageType.user
//                 : MessageType.operator,
//             requestId: unpackedMessage.id,
//             peer: PeerInfo(
//               id: unpackedMessage.message.from.id,
//               name: unpackedMessage.message.from.name,
//               type: unpackedMessage.message.from.type,
//             ),
//           ),
//         );
//       }
//     }
//   }
//
//   void handleError(Object error) {
//     if (error is GrpcError) {
//       completer.complete(
//         DialogMessageEntity(
//           type: MessageType.error,
//           dialogMessageContent: error.toString(),
//           requestId: '',
//           peer: PeerInfo(
//             name: 'ERROR',
//             type: 'Unknown',
//             id: '',
//           ),
//         ),
//       );
//     }
//   }
//
//   _responseStreamController.stream
//       .where((response) => response.id == message.requestId)
//       .listen(handleResponse, onError: handleError)
//       .onDone(() {
//     if (!completer.isCompleted) {
//       completer.complete(
//         DialogMessageEntity(
//           type: MessageType.error,
//           dialogMessageContent: 'Unknown Error',
//           requestId: '',
//           peer: PeerInfo(
//             name: 'ERROR',
//             type: 'Unknown',
//             id: '',
//           ),
//         ),
//       );
//     }
//   });
//
//   final maxRetries = 5;
//   var attempt = 0;
//
//   while (!completer.isCompleted && attempt < maxRetries) {
//     try {
//       final newMessageRequest = SendMessageRequest(
//         text: message.dialogMessageContent,
//         peer: Peer(
//           id: message.peer.id,
//           type: message.peer.type,
//           name: message.peer.name,
//         ),
//       );
//       final request = portal.Request(
//         path: '/webitel.portal.ChatMessages/SendMessage',
//         data: Any.pack(newMessageRequest),
//         id: message.requestId,
//       );
//
//       if (connectClosed == true) {
//         await connectToGrpcChannel();
//       }
//
//       _requestStreamController.add(request);
//       await completer.future.timeout(Duration(seconds: 2));
//     } catch (error) {
//       print(error);
//     }
//     attempt++;
//   }
//
//   return completer.future;
// }
