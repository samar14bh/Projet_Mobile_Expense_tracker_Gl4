import 'package:expense_tracker/presentation/widgets/charts/category_pie_chart.dart';
import 'package:expense_tracker/presentation/widgets/charts/spending_trend_chart.dart';
import 'package:expense_tracker/presentation/widgets/charts/budget_chart.dart';
import 'package:expense_tracker/presentation/widgets/charts/weekly_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/statistics_provider.dart';
import '../../core/services/export_service.dart';
import 'package:open_filex/open_filex.dart';
import '../../domain/entities/statistics.dart';
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: Column(
          children: [
            _PremiumHeader(
              title: 'Financial Analytics',
              selectedMonth: selectedMonth,
              onMonthTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedMonth,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  ref.read(selectedMonthProvider.notifier).state = date;
                }
              },
              onExportTap: () => _showExportDialog(context, ref, selectedMonth),
            ),
            const _SegmentedTabBar(),
            Expanded(
              child: TabBarView(
                children: [
                  _OverviewTab(),
                  _CategoriesTab(),
                  _TrendsTab(),
                  _InsightsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumHeader extends StatelessWidget {
  final String title;
  final DateTime selectedMonth;
  final VoidCallback onMonthTap;
  final VoidCallback onExportTap;

  const _PremiumHeader({
    required this.title,
    required this.selectedMonth,
    required this.onMonthTap,
    required this.onExportTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 16,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.file_upload_outlined, color: Colors.white),
                onPressed: onExportTap,
              ),
            ],
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: onMonthTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 18),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('MMMM yyyy').format(selectedMonth),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentedTabBar extends StatelessWidget {
  const _SegmentedTabBar();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1)),
      ),
      child: TabBar(
        padding: const EdgeInsets.all(5),
        indicator: BoxDecoration(
          color: isDark ? Theme.of(context).primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.3) : Theme.of(context).primaryColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: isDark ? Colors.white : Theme.of(context).primaryColor,
        unselectedLabelColor: isDark ? Colors.white60 : Colors.grey[500],
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        labelPadding: EdgeInsets.zero,
        tabs: const [
          Tab(
            height: 45,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.dashboard_outlined, size: 16),
                SizedBox(width: 4),
                Text('Overview'),
              ],
            ),
          ),
          Tab(
            height: 45,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pie_chart_outline, size: 16),
                SizedBox(width: 4),
                Text('Cats'),
              ],
            ),
          ),
          Tab(
            height: 45,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_graph_outlined, size: 16),
                SizedBox(width: 4),
                Text('Trends'),
              ],
            ),
          ),
          Tab(
            height: 45,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lightbulb_outline, size: 16),
                SizedBox(width: 4),
                Text('Tips'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

  Future<void> _showExportDialog(BuildContext context, WidgetRef ref, DateTime month) async {
    ExportFormat? selectedFormat = ExportFormat.csv;
    ExportScope? selectedScope = ExportScope.summary;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text('Generate Report'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('File Format', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _OptionChip(
                          label: 'Excel',
                          isSelected: selectedFormat == ExportFormat.csv,
                          onTap: () => setState(() => selectedFormat = ExportFormat.csv),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _OptionChip(
                          label: 'PDF',
                          isSelected: selectedFormat == ExportFormat.pdf,
                          onTap: () => setState(() => selectedFormat = ExportFormat.pdf),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Detail Level', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 8),
                  RadioListTile<ExportScope>(
                    title: const Text('Summary Dashboard'),
                    value: ExportScope.summary,
                    groupValue: selectedScope,
                    onChanged: (val) => setState(() => selectedScope = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile<ExportScope>(
                    title: const Text('Detailed Transaction List'),
                    value: ExportScope.detailed,
                    groupValue: selectedScope,
                    onChanged: (val) => setState(() => selectedScope = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                  child: FilledButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      try {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Working on your report...'), duration: Duration(seconds: 1)),
                          );
                        }
                        
                        final path = await ref.read(generateExportProvider((
                          month: month,
                          format: selectedFormat!,
                          scope: selectedScope!
                        )).future);

                        final result = await OpenFilex.open(path);
                        if (result.type != ResultType.done && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Report ready at $path')),
                            );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Something went wrong: $e')),
                          );
                        }
                      }
                    },
                    child: const Text('Export Now'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }


class _OptionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
            ? Theme.of(context).primaryColor 
            : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(monthlySummaryProvider);

    return summaryAsync.when(
      data: (summary) {
        return ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            _MainMetricCard(
              title: 'Total Spent',
              amount: summary.totalSpending,
              subtitle: '${summary.transactionCount} transactions',
              icon: Icons.account_balance_wallet,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.4,
              children: [
                _MiniMetricCard(
                  label: 'Daily Average',
                  value: '\$${summary.averageDailySpending.toStringAsFixed(0)}',
                  icon: Icons.calendar_today,
                  color: Colors.orange,
                ),
                _MiniMetricCard(
                  label: 'Peak Day',
                  value: summary.peakDayOfWeek,
                  icon: Icons.trending_up,
                  color: Colors.redAccent,
                ),
                _MiniMetricCard(
                  label: 'Consistency',
                  value: '${(summary.consistencyScore * 100).toStringAsFixed(0)}%',
                  icon: Icons.balance,
                  color: Colors.blueAccent,
                ),
                _MiniMetricCard(
                  label: 'Top Category',
                  value: summary.highestSpendingCategory,
                  icon: Icons.stars,
                  color: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Quick Category Check', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const _CategoryPreviewList(),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}

class _MainMetricCard extends StatelessWidget {
  final String title;
  final double amount;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _MainMetricCard({
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white70, fontSize: 16)),
              Icon(icon, color: Colors.white70, size: 24),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 14)),
        ],
      ),
    );
  }
}

class _MiniMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniMetricCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.05)),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: isDark ? Colors.white60 : Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _CategoryPreviewList extends ConsumerWidget {
  const _CategoryPreviewList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categorySpendingProvider);
    return categoriesAsync.when(
      data: (data) {
        if (data.isEmpty) return const Text('No expenses yet.');
        return Column(
          children: data.map((item) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: item.color.withOpacity(0.1),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            title: Text(item.categoryName, style: const TextStyle(fontWeight: FontWeight.w600)),
            trailing: Text('\$${item.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
          )).toList(),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (e, s) => Container(),
    );
  }
}

class _CategoriesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categorySpendingProvider);

    return categoriesAsync.when(
      data: (data) {
        if (data.isEmpty) return const Center(child: Text("Start tracking to see breakdown."));
        return Column(
          children: [
            const SizedBox(height: 20),
            SizedBox(height: 240, child: CategoryPieChart(data: data)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final item = data[index];
                  return Card(
                    elevation: 0,
                    color: Colors.transparent, // Let Container handle background
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.withOpacity(0.1)),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: item.color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(item.icon, color: item.color),
                        ),
                        title: Text(item.categoryName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: LinearProgressIndicator(
                          value: item.percentage / 100,
                          backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(item.color),
                          borderRadius: BorderRadius.circular(10),
                          minHeight: 6,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('\$${item.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('${item.percentage.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}

class _TrendsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyAsync = ref.watch(dailySpendingProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ChartWrapper(
            title: 'Daily Spending Pulse',
            description: 'This line chart tracks your daily expenses throughout the month. It helps you visualize spending spikes and quiet days.',
            child: dailyAsync.when(
              data: (data) => data.isEmpty 
                ? const Center(child: Text("Not enough data for patterns")) 
                : SpendingTrendChart(data: data, gradientColor: Theme.of(context).primaryColor),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Error: $e'),
            ),
          ),
          const SizedBox(height: 20),
          _ChartWrapper(
            title: 'Weekly Performance',
            description: 'Spending grouped by week. Useful for identifying which weeks of the month tend to be more expensive.',
            child: const _WeeklyChartSection(),
          ),
          const SizedBox(height: 20),
          _ChartWrapper(
            title: 'Budget Utilization',
            description: 'Gray bars show your set limit, while colored bars show actual spending. Red indicates overspending.',
            child: const _BudgetChartSection(),
          ),
        ],
      ),
    );
  }
}

class _InsightsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(advancedInsightsProvider);
    final smartInsightsAsync = ref.watch(smartInsightsProvider);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Smart Observations', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Automated analysis based on your recent activity.', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const SizedBox(height: 16),
        smartInsightsAsync.when(
          data: (list) {
            if (list.isEmpty) return const Text('Stay consistent for more insights!');
            return Column(
              children: list.map((item) => _SmartInsightCard(insight: item)).toList(),
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (e, s) => Container(),
        ),
        const SizedBox(height: 32),
        Text('Spending Behavior', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        insightsAsync.when(
          data: (insights) => Column(
            children: [
              _BehaviorCard(
                title: 'Purchase Size Distribution',
                description: 'Small (<\$20), Medium (<\$100), Large (\$+100). See if you are spending on many small items or few big ones.',
                child: _PurchaseSizeChart(distribution: insights.purchaseSizeDistribution),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _SimpleStatCard(
                      label: 'Spending Velocity',
                      value: '${insights.spendingVelocity > 0 ? '+' : ''}${insights.spendingVelocity.toStringAsFixed(1)}%',
                      description: 'Compared to last month.',
                      icon: insights.spendingVelocity > 0 ? Icons.trending_up : Icons.trending_down,
                      color: insights.spendingVelocity > 0 ? Colors.redAccent : Colors.greenAccent,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SimpleStatCard(
                      label: 'Category Dominance',
                      value: '${insights.categoryDominance.toStringAsFixed(1)}%',
                      description: 'Top category share.',
                      icon: Icons.pie_chart_outline,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: $e')),
        ),
      ],
    );
  }
}

class _ChartWrapper extends StatelessWidget {
  final String title;
  final String description;
  final Widget child;

  const _ChartWrapper({required this.title, required this.description, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: isDark ? Border.all(color: Colors.white10) : null,
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(description, style: TextStyle(color: isDark ? Colors.white60 : Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 24),
          SizedBox(height: 200, child: child),
        ],
      ),
    );
  }
}

class _SmartInsightCard extends StatelessWidget {
  final SmartInsight insight;
  const _SmartInsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: insight.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: insight.color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(insight.icon, color: insight.color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(insight.title, style: TextStyle(fontWeight: FontWeight.bold, color: insight.color)),
                Text(insight.message, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BehaviorCard extends StatelessWidget {
  final String title;
  final String description;
  final Widget child;
  const _BehaviorCard({required this.title, required this.description, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isDark ? Border.all(color: Colors.white10) : null,
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(description, style: TextStyle(color: isDark ? Colors.white60 : Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _PurchaseSizeChart extends StatelessWidget {
  final Map<String, int> distribution;
  const _PurchaseSizeChart({required this.distribution});

  @override
  Widget build(BuildContext context) {
    final total = distribution.values.fold(0, (a, b) => a + b);
    if (total == 0) return const Text('No data');

    return Row(
      children: [
        _SizeBar(label: 'Small', count: distribution['Small'] ?? 0, total: total, color: Colors.green),
        _SizeBar(label: 'Mid', count: distribution['Medium'] ?? 0, total: total, color: Colors.orange),
        _SizeBar(label: 'Large', count: distribution['Large'] ?? 0, total: total, color: Colors.purple),
      ],
    );
  }
}

class _SizeBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _SizeBar({required this.label, required this.count, required this.total, required this.color});

  @override
  Widget build(BuildContext context) {
    final percent = (count / total) * 100;
    return Expanded(
      child: Column(
        children: [
          Text('${percent.toStringAsFixed(0)}%', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Container(
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: FractionallySizedBox(
              widthFactor: 1,
              child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _SimpleStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String description;
  final IconData icon;
  final Color color;

  const _SimpleStatCard({
    required this.label, 
    required this.value, 
    required this.description,
    required this.icon, 
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        border: isDark ? Border.all(color: Colors.white10) : null,
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 4),
          Text(description, style: TextStyle(fontSize: 10, color: isDark ? Colors.white54 : Colors.grey[600]), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _WeeklyChartSection extends ConsumerWidget {
  const _WeeklyChartSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyAsync = ref.watch(weeklySpendingProvider);
    return weeklyAsync.when(
      data: (data) => data.isEmpty ? const Center(child: Text("Empty week")) : WeeklyChart(data: data),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text('Error: $e'),
    );
  }
}

class _BudgetChartSection extends ConsumerWidget {
  const _BudgetChartSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(budgetPerformanceProvider);
    return budgetAsync.when(
      data: (data) => data.isEmpty ? const Center(child: Text("No budgets set")) : BudgetChart(data: data),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text('Error: $e'),
    );
  }
}

