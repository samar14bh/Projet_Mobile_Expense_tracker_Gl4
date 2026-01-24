import '../../domain/entities/category_budget.dart';

class CategoryBudgetModel extends CategoryBudget {
  CategoryBudgetModel({
    required super.id,
    required super.categoryId,
    required super.amount,
    required super.monthlyBudgetId,
  });

  factory CategoryBudgetModel.fromJson(Map<String, dynamic> json) {
    return CategoryBudgetModel(
      id: json['id'],
      categoryId: json['categoryId'],
      amount: (json['amount'] as num).toDouble(),
      monthlyBudgetId: json['monthlyBudgetId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'amount': amount,
      'monthlyBudgetId': monthlyBudgetId,
    };
  }

  factory CategoryBudgetModel.fromEntity(CategoryBudget entity) {
    if (entity is CategoryBudgetModel) return entity;
    return CategoryBudgetModel(
      id: entity.id,
      categoryId: entity.categoryId,
      amount: entity.amount,
      monthlyBudgetId: entity.monthlyBudgetId,
    );
  }

  CategoryBudget toEntity() {
    return CategoryBudget(
      id: id,
      categoryId: categoryId,
      amount: amount,
      monthlyBudgetId: monthlyBudgetId,
    );
  }
}
