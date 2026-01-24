import 'package:expense_tracker/data/datasources/app_database.dart';
import 'package:expense_tracker/data/models/category_model.dart';
import 'package:sqflite/sqflite.dart';


class CategoryLocalDataSource {
  Future<Database> get _db async => await AppDatabase.init();

  Future<void> addCategory(CategoryModel category) async {
    final db = await _db;
    await db.insert(
      'categories',
      category.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCategory(CategoryModel category) async {
    final db = await _db;
    await db.update(
      'categories',
      category.toJson(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> deleteCategory(String id) async {
    final db = await _db;
    await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<CategoryModel>> getCategories() async {
    final db = await _db;
    final result = await db.query('categories');
    return result.map(CategoryModel.fromJson).toList();
  }
}
