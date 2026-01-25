import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/statistics.dart';

class WeeklyChart extends StatelessWidget {
  final List<WeeklySpending> data;

  const WeeklyChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    double maxY = 0;
    for (var item in data) {
      if (item.totalAmount > maxY) maxY = item.totalAmount;
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
                  String weekLabel = data[group.x.toInt()].label;
                  return BarTooltipItem(
                    '$weekLabel\n',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: rod.toY.toStringAsFixed(2),
                        style: const TextStyle(
                          color: Colors.yellow,
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
    final titles = data.map((e) => "W${e.weekNumber}").toList();

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

  BarChartGroupData makeGroupData(int x, WeeklySpending item) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: item.totalAmount,
          color: Colors.lightBlueAccent,
          width: 16,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
