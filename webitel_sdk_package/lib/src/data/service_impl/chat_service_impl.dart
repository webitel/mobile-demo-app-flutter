import 'dart:async';

import 'package:grpc/grpc.dart';
import 'package:grpc/grpc_or_grpcweb.dart';
import 'package:uuid/uuid.dart';
import 'package:webitel_sdk_package/src/backbone/builder/dialog_message_builder.dart';
import 'package:webitel_sdk_package/src/data/gateway/connect_listener_gateway.dart';
import 'package:webitel_sdk_package/src/data/gateway/shared_preferences_gateway.dart';
import 'package:webitel_sdk_package/src/domain/entities/dialog_message.dart';
import 'package:webitel_sdk_package/src/domain/services/chat/grpc_chat_service.dart';
import 'package:webitel_sdk_package/src/generated/chat/messages/history.pb.dart';
import 'package:webitel_sdk_package/src/generated/chat/messages/peer.pb.dart';
import 'package:webitel_sdk_package/src/generated/google/protobuf/any.pb.dart';
import 'package:webitel_sdk_package/src/generated/portal/connect.pb.dart'
    as portal;
import 'package:webitel_sdk_package/src/generated/portal/messages.pb.dart';

class ChatServiceImpl implements ChatService {
  final ConnectListenerGateway _connectListenerGateway;
  final SharedPreferencesGateway _sharedPreferencesGateway;

  late final StreamController<DialogMessageEntity> _userMessagesController;
  final uuid = Uuid();

  ChatServiceImpl(
    this._connectListenerGateway,
    this._sharedPreferencesGateway,
  ) {
    _userMessagesController = StreamController<DialogMessageEntity>.broadcast();
  }

  @override
  Future<StreamController<DialogMessageEntity>> listenToMessages() async {
    await _sharedPreferencesGateway.init();
    final userId = await _sharedPreferencesGateway.readUserId();

    _connectListenerGateway.updateStream.listen((update) {
      final dialogMessage = DialogMessageBuilder()
          .setDialogMessageContent(update.message.text)
          .setRequestId(update.id)
          .setMessageId(update.id)
          .setUserId(userId ?? '')
          .setChatId(update.message.chat.id)
          .setUpdate(update)
          .build();
      _userMessagesController.add(dialogMessage);
    });
    return _userMessagesController;
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
            chatId: unpackedMessage.message.chat.id,
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
            requestId: message.requestId,
            chatId: '',
            peer: PeerInfo(
              name: 'ERROR',
              type: 'Unknown',
              id: '',
            ),
          ),
        );

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
            requestId: message.requestId,
            chatId: '',
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
            requestId: message.requestId,
            chatId: '',
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
  Future<List<DialogMessageEntity>> fetchMessages(
      {int? limit, String? offset}) async {
    final chatId = await _sharedPreferencesGateway.getFromDisk('chatId');
    final id = uuid.v4();
    final fetchMessagesRequest =
        ChatMessagesRequest(chatId: chatId, limit: limit ?? 20);
    final request = portal.Request(
      path: '/webitel.portal.ChatMessages/ChatHistory',
      data: Any.pack(fetchMessagesRequest),
      id: id,
    );

    _connectListenerGateway.sendRequest(request);

    try {
      final response = await _connectListenerGateway.responseStream
          .firstWhere((response) => response.id == id);

      final canUnpackIntoDialogMessages =
          response.data.canUnpackInto(ChatMessages());
      if (canUnpackIntoDialogMessages == true) {
        final unpackedDialogMessages = response.data.unpackInto(ChatMessages());

        final messages = unpackedDialogMessages.messages
            .map((unpackedMessage) => DialogMessageEntity(
                  requestId: '',
                  chatId: chatId ?? '',
                  type: unpackedMessage.from.id == '1' //TODO
                      ? MessageType.operator
                      : MessageType.user,
                  dialogMessageContent: unpackedMessage.text,
                  peer: PeerInfo(
                    name: '',
                    type: '',
                    id: '',
                  ),
                ))
            .toList();

        return messages;
      }
    } catch (error) {
      print(error);
    }

    return [];
  }

  @override
  Future<List<DialogMessageEntity>> fetchMessageUpdates(
      {int? limit, String? offset}) async {
    final chatId = await _sharedPreferencesGateway.getFromDisk('chatId');
    final id = uuid.v4();
    final fetchMessageUpdatesRequest =
        ChatMessagesRequest(chatId: chatId, limit: limit ?? 20);
    final request = portal.Request(
      path: '/webitel.portal.ChatMessages/ChatUpdates',
      data: Any.pack(fetchMessageUpdatesRequest),
      id: id,
    );

    _connectListenerGateway.sendRequest(request);

    try {
      final response = await _connectListenerGateway.responseStream
          .firstWhere((response) => response.id == id);

      final canUnpackIntoDialogMessages =
          response.data.canUnpackInto(ChatMessages());
      if (canUnpackIntoDialogMessages == true) {
        final unpackedDialogMessages = response.data.unpackInto(ChatMessages());

        final messages = unpackedDialogMessages.messages
            .map((unpackedMessage) => DialogMessageEntity(
                  requestId: '',
                  chatId: '',
                  dialogMessageContent: unpackedMessage.text,
                  peer: PeerInfo(
                    name: unpackedMessage.chat.peer.name,
                    type: unpackedMessage.chat.peer.type,
                    id: unpackedMessage.chat.peer.id,
                  ),
                ))
            .toList();

        return messages;
      }
    } catch (error) {
      print(error);
    }

    return [];
  }

  void dispose() {
    _userMessagesController.close();
  }
}
