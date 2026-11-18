import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/verse.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('bible_verses.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';

    // Table for cached daily verses
    await db.execute('''
      CREATE TABLE cached_verses (
        id $idType,
        book $textType,
        chapter $intType,
        verse_number $intType,
        text $textType,
        translation $textType,
        date_fetched $textType,
        is_bookmarked $intType
      )
    ''');

    // Table for user bookmarked verses
    await db.execute('''
      CREATE TABLE bookmarks (
        id $idType,
        book $textType,
        chapter $intType,
        verse_number $intType,
        text $textType,
        translation $textType,
        date_fetched $textType,
        created_at $textType
      )
    ''');
  }

  /// Cache a daily verse into SQLite
  Future<void> cacheVerse(Verse verse) async {
    final db = await database;
    await db.insert(
      'cached_verses',
      verse.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieve cached daily verse by date string (YYYY-MM-DD)
  Future<Verse?> getCachedVerseByDate(String dateStr) async {
    final db = await database;
    final maps = await db.query(
      'cached_verses',
      where: 'date_fetched = ?',
      whereArgs: [dateStr],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      final isBookmarked = await isVerseBookmarked(maps.first['id'] as String);
      final map = Map<String, dynamic>.from(maps.first);
      map['is_bookmarked'] = isBookmarked ? 1 : 0;
      return Verse.fromMap(map);
    }
    return null;
  }

  /// Retrieve the latest cached verse as fallback
  Future<Verse?> getLatestCachedVerse() async {
    final db = await database;
    final maps = await db.query(
      'cached_verses',
      orderBy: 'date_fetched DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      final isBookmarked = await isVerseBookmarked(maps.first['id'] as String);
      final map = Map<String, dynamic>.from(maps.first);
      map['is_bookmarked'] = isBookmarked ? 1 : 0;
      return Verse.fromMap(map);
    }
    return null;
  }

  /// Add verse to Bookmarks
  Future<void> addBookmark(Verse verse) async {
    final db = await database;
    final map = verse.toMap();
    map['created_at'] = DateTime.now().toIso8601String();
    map.remove('is_bookmarked');

    await db.insert(
      'bookmarks',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Remove verse from Bookmarks
  Future<void> removeBookmark(String verseId) async {
    final db = await database;
    await db.delete(
      'bookmarks',
      where: 'id = ?',
      whereArgs: [verseId],
    );
  }

  /// Check if a verse is bookmarked
  Future<bool> isVerseBookmarked(String verseId) async {
    final db = await database;
    final maps = await db.query(
      'bookmarks',
      where: 'id = ?',
      whereArgs: [verseId],
    );
    return maps.isNotEmpty;
  }

  /// Get all bookmarked verses
  Future<List<Verse>> getAllBookmarks() async {
    final db = await database;
    final maps = await db.query('bookmarks', orderBy: 'created_at DESC');

    return maps.map((map) {
      final mutableMap = Map<String, dynamic>.from(map);
      mutableMap['is_bookmarked'] = 1;
      return Verse.fromMap(mutableMap);
    }).toList();
  }

  /// Clear database (for testing or reset)
  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('cached_verses');
    await db.delete('bookmarks');
  }

  /// Close database
  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}
