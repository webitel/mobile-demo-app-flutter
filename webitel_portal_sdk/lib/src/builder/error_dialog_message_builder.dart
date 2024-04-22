import 'package:webitel_portal_sdk/src/domain/entities/dialog_message.dart';

class ErrorDialogMessageBuilder {
  late String _dialogMessageContent;
  late String _requestId;

  ErrorDialogMessageBuilder setDialogMessageContent(
      String dialogMessageContent) {
    _dialogMessageContent = dialogMessageContent;
    return this;
  }

  ErrorDialogMessageBuilder setRequestId(String requestId) {
    _requestId = requestId;
    return this;
  }

  DialogMessageEntity build() {
    final messageType = MessageType.operator;

    final peerInfo = PeerInfo(
      id: '',
      name: 'ERROR',
      type: 'Unknown',
    );

    return DialogMessageEntity(
      chatId: '',
      dialogMessageContent: _dialogMessageContent,
      type: messageType,
      requestId: _requestId,
      peer: peerInfo,
      messageId: '',
    );
  }
}
