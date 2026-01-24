import 'package:expense_tracker/data/models/expenseModel.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense/expense_local_datasource.dart';
import '../datasources/expense/expense_remote_datasource.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource localDataSource;
  final ExpenseRemoteDataSource remoteDataSource;

  ExpenseRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<void> addExpense(Expense expense) async {
    final model = ExpenseModel.fromEntity(expense);
    await localDataSource.addExpense(model);
    
    // Sync to remote in background (text data only, local image path won't work on other devices but that's fine for local storage)
    remoteDataSource.addExpense(model).catchError((e) => debugPrint("Remote addExpense failed: $e"));
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final model = ExpenseModel.fromEntity(expense);
    await localDataSource.updateExpense(model);
    remoteDataSource.updateExpense(model).catchError((e) => debugPrint("Remote updateExpense failed: $e"));
  }

  @override
  Future<void> deleteExpense(String id) async {
    await localDataSource.deleteExpense(id);
    remoteDataSource.deleteExpense(id).catchError((e) => debugPrint("Remote deleteExpense failed: $e"));
  }

  @override
  Future<List<Expense>> getExpenses() async {
    final models = await localDataSource.getExpenses();
    return models.map((m) => m.toEntity()).toList();
  }
}
