import 'package:expense_tracker/data/models/category_budget_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/monthly_budget.dart';
import '../../domain/entities/category_budget.dart';
import '../providers/category_providers.dart';
import '../providers/budget_providers.dart';
import '../screens/add_category_screen.dart';
import '../screens/category_details_screen.dart';
import '../../domain/entities/category.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  String _currentMonthStr = DateFormat('yyyy-MM').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(allCategoriesProvider);
    final budgetAsync = ref.watch(currentMonthBudgetProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Categories & Budgets'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddCategoryScreen()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month & Total Budget Header
            budgetAsync.when(
              data: (budget) => Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryPurple, AppTheme.accentPink],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: AppTheme.primaryPurple.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Monthly Budget',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                          onPressed: () => _showSetTotalBudgetDialog(context, budget),
                        ),
                      ],
                    ),
                    Text(
                      '\$${budget?.totalAmount.toStringAsFixed(2) ?? "0.00"}',
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('MMMM yyyy').format(DateTime.now()),
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                    ),
                  ],
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: 32),

            Text(
              'Allocations by Category',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 16),

            // Categories List
            Expanded(
              child: categoriesAsync.when(
                data: (categories) => budgetAsync.when(
                  data: (budget) => ListView.separated(
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final catBudget = budget?.categoryBudgets.firstWhere(
                        (cb) => cb.categoryId == category.id,
                        orElse: () => CategoryBudgetModel(
                          id: '',
                          monthlyBudgetId: budget.id,
                          categoryId: category.id,
                          amount: 0.0,
                        ),
                      );

                      return InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CategoryDetailsScreen(category: category, budget: budget),
                          ),
                        ),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.light ? 0.02 : 0.1), blurRadius: 10)
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: category.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(category.icon, color: category.color),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(category.name, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                                    Text(
                                      'Budget: \$${catBudget?.amount.toStringAsFixed(2) ?? "0.00"}',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 20, color: AppTheme.primaryPurple),
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => AddCategoryScreen(categoryToEdit: category)),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.attach_money, size: 20, color: Colors.green),
                                    onPressed: () => _showSetBudgetDialog(context, category, budget),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                                    onPressed: () => _confirmDeleteCategory(context, category),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSetTotalBudgetDialog(BuildContext context, MonthlyBudget? currentBudget) async {
    final controller = TextEditingController(text: currentBudget?.totalAmount.toString() ?? '5000');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Total Monthly Budget'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Enter total amount', prefixText: '\$'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newTotal = double.tryParse(controller.text) ?? 5000.0;
              await _updateTotalBudget(newTotal, currentBudget);
              if (mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateTotalBudget(double newTotal, MonthlyBudget? currentBudget) async {
    final monthStr = DateFormat('yyyy-MM').format(DateTime.now());
    final newBudget = MonthlyBudget(
      id: currentBudget?.id ?? 'budget_$monthStr',
      month: currentBudget?.month ?? monthStr,
      totalAmount: newTotal,
      categoryBudgets: currentBudget?.categoryBudgets ?? [],
    );

    try {
      await ref.read(budgetRepositoryProvider).setMonthlyBudget(newBudget);
      ref.invalidate(currentMonthBudgetProvider);
    } catch (e) {
      debugPrint("Error updating total budget: $e");
    }
  }

  Future<void> _confirmDeleteCategory(BuildContext context, Category category) async {
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"? This will not delete expenses in this category but will remove the budget allocation.'),
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
        await ref.read(categoryRepositoryProvider).deleteCategory(category.id);
        ref.invalidate(allCategoriesProvider);
      } catch (e) {
        debugPrint("Error deleting category: $e");
      }
    }
  }

  Future<void> _showSetBudgetDialog(BuildContext context, Category category, MonthlyBudget? currentBudget) async {
    final controller = TextEditingController(
      text: currentBudget?.categoryBudgets
              .where((cb) => cb.categoryId == category.id)
              .firstOrNull
              ?.amount
              .toString() ??
          '',
    );

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Set Budget for ${category.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Enter amount', prefixText: '\$'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newAmount = double.tryParse(controller.text) ?? 0.0;
              await _updateBudget(category.id, newAmount, currentBudget);
              if (mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateBudget(String categoryId, double amount, MonthlyBudget? currentBudget) async {
    final monthStr = _currentMonthStr;
    
    // 1. Get or Create Monthly Budget for this month
    MonthlyBudget budget;
    if (currentBudget == null) {
      budget = MonthlyBudget(
        id: 'budget_$monthStr',
        month: monthStr,
        totalAmount: 5000.0, // Default total budget
        categoryBudgets: [],
      );
    } else {
      budget = currentBudget;
    }

    // 2. Sum existing allocations EXCEPT the one we are updating
    final otherAllocationsSum = budget.categoryBudgets
        .where((cb) => cb.categoryId != categoryId)
        .fold(0.0, (sum, cb) => sum + cb.amount);

    // 3. Validation
    if (otherAllocationsSum + amount > budget.totalAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Total category budgets (\$${(otherAllocationsSum + amount).toStringAsFixed(2)}) would exceed monthly budget (\$${budget.totalAmount.toStringAsFixed(2)})'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 4. Update/Add allocation
    final updatedAllocations = List<CategoryBudget>.from(budget.categoryBudgets);
    final existingIdx = updatedAllocations.indexWhere((cb) => cb.categoryId == categoryId);
    
    if (existingIdx != -1) {
      updatedAllocations[existingIdx] = CategoryBudgetModel(
        id: updatedAllocations[existingIdx].id,
        monthlyBudgetId: budget.id,
        categoryId: categoryId,
        amount: amount,
      );
    } else {
      updatedAllocations.add(CategoryBudgetModel(
        id: const Uuid().v4(),
        monthlyBudgetId: budget.id,
        categoryId: categoryId,
        amount: amount,
      ));
    }

    final newBudget = MonthlyBudget(
      id: budget.id,
      month: budget.month,
      totalAmount: budget.totalAmount,
      categoryBudgets: updatedAllocations,
    );

    try {
      await ref.read(budgetRepositoryProvider).setMonthlyBudget(newBudget);
      ref.invalidate(currentMonthBudgetProvider);
      ref.invalidate(allMonthlyBudgetsProvider);
    } catch (e) {
      debugPrint("Error updating category budget: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating budget: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
