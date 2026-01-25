import 'package:flutter/material.dart';

class CategorySpending {
  final String categoryId;
  final String categoryName;
  final Color color;
  final double totalAmount;
  final double percentage;
  final IconData? icon;

  CategorySpending({
    required this.categoryId,
    required this.categoryName,
    required this.color,
    required this.totalAmount,
    required this.percentage,
    this.icon,
  });
}

class DailySpending {
  final DateTime date;
  final double totalAmount;

  DailySpending({
    required this.date,
    required this.totalAmount,
  });
}

class MonthlySummary {
  final double totalSpending;
  final double averageDailySpending;
  final double highestDailySpending;
  final String highestSpendingCategory;
  final int transactionCount;
  final DateTime? highestDay;
  final DateTime? lowestDay;
  final String peakDayOfWeek;
  final double consistencyScore; // 0-1 (1 being very consistent daily spending)

  MonthlySummary({
    required this.totalSpending,
    required this.averageDailySpending,
    required this.highestDailySpending,
    required this.highestSpendingCategory,
    required this.transactionCount,
    this.highestDay,
    this.lowestDay,
    required this.peakDayOfWeek,
    required this.consistencyScore,
  });
}

class AdvancedInsights {
  final double fixedCosts; // Recurring
  final double variableCosts; // One-time
  final Map<String, int> purchaseSizeDistribution; // 'Small', 'Medium', 'Large'
  final double spendingVelocity; // % change vs previous month
  final double categoryDominance; // % of top category

  AdvancedInsights({
    required this.fixedCosts,
    required this.variableCosts,
    required this.purchaseSizeDistribution,
    required this.spendingVelocity,
    required this.categoryDominance,
  });
}

class SmartInsight {
  final String title;
  final String message;
  final IconData icon;
  final Color color;

  SmartInsight({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });
}

class WeeklySpending {
  final int weekNumber;
  final String label;
  final double totalAmount;

  WeeklySpending({
    required this.weekNumber,
    required this.label,
    required this.totalAmount,
  });
}

class BudgetPerformance {
  final String categoryName;
  final double budgetLimit;
  final double actualSpending;
  final double percentage;

  BudgetPerformance({
    required this.categoryName,
    required this.budgetLimit,
    required this.actualSpending,
  }) : percentage = budgetLimit > 0 ? (actualSpending / budgetLimit) * 100 : 0;
}

