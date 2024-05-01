import 'dart:async';
import 'dart:io';

import 'package:webitel_portal_sdk/webitel_portal_sdk.dart';
import 'package:webitel_sdk/data/gateway/file_picker_gateway.dart';
import 'package:webitel_sdk/database/database_provider.dart';
import 'package:webitel_sdk/domain/entity/dialog_message_entity.dart';
import 'package:webitel_sdk/domain/entity/response_entity.dart';
import 'package:webitel_sdk/domain/service/chat_service.dart';

class ChatServiceImpl implements ChatService {
  final DatabaseProvider _databaseProvider;
  final FilePickerGateway _filePickerGateway;
  late final StreamController<DialogMessageEntity> messagesStreamController;

  ChatServiceImpl(
    this._databaseProvider,
    this._filePickerGateway,
  );

  @override
  Future<File?> pickFile() async {
    File? media = await _filePickerGateway.pickFile();
    if (media != null) {
      return media;
    } else {
      return null;
    }
  }

  @override
  Future<ResponseEntity> sendDialogMessage({
    required DialogMessageEntity dialogMessageEntity,
  }) async {
    if (dialogMessageEntity.file != null) {
      final message =
          await WebitelPortalSdk.instance.messageHandler.sendMessage(
        dialogMessageContent: dialogMessageEntity.dialogMessageContent,
        requestId: dialogMessageEntity.requestId,
        peerType: dialogMessageEntity.peer.type,
        peerName: dialogMessageEntity.peer.name,
        peerId: dialogMessageEntity.peer.id,
        mediaType: dialogMessageEntity.file!.type,
        mediaName: dialogMessageEntity.file!.name,
        mediaData: dialogMessageEntity.file!.data,
      );
      return ResponseEntity(
        status: ResponseStatus.success,
        message: message.dialogMessageContent,
      );
    } else if (dialogMessageEntity.file == null) {
      final message =
          await WebitelPortalSdk.instance.messageHandler.sendMessage(
        dialogMessageContent: dialogMessageEntity.dialogMessageContent,
        requestId: dialogMessageEntity.requestId,
        peerType: dialogMessageEntity.peer.type,
        peerName: dialogMessageEntity.peer.name,
        peerId: dialogMessageEntity.peer.id,
      );
      return ResponseEntity(
        status: ResponseStatus.success,
        message: message.dialogMessageContent,
      );
    }
    return ResponseEntity(status: ResponseStatus.error, message: '');
  }

  @override
  Future<List<DialogMessageEntity>> fetchMessages() async {
    await WebitelPortalSdk.instance.chatListHandler.fetchDialogs();
    //Checking if messages from server is not empty, if empty - load last cached messages in database

    final messagesFromServer =
        await WebitelPortalSdk.instance.messageHandler.fetchMessages(limit: 20);
    if (messagesFromServer.isNotEmpty) {
      // if is not empty, clear last cached messages and write new ones

      await _databaseProvider.clear();
      await _databaseProvider.writeMessages();
      // fetch messages by chatId(for now have only one chat)

      final fetchedMessages =
          await _databaseProvider.fetchMessagesByChatId(chatId: '');
      return fetchedMessages;
    } else if (messagesFromServer.isEmpty) {
      return await _databaseProvider.fetchMessagesByChatId(chatId: '');
    }
    return [];
  }

  @override
  Future<Stream<DialogMessageEntity>> listenToMessages() async {
    // this is messages stream for all user/operator messages
    final messagesStream =
        await WebitelPortalSdk.instance.messageHandler.listenToMessages();

    final messagesStreamController = StreamController<DialogMessageEntity>();

    messagesStream.stream.listen((message) {
      final messageEntity = DialogMessageEntity(
        dialogMessageContent: message.dialogMessageContent,
        peer: Peer(id: '', type: '', name: ''),
        requestId: message.requestId,
        messageType: message.type!.name == 'user'
            ? MessageType.user
            : MessageType.operator,
      );

      _databaseProvider.writeMessageToDatabase(
        message: messageEntity,
      );
      messagesStreamController.add(
        messageEntity,
      );
    });

    return messagesStreamController.stream;
  }
}
