import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../../data/repositoriesImpl/category_repository_impl.dart';
import '../../data/datasources/category/catgeory_local_datasource.dart';
import '../../data/datasources/category/category_remote_datasource.dart';

// Repository Provider
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(
    localDataSource: CategoryLocalDataSource(),
    remoteDataSource: CategoryRemoteDataSource(),
  );
});

// List of all categories
final allCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return await repository.getCategories();
});
