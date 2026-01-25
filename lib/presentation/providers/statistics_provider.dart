import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/statistics.dart';
import '../../data/datasources/statistics/statistics_local_datasource.dart';
import 'package:open_filex/open_filex.dart';
import '../../data/repositoriesImpl/statistics_repository_impl.dart';
import '../../core/services/export_service.dart';

// Repository Provider
final statisticsRepositoryProvider = Provider<StatisticsRepositoryImpl>((ref) {
  return StatisticsRepositoryImpl(
    localDataSource: StatisticsLocalDataSource(),
  );
});

// State for selected month
final selectedMonthProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

// Category Spending Future Provider
final categorySpendingProvider = FutureProvider.autoDispose<List<CategorySpending>>((ref) async {
  final repository = ref.watch(statisticsRepositoryProvider);
  final month = ref.watch(selectedMonthProvider);
  return repository.getCategorySpending(month);
});

// Daily Spending Future Provider
final dailySpendingProvider = FutureProvider.autoDispose<List<DailySpending>>((ref) async {
  final repository = ref.watch(statisticsRepositoryProvider);
  final month = ref.watch(selectedMonthProvider);
  return repository.getDailySpending(month);
});

// Monthly Summary Future Provider
final monthlySummaryProvider = FutureProvider.autoDispose<MonthlySummary>((ref) async {
  final repository = ref.watch(statisticsRepositoryProvider);
  final month = ref.watch(selectedMonthProvider);
  return repository.getMonthlySummary(month);
});

// Weekly Spending Future Provider
final weeklySpendingProvider = FutureProvider.autoDispose<List<WeeklySpending>>((ref) async {
  final repository = ref.watch(statisticsRepositoryProvider);
  final month = ref.watch(selectedMonthProvider);
  return repository.getWeeklySpending(month);
});

// Budget Performance Future Provider
final budgetPerformanceProvider = FutureProvider.autoDispose<List<BudgetPerformance>>((ref) async {
  final repository = ref.watch(statisticsRepositoryProvider);
  final month = ref.watch(selectedMonthProvider);
  return repository.getBudgetPerformance(month);
});



// Export Service Provider
final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService();
});

// Generate Export Provider
final generateExportProvider = FutureProvider.family<String, ({DateTime month, ExportFormat format, ExportScope scope})>((ref, params) async {
  final exportService = ref.read(exportServiceProvider);
  final repository = ref.read(statisticsRepositoryProvider);
  
  // Fetch all necessary data
  final summary = await repository.getMonthlySummary(params.month);
  final categorySpending = await repository.getCategorySpending(params.month);
  final dailySpending = await repository.getDailySpending(params.month);

  return exportService.generateExport(
    format: params.format,
    scope: params.scope,
    month: params.month,
    summary: summary,
    categorySpending: categorySpending,
    dailySpending: dailySpending,
  );
});

// Old provider kept for backward compatibility if needed, but we should migrate.
// CSV Export Provider
final exportReportProvider = FutureProvider.family<String, DateTime>((ref, month) async {
  final repository = ref.read(statisticsRepositoryProvider);
  return repository.generateCsvReport(month);
});



// Advanced Insights Future Provider
final advancedInsightsProvider = FutureProvider.autoDispose<AdvancedInsights>((ref) async {
  final repository = ref.watch(statisticsRepositoryProvider);
  final month = ref.watch(selectedMonthProvider);
  return repository.getAdvancedInsights(month);
});

// Smart Insights Future Provider
final smartInsightsProvider = FutureProvider.autoDispose<List<SmartInsight>>((ref) async {
  final repository = ref.watch(statisticsRepositoryProvider);
  final month = ref.watch(selectedMonthProvider);
  return repository.getSmartInsights(month);
});

// Open Report Function
Future<void> openReport(String path) async {
  await OpenFilex.open(path);
}
