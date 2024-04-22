import 'package:sqflite/sqflite.dart';
import 'package:webitel_portal_sdk/webitel_portal_sdk.dart';
import 'package:webitel_sdk/database/database_provider.dart';
import 'package:webitel_sdk/domain/entity/dialog_message_entity.dart';
import 'package:webitel_sdk/domain/service/data_base_service.dart';

class DatabaseServiceImpl implements DatabaseService {
  final DatabaseProvider database;

  DatabaseServiceImpl(this.database);

  @override
  Future<List<DialogMessageEntity>> fetchMessagesByChatId(
      {required String chatId}) async {
    final db = await database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseProvider.messageTable,
      where: 'chatId = ?',
      whereArgs: ['AxUSFAMCDxQ'],
    );
    final messages = maps
        .map(
          (message) => DialogMessageEntity(
            messageStatus: MessageStatus.sent,
            messageType: message['messageType'] == 'operator'
                ? MessageType.operator
                : MessageType.user,
            dialogMessageContent: message['dialogMessageContent'],
            peer: Peer(id: '', type: '', name: ''),
            requestId: '',
          ),
        )
        .toList();

    return messages;
  }

  @override
  Future<void> writeMessageToDatabase(
      {required DialogMessageEntity message}) async {
    await database.writeMessage(message);
  }

  @override
  Future<void> writeMessages() async {
    final messagesFromServer =
        await WebitelPortalSdk.instance.messageHandler.fetchMessages(limit: 20);

    if (messagesFromServer.isNotEmpty) {
      await clear();
      final db = await database.database;
      await db.transaction((txn) async {
        for (final message in messagesFromServer) {
          await txn.insert(
            DatabaseProvider.messageTable,
            {
              'chatId': message.chatId,
              'messageId': message.messageId,
              'messageType': message.type!.name,
              'dialogMessageContent': message.dialogMessageContent,
              'peerId': message.peer.id,
              'peerType': message.peer.type,
              'peerName': message.peer.name,
              'requestId': message.requestId,
              'messageStatus': 'Success',
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
    } else {
      return;
    }
  }

  @override
  Future<void> updateMessageStatus(
      {required String requestId, required MessageStatus newStatus}) async {
    await database.updateMessageStatus(requestId, newStatus);
  }

  // Method to clear the message table
  @override
  Future<void> clear() async {
    final db = await database.database;
    await db.delete(DatabaseProvider.messageTable);
  }
}
