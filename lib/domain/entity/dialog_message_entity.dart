enum MessageType { error, user, operator }

enum MessageStatus { loading, error, sent }

class DialogMessageEntity {
  final String dialogMessageContent;
  final Peer peer;
  final MessageType? messageType;
  final MessageStatus? messageStatus;
  final String requestId;
  final String? chatId;

  DialogMessageEntity({
    this.chatId,
    this.messageType,
    this.messageStatus,
    required this.dialogMessageContent,
    required this.peer,
    required this.requestId,
  });

  factory DialogMessageEntity.fromMap(Map<String, dynamic> map) {
    return DialogMessageEntity(
      chatId: map['chatId'],
      messageType: map['messageType'] != null
          ? MessageType.values
              .firstWhere((type) => type.toString() == map['messageType'])
          : null,
      messageStatus: map['messageStatus'] != null
          ? MessageStatus.values
              .firstWhere((status) => status.toString() == map['messageStatus'])
          : null,
      dialogMessageContent: map['dialogMessageContent'],
      peer: Peer(
        id: map['peerId'],
        type: map['peerType'],
        name: map['peerName'],
      ),
      requestId: map['requestId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'messageType': messageType?.toString(),
      'messageStatus': messageStatus?.toString(),
      'dialogMessageContent': dialogMessageContent,
      'peerId': peer.id,
      'peerType': peer.type,
      'peerName': peer.name,
      'requestId': requestId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }
}

class Peer {
  final String id;
  final String type;
  final String name;

  Peer({
    required this.id,
    required this.type,
    required this.name,
  });
}
