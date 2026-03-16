import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';


/// Smart Alerts Widget
/// Displays actionable business insights and alerts
class SmartAlertsWidget extends StatelessWidget {
  final List<SmartAlert> alerts;

  const SmartAlertsWidget({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Smart Insights',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSM),
        ...alerts.asMap().entries.map((entry) {
          final index = entry.key;
          final alert = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingSM),
            child: _buildAlertCard(alert, index),
          );
        }),
      ],
    );
  }

  Widget _buildAlertCard(SmartAlert alert, int index) {
    return Container(
          padding: const EdgeInsets.all(AppTheme.spacingMD),
          decoration: BoxDecoration(
            color: alert.type.backgroundColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusLG),
            border: Border.all(color: alert.type.borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: alert.type.iconBackground,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
                child: Icon(alert.icon, color: alert.type.color, size: 20),
              ),
              const SizedBox(width: AppTheme.spacingMD),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.message,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryLight,
                      ),
                    ),
                    if (alert.actionLabel != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        alert.actionLabel!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: alert.type.color,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Action Icon
              if (alert.onTap != null)
                Icon(Icons.chevron_right_rounded, color: alert.type.color),
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn()
        .slideX(begin: -0.1);
  }
}

/// Smart Alert Data Model
class SmartAlert {
  final String message;
  final String? actionLabel;
  final IconData icon;
  final SmartAlertType type;
  final VoidCallback? onTap;

  const SmartAlert({
    required this.message,
    this.actionLabel,
    required this.icon,
    required this.type,
    this.onTap,
  });

  factory SmartAlert.warning({
    required String message,
    String? actionLabel,
    VoidCallback? onTap,
  }) {
    return SmartAlert(
      message: message,
      actionLabel: actionLabel,
      icon: Icons.warning_amber_rounded,
      type: SmartAlertType.warning,
      onTap: onTap,
    );
  }

  factory SmartAlert.info({
    required String message,
    String? actionLabel,
    VoidCallback? onTap,
  }) {
    return SmartAlert(
      message: message,
      actionLabel: actionLabel,
      icon: Icons.info_outline_rounded,
      type: SmartAlertType.info,
      onTap: onTap,
    );
  }

  factory SmartAlert.success({
    required String message,
    String? actionLabel,
    VoidCallback? onTap,
  }) {
    return SmartAlert(
      message: message,
      actionLabel: actionLabel,
      icon: Icons.check_circle_outline_rounded,
      type: SmartAlertType.success,
      onTap: onTap,
    );
  }

  factory SmartAlert.urgent({
    required String message,
    String? actionLabel,
    VoidCallback? onTap,
  }) {
    return SmartAlert(
      message: message,
      actionLabel: actionLabel,
      icon: Icons.priority_high_rounded,
      type: SmartAlertType.urgent,
      onTap: onTap,
    );
  }
}

/// Smart Alert Types
enum SmartAlertType {
  warning,
  info,
  success,
  urgent;

  Color get color {
    switch (this) {
      case SmartAlertType.warning:
        return AppTheme.warning;
      case SmartAlertType.info:
        return AppTheme.info;
      case SmartAlertType.success:
        return AppTheme.success;
      case SmartAlertType.urgent:
        return AppTheme.error;
    }
  }

  Color get backgroundColor {
    return color.withValues(alpha: 0.08);
  }

  Color get borderColor {
    return color.withValues(alpha: 0.2);
  }

  Color get iconBackground {
    return color.withValues(alpha: 0.15);
  }
}
