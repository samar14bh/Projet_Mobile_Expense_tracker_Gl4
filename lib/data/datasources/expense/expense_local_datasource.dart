import 'package:flutter/foundation.dart';
import 'package:expense_tracker/data/datasources/app_database.dart';
import 'package:expense_tracker/data/models/expenseModel.dart';
import 'package:sqflite/sqflite.dart';


class ExpenseLocalDataSource {
  Future<Database> get _db async => await AppDatabase.init();

  Future<void> addExpense(ExpenseModel expense) async {
    try {
      final db = await _db;
      await db.insert(
        'expenses',
        expense.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint("Expense added locally: ${expense.id}");
    } catch (e) {
      debugPrint("Error in addExpense (local): $e");
      rethrow;
    }
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      final db = await _db;
      await db.update(
        'expenses',
        expense.toJson(),
        where: 'id = ?',
        whereArgs: [expense.id],
      );
    } catch (e) {
      debugPrint("Error in updateExpense (local): $e");
      rethrow;
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      final db = await _db;
      await db.delete(
        'expenses',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint("Error in deleteExpense (local): $e");
      rethrow;
    }
  }

  Future<List<ExpenseModel>> getExpenses() async {
    try {
      final db = await _db;
      final result = await db.query('expenses');
      return result.map(ExpenseModel.fromJson).toList();
    } catch (e) {
      debugPrint("Error in getExpenses (local): $e");
      return [];
    }
  }
}
