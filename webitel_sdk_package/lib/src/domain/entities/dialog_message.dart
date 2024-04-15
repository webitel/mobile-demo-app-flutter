enum MessageType { user, operator, error }

class DialogMessageEntity {
  final String dialogMessageContent;
  final PeerInfo peer;
  final MessageType? type;
  final String requestId;

  DialogMessageEntity({
    required this.requestId,
    required this.dialogMessageContent,
    required this.peer,
    this.type,
  });
}

class PeerInfo {
  final String id;
  final String type;
  final String name;

  PeerInfo({
    required this.id,
    required this.type,
    required this.name,
  });
}
