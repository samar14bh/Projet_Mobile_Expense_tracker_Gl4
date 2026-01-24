import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/category.dart';
import '../providers/category_providers.dart';
import '../../core/theme/app_theme.dart';
import '../screens/expense_details_screen.dart';

class ExpenseTile extends ConsumerWidget {
  final Expense expense;
  final Category? category;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const ExpenseTile({
    super.key,
    required this.expense,
    this.category,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If category is not provided, look it up from the provider
    final categoriesAsync = ref.watch(allCategoriesProvider);
    
    return categoriesAsync.when(
      data: (categories) {
        final displayCategory = category ?? categories.firstWhere(
          (c) => c.id == expense.categoryId,
          orElse: () => categories.first,
        );

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ExpenseDetailsScreen(
                  expense: expense,
                  category: displayCategory,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(12),
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
                    color: displayCategory.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(displayCategory.icon, color: displayCategory.color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayCategory.name,
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        expense.notes == null || expense.notes!.isEmpty ? 'No notes' : expense.notes!,
                        style: context.textTheme.bodyMedium?.copyWith(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '-\$${expense.amount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent),
                    ),
                    Text(
                      DateFormat('MMM dd').format(expense.date),
                      style: context.textTheme.bodyMedium?.copyWith(fontSize: 10),
                    ),
                  ],
                ),
                if (onEdit != null || onDelete != null)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, size: 18, color: context.textTheme.bodyMedium?.color),
                    onSelected: (value) {
                      if (value == 'edit' && onEdit != null) onEdit!();
                      if (value == 'delete' && onDelete != null) onDelete!();
                    },
                    itemBuilder: (context) => [
                      if (onEdit != null)
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                      if (onDelete != null)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox(height: 70, child: Center(child: CircularProgressIndicator())),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
