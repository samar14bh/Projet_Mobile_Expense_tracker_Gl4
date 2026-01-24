import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static Database? _database;

  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  static Future<Database> init() async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'expense_tracker.db');

    return _database = await openDatabase(
      path,
      version: 6,
      onCreate: (db, version) async {
        
        await db.execute('''
          CREATE TABLE recurring_expenses (
            id TEXT PRIMARY KEY,
            name TEXT,
            amount REAL,
            categoryId TEXT,
            dayOfMonth INTEGER,
            startDate TEXT,
            notes TEXT,
            isActive INTEGER,
            createdAt TEXT,
            FOREIGN KEY (categoryId) REFERENCES categories (id)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {

        if (oldVersion < 5) {
          await db.execute('''
            CREATE TABLE recurring_expenses (
              id TEXT PRIMARY KEY,
              name TEXT,
              amount REAL,
              categoryId TEXT,
              dayOfMonth INTEGER,
              notes TEXT,
              isActive INTEGER,
              createdAt TEXT,
              FOREIGN KEY (categoryId) REFERENCES categories (id)
            )
          ''');
        }
        if (oldVersion < 6) {
          
          
          try {
             await db.execute('ALTER TABLE recurring_expenses ADD COLUMN startDate TEXT');
          } catch (e) {
            // Ignore if column exists
          }
        }
      },
    );
  }
}
