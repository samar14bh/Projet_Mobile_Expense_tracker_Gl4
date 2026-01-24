import '../entities/category.dart';

abstract class CategoryRepository {
  Future<void> addCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String id);
  Future<List<Category>> getCategories();
}
