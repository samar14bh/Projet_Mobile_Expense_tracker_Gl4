import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/recurring_expense.dart';
import '../providers/category_providers.dart';
import '../../core/theme/app_theme.dart';

class AddRecurringExpenseScreen extends ConsumerStatefulWidget {
  final RecurringExpense? expenseToEdit;
  
  const AddRecurringExpenseScreen({super.key, this.expenseToEdit});

  @override
  ConsumerState<AddRecurringExpenseScreen> createState() => _AddRecurringExpenseScreenState();
}

class _AddRecurringExpenseScreenState extends ConsumerState<AddRecurringExpenseScreen> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  String? _selectedCategoryId;
  int _selectedDay = 1;
  DateTime _startDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.expenseToEdit?.name ?? '');
    _amountController = TextEditingController(text: widget.expenseToEdit?.amount.toString() ?? '');
    _notesController = TextEditingController(text: widget.expenseToEdit?.notes ?? '');
    _selectedCategoryId = widget.expenseToEdit?.categoryId;
    _selectedDay = widget.expenseToEdit?.dayOfMonth ?? DateTime.now().day;
    _startDate = widget.expenseToEdit?.startDate ?? DateTime.now();
  }

  // ... (dispose)

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Select Start Month',
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  void _saveRecurringExpense() {
    if (_nameController.text.isEmpty || _amountController.text.isEmpty || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null) return;

    final recurringExpense = RecurringExpense(
      id: widget.expenseToEdit?.id ?? const Uuid().v4(),
      name: _nameController.text,
      amount: amount,
      categoryId: _selectedCategoryId!,
      dayOfMonth: _selectedDay,
      startDate: _startDate,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      isActive: true,
      createdAt: widget.expenseToEdit?.createdAt ?? DateTime.now(),
    );

    Navigator.pop(context, recurringExpense);
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.expenseToEdit != null ? 'Edit Recurring Expense' : 'Add Recurring Expense'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ... (Name, Amount, Category inputs remain same) ...
              // Name Input
              const Text('Expense Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'e.g., Netflix Subscription, Rent',
                ),
              ),

              const SizedBox(height: 24),

              // Amount Input
              const Text('Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: context.theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [context.tokens.cardShadow],
                ),
                child: TextField(
                  controller: _amountController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryPurple),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    border: InputBorder.none,
                    prefixText: '\$',
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Category Picker
              const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              categoriesAsync.when(
                data: (categories) => Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: categories.map((cat) {
                    final isSelected = _selectedCategoryId == cat.id;
                    return InkWell(
                      onTap: () => setState(() => _selectedCategoryId = cat.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? cat.color : context.theme.cardTheme.color,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isSelected ? cat.color : (context.theme.brightness == Brightness.light ? Colors.grey[200]! : Colors.grey[800]!)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(cat.icon, size: 18, color: isSelected ? Colors.white : cat.color),
                            const SizedBox(width: 8),
                            Text(
                              cat.name,
                              style: TextStyle(
                                color: isSelected ? Colors.white : context.textTheme.bodyLarge?.color,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
              ),

              const SizedBox(height: 24),
              
              // Billing Day & Start Date Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Billing Day', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: context.theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _selectedDay,
                              isExpanded: true,
                              items: List.generate(31, (index) => index + 1)
                                  .map((day) => DropdownMenuItem(value: day, child: Text('Day $day')))
                                  .toList(),
                              onChanged: (value) => setState(() => _selectedDay = value!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Start From', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _selectStartDate,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: context.theme.cardTheme.color,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_month, size: 18, color: AppTheme.primaryPurple),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    // Only show Month/Year as specific day is 'Billing Day'
                                    '${_monthName(_startDate.month)} ${_startDate.year}',
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              // Helper text explaining when it will be added
              if (_willBeAddedImmediately())
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Since this billing date has passed for this month, an expense will be added IMMEDIATELY upon saving.',
                          style: TextStyle(color: Colors.deepOrange, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Notes
              const Text('Notes (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  hintText: 'Add any additional details...',
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _saveRecurringExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  child: const Text('Save Recurring Expense', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
  
  bool _willBeAddedImmediately() {
    final now = DateTime.now();
    // If start date is in a future month, NO
    if (_startDate.year > now.year || (_startDate.year == now.year && _startDate.month > now.month)) {
      return false;
    }
    // If we are in the start month (or past it), check the day
    // If today is past the selected billing day, we missed it -> add immediately
    if (now.day >= _selectedDay) {
      return true;
    }
    return false;
  }
}
