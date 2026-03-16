import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';

/// Top Products Chart Widget
/// Displays horizontal bar chart for top-selling products
class TopProductsChart extends StatelessWidget {
  final String title;
  final List<ProductBarData> products;
  final double? height;

  const TopProductsChart({
    super.key,
    required this.title,
    required this.products,
    this.height,
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
          products.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingXL),
                    child: Text(
                      'No products data',
                      style: TextStyle(
                        color: AppTheme.textTertiaryLight,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              : Column(
                  children: products.asMap().entries.map((entry) {
                    final index = entry.key;
                    final product = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppTheme.spacingSM,
                      ),
                      child: _buildProductBar(product, index),
                    );
                  }).toList(),
                ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildProductBar(ProductBarData product, int index) {
    final maxValue = products.isEmpty
        ? 100.0
        : products.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final percentage = (product.value / maxValue) * 100;

    return Row(
      children: [
        // Product name
        SizedBox(
          width: 80,
          child: Text(
            product.name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryLight,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppTheme.spacingSM),

        // Bar
        Expanded(
          child: Stack(
            children: [
              // Background
              Container(
                height: 28,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                ),
              ),
              // Progress
              FractionallySizedBox(
                widthFactor: percentage / 100,
                child:
                    Container(
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                product.color,
                                product.color.withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusSM,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${product.value.toStringAsFixed(0)} orders',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                        .animate(delay: Duration(milliseconds: 100 * index))
                        .scaleX(
                          begin: 0,
                          alignment: Alignment.centerLeft,
                          curve: Curves.easeOutCubic,
                        ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Product Bar Data Model
class ProductBarData {
  final String name;
  final double value;
  final Color color;

  const ProductBarData({
    required this.name,
    required this.value,
    required this.color,
  });
}
