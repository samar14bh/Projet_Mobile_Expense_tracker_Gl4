import '../entities/statistics.dart';

abstract class StatisticsRepository {
  Future<List<CategorySpending>> getCategorySpending(DateTime month);
  Future<List<DailySpending>> getDailySpending(DateTime month);
  Future<List<WeeklySpending>> getWeeklySpending(DateTime month);
  Future<List<BudgetPerformance>> getBudgetPerformance(DateTime month);
  Future<MonthlySummary> getMonthlySummary(DateTime month);
  Future<AdvancedInsights> getAdvancedInsights(DateTime month);
  Future<List<SmartInsight>> getSmartInsights(DateTime month);
  Future<String> generateCsvReport(DateTime month);
}
