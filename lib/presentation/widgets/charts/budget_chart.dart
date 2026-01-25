import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/statistics.dart';

class BudgetChart extends StatelessWidget {
  final List<BudgetPerformance> data;

  const BudgetChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    double maxY = 0;
    for (var item in data) {
      if (item.budgetLimit > maxY) maxY = item.budgetLimit;
      if (item.actualSpending > maxY) maxY = item.actualSpending;
    }
    maxY = (maxY * 1.2).ceilToDouble();
    if (maxY == 0) maxY = 100;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? Colors.white60 : const Color(0xff7589a2);

    return AspectRatio(
      aspectRatio: 1.6,
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0, right: 16.0),
        child: BarChart(
          BarChartData(
            maxY: maxY,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: Colors.blueGrey,
                tooltipHorizontalAlignment: FLHorizontalAlignment.right,
                tooltipMargin: -10,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  String categoryName = data[group.x.toInt()].categoryName;
                  return BarTooltipItem(
                    '$categoryName\n',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: (rodIndex == 0 ? 'Limit: ' : 'Actual: ') + rod.toY.toStringAsFixed(2),
                        style: TextStyle(
                          color: rodIndex == 0 ? Colors.yellow : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) => bottomTitles(value, meta, labelColor),
                  reservedSize: 42,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 45,
                  interval: maxY / 5,
                  getTitlesWidget: (value, meta) => leftTitles(value, meta, labelColor),
                ),
              ),
            ),
            borderData: FlBorderData(
              show: false,
            ),
            barGroups: List.generate(data.length, (i) => makeGroupData(i, data[i])),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxY / 5,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.withOpacity(0.1),
                strokeWidth: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta, Color labelColor) {
    final titles = data.map((e) {
      if (e.categoryName.length > 6) {
        return "${e.categoryName.substring(0, 5)}..";
      }
      return e.categoryName;
    }).toList();

    final Widget text = Text(
      titles[value.toInt()],
      style: TextStyle(
        color: labelColor,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: text,
    );
  }

  Widget leftTitles(double value, TitleMeta meta, Color labelColor) {
    final style = TextStyle(
      color: labelColor,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    if (value == 0) {
      text = '0';
    } else if (value >= 1000) {
      text = '${(value / 1000).toStringAsFixed(0)}k';
    } else {
      text = value.toInt().toString();
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 0,
      child: Text(text, style: style),
    );
  }

  BarChartGroupData makeGroupData(int x, BudgetPerformance item) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          toY: item.budgetLimit,
          color: Colors.grey,
          width: 7,
        ),
        BarChartRodData(
          toY: item.actualSpending,
          color: item.actualSpending > item.budgetLimit ? Colors.red : Colors.green,
          width: 7,
        ),
      ],
    );
  }
}
