import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// A singleton service that manages the local SQLite database
class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  static Database? _db;

  factory DatabaseService() => instance;

  DatabaseService._internal();

  /// Provides the database instance, initializing it if needed
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  /// Initializes the database and creates tables if not exist
  Future<Database> _initDB() async {
    try {
      final dbPath = await databaseFactoryFfi.getDatabasesPath();
      final path = join(dbPath, 'app.db');

      return await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _onCreate,
          onConfigure: _onConfigure,
        ),
      );
    } catch (e) {
      print('❌ Error initializing database: $e');
      rethrow;
    }
  }

  /// Enable foreign key constraints
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Creates all tables in the database
  Future<void> _onCreate(Database db, int version) async {
    try {
      await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');

      await db.execute('''
      CREATE TABLE todos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        status TEXT NOT NULL CHECK(status IN ('Active', 'Completed')),
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
    } catch (e) {
      print('❌ Error creating tables: $e');
      rethrow;
    }
  }


  /// Closes the database connection
  Future<void> close() async {
    try {
      final dbClient = await database;
      await dbClient.close();
      _db = null;
    } catch (e) {
      print('❌ Error closing database: $e');
    }
  }
}
