class RequestEntity {
  final String id;
  final String chatId;
  final String text;
  final DateTime timestamp;
  final String path;

  RequestEntity({
    required this.chatId,
    required this.id,
    required this.text,
    required this.timestamp,
    required this.path,
  });
}
