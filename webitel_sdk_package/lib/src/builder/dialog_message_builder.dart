import 'package:webitel_sdk_package/src/domain/entities/dialog_message.dart';
import 'package:webitel_sdk_package/src/generated/portal/messages.pb.dart';

class DialogMessageBuilder {
  late String _dialogMessageContent;
  late String _requestId;
  late String _userId;
  late UpdateNewMessage _update;

  DialogMessageBuilder setDialogMessageContent(String dialogMessageContent) {
    _dialogMessageContent = dialogMessageContent;
    return this;
  }

  DialogMessageBuilder setRequestId(String requestId) {
    _requestId = requestId;
    return this;
  }

  DialogMessageBuilder setUserId(String userId) {
    _userId = userId;
    return this;
  }

  DialogMessageBuilder setUpdate(UpdateNewMessage update) {
    _update = update;
    return this;
  }

  DialogMessageEntity build() {
    final messageType = _update.message.from.id == _userId
        ? MessageType.user
        : MessageType.operator;

    final peerInfo = PeerInfo(
      id: _update.message.from.id,
      name: _update.message.from.name,
      type: _update.message.from.type,
    );

    return DialogMessageEntity(
      dialogMessageContent: _dialogMessageContent,
      type: messageType,
      requestId: _requestId,
      peer: peerInfo,
    );
  }
}
