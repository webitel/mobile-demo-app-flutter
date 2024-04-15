import 'package:webitel_sdk/domain/entity/dialog_message_entity.dart';

MessageType categorizeMessageType(String messageType) {
  if (messageType == 'user') {
    return MessageType.user;
  } else if (messageType == 'operator') {
    return MessageType.operator;
  } else if (messageType == 'error') {
    return MessageType.error;
  } else {
    return MessageType.error;
  }
}
