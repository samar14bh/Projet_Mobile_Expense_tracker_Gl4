class RecurringExpense {
  final String id;
  final String name;
  final double amount;
  final String categoryId;
  final int dayOfMonth; // 1-31, day when expense should be added
  final DateTime startDate;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;

  RecurringExpense({
    required this.id,
    required this.name,
    required this.amount,
    required this.categoryId,
    required this.dayOfMonth,
    required this.startDate,
    this.notes,
    this.isActive = true,
    required this.createdAt,
  });
}
