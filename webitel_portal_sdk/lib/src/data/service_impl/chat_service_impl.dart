import 'dart:async';

import 'package:grpc/grpc.dart';
import 'package:grpc/grpc_or_grpcweb.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'package:webitel_portal_sdk/src/backbone/logger.dart';
import 'package:webitel_portal_sdk/src/builder/dialog_message_builder.dart';
import 'package:webitel_portal_sdk/src/builder/error_dialog_message_builder.dart';
import 'package:webitel_portal_sdk/src/builder/messages_list_message_builder.dart';
import 'package:webitel_portal_sdk/src/data/gateway/connect_listener_gateway.dart';
import 'package:webitel_portal_sdk/src/data/gateway/shared_preferences_gateway.dart';
import 'package:webitel_portal_sdk/src/database/database.dart';
import 'package:webitel_portal_sdk/src/domain/entities/dialog_message.dart';
import 'package:webitel_portal_sdk/src/domain/entities/request/request_entity.dart';
import 'package:webitel_portal_sdk/src/domain/services/chat_service.dart';
import 'package:webitel_portal_sdk/src/generated/chat/messages/history.pb.dart';
import 'package:webitel_portal_sdk/src/generated/chat/messages/peer.pb.dart';
import 'package:webitel_portal_sdk/src/generated/google/protobuf/any.pb.dart';
import 'package:webitel_portal_sdk/src/generated/portal/connect.pb.dart'
    as portal;
import 'package:webitel_portal_sdk/src/generated/portal/messages.pb.dart';

@LazySingleton(as: ChatService)
class ChatServiceImpl implements ChatService {
  final ConnectListenerGateway _connectListenerGateway;
  final SharedPreferencesGateway _sharedPreferencesGateway;
  final DatabaseProvider _databaseProvider;

  late final StreamController<DialogMessageEntity> _userMessagesController;
  final uuid = Uuid();
  Logger logger = CustomLogger.getLogger();

  ChatServiceImpl(
    this._databaseProvider,
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
          .setChatId(update.message.chat.id) //TODO
          .setUpdate(update)
          .build();
      _userMessagesController.add(dialogMessage);
    });
    return _userMessagesController;
  }

  @override
  Future<DialogMessageEntity> sendMessage(
      {required DialogMessageEntity message}) async {
    final userId = await _sharedPreferencesGateway.getFromDisk('userId');
    final chatId = await _sharedPreferencesGateway.getFromDisk('chatId');
    final completer = Completer<DialogMessageEntity>();

    StreamSubscription? subscription;
    subscription = _connectListenerGateway.responseStream
        .where((response) => response.id == message.requestId)
        .listen((portal.Response response) {
      if (response.data.canUnpackInto(UpdateNewMessage())) {
        final unpackedMessage = response.data.unpackInto(UpdateNewMessage());
        completer.complete(
          DialogMessageBuilder()
              .setDialogMessageContent(unpackedMessage.message.text)
              .setRequestId(unpackedMessage.id)
              .setMessageId(unpackedMessage.id)
              .setUserId(userId ?? '')
              .setChatId(unpackedMessage.message.chat.id)
              .setUpdate(unpackedMessage)
              .build(),
        );
        subscription?.cancel();
      } else if (response.err.hasMessage()) {
        final error = response;
        completer.complete(
          ErrorDialogMessageBuilder()
              .setDialogMessageContent(error.err.message)
              .setRequestId(error.id)
              .build(),
        );
      }
    }, onError: (Object error) {
      if (error is GrpcError) {
        completer.complete(
          ErrorDialogMessageBuilder()
              .setDialogMessageContent(error.toString())
              .setRequestId(message.requestId)
              .build(),
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
      final requestDb = RequestEntity(
        chatId: chatId ?? '',
        id: message.requestId,
        text: message.dialogMessageContent,
        timestamp: DateTime.now(),
        path: '/webitel.portal.ChatMessages/SendMessage',
      );
      await _databaseProvider.insertRequest(request: requestDb);
      _connectListenerGateway.sendRequest(request);
    } catch (error) {
      if (error is GrpcError) {
        completer.complete(
          ErrorDialogMessageBuilder()
              .setDialogMessageContent(error.toString())
              .setRequestId(message.requestId)
              .build(),
        );
      }
    }

    return completer.future.timeout(Duration(seconds: 5), onTimeout: () {
      if (!completer.isCompleted) {
        completer.complete(
          ErrorDialogMessageBuilder()
              .setDialogMessageContent('Messages was not sent by timeout')
              .setRequestId(message.requestId)
              .build(),
        );
      }
      return completer.future;
    });
  }

  @override
  Future<List<DialogMessageEntity>> fetchMessages(
      {int? limit, String? offset}) async {
    final chatId = await _sharedPreferencesGateway.getFromDisk('chatId');
    final userId = await _sharedPreferencesGateway.readUserId();
    final id = uuid.v4();
    final fetchMessagesRequest =
        ChatMessagesRequest(chatId: chatId, limit: limit ?? 20);
    final request = portal.Request(
      path: '/webitel.portal.ChatMessages/ChatHistory',
      data: Any.pack(fetchMessagesRequest),
      id: id,
    );
    final requestDb = RequestEntity(
      chatId: chatId ?? '',
      id: id,
      text: '',
      timestamp: DateTime.now(),
      path: '/webitel.portal.ChatMessages/ChatHistory',
    );
    await _databaseProvider.insertRequest(request: requestDb);
    await _connectListenerGateway.sendRequest(request);

    try {
      final response = await _connectListenerGateway.responseStream
          .firstWhere((response) => response.id == id)
          .timeout(Duration(seconds: 5));

      final canUnpackIntoDialogMessages =
          response.data.canUnpackInto(ChatMessages());
      if (canUnpackIntoDialogMessages == true) {
        final unpackedDialogMessages = response.data.unpackInto(ChatMessages());
        final peers = unpackedDialogMessages.peers;
        final messagesBuilder = MessagesListMessageBuilder()
            .setRequestId('')
            .setChatId(chatId ?? '')
            .setUserId(userId ?? '')
            .setMessages(unpackedDialogMessages.messages)
            .setPeers(peers);

        final messages = messagesBuilder.build();
        return messages;
      }
    } catch (error, stackTrace) {
      logger.e(error: error, stackTrace: stackTrace, error);
    }

    return [];
  }

  @override
  Future<List<DialogMessageEntity>> fetchUpdates(
      {int? limit, String? offset}) async {
    final chatId = await _sharedPreferencesGateway.getFromDisk('chatId');
    final userId = await _sharedPreferencesGateway.readUserId();
    final id = uuid.v4();
    final fetchMessageUpdatesRequest =
        ChatMessagesRequest(chatId: chatId, limit: limit ?? 20);
    final request = portal.Request(
      path: '/webitel.portal.ChatMessages/ChatUpdates',
      data: Any.pack(fetchMessageUpdatesRequest),
      id: id,
    );
    final requestDb = RequestEntity(
      chatId: chatId ?? '',
      id: id,
      text: '',
      timestamp: DateTime.now(),
      path: '/webitel.portal.ChatMessages/ChatUpdates',
    );
    await _databaseProvider.insertRequest(request: requestDb);
    _connectListenerGateway.sendRequest(request);

    try {
      final response = await _connectListenerGateway.responseStream
          .firstWhere((response) => response.id == id)
          .timeout(Duration(seconds: 5));

      final canUnpackIntoDialogMessages =
          response.data.canUnpackInto(ChatMessages());
      if (canUnpackIntoDialogMessages == true) {
        final unpackedDialogMessages = response.data.unpackInto(ChatMessages());
        final peers = unpackedDialogMessages.peers;
        final messagesBuilder = MessagesListMessageBuilder()
            .setRequestId('')
            .setChatId(chatId ?? '')
            .setUserId(userId ?? '')
            .setMessages(unpackedDialogMessages.messages)
            .setPeers(peers);

        final messages = messagesBuilder.build();
        return messages;
      }
    } catch (error) {
      return [];
    }

    return [];
  }

  @override
  Future<void> enterChat({required String chatId}) async {
    await _sharedPreferencesGateway.saveChatId(chatId);
  }

  @override
  Future<void> exitChat() async {
    await _sharedPreferencesGateway.deleteChatId();
  }

  void dispose() {
    _userMessagesController.close();
  }
}
