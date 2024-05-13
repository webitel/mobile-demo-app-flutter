import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:webitel_portal_sdk/webitel_portal_sdk.dart';
import 'package:webitel_sdk/domain/entity/cached_file.dart';
import 'package:webitel_sdk/domain/entity/dialog_message_entity.dart';
import 'package:webitel_sdk/domain/entity/media_file.dart';

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

  static const String cachedFiles = 'cachedFiles';

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''CREATE TABLE $messageTable(
        chatId TEXT,
        fileId TEXT,
        messageCategory TEXT,
        fileType TEXT,
        fileName TEXT,
        path TEXT,
        messageId TEXT PRIMARY KEY,
        messageType TEXT,
        dialogMessageContent TEXT,
        requestId TEXT,
        id INTEGER,
        messageStatus TEXT,
        timestamp INTEGER
      )''');

    await db.execute('''CREATE TABLE $cachedFiles(
        path TEXT,
        name TEXT,
        type TEXT,
        requestId TEXT,
        id TEXT,
        status TEXT    
      )''');
  }

  Future<void> saveCachedFile(CachedFileEntity file) async {
    final db = await database;
    await db.insert(
      cachedFiles,
      file.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> writeMessages(Dialog dialog) async {
    // Fetch messages from the server

    final messagesFromServer = await dialog.fetchMessages(limit: 20);

    if (messagesFromServer.isEmpty) return;

    // Clear previous messages
    await clear();

    // Fetch cached files and map them by requestId
    final db = await database;
    final List<Map<String, dynamic>> cachedFilesMaps =
        await db.query(cachedFiles);
    final Map<String, String> pathByRequestId = {
      for (var file in cachedFilesMaps) file['id']: file['path'] as String,
    };

    await db.transaction((txn) async {
      for (final message in messagesFromServer) {
        String path = '';
        if (message.file.id.isNotEmpty) {
          path = pathByRequestId[message.file.id] ?? '';
        }

        await txn.insert(
          messageTable,
          {
            'id': message.id,
            'chatId': message.chatId,
            'path': path,
            'fileId': message.file.id,
            'fileType': message.file.type,
            'fileName': message.file.name,
            'messageId': message.messageId,
            'messageType': message.sender!.name,
            'dialogMessageContent': message.dialogMessageContent,
            'requestId': message.requestId,
            'messageStatus': 'Success',
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
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
        .map(
          (message) => DialogMessageEntity(
            id: message['id'],
            messageStatus: MessageStatus.sent,
            messageType: message['messageType'] == 'operator'
                ? MessageType.operator
                : MessageType.user,
            dialogMessageContent: message['dialogMessageContent'],
            requestId: message['requestId'],
            file: MediaFileEntity(
              path: message['path'],
              id: message['fileId'],
              size: 0,
              bytes: [],
              data: const Stream<List<int>>.empty(),
              name: message['fileName'],
              type: message['fileType'],
              requestId: message['requestId'],
            ),
          ),
        )
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

  Future<void> clear() async {
    final db = await database;
    await db.delete(messageTable);
  }
}
