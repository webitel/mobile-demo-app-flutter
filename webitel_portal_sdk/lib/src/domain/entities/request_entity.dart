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

  // Factory method to create a RequestEntity from a map
  factory RequestEntity.fromMap(Map<String, dynamic> map) {
    return RequestEntity(
      id: map['id'] ?? '',
      chatId: map['chatId'] ?? '',
      text: map['text'] ?? '',
      timestamp:
          DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      path: map['path'] ?? '',
    );
  }

  // Method to convert RequestEntity to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'path': path,
    };
  }
}
