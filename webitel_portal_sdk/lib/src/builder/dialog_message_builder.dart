import 'package:webitel_portal_sdk/src/domain/entities/dialog_message.dart';
import 'package:webitel_portal_sdk/src/domain/entities/media_file.dart';
import 'package:webitel_portal_sdk/src/generated/portal/messages.pb.dart';

class DialogMessageBuilder {
  late String _dialogMessageContent;
  late String _requestId;
  late String _userId;
  late String _chatId;
  late String _messageId;
  late UpdateNewMessage _update;
  MediaFileEntity? _file;

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

  DialogMessageBuilder setChatId(String chatId) {
    _chatId = chatId;
    return this;
  }

  DialogMessageBuilder setMessageId(String messageId) {
    _messageId = messageId;
    return this;
  }

  DialogMessageBuilder setUpdate(UpdateNewMessage update) {
    _update = update;
    return this;
  }

  DialogMessageBuilder setFile(MediaFileEntity? file) {
    _file = file;
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
      chatId: _chatId,
      dialogMessageContent: _dialogMessageContent,
      type: messageType,
      requestId: _requestId,
      peer: peerInfo,
      messageId: _messageId,
      file: _file,
    );
  }
}
