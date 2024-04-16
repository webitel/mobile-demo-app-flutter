import 'package:webitel_sdk_package/src/domain/entities/dialog_message.dart';

class ErrorMessageBuilder {
  static DialogMessageEntity buildErrorMessage(String errorMessage) {
    return DialogMessageEntity(
      dialogMessageContent: errorMessage,
      type: MessageType.error,
      requestId: '',
      peer: PeerInfo(id: '', name: '', type: ''),
    );
  }
}
