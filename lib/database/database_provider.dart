import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:webitel_portal_sdk/webitel_portal_sdk.dart';
import 'package:webitel_sdk/domain/entity/dialog_message_entity.dart';

class DatabaseProvider {
  Database? _database;

  Future<Database> get database async {
    final dbDirectory = await getDatabasesPath();
    const dbName = 'chat.db';
    final path = join(dbDirectory, dbName);

    _database ??= await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
    return _database!;
  }

  static const String messageTable = 'messageTable';

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''CREATE TABLE $messageTable(
        chatId TEXT,
        messageCategory TEXT,
        fileName TEXT,
        path TEXT,
        messageId TEXT PRIMARY KEY,
        messageType TEXT,
        dialogMessageContent TEXT,
        peerId TEXT,
        peerType TEXT,
        peerName TEXT,
        requestId TEXT,
        messageStatus TEXT,
        timestamp INTEGER
      )''');
  }

  Future<List<DialogMessageEntity>> fetchMessagesByChatId(
      {required String chatId}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      messageTable,
      where: 'chatId = ?',
      whereArgs: ['AxUSFAMCDxQ'],
    );
    final messages = maps
        .map((message) => DialogMessageEntity(
              messageStatus: MessageStatus.sent,
              messageType: message['messageType'] == 'operator'
                  ? MessageType.operator
                  : MessageType.user,
              dialogMessageContent: message['dialogMessageContent'],
              peer: Peer(id: '', type: '', name: ''),
              requestId: '',
            ))
        .toList();

    return messages;
  }

  Future<void> writeMessageToDatabase(
      {required DialogMessageEntity message}) async {
    final db = await database;
    await db.insert(
      messageTable,
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> writeMessages() async {
    final messagesFromServer =
        await WebitelPortalSdk.instance.messageHandler.fetchMessages(limit: 20);

    if (messagesFromServer.isNotEmpty) {
      await clear();
      final db = await database;
      await db.transaction((txn) async {
        for (final message in messagesFromServer) {
          await txn.insert(
            messageTable,
            {
              'chatId': message.chatId,
              'path': '',
              'messageCategory': '',
              'fileName': message.file?.name,
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

  Future<void> clear() async {
    final db = await database;
    await db.delete(messageTable);
  }
}
