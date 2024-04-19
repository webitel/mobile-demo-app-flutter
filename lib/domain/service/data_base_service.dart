import 'package:webitel_sdk/domain/entity/dialog_message_entity.dart';

abstract interface class DatabaseService {
  Future<List<DialogMessageEntity>> fetchMessagesByChatId(
      {required String chatId});

  Future<void> writeMessageToDatabase({required DialogMessageEntity message});

  Future<void> updateMessageStatus(
      {required String requestId, required MessageStatus newStatus});

  Future<void> writeMessages();

  Future<void> clear();
}
