import 'package:expense_tracker/data/datasources/category/catgeory_local_datasource.dart';
import 'package:expense_tracker/data/datasources/category/category_remote_datasource.dart';
import 'package:flutter/foundation.dart' hide Category;

import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource localDataSource;
  final CategoryRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<void> addCategory(Category category) async {
    final model = CategoryModel.fromEntity(category);
    await localDataSource.addCategory(model);
    remoteDataSource.addCategory(model).catchError((e) => debugPrint("Remote addCategory failed: $e"));
  }

  @override
  Future<void> updateCategory(Category category) async {
    final model = CategoryModel.fromEntity(category);
    await localDataSource.updateCategory(model);
    remoteDataSource.updateCategory(model).catchError((e) => debugPrint("Remote updateCategory failed: $e"));
  }

  @override
  Future<void> deleteCategory(String id) async {
    await localDataSource.deleteCategory(id);
    remoteDataSource.deleteCategory(id).catchError((e) => debugPrint("Remote deleteCategory failed: $e"));
  }

  @override
  Future<List<Category>> getCategories() async {
    final models = await localDataSource.getCategories();
    return models.map((m) => m.toEntity()).toList();
  }
}
