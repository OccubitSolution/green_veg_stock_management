import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/reports_controller.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});

  String get lang => Get.locale?.languageCode ?? 'en';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(child: _buildHeader(context)),

            // Summary Cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMD),
                child: _buildSummaryCards(context),
              ),
            ),

            // Price Trends Chart
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMD,
                ),
                child: _buildPriceChart(context),
              ),
            ),

            // Top Products
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.spacingMD,
                  AppTheme.spacingLG,
                  AppTheme.spacingMD,
                  120, // Space for bottom nav
                ),
                child: _buildTopProducts(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'reports'.tr,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // Export Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.download_rounded,
                    color: AppTheme.textSecondaryLight,
                  ),
                  onPressed: () {
                    // TODO: Export functionality
                  },
                ),
              ),
            ],
          ).animate().fadeIn().slideX(begin: -0.1),
          const SizedBox(height: AppTheme.spacingSM),
          // Date Range Selector
          Obx(
            () => GestureDetector(
              onTapDown: (details) {
                final offset = details.globalPosition;
                showMenu(
                  context: context,
                  position: RelativeRect.fromLTRB(
                    offset.dx,
                    offset.dy,
                    offset.dx,
                    offset.dy,
                  ),
                  items: [
                    PopupMenuItem(
                      value: '7_days',
                      child: Text('last_7_days'.tr),
                    ),
                    PopupMenuItem(
                      value: '30_days',
                      child: Text('last_30_days'.tr),
                    ),
                    PopupMenuItem(
                      value: '90_days',
                      child: Text('last_90_days'.tr),
                    ),
                  ],
                  elevation: 8,
                ).then((value) {
                  if (value != null) {
                    controller.onChangePeriod(value);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'last_${controller.selectedPeriod.value}'.tr,
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(delay: 100.ms).scale(),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: PremiumStatCard(
              icon: Icons.inventory_2_rounded,
              label: 'total_products'.tr,
              value: controller.totalProducts.value.toString(),
              color: AppTheme.vegLeafy,
              onTap: () {},
            ).animate().fadeIn(delay: 150.ms).slideX(begin: -0.1),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PremiumStatCard(
              icon: Icons.attach_money_rounded,
              label: 'prices_set_today'.tr,
              value: controller.pricesSetToday.value.toString(),
              color: AppTheme.accentColor,
              trendIcon: Icons.trending_up_rounded,
              trendColor: AppTheme.success,
            ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceChart(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                ),
                child: const Icon(
                  Icons.show_chart_rounded,
                  color: AppTheme.info,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'price_trends'.tr,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLG),
          SizedBox(
            height: 180,
            child: Obx(() {
              if (controller.chartData.isEmpty) {
                return Center(
                  child: Text(
                    'no_data_available'.tr,
                    style: TextStyle(color: AppTheme.textTertiaryLight),
                  ),
                );
              }

              return LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppTheme.borderLight,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '₹${value.toInt()}',
                            style: const TextStyle(
                              color: AppTheme.textTertiaryLight,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              controller.getDateLabel(value.toInt()),
                              style: const TextStyle(
                                color: AppTheme.textTertiaryLight,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: controller.chartData
                          .asMap()
                          .entries
                          .map(
                            (e) => FlSpot(
                              e.key.toDouble(),
                              (e.value['value'] as num).toDouble(),
                            ),
                          )
                          .toList(),
                      isCurved: true,
                      color: AppTheme.primaryColor,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: AppTheme.primaryColor,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withValues(alpha: 0.2),
                            AppTheme.primaryColor.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1);
  }

  Widget _buildTopProducts(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'top_products'.tr,
          icon: Icons.star_rounded,
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: AppTheme.spacingSM),
        Obx(() {
          if (controller.topProducts.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.trending_up_rounded,
              message: 'no_products_available'.tr,
            );
          }

          return Column(
            children: controller.topProducts
                .take(5)
                .toList()
                .asMap()
                .entries
                .map((entry) {
                  final index = entry.key;
                  final product = entry.value;
                  return _buildProductRankCard(context, product, index);
                })
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _buildProductRankCard(
    BuildContext context,
    dynamic product,
    int index,
  ) {
    final iconColor = AppTheme.getCategoryColor(product.categoryId);

    return PremiumCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: index < 3
                  ? LinearGradient(
                      colors: [
                        _getRankColor(index),
                        _getRankColor(index).withValues(alpha: 0.7),
                      ],
                    )
                  : null,
              color: index >= 3 ? AppTheme.borderLight : null,
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: index < 3 ? Colors.white : AppTheme.textSecondaryLight,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Product Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            ),
            child: Icon(Icons.eco, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.getName(lang),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '${product.priceUpdates ?? 0} ${'price_updates'.tr}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          // Current Price
          if (product.currentPrice != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              ),
              child: Text(
                '₹${product.currentPrice}',
                style: TextStyle(
                  color: iconColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: (350 + index * 50).ms).slideX(begin: 0.05);
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 0:
        return const Color(0xFFFFD700); // Gold
      case 1:
        return const Color(0xFFC0C0C0); // Silver
      case 2:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppTheme.textTertiaryLight;
    }
  }
}
