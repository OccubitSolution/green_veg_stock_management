import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';

/// Trend Chart Widget
/// Displays line chart for sales/revenue trends
class TrendChartWidget extends StatelessWidget {
  final String title;
  final List<double> data;
  final List<String>? labels;
  final Color? color;
  final double? height;
  final bool showGrid;

  const TrendChartWidget({
    super.key,
    required this.title,
    required this.data,
    this.labels,
    this.color,
    this.height,
    this.showGrid = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppTheme.spacingLG),
          SizedBox(
            height: height ?? 180,
            child: data.isEmpty
                ? Center(
                    child: Text(
                      'No data available',
                      style: TextStyle(
                        color: AppTheme.textTertiaryLight,
                        fontSize: 14,
                      ),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: showGrid,
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: AppTheme.borderLight,
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
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              if (labels == null ||
                                  value.toInt() >= labels!.length) {
                                return const SizedBox();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  labels![value.toInt()],
                                  style: const TextStyle(
                                    color: AppTheme.textSecondaryLight,
                                    fontSize: 11,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: null,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '₹${_formatNumber(value)}',
                                style: const TextStyle(
                                  color: AppTheme.textSecondaryLight,
                                  fontSize: 11,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: (data.length - 1).toDouble(),
                      minY: 0,
                      maxY: _getMaxY(),
                      lineBarsData: [
                        LineChartBarData(
                          spots: data
                              .asMap()
                              .entries
                              .map((e) => FlSpot(e.key.toDouble(), e.value))
                              .toList(),
                          isCurved: true,
                          color: color ?? AppTheme.primaryColor,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: Colors.white,
                                strokeWidth: 2,
                                strokeColor: color ?? AppTheme.primaryColor,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                (color ?? AppTheme.primaryColor).withValues(
                                  alpha: 0.2,
                                ),
                                (color ?? AppTheme.primaryColor).withValues(
                                  alpha: 0.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                  ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1);
  }

  double _getMaxY() {
    if (data.isEmpty) return 100;
    final max = data.reduce((a, b) => a > b ? a : b);
    return (max * 1.2).ceilToDouble();
  }

  String _formatNumber(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(0);
  }
}
