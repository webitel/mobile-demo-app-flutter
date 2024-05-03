import 'dart:async';

import 'package:grpc/grpc.dart';
import 'package:grpc/grpc_or_grpcweb.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'package:webitel_portal_sdk/src/backbone/logger.dart';
import 'package:webitel_portal_sdk/src/backbone/message_helper.dart';
import 'package:webitel_portal_sdk/src/builder/error_dialog_message_builder.dart';
import 'package:webitel_portal_sdk/src/builder/messages_list_message_builder.dart';
import 'package:webitel_portal_sdk/src/builder/response_dialog_message_builder.dart';
import 'package:webitel_portal_sdk/src/data/gateway/connect_listener_gateway.dart';
import 'package:webitel_portal_sdk/src/data/gateway/grpc_gateway.dart';
import 'package:webitel_portal_sdk/src/data/gateway/shared_preferences_gateway.dart';
import 'package:webitel_portal_sdk/src/domain/entities/dialog_message/dialog_message_request.dart';
import 'package:webitel_portal_sdk/src/domain/entities/dialog_message/dialog_message_response.dart';
import 'package:webitel_portal_sdk/src/domain/entities/media_file/media_file_response.dart';
import 'package:webitel_portal_sdk/src/domain/entities/message_type.dart';
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
    logger.i("Chat service initialized with broadcast stream controller.");
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
  Future<StreamController<DialogMessageResponseEntity>>
      listenToMessages() async {
    await _sharedPreferencesGateway.init();
    final userId = await _sharedPreferencesGateway.readUserId();
    _connectListenerGateway.updateStream.listen((update) async {
      final messageType = MessageHelper.determineMessageTypeResponse(update);
      logger.i("Received message update of type: $messageType");
      switch (messageType) {
        case MessageType.outcomingMedia:
          logger.i(
              "Processing ${messageType.toString()} message: ${update.message.text}");
          final dialogMessage = ResponseDialogMessageBuilder()
              .setDialogMessageContent(update.message.text)
              .setId(update.id)
              .setRequestId(update.id)
              .setMessageId(update.id)
              .setUserUd(userId ?? '')
              .setId(update.id)
              .setChatId(update.message.chat.id)
              .setUpdate(update)
              .setFile(
                MediaFileResponseEntity(
                  id: update.message.file.id,
                  type: update.message.file.type,
                  name: update.message.file.name,
                  bytes: [],
                  size: update.message.file.size.toInt(),
                ),
              )
              .build();
          print(dialogMessage.file.name);
          _userMessagesController.add(dialogMessage);
        case MessageType.outcomingMessage:
          logger.i(
              "Processing ${messageType.toString()} message: ${update.message.text}");
          final dialogMessage = ResponseDialogMessageBuilder()
              .setDialogMessageContent(update.message.text)
              .setId(update.id)
              .setRequestId(update.id)
              .setMessageId(update.id)
              .setUserUd(userId ?? '')
              .setId(update.id)
              .setChatId(update.message.chat.id)
              .setUpdate(update)
              .setFile(
                MediaFileResponseEntity(
                  id: update.message.file.id,
                  type: update.message.file.type,
                  name: update.message.file.name,
                  bytes: [],
                  size: update.message.file.size.toInt(),
                ),
              )
              .build();
          _userMessagesController.add(dialogMessage);
        case MessageType.incomingMedia:
          logger.i(
              "Processing ${messageType.toString()} message: ${update.message.text}");
          final media = _grpcGateway.mediaStorageStub
              .getFile(GetFileRequest(fileId: update.message.file.id));

          MediaFileResponseEntity? file;

          await for (MediaFile mediaFile in media) {
            file = MediaFileResponseEntity(
              size: mediaFile.file.size.toInt(),
              bytes: mediaFile.data,
              name: mediaFile.file.name,
              type: mediaFile.file.type,
              id: mediaFile.file.id,
            );
          }
          final dialogMessage = ResponseDialogMessageBuilder()
              .setDialogMessageContent(update.message.text)
              .setId(update.id)
              .setRequestId(update.id)
              .setMessageId(update.id)
              .setUserUd(userId ?? '')
              .setId(update.id)
              .setChatId(update.message.chat.id)
              .setUpdate(update)
              .setFile(
                MediaFileResponseEntity(
                  id: file != null ? file.id : '',
                  type: file != null ? file.type : '',
                  name: file != null ? file.name : '',
                  bytes: file != null ? file.bytes : [],
                  size: file != null ? file.size.toInt() : 0,
                ),
              )
              .build();
          _userMessagesController.add(dialogMessage);
        case MessageType.incomingMessage:
          logger.i(
              "Processing ${messageType.toString()} message: ${update.message.text}");

          final dialogMessage = ResponseDialogMessageBuilder()
              .setDialogMessageContent(update.message.text)
              .setId(update.id)
              .setRequestId(update.id)
              .setMessageId(update.id)
              .setUserUd(userId ?? '')
              .setId(update.id)
              .setChatId(update.message.chat.id)
              .setUpdate(update)
              .setFile(
                MediaFileResponseEntity(
                  id: '',
                  type: '',
                  name: '',
                  bytes: [],
                  size: 0,
                ),
              )
              .build();
          _userMessagesController.add(dialogMessage);
      }
    }, onError: (error) {
      logger.e("Error while listening to messages: $error");
    }, onDone: () {
      logger.e("Error while listening to messages: stream is done");
    });
    return _userMessagesController;
  }

  @override
  Future<DialogMessageResponseEntity> sendMessage(
      {required DialogMessageRequestEntity message}) async {
    try {
      final userId = await _sharedPreferencesGateway.readUserId();
      final messageType = MessageHelper.determineMessageTypeRequest(message);
      logger.i("Sending message of type $messageType for user $userId");
      final request = await _buildRequest(message, userId ?? '', messageType);

      _connectListenerGateway.sendRequest(request);
      return await _listenForResponse(message.requestId, userId ?? '')
          .timeout(const Duration(seconds: 5));
    } on GrpcError catch (err) {
      logger.e("GRPC Error on sendMessage: ${err.toString()}");
      return ErrorDialogMessageBuilder()
          .setDialogMessageContent(err.toString())
          .setRequestId(message.requestId)
          .build();
    } on TimeoutException {
      logger.e("Timeout exception on sendMessage");
      return ErrorDialogMessageBuilder()
          .setDialogMessageContent('Message was not sent due to timeout')
          .setRequestId(message.requestId)
          .build();
    }
  }

  Future<DialogMessageResponseEntity> _listenForResponse(
      String requestId, String userId) {
    final completer = Completer<DialogMessageResponseEntity>();
    StreamSubscription<portal.Response>? streamSubscription;
    streamSubscription = _connectListenerGateway.responseStream
        .where((response) => response.id == requestId)
        .listen((response) => _handleResponse(response, completer, userId),
            onError: (error) => _handleError(error, completer, requestId),
            onDone: () => streamSubscription?.cancel(),
            cancelOnError: true);
    return completer.future;
  }

  Future<void> _handleResponse(portal.Response response,
      Completer<DialogMessageResponseEntity> completer, String userId) async {
    if (response.data.canUnpackInto(UpdateNewMessage())) {
      final unpackedMessage = response.data.unpackInto(UpdateNewMessage());
      final messageType =
          MessageHelper.determineMessageTypeResponse(unpackedMessage);

      switch (messageType) {
        case MessageType.outcomingMessage:
          logger.i("Handled response for message type $messageType");
          final dialogMessage = ResponseDialogMessageBuilder()
              .setDialogMessageContent(unpackedMessage.message.text)
              .setRequestId(unpackedMessage.id)
              .setId(unpackedMessage.id)
              .setUserUd(userId)
              .setMessageId(unpackedMessage.id)
              .setChatId(unpackedMessage.message.chat.id)
              .setUpdate(unpackedMessage)
              .build();
          completer.complete(dialogMessage);
          break;
        case MessageType.outcomingMedia:
          logger.i("Handled response for message type $messageType");

          final dialogMessage = ResponseDialogMessageBuilder()
              .setDialogMessageContent(unpackedMessage.message.text)
              .setId(unpackedMessage.id)
              .setRequestId(unpackedMessage.id)
              .setMessageId(unpackedMessage.id)
              .setUserUd(userId)
              .setId(unpackedMessage.id)
              .setChatId(unpackedMessage.message.chat.id)
              .setUpdate(unpackedMessage)
              .setFile(
                MediaFileResponseEntity(
                  id: unpackedMessage.message.file.id,
                  type: unpackedMessage.message.file.type,
                  name: unpackedMessage.message.file.name,
                  bytes: [],
                  size: unpackedMessage.message.file.size.toInt(),
                ),
              )
              .build();
          completer.complete(dialogMessage);
          break;
        default:
          break;
      }
    } else if (response.err.hasMessage()) {
      completer.complete(ErrorDialogMessageBuilder()
          .setDialogMessageContent(response.err.message)
          .setRequestId(response.id)
          .build());
    }
  }

  void _handleError(Object error,
      Completer<DialogMessageResponseEntity> completer, String requestId) {
    final errorMessage =
        error is GrpcError ? error.toString() : 'Unknown error occurred';
    logger.e("Error on handling message response: $errorMessage");
    completer.complete(ErrorDialogMessageBuilder()
        .setDialogMessageContent(errorMessage)
        .setRequestId(requestId)
        .build());
  }

  Future<portal.Request> _buildRequest(DialogMessageRequestEntity message,
      String userId, MessageType messageType) async {
    logger.i("Building request for message type $messageType");
    final peer = Peer(
        id: message.peer.id, type: message.peer.type, name: message.peer.name);
    final baseRequest =
        SendMessageRequest(text: message.dialogMessageContent, peer: peer);

    if (messageType == MessageType.outcomingMedia) {
      logger.i("Uploading media for message.");
      final uploadedFile = await _grpcGateway.mediaStorageStub.uploadFile(
        stream(
          data: message.file.data,
          name: message.file.name,
          type: message.file.type,
        ),
      );
      baseRequest.file = file.File(
        id: uploadedFile.id,
        name: uploadedFile.name,
        type: uploadedFile.type,
      );
    }

    return portal.Request(
      path: '/webitel.portal.ChatMessages/SendMessage',
      data: Any.pack(baseRequest),
      id: message.requestId,
    );
  }

  @override
  Future<List<DialogMessageResponseEntity>> fetchMessages(
      {int? limit, String? offset}) async {
    final chatId = await _sharedPreferencesGateway.getFromDisk('chatId');
    final userId = await _sharedPreferencesGateway.readUserId();
    final requestId = uuid.v4();
    logger
        .i('Fetching messages for chatId: $chatId with limit: ${limit ?? 20}');

    final fetchMessagesRequest =
        ChatMessagesRequest(chatId: chatId, limit: limit ?? 20);
    final request = portal.Request(
      path: '/webitel.portal.ChatMessages/ChatHistory',
      data: Any.pack(fetchMessagesRequest),
      id: requestId,
    );

    try {
      await _connectListenerGateway.sendRequest(request);
      final response = await _connectListenerGateway.responseStream
          .firstWhere((response) => response.id == requestId)
          .timeout(const Duration(seconds: 5));

      if (response.data.canUnpackInto(ChatMessages())) {
        final unpackedDialogMessages = response.data.unpackInto(ChatMessages());
        final messagesBuilder = MessagesListMessageBuilder()
            .setChatId(chatId ?? '')
            .setUserId(userId ?? '')
            .setMessages(unpackedDialogMessages.messages)
            .setPeers(unpackedDialogMessages.peers);

        final messages = messagesBuilder.build();
        logger.i(
            'Successfully fetched ${messages.length} messages for chatId: $chatId');
        return messages;
      } else {
        logger.e('Failed to unpack dialog messages for requestId: $requestId');
        return [];
      }
    } catch (e, stackTrace) {
      if (e is TimeoutException) {
        logger.e('Timeout while fetching messages for chatId: $chatId',
            error: e, stackTrace: stackTrace);
      } else {
        logger.e(
            'An error occurred while fetching messages for chatId: $chatId',
            error: e,
            stackTrace: stackTrace);
      }
      return [];
    }
  }

  @override
  Future<List<DialogMessageResponseEntity>> fetchUpdates(
      {int? limit, String? offset}) async {
    final chatId = await _sharedPreferencesGateway.getFromDisk('chatId');
    final userId = await _sharedPreferencesGateway.readUserId();
    final requestId = uuid.v4();
    logger.i(
        'Fetching message updates for chatId: $chatId with limit: ${limit ?? 20}');

    final fetchMessageUpdatesRequest =
        ChatMessagesRequest(chatId: chatId, limit: limit ?? 20);
    final request = portal.Request(
      path: '/webitel.portal.ChatMessages/ChatUpdates',
      data: Any.pack(fetchMessageUpdatesRequest),
      id: requestId,
    );

    try {
      _connectListenerGateway.sendRequest(request);
      final response = await _connectListenerGateway.responseStream
          .firstWhere((response) => response.id == requestId)
          .timeout(const Duration(seconds: 5));

      if (response.data.canUnpackInto(ChatMessages())) {
        final unpackedDialogMessages = response.data.unpackInto(ChatMessages());
        final messagesBuilder = MessagesListMessageBuilder()
            .setChatId(chatId ?? '')
            .setUserId(userId ?? '')
            .setMessages(unpackedDialogMessages.messages)
            .setPeers(unpackedDialogMessages.peers);

        final messages = messagesBuilder.build();
        logger.i(
            'Successfully fetched ${messages.length} message updates for chatId: $chatId');
        return messages;
      } else {
        logger.e('Failed to unpack dialog messages for requestId: $requestId');
        return [];
      }
    } catch (e, stackTrace) {
      if (e is TimeoutException) {
        logger.e('Timeout while fetching message updates for chatId: $chatId',
            error: e, stackTrace: stackTrace);
      } else {
        logger.e(
            'An error occurred while fetching message updates for chatId: $chatId',
            error: e,
            stackTrace: stackTrace);
      }
      return [];
    }
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
