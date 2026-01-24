import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../app_database.dart';
import '../../models/monthly_budget_model.dart';
import '../../models/category_budget_model.dart';

class BudgetLocalDataSource {
  Future<Database> get _db async => await AppDatabase.init();

  // Save/Update Total Monthly Budget and its allocations
  Future<void> setMonthlyBudget(MonthlyBudgetModel budget) async {
    try {
      final db = await _db;
      await db.transaction((txn) async {
        // 1. Save Total Budget
        await txn.insert(
          'monthly_budgets',
          budget.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // 2. Delete existing allocations for this monthly budget to avoid duplicates/orphans
        await txn.delete(
          'category_budgets',
          where: 'monthlyBudgetId = ?',
          whereArgs: [budget.id],
        );

        // 3. Save new Category allocations
        for (var allocation in budget.categoryBudgets) {
          await txn.insert(
            'category_budgets',
            CategoryBudgetModel.fromEntity(allocation).toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
      debugPrint("Budget set successfully for month: ${budget.month}");
    } catch (e) {
      debugPrint("Error in setMonthlyBudget: $e");
      rethrow;
    }
  }

  Future<MonthlyBudgetModel?> getBudgetForMonth(String month) async {
    try {
      final db = await _db;
      
      // Fetch Total Budget
      final budgetResult = await db.query(
        'monthly_budgets',
        where: 'month = ?',
        whereArgs: [month],
      );

      if (budgetResult.isEmpty) return null;

      final budgetMap = budgetResult.first;
      final budgetId = budgetMap['id'] as String;

      // Fetch allocations
      final allocationResult = await db.query(
        'category_budgets',
        where: 'monthlyBudgetId = ?',
        whereArgs: [budgetId],
      );

      final List<CategoryBudgetModel> allocations = allocationResult
          .map((a) => CategoryBudgetModel.fromJson(a))
          .toList();

      return MonthlyBudgetModel.fromJson(budgetMap, allocations: allocations);
    } catch (e) {
      debugPrint("Error in getBudgetForMonth: $e");
      return null;
    }
  }

  Future<List<MonthlyBudgetModel>> getAllMonthlyBudgets() async {
    final db = await _db;
    final budgetResult = await db.query('monthly_budgets');
    
    List<MonthlyBudgetModel> budgets = [];
    for (var budgetMap in budgetResult) {
      final budgetId = budgetMap['id'] as String;
      
      final allocationResult = await db.query(
        'category_budgets',
        where: 'monthlyBudgetId = ?',
        whereArgs: [budgetId],
      );

      final allocations = allocationResult
          .map((a) => CategoryBudgetModel.fromJson(a))
          .toList();

      budgets.add(MonthlyBudgetModel.fromJson(budgetMap, allocations: allocations));
    }
    
    return budgets;
  }

  Future<void> deleteMonthlyBudget(String id) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete(
        'category_budgets',
        where: 'monthlyBudgetId = ?',
        whereArgs: [id],
      );
      await txn.delete(
        'monthly_budgets',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }
}
