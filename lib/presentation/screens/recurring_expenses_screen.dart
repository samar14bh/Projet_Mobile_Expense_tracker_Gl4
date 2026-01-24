import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/recurring_expense.dart';
import '../../core/theme/app_theme.dart';
import 'add_recurring_expense_screen.dart';
import '../providers/recurring_expense_providers.dart';
import '../providers/expense_providers.dart';
import '../../domain/entities/expense.dart';
import 'package:uuid/uuid.dart';

class RecurringExpensesScreen extends ConsumerWidget {
  const RecurringExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recurringExpensesAsync = ref.watch(recurringExpensesProvider);

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Recurring Expenses'),
        backgroundColor: Colors.transparent,
      ),
      body: recurringExpensesAsync.when(
        data: (expenses) => expenses.isEmpty
            ? _buildEmptyState(context)
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: expenses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final expense = expenses[index];
                  return _buildRecurringExpenseTile(context, ref, expense);
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddRecurringExpenseScreen()),
          );
          
          if (result != null && result is RecurringExpense) {
            await ref.read(recurringExpensesProvider.notifier).addRecurringExpense(result);
            
            // Logic for immediate deduction
            if (_shouldDeductImmediately(result)) {
               final expense = Expense(
                 id: const Uuid().v4(),
                 amount: result.amount,
                 date: DateTime.now(), // Deduct Now
                 categoryId: result.categoryId,
                 notes: result.name, // Use name as note
               );
               await ref.read(expenseRepositoryProvider).addExpense(expense);
               ref.invalidate(currentMonthExpensesProvider);
               ref.invalidate(allExpensesProvider);
               
               if (context.mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Expense added and deducted for this month!')),
                 );
               }
            }
          }
        },
        backgroundColor: AppTheme.primaryPurple,
        icon: const Icon(Icons.add),
        label: const Text('Add Recurring'),
      ),
    );
  }
  
  bool _shouldDeductImmediately(RecurringExpense expense) {
    final now = DateTime.now();
    // If start date is in future, no
    if (expense.startDate.year > now.year || 
       (expense.startDate.year == now.year && expense.startDate.month > now.month)) {
      return false;
    }
    
    // If we are past the billing day today, and we haven't 'processed' it yet (newly added),
    // we should deduct it for this month.
    // NOTE: In a real robust system, we'd check if an expense already exists for this month linked to this recurring ID.
    // For now, based on user flow "Add -> Deduct", this check is sufficient for creation time.
    if (now.day >= expense.dayOfMonth) {
      return true;
    }
    
    return false;
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.repeat,
            size: 80,
            color: context.textTheme.bodyMedium?.color?.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Recurring Expenses',
            style: context.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Add monthly bills like rent, subscriptions, etc.',
            style: context.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecurringExpenseTile(BuildContext context, WidgetRef ref, RecurringExpense expense) {
    return InkWell(
      onTap: () async {
        // EDIT
        final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddRecurringExpenseScreen(expenseToEdit: expense)),
        );
        if (result != null && result is RecurringExpense) {
           await ref.read(recurringExpensesProvider.notifier).updateRecurringExpense(result);
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.theme.cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [context.tokens.cardShadow],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.repeat, color: AppTheme.primaryPurple, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.name,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Every ${_getDayWithSuffix(expense.dayOfMonth)}',
                    style: context.textTheme.bodyMedium?.copyWith(fontSize: 12),
                  ),
                  if (expense.notes != null && expense.notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      expense.notes!,
                      style: context.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${expense.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryPurple,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: expense.isActive,
                      onChanged: (value) {
                        final updated = RecurringExpense(
                          id: expense.id,
                          name: expense.name,
                          amount: expense.amount,
                          categoryId: expense.categoryId,
                          dayOfMonth: expense.dayOfMonth,
                          startDate: expense.startDate,
                          notes: expense.notes,
                          isActive: value,
                          createdAt: expense.createdAt,
                        );
                        ref.read(recurringExpensesProvider.notifier).updateRecurringExpense(updated);
                      },
                      activeColor: AppTheme.primaryPurple,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                      onPressed: () => _confirmDelete(context, ref, expense.id),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      splashRadius: 20,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _confirmDelete(BuildContext context, WidgetRef ref, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Recurring Expense'),
        content: const Text('Are you sure? This will stop future auto-additions.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      ref.read(recurringExpensesProvider.notifier).deleteRecurringExpense(id);
    }
  }

  String _getDayWithSuffix(int day) {
    if (day >= 11 && day <= 13) return '${day}th';
    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }
}
