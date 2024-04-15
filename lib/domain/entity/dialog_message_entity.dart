enum MessageType { error, user, operator }

class DialogMessageEntity {
  final String dialogMessageContent;
  final Peer peer;
  final MessageType? messageType;
  final String requestId;

  DialogMessageEntity({
    this.messageType,
    required this.dialogMessageContent,
    required this.peer,
    required this.requestId,
  });
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
