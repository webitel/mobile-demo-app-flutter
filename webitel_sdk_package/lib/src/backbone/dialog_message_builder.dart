import 'package:webitel_sdk_package/src/domain/entities/dialog_message.dart';
import 'package:webitel_sdk_package/src/generated/portal/messages.pb.dart';

class DialogMessageBuilder {
  static DialogMessageEntity buildDialogMessage({
    required String dialogMessageContent,
    required String requestId,
    required String userId,
    required UpdateNewMessage update,
  }) {
    final messageType = update.message.from.id == userId
        ? MessageType.user
        : MessageType.operator;

    final peerInfo = PeerInfo(
      id: update.message.from.id,
      name: update.message.from.name,
      type: update.message.from.type,
    );

    return DialogMessageEntity(
      dialogMessageContent: dialogMessageContent,
      type: messageType,
      requestId: requestId,
      peer: peerInfo,
    );
  }
}
