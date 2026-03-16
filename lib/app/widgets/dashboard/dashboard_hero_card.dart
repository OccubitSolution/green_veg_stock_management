import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';

/// Dashboard Hero Card
/// Displays primary business metric with trend indicator and sparkline
class DashboardHeroCard extends StatelessWidget {
  final String primaryLabel;
  final String primaryValue;
  final String? trend;
  final bool trendPositive;
  final List<Widget>? secondaryMetrics;
  final Color? backgroundColor;

  const DashboardHeroCard({
    super.key,
    required this.primaryLabel,
    required this.primaryValue,
    this.trend,
    this.trendPositive = true,
    this.secondaryMetrics,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: backgroundColor != null
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withValues(alpha: 0.8),
                ],
              ),
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        boxShadow: [
          BoxShadow(
            color: (backgroundColor ?? AppTheme.primaryColor).withValues(
              alpha: 0.3,
            ),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppTheme.spacingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with label and trend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                primaryLabel,
                style: TextStyle(
                  color: backgroundColor != null
                      ? AppTheme.textSecondaryLight
                      : Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: (trendPositive ? AppTheme.success : AppTheme.error)
                        .withValues(
                          alpha: backgroundColor != null ? 0.12 : 0.25,
                        ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trendPositive
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        color: trendPositive
                            ? AppTheme.success
                            : AppTheme.error,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trend!,
                        style: TextStyle(
                          color: trendPositive
                              ? AppTheme.success
                              : AppTheme.error,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMD),

          // Primary Value
          Text(
            primaryValue,
            style: TextStyle(
              color: backgroundColor != null
                  ? AppTheme.textPrimaryLight
                  : Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),

          // Secondary Metrics
          if (secondaryMetrics != null && secondaryMetrics!.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingMD),
            Row(children: secondaryMetrics!),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 50.ms).scale(begin: const Offset(0.95, 0.95));
  }
}

/// Metric Pill for secondary metrics
class MetricPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;

  const MetricPill({
    super.key,
    required this.label,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (color ?? Colors.white).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color ?? Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
