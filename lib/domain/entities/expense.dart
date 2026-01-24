class Expense {
  final String id;
  final double amount;
  final DateTime date;
  final String categoryId;
  final String? notes;
  final String? receiptPath;

  Expense({
    required this.id,
    required this.amount,
    required this.date,
    required this.categoryId,
    this.notes,
    this.receiptPath,
  });
}
