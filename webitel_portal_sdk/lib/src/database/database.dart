import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart'; // Import the logger package
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:webitel_portal_sdk/src/domain/entities/user/user.dart';

@LazySingleton()
class DatabaseProvider {
  Database? _database;
  final Logger _logger = Logger();

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
  static const userTable = 'userTable';

  Future<void> _createDb(Database db, int version) async {
    await db.transaction((txn) async {
      // Create the current user table
      await txn.execute('''CREATE TABLE $userTable(
        id TEXT PRIMARY KEY,
        accessToken TEXT,
        clientToken TEXT,
        deviceId TEXT
      )''');
    });
    _logger.i("Database tables created.");
  }

  Future<void> writeUser(UserEntity user) async {
    final db = await database;
    final existingUser = await readUser();

    if (existingUser.id.isNotEmpty) {
      // Update only the fields that are different
      Map<String, dynamic> updatedFields = {};
      final userMap = user.toJson();
      final existingUserMap = existingUser.toJson();

      userMap.forEach((key, value) {
        if (existingUserMap[key] != value) {
          updatedFields[key] = value;
        }
      });

      if (updatedFields.isNotEmpty) {
        await db.update(
          userTable,
          updatedFields,
          where: 'id = ?',
          whereArgs: [user.id],
        );
        _logger.i("User updated: ${user.id}");
      }
    } else {
      // User does not exist, insert as new
      await db.insert(
        userTable,
        user.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _logger.i("New user inserted: ${user.id}");
    }
  }

  Future<UserEntity> readUser() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      userTable,
      limit: 1,
    );

    if (maps.isNotEmpty) {
      _logger.i("User read from database: ${maps[0]['id']}");
      return UserEntity.fromJson(maps[0]);
    } else {
      _logger.i("No user found in the database.");
      return UserEntity.initial();
    }
  }
}
