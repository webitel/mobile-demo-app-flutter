import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:webitel_portal_sdk/src/domain/entities/request_entity.dart';

@LazySingleton()
class DatabaseProvider {
  Database? _database;

  Future<Database> get database async {
    final dbDirectory = await getDatabasesPath();
    const dbName = 'request.db';
    final path = join(dbDirectory, dbName);

    _database ??= await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
    return _database!;
  }

  static const requestQueueTable = 'requestQueueTable';

  Future<void> _createDb(Database db, int version) async {
    await db.transaction(
      (txn) async {
        await txn.execute('''CREATE TABLE $requestQueueTable(
        id TEXT PRIMARY KEY,
        chatId TEXT,
        path TEXT,
        text TEXT,
        timestamp TEXT
      )''');
      },
    );
  }

  Future<void> insertRequest({
    required String id,
    required String chatID,
    required String path,
    required String text,
  }) async {
    final db = await database;
    await db.insert(
      requestQueueTable,
      {
        'id': id,
        'chatId': chatID,
        'path': path,
        'text': text,
        'timestamp': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteRequest({required String requestId}) async {
    final db = await database;
    await db.delete(
      requestQueueTable,
      where: 'id = ?',
      whereArgs: [requestId],
    );
  }

  Future<List<RequestEntity>> getAllRequests({String? chatID}) async {
    final db = await database;

    String whereClause = '';
    List<dynamic> whereArgs = [];
    if (chatID != null) {
      whereClause = 'WHERE chatId = ?';
      whereArgs = [chatID];
    }

    String sqlQuery =
        'SELECT * FROM $requestQueueTable $whereClause ORDER BY timestamp ASC';
    final List<Map<String, dynamic>> maps =
        await db.rawQuery(sqlQuery, whereArgs);

    return List.generate(
      maps.length,
      (i) {
        return RequestEntity(
          id: maps[i]['id'] ?? '',
          chatId: maps[i]['chatId'] ?? '',
          path: maps[i]['path'] ?? '',
          text: maps[i]['text'] ?? '',
          timestamp: DateTime.parse(
              maps[i]['timestamp'] ?? DateTime.now().toIso8601String()),
        );
      },
    );
  }

  Future<void> clearRequests({String? chatID}) async {
    final db = await database;

    String sqlQuery = 'DELETE FROM $requestQueueTable';
    List<dynamic> whereArgs = [];

    if (chatID != null) {
      sqlQuery += ' WHERE chatId = ?';
      whereArgs = [chatID];
    }

    await db.rawDelete(sqlQuery, whereArgs);
  }
}
