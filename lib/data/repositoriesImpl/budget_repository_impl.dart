import 'package:flutter/foundation.dart';

import '../../domain/entities/monthly_budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/monthlyBudget/budget_local_datasource.dart';
import '../datasources/monthlyBudget/budget_remote_datasource.dart';
import '../models/monthly_budget_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetLocalDataSource localDataSource;
  final BudgetRemoteDataSource remoteDataSource;

  BudgetRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<void> setMonthlyBudget(MonthlyBudget budget) async {
    final model = MonthlyBudgetModel.fromEntity(budget);
    // Persist locally first
    await localDataSource.setMonthlyBudget(model);
    // Sync to remote in background without blocking the UI
    remoteDataSource.setMonthlyBudget(model).catchError((e) {
      debugPrint("Background budget sync failed: $e");
    });
  }

  @override
  Future<MonthlyBudget?> getBudgetForMonth(String month) async {
    // 1. Try local first
    final localModel = await localDataSource.getBudgetForMonth(month);
    if (localModel != null) return localModel.toEntity();

    // 2. Fallback to remote
    final remoteModel = await remoteDataSource.getBudgetForMonth(month);
    if (remoteModel != null) {
      // Sync back to local
      await localDataSource.setMonthlyBudget(remoteModel);
      return remoteModel.toEntity();
    }

    return null;
  }

  @override
  Future<List<MonthlyBudget>> getAllMonthlyBudgets() async {
    final models = await localDataSource.getAllMonthlyBudgets();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> deleteMonthlyBudget(String id) async {
    await localDataSource.deleteMonthlyBudget(id);
    remoteDataSource.deleteMonthlyBudget(id).catchError((e) {
      debugPrint("Background budget deletion failed: $e");
    });
  }
}
