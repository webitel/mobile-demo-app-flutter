class DialogMessageEntity {
  final String dialogMessageContent;
  final PeerInfo peer;

  DialogMessageEntity({
    required this.dialogMessageContent,
    required this.peer,
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
