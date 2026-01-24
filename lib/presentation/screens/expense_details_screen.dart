import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/category.dart';
import '../../core/theme/app_theme.dart';
import '../providers/expense_providers.dart';
import 'add_expense_screen.dart';

class ExpenseDetailsScreen extends ConsumerWidget {
  final Expense expense;
  final Category category;

  const ExpenseDetailsScreen({
    super.key,
    required this.expense,
    required this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Expense Details'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddExpenseScreen(expenseToEdit: expense),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: category.color,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: category.color.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(category.icon, color: Colors.white, size: 48),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '-\$${expense.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category.name,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Details Section
              _buildDetailRow(
                context,
                label: 'Date',
                value: DateFormat('EEEE, MMMM dd, yyyy').format(expense.date),
                icon: Icons.calendar_today_outlined,
              ),
              const SizedBox(height: 20),
              _buildDetailRow(
                context,
                label: 'Category',
                value: category.name,
                icon: Icons.category_outlined,
              ),
              const SizedBox(height: 20),
              _buildDetailRow(
                context,
                label: 'Notes',
                value: expense.notes == null || expense.notes!.isEmpty
                    ? 'No notes provided'
                    : expense.notes!,
                icon: Icons.notes_outlined,
              ),
              
              if (expense.receiptPath != null) ...[
                const SizedBox(height: 32),
                Text(
                  'Receipt',
                  style: context.textTheme.titleLarge?.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: _buildReceiptImage(context),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [context.tokens.cardShadow],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: category.color, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptImage(BuildContext context) {
    return Image.file(
      File(expense.receiptPath!),
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(context),
    );
  }

  Widget _buildErrorPlaceholder(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      color: context.theme.cardTheme.color,
      child: const Icon(Icons.broken_image_outlined, size: 48),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) async {
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (proceed == true) {
      try {
        await ref.read(expenseRepositoryProvider).deleteExpense(expense.id);
        ref.invalidate(allExpensesProvider);
        ref.invalidate(currentMonthExpensesProvider);
        if (context.mounted) Navigator.pop(context);
      } catch (e) {
        debugPrint("Error deleting expense: $e");
      }
    }
  }
}
