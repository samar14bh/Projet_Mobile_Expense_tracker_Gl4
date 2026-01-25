import 'package:flutter/foundation.dart';
import '../../domain/entities/statistics.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../datasources/statistics/statistics_local_datasource.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  final StatisticsLocalDataSource localDataSource;

  StatisticsRepositoryImpl({required this.localDataSource});

  @override
  Future<List<CategorySpending>> getCategorySpending(DateTime month) async {
    try {
      return await localDataSource.getCategorySpending(month);
    } catch (e) {
      debugPrint("Error fetching category spending: $e");
      return [];
    }
  }

  @override
  Future<List<DailySpending>> getDailySpending(DateTime month) async {
    try {
      return await localDataSource.getDailySpending(month);
    } catch (e) {
      debugPrint("Error fetching daily spending: $e");
      return [];
    }
  }

  @override
  Future<MonthlySummary> getMonthlySummary(DateTime month) async {
    try {
      return await localDataSource.getMonthlySummary(month);
    } catch (e) {
      debugPrint("Error fetching monthly summary: $e");
      // Return empty summary on error
      return MonthlySummary(
        totalSpending: 0,
        averageDailySpending: 0,
        highestDailySpending: 0,
        highestSpendingCategory: 'None',
        transactionCount: 0,
        peakDayOfWeek: 'None',
        consistencyScore: 0,
      );
    }
  }

  @override
  Future<List<WeeklySpending>> getWeeklySpending(DateTime month) async {
    try {
      return await localDataSource.getWeeklySpending(month);
    } catch (e) {
      debugPrint("Error fetching weekly spending: $e");
      return [];
    }
  }

  @override
  Future<List<BudgetPerformance>> getBudgetPerformance(DateTime month) async {
    try {
      return await localDataSource.getBudgetPerformance(month);
    } catch (e) {
      debugPrint("Error fetching budget performance: $e");
      return [];
    }
  }

  @override
  Future<AdvancedInsights> getAdvancedInsights(DateTime month) async {
    try {
      return await localDataSource.getAdvancedInsights(month);
    } catch (e) {
      debugPrint("Error fetching advanced insights: $e");
      return AdvancedInsights(
        fixedCosts: 0,
        variableCosts: 0,
        purchaseSizeDistribution: {'Small': 0, 'Medium': 0, 'Large': 0},
        spendingVelocity: 0,
        categoryDominance: 0,
      );
    }
  }

  @override
  Future<List<SmartInsight>> getSmartInsights(DateTime month) async {
    try {
      return await localDataSource.getSmartInsights(month);
    } catch (e) {
      debugPrint("Error fetching smart insights: $e");
      return [];
    }
  }

  @override
  Future<String> generateCsvReport(DateTime month) async {
    try {
      final categorySpending = await localDataSource.getCategorySpending(month);
      final dailySpending = await localDataSource.getDailySpending(month);
      final summary = await localDataSource.getMonthlySummary(month);

      StringBuffer csvData = StringBuffer();
      
      // Header
      csvData.writeln('Expense Report for ${DateFormat('MMMM yyyy').format(month)}');
      csvData.writeln('Generated on ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}');
      csvData.writeln('');

      // Summary
      csvData.writeln('Summary');
      csvData.writeln('Total Spending,${summary.totalSpending.toStringAsFixed(2)}');
      csvData.writeln('Average Daily,${summary.averageDailySpending.toStringAsFixed(2)}');
      csvData.writeln('Highest Category,${summary.highestSpendingCategory}');
      csvData.writeln('');

      // Category Breakdown
      csvData.writeln('Category Breakdown');
      csvData.writeln('Category,Amount,Percentage');
      for (var item in categorySpending) {
        csvData.writeln('${item.categoryName},${item.totalAmount.toStringAsFixed(2)},${item.percentage.toStringAsFixed(1)}%');
      }
      csvData.writeln('');

      // Daily Breakdown
      csvData.writeln('Daily Spending');
      csvData.writeln('Date,Amount');
      for (var item in dailySpending) {
        csvData.writeln('${DateFormat('yyyy-MM-dd').format(item.date)},${item.totalAmount.toStringAsFixed(2)}');
      }

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/report_${DateFormat('yyyy_MM').format(month)}.csv';
      final file = File(path);
      await file.writeAsString(csvData.toString());

      return path;
    } catch (e) {
      debugPrint("Error generating CSV: $e");
      throw Exception("Failed to generate report");
    }
  }
}
