import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/monthly_budget.dart';
import '../../domain/entities/expense.dart';
import '../providers/expense_providers.dart';

import '../../core/theme/app_theme.dart';
import '../widgets/expense_tile.dart';
import 'add_expense_screen.dart';

import 'package:expense_tracker/data/models/category_budget_model.dart';

class CategoryDetailsScreen extends ConsumerWidget {
  final Category category;
  final MonthlyBudget? budget;

  const CategoryDetailsScreen({
    super.key,
    required this.category,
    required this.budget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(allExpensesProvider);
    
    // Find category-specific budget
    final catBudget = budget?.categoryBudgets.firstWhere(
      (cb) => cb.categoryId == category.id,
      orElse: () => CategoryBudgetModel(
        id: '',
        monthlyBudgetId: budget?.id ?? '',
        categoryId: category.id,
        amount: 0.0,
      ),
    );

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(category.name),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Category Summary Header
          _buildSummaryHeader(context, catBudget),
          
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Row(
              children: [
                Text(
                  'Expenses History',
                  style: context.textTheme.titleLarge?.copyWith(fontSize: 18),
                ),
              ],
            ),
          ),
          
          // Category Expenses List
          Expanded(
            child: expensesAsync.when(
              data: (expenses) {
                final catExpenses = expenses
                    .where((e) => e.categoryId == category.id)
                    .toList()
                  ..sort((a, b) => b.date.compareTo(a.date));

                if (catExpenses.isEmpty) {
                  return Center(
                    child: Text('No expenses found for this category', style: Theme.of(context).textTheme.bodyMedium),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  itemCount: catExpenses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final expense = catExpenses[index];
                    return ExpenseTile(
                      expense: expense,
                      category: category,
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AddExpenseScreen(expenseToEdit: expense)),
                        );
                      },
                      onDelete: () => _confirmDeleteExpense(context, ref, expense),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(BuildContext context, dynamic catBudget) {
    return Consumer(
      builder: (context, ref, _) {
        final expensesAsync = ref.watch(allExpensesProvider);
        
        return expensesAsync.when(
          data: (expenses) {
            // Calculate spent amount for this category
            final monthStr = DateFormat('yyyy-MM').format(DateTime.now());
            final spent = expenses
                .where((e) => 
                  e.categoryId == category.id && 
                  DateFormat('yyyy-MM').format(e.date) == monthStr
                )
                .fold(0.0, (sum, e) => sum + e.amount);

            final budgetAmount = catBudget.amount;
            final remaining = budgetAmount - spent;
            final percentage = budgetAmount > 0 ? (spent / budgetAmount) * 100 : 0.0;
            
            // Determine status
            final isOverBudget = spent > budgetAmount;
            final isNearLimit = percentage >= 80 && !isOverBudget;
            
            Color statusColor = Colors.white;
            String statusText = 'On Track';
            IconData statusIcon = Icons.check_circle;
            
            if (isOverBudget) {
              statusColor = Colors.red.shade100;
              statusText = 'Over Budget!';
              statusIcon = Icons.error;
            } else if (isNearLimit) {
              statusColor = Colors.orange.shade100;
              statusText = 'Near Limit';
              statusIcon = Icons.warning;
            }

            return Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    category.color,
                    category.color.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: category.color.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                children: [
                  // Icon and Name
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(category.icon, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    category.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Budget Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(
                        'Spent',
                        '\$${spent.toStringAsFixed(2)}',
                        Icons.shopping_cart_outlined,
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      _buildStatColumn(
                        'Budget',
                        '\$${budgetAmount.toStringAsFixed(2)}',
                        Icons.account_balance_wallet_outlined,
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      _buildStatColumn(
                        'Remaining',
                        '\$${remaining.toStringAsFixed(2)}',
                        Icons.savings_outlined,
                        valueColor: remaining < 0 ? Colors.red.shade100 : null,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Progress Bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Budget Usage',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: (percentage / 100).clamp(0.0, 1.0),
                          minHeight: 12,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isOverBudget
                                ? Colors.red
                                : isNearLimit
                                    ? Colors.orange
                                    : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Status Badge
                  if (isOverBudget || isNearLimit) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 16, color: category.color),
                          const SizedBox(width: 6),
                          Text(
                            statusText,
                            style: TextStyle(
                              color: category.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          loading: () => Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: category.color,
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Center(child: CircularProgressIndicator(color: Colors.white)),
          ),
          error: (_, __) => Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: category.color,
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(Icons.error, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon, {Color? valueColor}) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  }

  void _confirmDeleteExpense(BuildContext context, WidgetRef ref, Expense expense) async {
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
      } catch (e) {
        debugPrint("Error deleting expense: $e");
      }
    }
  }


