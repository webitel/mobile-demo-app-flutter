import 'package:webitel_portal_sdk/src/domain/entities/dialog_message.dart';

class ErrorMessageBuilder {
  late String _errorMessage;

  ErrorMessageBuilder setErrorMessage(String errorMessage) {
    _errorMessage = errorMessage;
    return this;
  }

  DialogMessageEntity build() {
    return DialogMessageEntity(
      dialogMessageContent: _errorMessage,
      type: MessageType.error,
      requestId: '',
      chatId: '',
      peer: PeerInfo(id: '', name: '', type: ''),
    );
  }
}
