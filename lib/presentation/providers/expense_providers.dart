import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../data/repositoriesImpl/expense_repository_impl.dart';
import '../../data/datasources/expense/expense_local_datasource.dart';
import '../../data/datasources/expense/expense_remote_datasource.dart';

// Repository Provider
final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepositoryImpl(
    localDataSource: ExpenseLocalDataSource(),
    remoteDataSource: ExpenseRemoteDataSource(),
  );
});

// Logic: Total expenses for current month
final currentMonthExpensesProvider = FutureProvider<double>((ref) async {
  final repository = ref.watch(expenseRepositoryProvider);
  final expenses = await repository.getExpenses();
  final now = DateTime.now();
  
  return expenses
      .where((e) => e.date.year == now.year && e.date.month == now.month)
      .fold<double>(0.0, (sum, e) => sum + e.amount);
});

// Logic: List of all expenses (for transaction lists)
final allExpensesProvider = FutureProvider<List<Expense>>((ref) async {
  final repository = ref.watch(expenseRepositoryProvider);
  return await repository.getExpenses();
});
