import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:webitel_portal_sdk/src/domain/entities/user/user.dart';

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
  static const userTable = 'userTable';

  // Method to create the database tables
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
      }
    } else {
      // User does not exist, insert as new
      await db.insert(
        userTable,
        user.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

// Method to read a user from the database
  Future<UserEntity> readUser() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      userTable,
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return UserEntity.fromJson(maps[0]);
    } else {
      return UserEntity.initial();
    }
  }
}
