import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:expense_tracker/data/models/expenseModel.dart';

class ExpenseRemoteDataSource {
  FirebaseFirestore? get _firestore {
    if (Firebase.apps.isEmpty) return null;
    return FirebaseFirestore.instance;
  }

  CollectionReference<Map<String, dynamic>>? get _collection =>
      _firestore?.collection('expenses');

  Future<void> addExpense(ExpenseModel expense) async {
    try {
      final collection = _collection;
      if (collection == null) return;
      await collection.doc(expense.id).set(expense.toJson());
      debugPrint("Expense synced to Firestore: ${expense.id}");
    } catch (e) {
      debugPrint("Error in addExpense (remote): $e");
    }
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      final collection = _collection;
      if (collection == null) return;
      await collection.doc(expense.id).update(expense.toJson());
    } catch (e) {
      debugPrint("Error in updateExpense (remote): $e");
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      final collection = _collection;
      if (collection == null) return;
      await collection.doc(id).delete();
    } catch (e) {
      debugPrint("Error in deleteExpense (remote): $e");
    }
  }

  Future<List<ExpenseModel>> getExpenses() async {
    try {
      final collection = _collection;
      if (collection == null) return [];
      final snapshot = await collection.get();
      return snapshot.docs
          .map((doc) => ExpenseModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint("Error in getExpenses (remote): $e");
      return [];
    }
  }
}
