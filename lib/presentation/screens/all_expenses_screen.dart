import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/expense_providers.dart';
import '../providers/category_providers.dart';
import '../widgets/expense_tile.dart';
import '../../core/theme/app_theme.dart';

class AllExpensesScreen extends ConsumerStatefulWidget {
  const AllExpensesScreen({super.key});

  @override
  ConsumerState<AllExpensesScreen> createState() => _AllExpensesScreenState();
}

class _AllExpensesScreenState extends ConsumerState<AllExpensesScreen> {
  String _searchQuery = '';
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(allExpensesProvider);
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Gorgeous Sliver AppBar
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: context.theme.scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'All Transactions',
                style: context.textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  shadows: [
                    if (context.theme.brightness == Brightness.dark)
                      const Shadow(color: Colors.black54, blurRadius: 10)
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      context.theme.colorScheme.primary.withOpacity(0.05),
                      context.theme.scaffoldBackgroundColor,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -20,
                      right: -20,
                      child: CircleAvatar(
                        radius: 80,
                        backgroundColor: context.theme.colorScheme.primary.withOpacity(0.05),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search and Filter Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  // Search Field
                  Container(
                    decoration: BoxDecoration(
                      color: context.theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [context.tokens.cardShadow],
                    ),
                    child: TextField(
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Search transactions...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Category Filter
                  categoriesAsync.when(
                    data: (categories) => SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'All',
                            isSelected: _selectedCategoryId == null,
                            onTap: () => setState(() => _selectedCategoryId = null),
                          ),
                          ...categories.map((cat) => _FilterChip(
                            label: cat.name,
                            icon: cat.icon,
                            isSelected: _selectedCategoryId == cat.id,
                            onTap: () => setState(() => _selectedCategoryId = cat.id),
                          )),
                        ],
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),

          // List of Expenses
          expensesAsync.when(
            data: (expenses) {
              // Apply Sorting and Filtering
              var filteredExpenses = expenses
                  .where((e) {
                    final matchesSearch = e.notes?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? true;
                    final matchesCategory = _selectedCategoryId == null || e.categoryId == _selectedCategoryId;
                    return matchesSearch && matchesCategory;
                  })
                  .toList()
                ..sort((a, b) => b.date.compareTo(a.date));

              if (filteredExpenses.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 64, color: context.textTheme.bodyMedium?.color?.withOpacity(0.2)),
                        const SizedBox(height: 16),
                        Text('No transactions found', style: context.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                );
              }

              // Group by date
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final expense = filteredExpenses[index];
                      bool showDateHeader = false;
                      
                      if (index == 0) {
                        showDateHeader = true;
                      } else {
                        final prevExpense = filteredExpenses[index - 1];
                        if (DateFormat('yyyy-MM-dd').format(expense.date) != 
                            DateFormat('yyyy-MM-dd').format(prevExpense.date)) {
                          showDateHeader = true;
                        }
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showDateHeader) ...[
                            Padding(
                              padding: const EdgeInsets.only(top: 24, bottom: 12, left: 4),
                              child: Text(
                                _formatHeaderDate(expense.date),
                                style: context.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.theme.colorScheme.primary,
                                  fontSize: 13,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                          ],
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ExpenseTile(
                              expense: expense,
                              onDelete: () => _confirmDelete(context, ref, expense.id),
                            ),
                          ),
                        ],
                      );
                    },
                    childCount: filteredExpenses.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  String _formatHeaderDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);

    if (d == today) return 'TODAY';
    if (d == yesterday) return 'YESTERDAY';
    return DateFormat('MMMM dd, yyyy').format(date).toUpperCase();
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) async {
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
      await ref.read(expenseRepositoryProvider).deleteExpense(id);
      ref.invalidate(allExpensesProvider);
      ref.invalidate(currentMonthExpensesProvider);
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? context.theme.colorScheme.primary : context.theme.cardTheme.color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected ? null : [context.tokens.cardShadow],
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: isSelected ? Colors.white : context.theme.colorScheme.primary),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : context.textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
