import 'dart:io';
import 'package:expense_tracker/presentation/widgets/summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/expense_providers.dart';
import '../providers/budget_providers.dart';
import '../providers/category_providers.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/expense_tile.dart';

import '../screens/add_expense_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesTotalAsync = ref.watch(currentMonthExpensesProvider);
    final budgetAsync = ref.watch(currentMonthBudgetProvider);
    final expensesListAsync = ref.watch(allExpensesProvider);
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(currentMonthExpensesProvider);
        ref.invalidate(currentMonthBudgetProvider);
        ref.invalidate(allExpensesProvider);
        ref.invalidate(allCategoriesProvider);
        // Wait for providers to refresh is automatic since Riverpod handles async invalidation gracefully,
        // but explicit waiting might be needed if we want the spinner to stay until data is fresh.
        // For simplicity with FutureProviders, simple invalidation triggers a reload.
        // To show the loading indicator during the reload, we can await the future of the providers.
        // However, ref.invalidate returns void. ref.refresh returns the new state.
        // Let's us ref.refresh to ensure we wait for the new data.
        await Future.wait([
          ref.refresh(currentMonthExpensesProvider.future),
          ref.refresh(currentMonthBudgetProvider.future),
          ref.refresh(allExpensesProvider.future),
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), // Ensure scroll even if content is short
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Total Balance / Expenses Card
              expensesTotalAsync.when(
                data: (expenseTotal) => budgetAsync.when(
                  data: (budget) {
                    final totalBudget = budget?.totalAmount ?? 0.0;
                    final balance = totalBudget - expenseTotal;
                    return SummaryCard(
                      title: 'Current Balance',
                      amount: balance,
                      isBalance: true,
                      income: totalBudget,
                      expense: expenseTotal,
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
              ),
              
              const SizedBox(height: 24),
              
              // Monthly Budget Summary
              budgetAsync.when(
                data: (budget) => SummaryCard(
                  title: 'Monthly Budget Limit',
                  amount: budget?.totalAmount ?? 0.0,
                  isBalance: false,
                ),
                loading: () => const SizedBox(),
                error: (e, _) => const SizedBox(),
              ),
              
              const SizedBox(height: 30),
              
              // Transactions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: context.textTheme.titleLarge?.copyWith(fontSize: 18),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'See All',
                      style: TextStyle(color: context.textTheme.bodyMedium?.color, fontSize: 13),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 10),
              
              // Real-time Transaction List
              expensesListAsync.when(
                data: (expenses) {
                  if (expenses.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.0),
                        child: Text('No transactions yet', style: TextStyle(color: Colors.grey)),
                      ),
                    );
                  }
  
                  // Sort by date descending
                  final sortedExpenses = [...expenses]..sort((a, b) => b.date.compareTo(a.date));
  
                  return categoriesAsync.when(
                    data: (categories) {
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sortedExpenses.length > 5 ? 5 : sortedExpenses.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final expense = sortedExpenses[index];
                          final category = categories.firstWhere(
                            (c) => c.id == expense.categoryId,
                            orElse: () => categories.first,
                          );
  
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
                    error: (e, _) => Text('Error: $e'),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error loading transactions: $e'),
              ),
              const SizedBox(height: 100), // Spacing for FAB
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteExpense(BuildContext context, WidgetRef ref, dynamic expense) async {
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

  }

