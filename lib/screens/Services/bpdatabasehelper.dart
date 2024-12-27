import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BookmarkedProviderDatabaseHelper {
  static final BookmarkedProviderDatabaseHelper _instance =
      BookmarkedProviderDatabaseHelper._internal();
  factory BookmarkedProviderDatabaseHelper() => _instance;
  static Database? _database;

  BookmarkedProviderDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'bookmarkedproviders.db');
    return await openDatabase(
      path,
      version: 1, // You can increase this version if you need to handle migrations
      onCreate: (db, version) async {
        await db.execute(''' 
          CREATE TABLE bookmarked_providers (
            userId TEXT,
            id TEXT PRIMARY KEY,
            firstname TEXT,
            lastname TEXT,
            email TEXT,
            specialization TEXT,
            description TEXT,
            phone TEXT,
            workplace TEXT,
            address TEXT,
            profileImage TEXT
          )
        ''');
      },
    );
  }

  Future<void> addBookmark(String userId, Map<String, dynamic> providerData) async {
    final db = await database;
    await db.insert(
      'bookmarked_providers',
      {
        'userId': userId,
        'id': providerData['id'],
        'firstname': providerData['firstname'],
        'lastname': providerData['lastname'],
        'email': providerData['email'],
        'specialization': providerData['specialization'],
        'description': providerData['description'],
        'phone': providerData['phone'],
        'workplace': providerData['workplace'],
        'address': providerData['address'],
        'profileImage': providerData['profileImage'],
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeBookmark(String providerId, String userId) async {
    var db = await database;

    // Correct column name used: 'id' instead of 'providerId'
    await db.delete(
      'bookmarked_providers', // table name
      where: 'id = ? AND userId = ?', // Ensure you're using 'id' here
      whereArgs: [providerId, userId],
    );
  }

  Future<List<Map<String, dynamic>>> getBookmarks(String userId) async {
    var db = await database;

    // Fetch the bookmarks for the provided userId
    var result = await db.query(
      'bookmarked_providers',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return result;
  }
}
