import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:expense_tracker/data/models/category_model.dart';


class CategoryRemoteDataSource {
  FirebaseFirestore? get _firestore {
    if (Firebase.apps.isEmpty) return null;
    return FirebaseFirestore.instance;
  }

  CollectionReference<Map<String, dynamic>>? get _collection =>
      _firestore?.collection('categories');

  Future<void> addCategory(CategoryModel category) async {
    try {
      final collection = _collection;
      if (collection == null) return;
      await collection.doc(category.id).set(category.toJson());
    } catch (e) {
      debugPrint("Error in addCategory (remote): $e");
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    try {
      final collection = _collection;
      if (collection == null) return;
      await collection.doc(category.id).update(category.toJson());
    } catch (e) {
      debugPrint("Error in updateCategory (remote): $e");
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      final collection = _collection;
      if (collection == null) return;
      await collection.doc(id).delete();
    } catch (e) {
      debugPrint("Error in deleteCategory (remote): $e");
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final collection = _collection;
      if (collection == null) return [];
      final snapshot = await collection.get();
      return snapshot.docs
          .map((doc) => CategoryModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint("Error in getCategories (remote): $e");
      return [];
    }
  }
}
