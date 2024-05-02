import 'dart:async';

import 'package:grpc/grpc.dart';
import 'package:grpc/grpc_or_grpcweb.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'package:webitel_portal_sdk/src/backbone/logger.dart';
import 'package:webitel_portal_sdk/src/builder/error_dialog_message_builder.dart';
import 'package:webitel_portal_sdk/src/builder/messages_list_message_builder.dart';
import 'package:webitel_portal_sdk/src/builder/response_dialog_message_builder.dart';
import 'package:webitel_portal_sdk/src/data/gateway/connect_listener_gateway.dart';
import 'package:webitel_portal_sdk/src/data/gateway/grpc_gateway.dart';
import 'package:webitel_portal_sdk/src/data/gateway/shared_preferences_gateway.dart';
import 'package:webitel_portal_sdk/src/domain/entities/dialog_message/dialog_message_request.dart';
import 'package:webitel_portal_sdk/src/domain/entities/dialog_message/dialog_message_response.dart';
import 'package:webitel_portal_sdk/src/domain/entities/media_file/media_file_response.dart';
import 'package:webitel_portal_sdk/src/domain/services/chat_service.dart';
import 'package:webitel_portal_sdk/src/generated/chat/messages/history.pb.dart';
import 'package:webitel_portal_sdk/src/generated/chat/messages/message.pb.dart'
    as file;
import 'package:webitel_portal_sdk/src/generated/chat/messages/peer.pb.dart';
import 'package:webitel_portal_sdk/src/generated/google/protobuf/any.pb.dart';
import 'package:webitel_portal_sdk/src/generated/portal/connect.pb.dart'
    as portal;
import 'package:webitel_portal_sdk/src/generated/portal/media.pb.dart';
import 'package:webitel_portal_sdk/src/generated/portal/messages.pb.dart';

@LazySingleton(as: ChatService)
class ChatServiceImpl implements ChatService {
  final ConnectListenerGateway _connectListenerGateway;
  final SharedPreferencesGateway _sharedPreferencesGateway;
  final GrpcGateway _grpcGateway;

  late final StreamController<DialogMessageResponseEntity>
      _userMessagesController;
  final uuid = Uuid();
  Logger logger = CustomLogger.getLogger();

  ChatServiceImpl(
    this._grpcGateway,
    this._connectListenerGateway,
    this._sharedPreferencesGateway,
  ) {
    _userMessagesController =
        StreamController<DialogMessageResponseEntity>.broadcast();
  }

  @override
  Future<StreamController<DialogMessageResponseEntity>>
      listenToMessages() async {
    await _sharedPreferencesGateway.init();
    final userId = await _sharedPreferencesGateway.readUserId();
    _connectListenerGateway.updateStream.listen((update) {
      final dialogMessage = ResponseDialogMessageBuilder()
          .setDialogMessageContent(update.message.text)
          .setId(update.id)
          .setRequestId(update.id)
          .setMessageId(update.id)
          .setUserUd(userId ?? '')
          .setId(update.id)
          .setChatId(update.message.chat.id) //TODO
          .setUpdate(update)
          .setFile(
            MediaFileResponseEntity(
              id: update.message.file.id,
              type: update.message.file.type,
              name: update.message.file.name,
              bytes: [],
              //TODO WHEN RECEIVING IMAGE - IF FILE IS NOT EMPTY CALL TO getFile from Server
              size: update.message.file.size.toInt(),
            ),
          )
          .build();
      _userMessagesController.add(dialogMessage);
    });
    return _userMessagesController;
  }

  Stream<UploadMedia> stream({
    required Stream<List<int>> data,
    required String name,
    required String type,
  }) async* {
    yield UploadMedia(file: InputFile(name: name, type: type));

    await for (var bytes in data) {
      yield UploadMedia(data: bytes);
    }
  }

  @override
  Future<DialogMessageResponseEntity> sendMessage(
      {required DialogMessageRequestEntity message}) async {
    final completer = Completer<DialogMessageResponseEntity>();
    final userId = await _sharedPreferencesGateway.readUserId();
    StreamSubscription? subscription;
    subscription = _connectListenerGateway.responseStream
        .where((response) => response.id == message.requestId)
        .listen((portal.Response response) {
      if (response.data.canUnpackInto(UpdateNewMessage())) {
        final unpackedMessage = response.data.unpackInto(UpdateNewMessage());
        completer.complete(
          ResponseDialogMessageBuilder()
              .setDialogMessageContent(unpackedMessage.message.text)
              .setRequestId(unpackedMessage.id)
              .setId(unpackedMessage.id)
              .setUserUd(userId ?? '')
              .setMessageId(unpackedMessage.id)
              .setChatId(unpackedMessage.message.chat.id)
              .setUpdate(unpackedMessage)
              .setFile(
                MediaFileResponseEntity(
                  name: unpackedMessage.message.file.name,
                  type: unpackedMessage.message.file.type,
                  size: unpackedMessage.message.file.size.toInt(),
                  bytes: [],
                  // TODO
                  id: unpackedMessage.message.file.id,
                ),
              )
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
    }, onError: (Object err) {
      if (err is GrpcError) {
        completer.complete(
          ErrorDialogMessageBuilder()
              .setDialogMessageContent(err.toString())
              .setRequestId(message.requestId)
              .build(),
        );

        subscription?.cancel();
      }
    });

    try {
      if (message.file!.name.isNotEmpty || message.file!.type.isNotEmpty) {
        final uploadedFile = await _grpcGateway.mediaStorageStub.uploadFile(
          stream(
            data: message.file!.data,
            name: message.file!.name,
            type: message.file!.type,
          ),
        );
        final newMessageRequest = SendMessageRequest(
          text: message.dialogMessageContent,
          peer: Peer(
            id: message.peer.id,
            type: message.peer.type,
            name: message.peer.name,
          ),
          file: file.File(
            id: uploadedFile.id,
            name: uploadedFile.name,
            type: uploadedFile.type,
          ),
        );
        final request = portal.Request(
          path: '/webitel.portal.ChatMessages/SendMessage',
          data: Any.pack(newMessageRequest),
          id: message.requestId,
        );
        _connectListenerGateway.sendRequest(request);
      } else if (message.file!.name.isEmpty || message.file!.type.isEmpty) {
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
      }
    } catch (err) {
      if (err is GrpcError) {
        completer.complete(
          ErrorDialogMessageBuilder()
              .setDialogMessageContent(err.toString())
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
  Future<List<DialogMessageResponseEntity>> fetchMessages(
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
            .setChatId(chatId ?? '')
            .setUserId(userId ?? '')
            .setMessages(unpackedDialogMessages.messages)
            .setPeers(peers);

        final messages = messagesBuilder.build();
        return messages;
      }
    } catch (err, stackTrace) {
      logger.e(error: err, stackTrace: stackTrace, err);
    }

    return [];
  }

  @override
  Future<List<DialogMessageResponseEntity>> fetchUpdates(
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
            .setChatId(chatId ?? '')
            .setUserId(userId ?? '')
            .setMessages(unpackedDialogMessages.messages)
            .setPeers(peers);

        final messages = messagesBuilder.build();
        return messages;
      }
    } catch (err) {
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
