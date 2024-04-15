enum MessageType { error, user, operator }

class DialogMessageEntity {
  final String dialogMessageContent;
  final Peer peer;
  final MessageType? messageType;

  DialogMessageEntity({
    this.messageType,
    required this.dialogMessageContent,
    required this.peer,
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
