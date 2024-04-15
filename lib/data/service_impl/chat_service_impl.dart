import 'package:webitel_sdk/domain/service/chat_service.dart';
import 'package:webitel_sdk_package/webitel_sdk_package.dart';

import '../../domain/entity/dialog_message_entity.dart';

class ChatServiceImpl implements ChatService {
  @override
  Future<void> sendDialogMessage({
    required DialogMessageEntity dialogMessageEntity,
  }) async {
    await WebitelSdkPackage.instance.dialogListHandler.dialogMessageHandler
        .sendDialogMessage(
      dialogMessageContent: dialogMessageEntity.dialogMessageContent,
      requestId: dialogMessageEntity.requestId,
      peerType: dialogMessageEntity.peer.type,
      peerName: dialogMessageEntity.peer.name,
      peerId: dialogMessageEntity.peer.id,
    );
  }
}
