import 'package:webitel_portal_sdk/src/domain/entities/dialog_message.dart';
import 'package:webitel_portal_sdk/src/generated/chat/messages/message.pb.dart';
import 'package:webitel_portal_sdk/src/generated/chat/messages/peer.pb.dart';

class MessagesListMessageBuilder {
  late String _requestId;
  late String _chatId;
  late String _userId;
  late List<Message> _messages;
  late List<Peer> _peers;

  MessagesListMessageBuilder setRequestId(String requestId) {
    _requestId = requestId;
    return this;
  }

  MessagesListMessageBuilder setChatId(String chatId) {
    _chatId = chatId;
    return this;
  }

  MessagesListMessageBuilder setUserId(String userId) {
    _userId = userId;
    return this;
  }

  MessagesListMessageBuilder setMessages(List<Message> messages) {
    _messages = messages;
    return this;
  }

  MessagesListMessageBuilder setPeers(List<Peer> peers) {
    _peers = peers;
    return this;
  }

  List<DialogMessageEntity> build() {
    return _messages.map((message) {
      final peerIndex = int.parse(message.from.id) - 1;
      final messageType = _peers[peerIndex].id == _userId
          ? MessageType.user
          : MessageType.operator;

      return DialogMessageEntity(
        requestId: _requestId,
        chatId: _chatId,
        type: messageType,
        dialogMessageContent: message.text,
        peer: PeerInfo(
          name: message.from.name,
          type: message.chat.peer.type,
          id: message.chat.peer.id,
        ),
      );
    }).toList();
  }
}