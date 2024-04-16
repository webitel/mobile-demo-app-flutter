import 'package:webitel_sdk_package/src/domain/entities/dialog_message.dart';

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
      peer: PeerInfo(id: '', name: '', type: ''),
    );
  }
}
