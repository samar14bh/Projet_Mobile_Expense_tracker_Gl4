import 'package:flutter/material.dart';
import 'package:expense_tracker/presentation/screens/categories_screen.dart';
import 'package:expense_tracker/presentation/screens/add_expense_screen.dart';
import 'package:expense_tracker/presentation/screens/all_expenses_screen.dart';
import 'package:expense_tracker/presentation/screens/statistics_screen.dart';
import 'package:expense_tracker/presentation/screens/security_settings_screen.dart';
import '../../presentation/widgets/secure_app_wrapper.dart';
import 'route_names.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.home:
        return MaterialPageRoute(
          builder: (_) => const SecureAppWrapper(),
        );
      
      case RouteNames.addExpense:
        return MaterialPageRoute(
          builder: (_) => const AddExpenseScreen(),
        );

      case RouteNames.categories:
        return MaterialPageRoute(
          builder: (_) => const CategoriesScreen(),
        );

      case RouteNames.allExpenses:
        return MaterialPageRoute(
          builder: (_) => const AllExpensesScreen(),
        );

      case RouteNames.statistics:
        return MaterialPageRoute(
          builder: (_) => const StatisticsScreen(),
        );

      case RouteNames.securitySettings:
        return MaterialPageRoute(
          builder: (_) => const SecuritySettingsScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
