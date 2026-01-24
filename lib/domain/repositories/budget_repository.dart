import '../entities/monthly_budget.dart';

abstract class BudgetRepository {
  Future<void> setMonthlyBudget(MonthlyBudget budget);
  Future<MonthlyBudget?> getBudgetForMonth(String month); // Get total budget + categories for a month
  Future<List<MonthlyBudget>> getAllMonthlyBudgets();
  Future<void> deleteMonthlyBudget(String id);
}
