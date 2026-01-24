import '../../domain/entities/recurring_expense.dart';

class RecurringExpenseModel extends RecurringExpense {
  RecurringExpenseModel({
    required super.id,
    required super.name,
    required super.amount,
    required super.categoryId,
    required super.dayOfMonth,
    required super.startDate,
    super.notes,
    super.isActive,
    required super.createdAt,
  });

  factory RecurringExpenseModel.fromJson(Map<String, dynamic> json) {
    return RecurringExpenseModel(
      id: json['id'],
      name: json['name'],
      amount: json['amount'],
      categoryId: json['categoryId'],
      dayOfMonth: json['dayOfMonth'],
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate']) 
          : DateTime.now(), // Fallback for old data
      notes: json['notes'],
      isActive: json['isActive'] == 1,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'categoryId': categoryId,
        'dayOfMonth': dayOfMonth,
        'startDate': startDate.toIso8601String(),
        'notes': notes,
        'isActive': isActive ? 1 : 0,
        'createdAt': createdAt.toIso8601String(),
      };

  factory RecurringExpenseModel.fromEntity(RecurringExpense entity) {
    return RecurringExpenseModel(
      id: entity.id,
      name: entity.name,
      amount: entity.amount,
      categoryId: entity.categoryId,
      dayOfMonth: entity.dayOfMonth,
      startDate: entity.startDate,
      notes: entity.notes,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
    );
  }

  RecurringExpense toEntity() {
    return RecurringExpense(
      id: id,
      name: name,
      amount: amount,
      categoryId: categoryId,
      dayOfMonth: dayOfMonth,
      startDate: startDate,
      notes: notes,
      isActive: isActive,
      createdAt: createdAt,
    );
  }
}
