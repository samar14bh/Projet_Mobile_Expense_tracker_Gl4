import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/monthly_budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../data/repositoriesImpl/budget_repository_impl.dart';
import '../../data/datasources/monthlyBudget/budget_local_datasource.dart';
import '../../data/datasources/monthlyBudget/budget_remote_datasource.dart';

// Repository Provider
final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepositoryImpl(
    localDataSource: BudgetLocalDataSource(),
    remoteDataSource: BudgetRemoteDataSource(),
  );
});

// Logic: Total budget for current month
final currentMonthBudgetProvider = FutureProvider<MonthlyBudget?>((ref) async {
  final repository = ref.watch(budgetRepositoryProvider);
  final monthStr = DateFormat('yyyy-MM').format(DateTime.now());
  return await repository.getBudgetForMonth(monthStr);
});

// Logic: History of all budgets
final allMonthlyBudgetsProvider = FutureProvider<List<MonthlyBudget>>((ref) async {
  final repository = ref.watch(budgetRepositoryProvider);
  return await repository.getAllMonthlyBudgets();
});
