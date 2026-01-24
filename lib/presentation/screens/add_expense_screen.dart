import 'dart:io';
import 'package:expense_tracker/data/models/category_budget_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../core/theme/app_theme.dart';
import '../../domain/entities/expense.dart';
import '../providers/expense_providers.dart';
import '../providers/budget_providers.dart';
import '../providers/category_providers.dart';


import 'package:permission_handler/permission_handler.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final Expense? expenseToEdit;
  const AddExpenseScreen({super.key, this.expenseToEdit});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  late DateTime _selectedDate;
  String? _selectedCategoryId;
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.expenseToEdit?.amount.toString() ?? '');
    _notesController = TextEditingController(text: widget.expenseToEdit?.notes ?? '');
    _selectedDate = widget.expenseToEdit?.date ?? DateTime.now();
    _selectedCategoryId = widget.expenseToEdit?.categoryId;
    if (widget.expenseToEdit?.receiptPath != null) {
      _pickedImage = File(widget.expenseToEdit!.receiptPath!);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    // Permission Handling
    PermissionStatus status;
    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    } else {
      status = Platform.isAndroid 
          ? await Permission.storage.request() 
          : await Permission.photos.request();
    }

    if (status.isPermanentlyDenied) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Permission Denied'),
            content: const Text('Please enable camera/gallery permissions in settings to use this feature.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              TextButton(onPressed: () => openAppSettings(), child: const Text('Settings')),
            ],
          ),
        );
      }
      return;
    }

    if (!status.isGranted) return;

    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() => _pickedImage = File(image.path));
    }
  }

  Future<void> _saveExpense() async {
    if (_amountController.text.isEmpty || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter amount and select category')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null) return;

    // --- Budget Validation (Only if not editing or amount increased) ---
    final monthStr = DateFormat('yyyy-MM').format(_selectedDate);
    final budget = await ref.read(budgetRepositoryProvider).getBudgetForMonth(monthStr);
    
    if (budget != null) {
      final catBudget = budget.categoryBudgets.firstWhere(
        (cb) => cb.categoryId == _selectedCategoryId,
        orElse: () => CategoryBudgetModel(
          id: '',
          monthlyBudgetId: budget.id,
          categoryId: _selectedCategoryId!,
          amount: 0.0,
        ),
      );

      final expenses = await ref.read(expenseRepositoryProvider).getExpenses();
      final spentInCategory = expenses
          .where((e) =>
              e.id != widget.expenseToEdit?.id && // Exclude self if editing
              e.categoryId == _selectedCategoryId &&
              DateFormat('yyyy-MM').format(e.date) == monthStr)
          .fold(0.0, (sum, e) => sum + e.amount);

      if (spentInCategory + amount > catBudget.amount) {
        final proceed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Budget Exceeded'),
            content: Text(
                'This expense exceeds your category budget of \$${catBudget.amount.toStringAsFixed(2)}. Spent: \$${spentInCategory.toStringAsFixed(2)}. Proceed anyway?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Proceed')),
            ],
          ),
        );
        if (proceed != true) return;
      }
    }

    // --- Image Handling & Saving ---
    try {
      String? finalImagePath = widget.expenseToEdit?.receiptPath;
      
      // If a NEW image was picked, copy it. 
      // check if the path is different from existing one or if it was null before
      if (_pickedImage != null && _pickedImage?.path != widget.expenseToEdit?.receiptPath) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = p.basename(_pickedImage!.path);
        final savedImage = await _pickedImage!.copy('${appDir.path}/$fileName');
        finalImagePath = savedImage.path;
      }

      final expense = Expense(
        id: widget.expenseToEdit?.id ?? const Uuid().v4(),
        amount: amount,
        date: _selectedDate,
        categoryId: _selectedCategoryId!,
        notes: _notesController.text,
        receiptPath: finalImagePath,
      );

      if (widget.expenseToEdit != null) {
        await ref.read(expenseRepositoryProvider).updateExpense(expense);
      } else {
        await ref.read(expenseRepositoryProvider).addExpense(expense);
      }
      
      ref.invalidate(currentMonthExpensesProvider);
      ref.invalidate(allExpensesProvider);
      
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Fatal error in _saveExpense: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving expense: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(allCategoriesProvider);
    final isEditing = widget.expenseToEdit != null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Expense' : 'Add Expense'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount Input
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.light ? 0.05 : 0.1), blurRadius: 10)
                  ],
                ),
                child: Column(
                  children: [
                    Text('Amount', style: Theme.of(context).textTheme.bodyMedium),
                    TextField(
                      controller: _amountController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppTheme.primaryPurple),
                      decoration: const InputDecoration(
                        hintText: '0.00',
                        border: InputBorder.none,
                        prefixText: '\$',
                      ),
                    ),
                  ],
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
                          color: isSelected ? cat.color : Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isSelected ? cat.color : (Theme.of(context).brightness == Brightness.light ? Colors.grey[200]! : Colors.grey[800]!)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(cat.icon, size: 18, color: isSelected ? Colors.white : cat.color),
                            const SizedBox(width: 8),
                              Text(
                                cat.name,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
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

              // Date Picker
              const Text('Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20, color: AppTheme.primaryPurple),
                      const SizedBox(width: 12),
                      Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Notes
              const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  hintText: 'Add a note...',
                  filled: true,
                  fillColor: Theme.of(context).cardTheme.color,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 24),
              // Receipt UI
              const Text('Receipt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    if (_pickedImage != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_pickedImage!, height: 150, width: double.infinity, fit: BoxFit.cover),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Camera'),
                        ),
                        TextButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.image_outlined),
                          label: const Text('Gallery'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _saveExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  child: const Text('Save Expense', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
