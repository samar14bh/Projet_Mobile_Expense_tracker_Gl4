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
      version: 7,
      onCreate: (db, version) async {
        
        // 1. Create Categories Table (Base table, no foreign keys yet)
        await db.execute('''
          CREATE TABLE categories (
            id TEXT PRIMARY KEY,
            name TEXT,
            color TEXT,
            icon INTEGER,
            monthlyBudgetId TEXT
          )
        ''');

        // 2. Create Monthly Budgets Table
        await db.execute('''
          CREATE TABLE monthly_budgets (
            id TEXT PRIMARY KEY,
            month TEXT,
            totalAmount REAL
          )
        ''');

        // 3. Create Category Budgets Table
        await db.execute('''
          CREATE TABLE category_budgets (
            id TEXT PRIMARY KEY,
            categoryId TEXT,
            amount REAL,
            monthlyBudgetId TEXT,
            FOREIGN KEY (categoryId) REFERENCES categories (id),
            FOREIGN KEY (monthlyBudgetId) REFERENCES monthly_budgets (id)
          )
        ''');

        // 4. Create Expenses Table
        await db.execute('''
          CREATE TABLE expenses (
            id TEXT PRIMARY KEY,
            amount REAL,
            date TEXT,
            categoryId TEXT,
            notes TEXT,
            receiptPath TEXT,
            FOREIGN KEY (categoryId) REFERENCES categories (id)
          )
        ''');

        // 5. Create Recurring Expenses Table
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
        
        // Upgrade to Version 7: Create missing tables for existing users
        if (oldVersion < 7) {
           // We use CREATE TABLE IF NOT EXISTS to be safe, though strict creation is also fine if we know they are missing.
           // Given the error was "no such table", they are definitely missing.
           
           await db.execute('''
            CREATE TABLE IF NOT EXISTS categories (
              id TEXT PRIMARY KEY,
              name TEXT,
              color TEXT,
              icon INTEGER,
              monthlyBudgetId TEXT
            )
          ''');

          await db.execute('''
            CREATE TABLE IF NOT EXISTS monthly_budgets (
              id TEXT PRIMARY KEY,
              month TEXT,
              totalAmount REAL
            )
          ''');

          await db.execute('''
            CREATE TABLE IF NOT EXISTS category_budgets (
              id TEXT PRIMARY KEY,
              categoryId TEXT,
              amount REAL,
              monthlyBudgetId TEXT,
              FOREIGN KEY (categoryId) REFERENCES categories (id),
              FOREIGN KEY (monthlyBudgetId) REFERENCES monthly_budgets (id)
            )
          ''');

          await db.execute('''
            CREATE TABLE IF NOT EXISTS expenses (
              id TEXT PRIMARY KEY,
              amount REAL,
              date TEXT,
              categoryId TEXT,
              notes TEXT,
              receiptPath TEXT,
              FOREIGN KEY (categoryId) REFERENCES categories (id)
            )
          ''');
          
          // Recurring expenses usually exists from v6, but just in case, we can leave it or ensure it.
          // The previous migration steps (v5, v6) should have handled it.
        }
      },
    );
  }
}
