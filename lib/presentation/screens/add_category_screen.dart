import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/category.dart';
import '../providers/category_providers.dart';

class AddCategoryScreen extends ConsumerStatefulWidget {
  final Category? categoryToEdit;
  const AddCategoryScreen({super.key, this.categoryToEdit});

  @override
  ConsumerState<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends ConsumerState<AddCategoryScreen> {
  late TextEditingController _nameController;
  late Color _selectedColor;
  late IconData _selectedIcon;

  final List<Color> _colors = [
    AppTheme.primaryPurple,
    AppTheme.accentPink,
    Colors.orange,
    Colors.teal,
    Colors.blue,
    Colors.red,
    Colors.amber,
    Colors.green,
  ];

  final List<IconData> _icons = [
    Icons.restaurant,
    Icons.directions_car,
    Icons.home,
    Icons.movie,
    Icons.shopping_bag,
    Icons.health_and_safety,
    Icons.school,
    Icons.fitness_center,
    Icons.flight,
    Icons.work,
    Icons.savings,
    Icons.category_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.categoryToEdit?.name ?? '');
    _selectedColor = widget.categoryToEdit?.color ?? AppTheme.primaryPurple;
    _selectedIcon = widget.categoryToEdit?.icon ?? Icons.category_rounded;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name')),
      );
      return;
    }

    final category = Category(
      id: widget.categoryToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      color: _selectedColor,
      icon: _selectedIcon,
    );

    try {
      if (widget.categoryToEdit != null) {
        await ref.read(categoryRepositoryProvider).updateCategory(category);
      } else {
        await ref.read(categoryRepositoryProvider).addCategory(category);
      }
      ref.invalidate(allCategoriesProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Error saving category: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving category: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.categoryToEdit != null;

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Category' : 'Add Category'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Field: Name
              const Text('Category Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Shopping',
                ),
              ),
              const SizedBox(height: 24),

              // Color Picker
              const Text('Color', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _colors.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final color = _colors[index];
                    final isSelected = _selectedColor.value == color.value;
                    return InkWell(
                      onTap: () => setState(() => _selectedColor = color),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                          boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10)] : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Icon Picker
              const Text('Icon', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _icons.length,
                itemBuilder: (context, index) {
                  final icon = _icons[index];
                  final isSelected = _selectedIcon.codePoint == icon.codePoint;
                  return InkWell(
                    onTap: () => setState(() => _selectedIcon = icon),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? _selectedColor : context.theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected ? Colors.white : context.textTheme.bodyMedium?.color,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _saveCategory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  child: Text(
                    isEditing ? 'Update Category' : 'Save Category',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
