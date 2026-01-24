import 'category_budget.dart';

class MonthlyBudget {
  final String id;
  final String month; // Format: YYYY-MM
  final double totalAmount;
  final List<CategoryBudget> categoryBudgets;

  MonthlyBudget({
    required this.id,
    required this.month,
    required this.totalAmount,
    this.categoryBudgets = const [],
  });

  // Helper to calculate how much is left to allocate
  double get totalAllocated => categoryBudgets.fold(0, (sum, item) => sum + item.amount);
  double get remainingAmount => totalAmount - totalAllocated;
}
