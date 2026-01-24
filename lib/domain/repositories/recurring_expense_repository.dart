import '../../domain/entities/recurring_expense.dart';

abstract class RecurringExpenseRepository {
  Future<List<RecurringExpense>> getRecurringExpenses();
  Future<void> addRecurringExpense(RecurringExpense expense);
  Future<void> updateRecurringExpense(RecurringExpense expense);
  Future<void> deleteRecurringExpense(String id);
}
