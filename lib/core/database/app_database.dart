import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();

    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbDirectory = await getDatabasesPath();
    final dbPath = join(dbDirectory, 'app_database.db');

    return openDatabase(
      dbPath,
      version: 3,

      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },

      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products (
            id TEXT PRIMARY KEY,
            code TEXT NOT NULL UNIQUE,
            name TEXT NOT NULL,
            priceMmk INTEGER NOT NULL,
            isNew INTEGER NOT NULL DEFAULT 0,
            discountPercent INTEGER,
            description TEXT,
            imageUrl TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE banners (
            id TEXT PRIMARY KEY,
            imageUrl TEXT NOT NULL,
            isPopular INTEGER NOT NULL DEFAULT 0,
            productId TEXT NOT NULL,
            isActive INTEGER NOT NULL DEFAULT 1,
            sortOrder INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (productId) REFERENCES products(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE shops (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            address TEXT NOT NULL,
            imageUrl TEXT
          )
        ''');
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE banners (
              id TEXT PRIMARY KEY,
              imageUrl TEXT NOT NULL,
              isPopular INTEGER NOT NULL DEFAULT 0,
              productId TEXT NOT NULL,
              isActive INTEGER NOT NULL DEFAULT 1,
              sortOrder INTEGER NOT NULL DEFAULT 0,
              FOREIGN KEY (productId) REFERENCES products(id)
            )
          ''');
        }

        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE shops (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              address TEXT NOT NULL,
              imageUrl TEXT
            )
          ''');
        }
      },
    );
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
