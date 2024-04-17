import 'dart:async';

import 'package:grpc/grpc.dart';
import 'package:grpc/grpc_or_grpcweb.dart';
import 'package:uuid/uuid.dart';
import 'package:webitel_sdk_package/src/backbone/builder/dialog_message_builder.dart';
import 'package:webitel_sdk_package/src/data/gateway/connect_listener_gateway.dart';
import 'package:webitel_sdk_package/src/data/gateway/shared_preferences_gateway.dart';
import 'package:webitel_sdk_package/src/domain/entities/connect_status.dart';
import 'package:webitel_sdk_package/src/domain/entities/dialog_message.dart';
import 'package:webitel_sdk_package/src/domain/services/grpc_chat/grpc_chat_service.dart';
import 'package:webitel_sdk_package/src/generated/chat/messages/history.pb.dart';
import 'package:webitel_sdk_package/src/generated/chat/messages/peer.pb.dart';
import 'package:webitel_sdk_package/src/generated/google/protobuf/any.pb.dart';
import 'package:webitel_sdk_package/src/generated/portal/connect.pb.dart'
    as portal;
import 'package:webitel_sdk_package/src/generated/portal/messages.pb.dart';

class GrpcChatServiceImpl implements GrpcChatService {
  final ConnectListenerGateway _connectListenerGateway;
  final SharedPreferencesGateway _sharedPreferencesGateway;

  late final StreamController<DialogMessageEntity> _userMessagesController;
  final uuid = Uuid();

  GrpcChatServiceImpl(
    this._connectListenerGateway,
    this._sharedPreferencesGateway,
  ) {
    _userMessagesController = StreamController<DialogMessageEntity>.broadcast();
  }

  @override
  Future<Stream<ConnectStreamStatus>> listenConnectStatus() async {
    return _connectListenerGateway.connectStatusStream;
  }

  @override
  Future<Stream<DialogMessageEntity>> listenToMessages() async {
    await _sharedPreferencesGateway.init();
    final userId = await _sharedPreferencesGateway.readUserId();

    _connectListenerGateway.updateStream.listen((update) {
      final dialogMessage = DialogMessageBuilder()
          .setDialogMessageContent(update.message.text)
          .setRequestId(update.id)
          .setUserId(userId ?? '')
          .setUpdate(update)
          .build();
      _userMessagesController.add(dialogMessage);
    });
    return _userMessagesController.stream;
  }

  @override
  Future<DialogMessageEntity> sendDialogMessage(
      {required DialogMessageEntity message}) async {
    final userId = await _sharedPreferencesGateway.getFromDisk('userId');
    final completer = Completer<DialogMessageEntity>();

    StreamSubscription? subscription;
    subscription = _connectListenerGateway.responseStream
        .where((response) => response.id == message.requestId)
        .listen((portal.Response response) {
      if (response.data.canUnpackInto(UpdateNewMessage())) {
        final unpackedMessage = response.data.unpackInto(UpdateNewMessage());
        completer.complete(
          DialogMessageEntity(
            dialogMessageContent: unpackedMessage.message.text,
            type: unpackedMessage.message.from.id == userId
                ? MessageType.user
                : MessageType.operator,
            requestId: unpackedMessage.id,
            peer: PeerInfo(
              id: unpackedMessage.message.from.id,
              name: unpackedMessage.message.from.name,
              type: unpackedMessage.message.from.type,
            ),
          ),
        );

        subscription?.cancel();
      }
    }, onError: (Object error) {
      if (error is GrpcError) {
        completer.complete(
          DialogMessageEntity(
            type: MessageType.error,
            dialogMessageContent: error.toString(),
            requestId: '',
            peer: PeerInfo(
              name: 'ERROR',
              type: 'Unknown',
              id: '',
            ),
          ),
        );
        // Cancel subscription on error too
        subscription?.cancel();
      }
    });

    try {
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
        id: message.requestId,
      );

      _connectListenerGateway.sendRequest(request);
    } catch (error) {
      if (error is GrpcError) {
        completer.complete(
          DialogMessageEntity(
            type: MessageType.error,
            dialogMessageContent: error.toString(),
            requestId: '',
            peer: PeerInfo(
              name: 'ERROR',
              type: 'Unknown',
              id: '',
            ),
          ),
        );
      }
    }

    return completer.future.timeout(Duration(seconds: 5), onTimeout: () {
      if (!completer.isCompleted) {
        completer.complete(
          DialogMessageEntity(
            type: MessageType.error,
            dialogMessageContent: 'Unknown error',
            requestId: '',
            peer: PeerInfo(
              name: 'ERROR',
              type: 'Unknown',
              id: '',
            ),
          ),
        );
      }
      return completer.future;
    });
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

        _connectListenerGateway.sendRequest(request);
        StreamSubscription<portal.Response>? subscription;
        subscription =
            _connectListenerGateway.responseStream.listen((response) {
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

        _connectListenerGateway.sendRequest(request);

        StreamSubscription<portal.Response>? subscription;
        subscription =
            _connectListenerGateway.responseStream.listen((response) {
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
    _userMessagesController.close();
  }
}
