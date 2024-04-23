import 'dart:async';

import 'package:webitel_portal_sdk/webitel_portal_sdk.dart';
import 'package:webitel_sdk/database/database_provider.dart';
import 'package:webitel_sdk/domain/entity/dialog_message_entity.dart';
import 'package:webitel_sdk/domain/entity/response_entity.dart';
import 'package:webitel_sdk/domain/service/chat_service.dart';

class ChatServiceImpl implements ChatService {
  final DatabaseProvider _databaseProvider;
  late final StreamController<DialogMessageEntity> messagesStreamController;

  ChatServiceImpl(this._databaseProvider);

  @override
  Future<ResponseEntity> sendDialogMessage({
    required DialogMessageEntity dialogMessageEntity,
  }) async {
    final message =
        await WebitelPortalSdk.instance.messageHandler.sendDialogMessage(
      dialogMessageContent: dialogMessageEntity.dialogMessageContent,
      requestId: dialogMessageEntity.requestId,
      peerType: dialogMessageEntity.peer.type,
      peerName: dialogMessageEntity.peer.name,
      peerId: dialogMessageEntity.peer.id,
    );
    return ResponseEntity(
        status: ResponseStatus.success, message: message.dialogMessageContent);
  }

  @override
  Future<List<DialogMessageEntity>> fetchMessages() async {
    final messagesFromServer =
        await WebitelPortalSdk.instance.messageHandler.fetchMessages(limit: 20);
    if (messagesFromServer.isNotEmpty) {
      await _databaseProvider.clear();
      await _databaseProvider.writeMessages();
      return await _databaseProvider.fetchMessagesByChatId(chatId: '');
    }
    return [];
  }

  @override
  Future<Stream<DialogMessageEntity>> listenToMessages() async {
    final messagesStream =
        await WebitelPortalSdk.instance.eventHandler.listenToMessages();

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
