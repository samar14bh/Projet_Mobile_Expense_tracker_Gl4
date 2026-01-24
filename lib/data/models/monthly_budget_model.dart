import '../../domain/entities/monthly_budget.dart';
import 'category_budget_model.dart';

class MonthlyBudgetModel extends MonthlyBudget {
  MonthlyBudgetModel({
    required super.id,
    required super.month,
    required super.totalAmount,
    super.categoryBudgets,
  });

  factory MonthlyBudgetModel.fromJson(Map<String, dynamic> json, {List<CategoryBudgetModel>? allocations}) {
    return MonthlyBudgetModel(
      id: json['id'],
      month: json['month'],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      categoryBudgets: allocations ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'month': month,
      'totalAmount': totalAmount,
    };
  }

  factory MonthlyBudgetModel.fromEntity(MonthlyBudget entity) {
    return MonthlyBudgetModel(
      id: entity.id,
      month: entity.month,
      totalAmount: entity.totalAmount,
      categoryBudgets: entity.categoryBudgets
          .map((cb) => CategoryBudgetModel.fromEntity(cb))
          .toList(),
    );
  }

  MonthlyBudget toEntity() {
    return MonthlyBudget(
      id: id,
      month: month,
      totalAmount: totalAmount,
      categoryBudgets: categoryBudgets,
    );
  }
}
