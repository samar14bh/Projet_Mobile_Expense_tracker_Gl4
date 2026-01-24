import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/monthly_budget_model.dart';
import '../../models/category_budget_model.dart';

class BudgetRemoteDataSource {
  FirebaseFirestore? get _firestore {
    if (Firebase.apps.isEmpty) return null;
    return FirebaseFirestore.instance;
  }

  CollectionReference<Map<String, dynamic>>? get _budgetCollection =>
      _firestore?.collection('monthly_budgets');

  CollectionReference<Map<String, dynamic>>? get _allocationCollection =>
      _firestore?.collection('category_budgets');

  Future<void> setMonthlyBudget(MonthlyBudgetModel budget) async {
    try {
      final db = _firestore;
      if (db == null) return;
      
      final batch = db.batch();
      
      // 1. Save Total Budget
      batch.set(_budgetCollection!.doc(budget.id), budget.toJson());

      for (var allocation in budget.categoryBudgets) {
        final model = CategoryBudgetModel.fromEntity(allocation);
        batch.set(_allocationCollection!.doc(model.id), model.toJson());
      }

      await batch.commit();
    } catch (e) {
      debugPrint("Error in Remote setMonthlyBudget: $e");
    }
  }

  Future<MonthlyBudgetModel?> getBudgetForMonth(String month) async {
    try {
      final collection = _budgetCollection;
      if (collection == null) return null;

      final query = await collection.where('month', isEqualTo: month).limit(1).get();
      if (query.docs.isEmpty) return null;

      final budgetDoc = query.docs.first;
      final budgetData = budgetDoc.data();
      final budgetId = budgetDoc.id;

      final allocationQuery = await _allocationCollection!
          .where('monthlyBudgetId', isEqualTo: budgetId)
          .get();

      final List<CategoryBudgetModel> allocations = allocationQuery.docs
          .map((doc) => CategoryBudgetModel.fromJson(doc.data()))
          .toList();

      return MonthlyBudgetModel.fromJson(budgetData, allocations: allocations);
    } catch (e) {
      debugPrint("Error in Remote getBudgetForMonth: $e");
      return null;
    }
  }

  Future<List<MonthlyBudgetModel>> getAllMonthlyBudgets() async {
    try {
      final collection = _budgetCollection;
      if (collection == null) return [];

      final snapshot = await collection.get();
      List<MonthlyBudgetModel> budgets = [];

      for (var doc in snapshot.docs) {
        final budgetData = doc.data();
        final budgetId = doc.id;

        final allocationQuery = await _allocationCollection!
            .where('monthlyBudgetId', isEqualTo: budgetId)
            .get();

        final allocations = allocationQuery.docs
            .map((doc) => CategoryBudgetModel.fromJson(doc.data()))
            .toList();

        budgets.add(MonthlyBudgetModel.fromJson(budgetData, allocations: allocations));
      }
      return budgets;
    } catch (e) {
      debugPrint("Error in Remote getAllMonthlyBudgets: $e");
      return [];
    }
  }

  Future<void> deleteMonthlyBudget(String id) async {
    try {
      final db = _firestore;
      if (db == null) return;

      final batch = db.batch();
      batch.delete(_budgetCollection!.doc(id));
      
      final allocations = await _allocationCollection!.where('monthlyBudgetId', isEqualTo: id).get();
      for (var doc in allocations.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      debugPrint("Error in Remote deleteMonthlyBudget: $e");
    }
  }
}
