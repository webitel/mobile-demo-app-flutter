enum MessageType { user, operator, error }

class DialogMessageEntity {
  final File? file;
  final String dialogMessageContent;
  final PeerInfo peer;
  final MessageType? type;
  final String requestId;
  final String? chatId;
  final String? messageId;

  DialogMessageEntity({
    required this.requestId,
    required this.dialogMessageContent,
    required this.peer,
    this.type,
    this.file,
    this.chatId,
    this.messageId,
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

class File {
  final String id;
  final int size;
  final String type;
  final String name;

  File({
    required this.id,
    required this.size,
    required this.type,
    required this.name,
  });
}
