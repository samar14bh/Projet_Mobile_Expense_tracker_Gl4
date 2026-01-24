import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/routes/route_names.dart';
import '../widgets/app_bar.dart';
import '../widgets/side_menu.dart';
import 'home_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Expense Tracker'),
      drawer: SideMenu(),
      body: const HomeScreen(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, RouteNames.addExpense);
        },
        backgroundColor: AppTheme.primaryPurple,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Theme.of(context).cardTheme.color,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home_filled, color: Theme.of(context).colorScheme.primary),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(
                Icons.account_balance_wallet_outlined,
                color: Theme.of(context).brightness == Brightness.light ? AppTheme.textLight : Colors.grey[400],
              ),
              onPressed: () => Navigator.pushNamed(context, RouteNames.categories),
            ),
            const SizedBox(width: 40),
            IconButton(
              icon: Icon(
                Icons.bar_chart_outlined,
                color: Theme.of(context).brightness == Brightness.light ? AppTheme.textLight : Colors.grey[400],
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(
                Icons.person_outline,
                color: Theme.of(context).brightness == Brightness.light ? AppTheme.textLight : Colors.grey[400],
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
