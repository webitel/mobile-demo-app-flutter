import 'package:webitel_portal_sdk/webitel_portal_sdk.dart';
import 'package:webitel_sdk/domain/entity/dialog_message_entity.dart';
import 'package:webitel_sdk/domain/service/chat_service.dart';

class ChatServiceImpl implements ChatService {
  @override
  Future<void> sendDialogMessage({
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
    print(message.chatId);
    print(message.dialogMessageContent);
  }
}
