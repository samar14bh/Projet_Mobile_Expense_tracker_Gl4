import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import '../../models/category_model.dart';
import '../app_database.dart';
import '../../../domain/entities/statistics.dart';

class StatisticsLocalDataSource {
  Future<Database> get _db async => await AppDatabase.init();

  Future<List<CategorySpending>> getCategorySpending(DateTime month) async {
    final db = await _db;
    final startOfMonth = DateTime(month.year, month.month, 1).toIso8601String();
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59).toIso8601String();

    final result = await db.rawQuery('''
      SELECT 
        c.id, 
        c.name, 
        c.color, 
        c.icon, 
        SUM(e.amount) as total
      FROM expenses e
      JOIN categories c ON e.categoryId = c.id
      WHERE e.date BETWEEN ? AND ?
      GROUP BY c.id
    ''', [startOfMonth, endOfMonth]);

    double totalExpenses = 0.0;
    for (var row in result) {
      totalExpenses += (row['total'] as num).toDouble();
    }
    
    // Avoid division by zero
    if (totalExpenses == 0) totalExpenses = 1;

    return result.map((row) {
      final total = (row['total'] as num).toDouble();
      return CategorySpending(
        categoryId: row['id'] as String,
        categoryName: row['name'] as String,
        color: Color(int.parse(row['color'] as String)),
        totalAmount: total,
        percentage: (total / totalExpenses) * 100,
        icon: IconData(row['icon'] as int, fontFamily: 'MaterialIcons'),
      );
    }).toList();
  }

  Future<List<DailySpending>> getDailySpending(DateTime month) async {
    final db = await _db;
    final startOfMonth = DateTime(month.year, month.month, 1).toIso8601String();
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59).toIso8601String();

    final result = await db.rawQuery('''
      SELECT 
        date(substr(date, 1, 10)) as day, 
        SUM(amount) as total
      FROM expenses
      WHERE date BETWEEN ? AND ?
      GROUP BY day
      ORDER BY day ASC
    ''', [startOfMonth, endOfMonth]);

    return result.map((row) {
      return DailySpending(
        date: DateTime.parse(row['day'] as String),
        totalAmount: (row['total'] as num).toDouble(),
      );
    }).toList();
  }

  Future<MonthlySummary> getMonthlySummary(DateTime month) async {
    final db = await _db;
    final startOfMonth = DateTime(month.year, month.month, 1).toIso8601String();
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59).toIso8601String();

    // 1. Total Spending & Transaction Count
    final basicStatsResult = await db.rawQuery('''
      SELECT SUM(amount) as total, COUNT(*) as count 
      FROM expenses 
      WHERE date BETWEEN ? AND ?
    ''', [startOfMonth, endOfMonth]);
    
    final totalSpending = (basicStatsResult.first['total'] as num?)?.toDouble() ?? 0.0;
    final transactionCount = (basicStatsResult.first['count'] as int?) ?? 0;

    // 2. Daily Totals for Peaks & Consistency
    final dailyTotalsResult = await db.rawQuery('''
      SELECT date(substr(date, 1, 10)) as day, SUM(amount) as daily_total
      FROM expenses
      WHERE date BETWEEN ? AND ?
      GROUP BY day
      ORDER BY daily_total DESC
    ''', [startOfMonth, endOfMonth]);

    DateTime? highestDay;
    DateTime? lowestDay;
    double highestDaily = 0.0;
    
    if (dailyTotalsResult.isNotEmpty) {
      highestDay = DateTime.parse(dailyTotalsResult.first['day'] as String);
      highestDaily = (dailyTotalsResult.first['daily_total'] as num).toDouble();
      lowestDay = DateTime.parse(dailyTotalsResult.last['day'] as String);
    }

    // 3. Highest Category
    final categoryResult = await db.rawQuery('''
      SELECT c.name, SUM(e.amount) as total
      FROM expenses e
      JOIN categories c ON e.categoryId = c.id
      WHERE e.date BETWEEN ? AND ?
      GROUP BY c.id
      ORDER BY total DESC
      LIMIT 1
    ''', [startOfMonth, endOfMonth]);
    
    final highestCategory = categoryResult.isNotEmpty 
        ? categoryResult.first['name'] as String 
        : 'None';

    // 4. Peak Day of Week
    final dowResult = await db.rawQuery('''
      SELECT strftime('%w', date) as dow, SUM(amount) as total
      FROM expenses
      WHERE date BETWEEN ? AND ?
      GROUP BY dow
      ORDER BY total DESC
      LIMIT 1
    ''', [startOfMonth, endOfMonth]);
    
    final dowNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final peakDayOfWeek = dowResult.isNotEmpty 
        ? dowNames[int.parse(dowResult.first['dow'] as String)]
        : 'None';

    // 5. Consistency Score (based on daily variance)
    double consistencyScore = 1.0;
    if (dailyTotalsResult.length > 1) {
      final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
      final avg = totalSpending / daysInMonth;
      
      double varianceSum = 0;
      for (var row in dailyTotalsResult) {
        final val = (row['daily_total'] as num).toDouble();
        varianceSum += (val - avg) * (val - avg);
      }
      // Filling in zeros for empty days
      final emptyDays = daysInMonth - dailyTotalsResult.length;
      varianceSum += emptyDays * (avg * avg);
      
      final variance = varianceSum / daysInMonth;
      final stdDev = variance > 0 ? (totalSpending > 0 ? (variance / (totalSpending / daysInMonth)) : 0) : 0;
      
      // Consistency = 1 - (Normalized StdDev)
      // We use a log-base approach or a steeper clamp to make it more meaningful
      consistencyScore = (1 - (stdDev / 200)).clamp(0.0, 1.0); 
    }

    return MonthlySummary(
      totalSpending: totalSpending,
      averageDailySpending: totalSpending / DateTime(month.year, month.month + 1, 0).day,
      highestDailySpending: highestDaily,
      highestSpendingCategory: highestCategory,
      transactionCount: transactionCount,
      highestDay: highestDay,
      lowestDay: lowestDay,
      peakDayOfWeek: peakDayOfWeek,
      consistencyScore: consistencyScore,
    );
  }

  Future<List<WeeklySpending>> getWeeklySpending(DateTime month) async {
    final db = await _db;
    final startOfMonth = DateTime(month.year, month.month, 1).toIso8601String();
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59).toIso8601String();

    // SQLite strftime('%W', date) returns week of year 00-53
    // We group by this week number
    final result = await db.rawQuery('''
      SELECT 
        strftime('%W', date) as week_num,
        MIN(date) as start_date,
        SUM(amount) as total
      FROM expenses
      WHERE date BETWEEN ? AND ?
      GROUP BY week_num
      ORDER BY week_num ASC
    ''', [startOfMonth, endOfMonth]);

    int counter = 1;
    return result.map((row) {
      return WeeklySpending(
        weekNumber: counter++,
        label: 'Week ${counter - 1}',
        totalAmount: (row['total'] as num).toDouble(),
      );
    }).toList();
  }

  Future<List<BudgetPerformance>> getBudgetPerformance(DateTime month) async {
    final db = await _db;
    final startOfMonth = DateTime(month.year, month.month, 1).toIso8601String();
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59).toIso8601String();
    final monthStr = "${month.year}-${month.month.toString().padLeft(2, '0')}"; // Format YYYY-MM

    // Simplified query joining directly on the month identifier
    final result = await db.rawQuery('''
      SELECT 
        c.name,
        cb.amount as budget_limit,
        COALESCE(SUM(e.amount), 0) as actual_spending
      FROM category_budgets cb
      JOIN categories c ON cb.categoryId = c.id
      JOIN monthly_budgets mb ON cb.monthlyBudgetId = mb.id
      LEFT JOIN expenses e ON e.categoryId = c.id AND e.date BETWEEN ? AND ?
      WHERE mb.month = ?
      GROUP BY c.id
    ''', [startOfMonth, endOfMonth, monthStr]);

    return result.map((row) {
      return BudgetPerformance(
        categoryName: row['name'] as String,
        budgetLimit: (row['budget_limit'] as num).toDouble(),
        actualSpending: (row['actual_spending'] as num).toDouble(),
      );
    }).toList();
  }

  Future<AdvancedInsights> getAdvancedInsights(DateTime month) async {
    final db = await _db;
    final startOfMonth = DateTime(month.year, month.month, 1).toIso8601String();
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59).toIso8601String();

    // 1. Category Dominance (Share of top category)
    final topCategoryResult = await db.rawQuery('''
      SELECT SUM(amount) as cat_total
      FROM expenses
      WHERE date BETWEEN ? AND ?
      GROUP BY categoryId
      ORDER BY cat_total DESC
      LIMIT 1
    ''', [startOfMonth, endOfMonth]);

    final totalResult = await db.rawQuery('''
      SELECT SUM(amount) as total FROM expenses WHERE date BETWEEN ? AND ?
    ''', [startOfMonth, endOfMonth]);

    final total = (totalResult.first['total'] as num?)?.toDouble() ?? 0.0;
    double categoryDominance = 0;
    if (total > 0 && topCategoryResult.isNotEmpty) {
      categoryDominance = ((topCategoryResult.first['cat_total'] as num).toDouble() / total) * 100;
    }

    // 2. Spending Velocity (% change vs previous month)
    final prevStart = DateTime(month.year, month.month - 1, 1).toIso8601String();
    final prevEnd = DateTime(month.year, month.month, 0, 23, 59, 59).toIso8601String();
    final prevTotalResult = await db.rawQuery('''
      SELECT SUM(amount) as total FROM expenses WHERE date BETWEEN ? AND ?
    ''', [prevStart, prevEnd]);
    final prevTotal = (prevTotalResult.first['total'] as num?)?.toDouble() ?? 0.0;
    
    double velocity = 0;
    if (prevTotal > 0) {
      velocity = ((total - prevTotal) / prevTotal) * 100;
    }

    // 3. Purchase Size Distribution (Small < 20, Medium < 100, Large >= 100)
    final distributionResult = await db.rawQuery('''
      SELECT 
        CASE 
          WHEN amount < 20 THEN 'Small'
          WHEN amount < 100 THEN 'Medium'
          ELSE 'Large'
        END as size,
        COUNT(*) as count
      FROM expenses
      WHERE date BETWEEN ? AND ?
      GROUP BY size
    ''', [startOfMonth, endOfMonth]);

    Map<String, int> distribution = {'Small': 0, 'Medium': 0, 'Large': 0};
    for (var row in distributionResult) {
      distribution[row['size'] as String] = row['count'] as int;
    }

    return AdvancedInsights(
      fixedCosts: 0.0, // Temporary placeholder until migration
      variableCosts: total,
      purchaseSizeDistribution: distribution,
      spendingVelocity: velocity,
      categoryDominance: categoryDominance,
    );
  }

  Future<List<SmartInsight>> getSmartInsights(DateTime month) async {
    // This will be implemented in the presentation layer or a separate service 
    // but we define the repository method here. For now, we'll generate basic ones.
    final summary = await getMonthlySummary(month);
    final insights = await getAdvancedInsights(month);
    
    List<SmartInsight> list = [];
    
    if (insights.spendingVelocity > 10) {
      list.add(SmartInsight(
        title: 'Spending Spike',
        message: 'Your spending is ${insights.spendingVelocity.toStringAsFixed(1)}% higher than last month.',
        icon: Icons.trending_up,
        color: Colors.red,
      ));
    } else if (insights.spendingVelocity < -10) {
      list.add(SmartInsight(
        title: 'Great Savings!',
        message: 'You spent ${insights.spendingVelocity.abs().toStringAsFixed(1)}% less than last month.',
        icon: Icons.trending_down,
        color: Colors.green,
      ));
    }

    if (insights.categoryDominance > 40) {
      list.add(SmartInsight(
        title: 'Category Dominance',
        message: 'Your top category accounts for ${insights.categoryDominance.toStringAsFixed(1)}% of your budget.',
        icon: Icons.pie_chart,
        color: Colors.orange,
      ));
    }

    if (summary.consistencyScore > 0.8) {
      list.add(SmartInsight(
        title: 'Consistent Spending',
        message: 'Your daily spending habits are very stable this month.',
        icon: Icons.check_circle,
        color: Colors.blue,
      ));
    }

    return list;
  }
}
