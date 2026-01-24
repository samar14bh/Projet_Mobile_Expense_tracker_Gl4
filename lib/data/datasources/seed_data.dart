import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'app_database.dart';
import '../models/category_model.dart';
import '../models/expenseModel.dart';
import '../models/monthly_budget_model.dart';
import '../models/category_budget_model.dart';
import 'category/catgeory_local_datasource.dart';
import 'expense/expense_local_datasource.dart';
import 'monthlyBudget/budget_local_datasource.dart';

class DatabaseSeeder {
  static final _uuid = const Uuid();

  static Future<void> reseed() async {
    final db = await AppDatabase.init();
    
    // Clear all tables
    await db.delete('expenses');
    await db.delete('categories');
    await db.delete('monthly_budgets');
    await db.delete('category_budgets');
    await db.delete('recurring_expenses');
    
    // Re-run standard seed logic
    await seed(force: true);
  }

  static Future<void> seed({bool force = false}) async {
    final db = await AppDatabase.init();
    
    // Check if we should skip
    if (!force) {
      final existingExpenses = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM expenses'),
          ) ?? 0;
      if (existingExpenses > 0) {
        debugPrint("Skipping seed; expenses already populated ($existingExpenses rows)");
        return;
      }
    }

    final categoryDataSource = CategoryLocalDataSource();
    final expenseDataSource = ExpenseLocalDataSource();
    final budgetDataSource = BudgetLocalDataSource();

    // 1. Define Categories
    final categories = [
      CategoryModel(
        id: 'cat_food',
        name: 'Food',
        color: Colors.orange,
        icon: Icons.restaurant,
      ),
      CategoryModel(
        id: 'cat_transport',
        name: 'Transport',
        color: Colors.blue,
        icon: Icons.directions_car,
      ),
      CategoryModel(
        id: 'cat_rent',
        name: 'Rent',
        color: Colors.purple,
        icon: Icons.home,
      ),
      CategoryModel(
        id: 'cat_entertainment',
        name: 'Entertainment',
        color: Colors.pink,
        icon: Icons.movie,
      ),
    ];

    for (var cat in categories) {
      await categoryDataSource.addCategory(cat);
    }

    // 2. Define Monthly Budgets for last 3 months
    final now = DateTime.now();
    for (int i = 0; i < 3; i++) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final monthStr = "${monthDate.year}-${monthDate.month.toString().padLeft(2, '0')}";
      final budgetId = 'budget_$monthStr';

      final totalBudget = 5000.0 - (i * 200); // Slight variation

      final allocations = [
        CategoryBudgetModel(
          id: _uuid.v4(),
          monthlyBudgetId: budgetId,
          categoryId: 'cat_food',
          amount: 600.0,
        ),
        CategoryBudgetModel(
          id: _uuid.v4(),
          monthlyBudgetId: budgetId,
          categoryId: 'cat_transport',
          amount: 300.0,
        ),
        CategoryBudgetModel(
          id: _uuid.v4(),
          monthlyBudgetId: budgetId,
          categoryId: 'cat_rent',
          amount: 2000.0,
        ),
        CategoryBudgetModel(
          id: _uuid.v4(),
          monthlyBudgetId: budgetId,
          categoryId: 'cat_entertainment',
          amount: 400.0,
        ),
      ];

      final monthlyBudget = MonthlyBudgetModel(
        id: budgetId,
        month: monthStr,
        totalAmount: totalBudget,
        categoryBudgets: allocations,
      );

      await budgetDataSource.setMonthlyBudget(monthlyBudget);

      // 3. Add some sample expenses for each month
      final daysInMonth = i == 0 ? now.day : 28;
      for (int d = 1; d <= daysInMonth; d += 5) {
        await expenseDataSource.addExpense(ExpenseModel(
          id: _uuid.v4(),
          amount: 20.0 + (d * 2),
          date: DateTime(monthDate.year, monthDate.month, d),
          categoryId: 'cat_food',
          notes: 'Groceries $d',
        ));

        await expenseDataSource.addExpense(ExpenseModel(
          id: _uuid.v4(),
          amount: 15.0 + (d * 1.5),
          date: DateTime(monthDate.year, monthDate.month, d),
          categoryId: 'cat_transport',
          notes: 'Fuel $d',
        ));
      }
      
      // Fixed monthly rent expense
      await expenseDataSource.addExpense(ExpenseModel(
        id: _uuid.v4(),
        amount: 2000.0,
        date: DateTime(monthDate.year, monthDate.month, 1),
        categoryId: 'cat_rent',
        notes: 'Monthly Rent',
      ));
    }
  }
}
