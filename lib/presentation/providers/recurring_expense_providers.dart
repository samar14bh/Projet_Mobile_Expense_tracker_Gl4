import 'package:expense_tracker/domain/repositories/recurring_expense_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/recurring_expense.dart';
import '../../data/datasources/recurring_expense/recurring_expense_local_datasource.dart';
import '../../data/repositoriesImpl/recurring_expense_repository_impl.dart';

// Repository Provider
final recurringExpenseRepositoryProvider = Provider<RecurringExpenseRepository>((ref) {
  return RecurringExpenseRepositoryImpl(localDataSource: RecurringExpenseLocalDataSource());
});

// State Notifier for List
class RecurringExpensesNotifier extends StateNotifier<AsyncValue<List<RecurringExpense>>> {
  final RecurringExpenseRepository _repository;

  RecurringExpensesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadRecurringExpenses();
  }

  Future<void> loadRecurringExpenses() async {
    try {
      final expenses = await _repository.getRecurringExpenses();
      state = AsyncValue.data(expenses);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addRecurringExpense(RecurringExpense expense) async {
    try {
      await _repository.addRecurringExpense(expense);
      await loadRecurringExpenses();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateRecurringExpense(RecurringExpense expense) async {
    try {
      await _repository.updateRecurringExpense(expense);
      await loadRecurringExpenses();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteRecurringExpense(String id) async {
    try {
      await _repository.deleteRecurringExpense(id);
      await loadRecurringExpenses();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final recurringExpensesProvider = StateNotifierProvider<RecurringExpensesNotifier, AsyncValue<List<RecurringExpense>>>((ref) {
  final repo = ref.watch(recurringExpenseRepositoryProvider);
  return RecurringExpensesNotifier(repo);
});
