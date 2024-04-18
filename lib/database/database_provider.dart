import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
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

  Future<void> writeMessage(DialogMessageEntity message) async {
    final Database db = await database;
    await db.insert(
      messageTable,
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateMessageStatus(
      String requestId, MessageStatus newStatus) async {
    final Database db = await database;
    await db.update(
      messageTable,
      {'messageStatus': newStatus.toString()},
      where: 'requestId = ?',
      whereArgs: [requestId],
    );
  }
}
