import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/statistics.dart';
import 'package:intl/intl.dart';

class SpendingTrendChart extends StatelessWidget {
  final List<DailySpending> data;
  final Color gradientColor;

  const SpendingTrendChart({
    super.key,
    required this.data,
    this.gradientColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
       return const Center(child: Text('No trend data available'));
    }

    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 12,
              top: 24,
              bottom: 12,
            ),
            child: LineChart(
              mainData(Theme.of(context)),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData mainData(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final labelColor = isDark ? Colors.white70 : (Colors.grey[700] ?? Colors.grey);
    final lineColor = isDark ? Colors.lightBlueAccent : gradientColor; // Brighter line in dark mode
    
    // Find min/max for scaling
    double maxY = 0;
    for (var item in data) {
      if (item.totalAmount > maxY) maxY = item.totalAmount;
    }
    maxY = maxY * 1.2; // Add some headroom

    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: isDark ? Colors.blueAccent.withOpacity(0.9) : Colors.blueGrey.withOpacity(0.8),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((LineBarSpot touchedSpot) {
              final date = data[touchedSpot.x.toInt()].date;
              return LineTooltipItem(
                '${DateFormat('MMM d').format(date)}\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: '\$${touchedSpot.y.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: isDark ? Colors.white : gradientColor.withOpacity(0.8),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              );
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: maxY / 5,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
            strokeWidth: 1,
          );
        },
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
            reservedSize: 30,
            interval: (data.length / 5).ceil().toDouble(), // Show roughly 5 labels
            getTitlesWidget: (value, meta) => bottomTitleWidgets(value, meta, labelColor),
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: maxY / 5,
            getTitlesWidget: (value, meta) => leftTitleWidgets(value, meta, labelColor),
            reservedSize: 45,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.2)),
      ),
      minX: 0,
      maxX: (data.length - 1).toDouble(),
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: data.asMap().entries.map((e) {
            return FlSpot(e.key.toDouble(), e.value.totalAmount);
          }).toList(),
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              lineColor,
              lineColor.withOpacity(0.7),
            ],
          ),
          barWidth: isDark ? 4 : 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                lineColor.withOpacity(isDark ? 0.4 : 0.3),
                lineColor.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta, Color labelColor) {
    final style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
      color: labelColor,
    );
    
    int index = value.toInt();
    if (index < 0 || index >= data.length) return Container();

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(DateFormat('d').format(data[index].date), style: style),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta, Color labelColor) {
    final style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
      color: labelColor,
    );
    String text;
    if (value >= 1000) {
      text = '${(value / 1000).toStringAsFixed(1)}k';
    } else {
      text = value.toInt().toString();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }
}
