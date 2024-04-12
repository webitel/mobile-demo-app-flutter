import 'package:webitel_sdk/domain/service/chat_service.dart';
import 'package:webitel_sdk_package/webitel_sdk_package.dart';

import '../../domain/entity/dialog_message_entity.dart';

class ChatServiceImpl implements ChatService {
  @override
  Future<DialogMessageEntity> sendDialogMessage(
      {required DialogMessageEntity dialogMessageEntity}) async {
    final dialogMessageEntityRes = await WebitelSdkPackage
        .instance.dialogListHandler.dialogMessageHandler
        .sendDialogMessage(
      dialogMessageContent: dialogMessageEntity.dialogMessageContent,
      peerType: dialogMessageEntity.peer.type,
      peerName: dialogMessageEntity.peer.name,
      peerId: dialogMessageEntity.peer.id,
    );
    return DialogMessageEntity(
      dialogMessageContent: dialogMessageEntityRes.dialogMessageContent,
      peer: Peer(
        type: dialogMessageEntityRes.peer.type,
        id: dialogMessageEntityRes.peer.id,
        name: dialogMessageEntityRes.peer.name,
      ),
    );
  }
}
