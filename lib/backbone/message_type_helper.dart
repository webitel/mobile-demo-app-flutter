import '../domain/entity/msg_type.dart';

MsgType categorizeMessageType(String messageType) {
  if (messageType == 'user') {
    return MsgType.user;
  } else if (messageType == 'operator') {
    return MsgType.operator;
  } else if (messageType == 'error') {
    return MsgType.error;
  } else {
    return MsgType.error;
  }
}
