class DialogMessageEntity {
  final String dialogMessageContent;
  final Peer peer;

  DialogMessageEntity({
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
