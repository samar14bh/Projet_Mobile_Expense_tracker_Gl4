import '../../domain/repositories/recurring_expense_repository.dart';
import '../../domain/entities/recurring_expense.dart';
import '../datasources/recurring_expense/recurring_expense_local_datasource.dart';
import '../models/recurring_expense_model.dart';

class RecurringExpenseRepositoryImpl implements RecurringExpenseRepository {
  final RecurringExpenseLocalDataSource localDataSource;

  RecurringExpenseRepositoryImpl({required this.localDataSource});

  @override
  Future<void> addRecurringExpense(RecurringExpense expense) async {
    final model = RecurringExpenseModel.fromEntity(expense);
    await localDataSource.addRecurringExpense(model);
  }

  @override
  Future<void> updateRecurringExpense(RecurringExpense expense) async {
    final model = RecurringExpenseModel.fromEntity(expense);
    await localDataSource.updateRecurringExpense(model);
  }

  @override
  Future<void> deleteRecurringExpense(String id) async {
    await localDataSource.deleteRecurringExpense(id);
  }

  @override
  Future<List<RecurringExpense>> getRecurringExpenses() async {
    final models = await localDataSource.getRecurringExpenses();
    return models.map((m) => m.toEntity()).toList();
  }
}
