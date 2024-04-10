import 'package:webitel_sdk/domain/entity/dialog_message.dart';
import 'package:webitel_sdk/domain/service/chat_service.dart';
import 'package:webitel_sdk_package/webitel_sdk_package.dart';

class ChatServiceImpl implements ChatService {
  @override
  Future<DialogMessageEntity> sendDialogMessage(
      {required DialogMessageEntity dialogMessageEntity}) async {
    final dialogMessageEntityRes =
        await WebitelSdkPackage.instance.messageHandler.sendDialogMessage(
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

  @override
  Future<Stream<dynamic>> listenIncomingOperatorMessages() async {
    final stream = await WebitelSdkPackage.instance.messageHandler
        .listenToOperatorMessages();
    return stream;
  }
}
