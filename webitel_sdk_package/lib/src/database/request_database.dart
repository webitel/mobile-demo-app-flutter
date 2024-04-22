import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:webitel_sdk_package/src/domain/entities/reqeust_entity.dart';

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

  static const requestTable = 'requestTable';

  Future<void> _createDb(Database db, int version) async {
    await db.transaction(
      (txn) async {
        await txn.execute('''CREATE TABLE $requestTable(
        id TEXT PRIMARY KEY,
        path TEXT,
        text TEXT,
        timestamp TEXT
      )''');
      },
    );
  }

  Future<void> insertRequest(String id, String path, String text) async {
    final db = await database;
    await db.insert(
      requestTable,
      {
        'id': id,
        'path': path,
        'text': text,
        'timestamp': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteRequest(String requestId) async {
    final db = await database;
    await db.delete(
      requestTable,
      where: 'id = ?',
      whereArgs: [requestId],
    );
  }

  Future<List<RequestEntity>> getAllRequests() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(requestTable);

    return List.generate(maps.length, (i) {
      return RequestEntity(
        id: maps[i]['id'],
        path: maps[i]['path'],
        text: maps[i]['text'],
        timestamp: DateTime.parse(maps[i]['timestamp']),
      );
    });
  }
}
