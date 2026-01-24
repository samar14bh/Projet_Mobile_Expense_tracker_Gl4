import 'package:expense_tracker/data/datasources/seed_data.dart';
import 'package:expense_tracker/presentation/providers/budget_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/routes/route_names.dart';
import '../screens/notification_settings_screen.dart';
import '../screens/recurring_expenses_screen.dart';
import '../providers/expense_providers.dart';
import '../providers/category_providers.dart';

class SideMenu extends ConsumerWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30,
                  child: Icon(Icons.person, size: 35, color: Colors.blueGrey),
                ),
                const SizedBox(height: 10),
                Text(
                  'Expense Tracker',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, RouteNames.home);
            },
          ),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('Categories'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, RouteNames.categories);
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add Expense'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, RouteNames.addExpense);
            },
          ),
          ListTile(
            leading: const Icon(Icons.repeat),
            title: const Text('Recurring Expenses'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RecurringExpensesScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              themeMode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode,
            ),
            title: Text(themeMode == ThemeMode.light ? 'Dark Mode' : 'Light Mode'),
            trailing: Switch(
              value: themeMode == ThemeMode.dark,
              onChanged: (_) {
                ref.read(themeProvider.notifier).toggleTheme();
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.restart_alt, color: Colors.redAccent),
            title: const Text('Restart App', style: TextStyle(color: Colors.redAccent)),
            onTap: () async {
              Navigator.pop(context);
              
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Reset All Data'),
                  content: const Text(
                    'Are you sure you want to delete EVERYTHING? This will remove all your expenses and categories. This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Reset', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                // 1. Force re-seed database (clears everything and adds defaults)
                await DatabaseSeeder.reseed();
                
                // 2. Invalidate all Riverpod providers to force UI refresh
                ref.invalidate(allExpensesProvider);
                ref.invalidate(currentMonthExpensesProvider);
                ref.invalidate(allCategoriesProvider);
                ref.invalidate(currentMonthBudgetProvider);
                ref.invalidate(allMonthlyBudgetsProvider);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('App data has been fully reset')),
                  );
                  // 3. Navigate to home to ensure fresh state
                  Navigator.pushReplacementNamed(context, RouteNames.home);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
