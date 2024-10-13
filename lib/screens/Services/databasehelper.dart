import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'bookmarks.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE bookmarks(
            id TEXT PRIMARY KEY,
            firstname TEXT,
            lastname TEXT,
            email TEXT,
            specialization TEXT,
            description TEXT,
            phone TEXT,
            workplace TEXT,
            Address TEXT,
            profileImage TEXT
          )
        ''');
      },
    );
  }

  Future<void> addBookmark(Map<String, dynamic> provider) async {
    final db = await database;
    await db.insert(
      'bookmarks', 
      provider, 
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  Future<void> removeBookmark(String providerId) async {
    final db = await database;
    await db.delete('bookmarks', where: 'id = ?', whereArgs: [providerId]);
  }

  Future<List<Map<String, dynamic>>> getBookmarks() async {
    final db = await database;
    return await db.query('bookmarks');
  }

  Future<bool> isBookmarked(String providerId) async {
    final db = await database;
    final result = await db.query('bookmarks', where: 'id = ?', whereArgs: [providerId]);
    return result.isNotEmpty;
  }
}
