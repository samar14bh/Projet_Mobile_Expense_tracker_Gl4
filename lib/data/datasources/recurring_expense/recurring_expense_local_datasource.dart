import 'package:sqflite/sqflite.dart';
import '../../models/recurring_expense_model.dart';
import '../app_database.dart';

class RecurringExpenseLocalDataSource {
  Future<Database> get _db async => await AppDatabase.init();

  Future<void> addRecurringExpense(RecurringExpenseModel expense) async {
    try {
      final db = await _db;
      await db.insert(
        'recurring_expenses',
        expense.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      // Possible schema mismatch, try to heal
      await AppDatabase.close();
      final db = await _db; // Re-init
      await db.insert(
        'recurring_expenses',
        expense.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> updateRecurringExpense(RecurringExpenseModel expense) async {
    final db = await _db;
    await db.update(
      'recurring_expenses',
      expense.toJson(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<void> deleteRecurringExpense(String id) async {
    final db = await _db;
    await db.delete(
      'recurring_expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<RecurringExpenseModel>> getRecurringExpenses() async {
    try {
      final db = await _db;
      final result = await db.query('recurring_expenses', orderBy: 'createdAt DESC');
      return result.map((e) => RecurringExpenseModel.fromJson(e)).toList();
    } catch (e) {
      // Possible schema mismatch, try to heal
      await AppDatabase.close();
      final db = await _db; // Re-init
      final result = await db.query('recurring_expenses', orderBy: 'createdAt DESC');
      return result.map((e) => RecurringExpenseModel.fromJson(e)).toList();
    }
  }
}
