import '../../domain/entities/expense.dart';

class ExpenseModel extends Expense {
  ExpenseModel({
    required super.id,
    required super.amount,
    required super.date,
    required super.categoryId,
    super.notes,
    super.receiptPath,
  });

  // Convert from JSON (for storage like Firebase/SQLite)
  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      categoryId: json['categoryId'],
      notes: json['notes'],
      receiptPath: json['receiptPath'],
    );
  }

  // Convert to JSON (for storage)
  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'date': date.toIso8601String(),
        'categoryId': categoryId,
        'notes': notes,
        'receiptPath': receiptPath,
      };

  // ✅ Convert Entity -> Model
  factory ExpenseModel.fromEntity(Expense entity) {
    return ExpenseModel(
      id: entity.id,
      amount: entity.amount,
      date: entity.date,
      categoryId: entity.categoryId,
      notes: entity.notes,
      receiptPath: entity.receiptPath,
    );
  }

  // ✅ Convert Model -> Entity
  Expense toEntity() {
    return Expense(
      id: id,
      amount: amount,
      date: date,
      categoryId: categoryId,
      notes: notes,
      receiptPath: receiptPath,
    );
  }
}
