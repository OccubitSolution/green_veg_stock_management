import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/home_controller.dart';
import '../../../controllers/app_controller.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';
import '../../../routes/app_routes.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  String get lang => Get.locale?.languageCode ?? 'gu';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        color: AppTheme.primaryColor,
        child: Obx(() {
          if (controller.isLoading.value) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMD),
                  sliver: SliverToBoxAdapter(child: _buildHomeSkeleton()),
                ),
              ],
            );
          }

          if (controller.hasError.value) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context)),
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_off_rounded,
                          size: 64,
                          color: AppTheme.textTertiaryLight,
                        ),
                        const SizedBox(height: AppTheme.spacingMD),
                        Text(
                          'something_went_wrong'.tr,
                          style: TextStyle(
                            color: AppTheme.textSecondaryLight,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingMD),
                        ElevatedButton.icon(
                          onPressed: controller.refreshData,
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text('retry'.tr),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // Header Section
              SliverToBoxAdapter(child: _buildHeader(context)),

              // Content
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMD,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // === PHASE 1: NEW PROFESSIONAL DASHBOARD ===

                    // Hero Revenue Card
                    _buildRevenueHero(context),

                    const SizedBox(height: AppTheme.spacingLG),

                    // Quick Actions (Create Bill / Add Product)
                    _buildQuickActions(context),

                    const SizedBox(height: AppTheme.spacingLG),

                    // Smart Alerts
                    _buildSmartAlerts(context),

                    const SizedBox(height: AppTheme.spacingLG),

                    // Revenue Trend Chart
                    _buildRevenueTrend(context),

                    const SizedBox(height: AppTheme.spacingLG),

                    // Top Products Chart
                    _buildTopProducts(context),

                    const SizedBox(height: AppTheme.spacingLG),

                    // Quick Stats (condensed)
                    _buildQuickStats(context),

                    // Bottom padding for nav bar
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'good_morning'.tr;
    } else if (hour < 17) {
      return 'good_afternoon'.tr;
    } else {
      return 'good_evening'.tr;
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppTheme.spacingMD,
        left: AppTheme.spacingMD,
        right: AppTheme.spacingMD,
        bottom: AppTheme.spacingMD,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Obx(
                () => Text(
                  controller.vendorName.value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            ),
            child: IconButton(
              onPressed: () => Get.toNamed(AppRoutes.settings),
              icon: const Icon(
                Icons.settings_outlined,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ).animate().fadeIn().slideY(begin: -0.3),
    );
  }

  /// Quick Actions Section
  Widget _buildQuickActions(BuildContext context) {
    final appController = Get.find<AppController>();
    final isStaff = appController.role.value == 'staff';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSM),
        
        // Staff users: Show Clients (Client Orders View) and Purchase List only
        if (isStaff) ...[
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  'Clients',
                  Icons.people_outline,
                  AppTheme.primaryColor,
                  () => Get.toNamed(AppRoutes.customers),
                ),
              ),
              const SizedBox(width: AppTheme.spacingSM),
              Expanded(
                child: _buildActionButton(
                  context,
                  'Purchase List',
                  Icons.shopping_cart_outlined,
                  AppTheme.vegLeafy,
                  () => Get.toNamed(AppRoutes.purchaseList),
                ),
              ),
            ],
          ),
        ] else ...[
          // Admin users: Show all options
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  'Create Bill',
                  Icons.receipt_long_rounded,
                  AppTheme.primaryColor,
                  () => Get.toNamed(AppRoutes.addOrder),
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: AppTheme.spacingSM),
              Expanded(
                child: _buildActionButton(
                  context,
                  'Add Product',
                  Icons.add_box_outlined,
                  AppTheme.textSecondaryLight,
                  () => Get.toNamed(AppRoutes.addProduct),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSM),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  'Clients',
                  Icons.people_outline,
                  AppTheme.accentColor,
                  () => Get.toNamed(AppRoutes.customers),
                ),
              ),
              const SizedBox(width: AppTheme.spacingSM),
              Expanded(
                child: _buildActionButton(
                  context,
                  'Purchase List',
                  Icons.shopping_cart_outlined,
                  AppTheme.vegLeafy,
                  () => Get.toNamed(AppRoutes.purchaseList),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool isPrimary = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isPrimary ? AppTheme.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusLG),
            border: isPrimary ? null : Border.all(color: AppTheme.borderLight),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isPrimary
                      ? Colors.white.withValues(alpha: 0.2)
                      : AppTheme.backgroundLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isPrimary ? Colors.white : color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary ? Colors.white : AppTheme.textPrimaryLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().scale(
      delay: 200.ms,
      duration: 300.ms,
      curve: Curves.easeOutBack,
    );
  }

  // =================================================================
  // PHASE 1: NEW DASHBOARD BUILDER METHODS
  // =================================================================

  /// Hero Revenue Card with Trend
  Widget _buildRevenueHero(BuildContext context) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primaryColor, Color(0xFF059669)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppTheme.spacingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Today's Revenue",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (controller.revenueTrend.value.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (controller.revenueTrendPositive.value
                                  ? AppTheme.success
                                  : AppTheme.error)
                              .withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          controller.revenueTrendPositive.value
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          color: controller.revenueTrendPositive.value
                              ? AppTheme.success
                              : AppTheme.error,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          controller.revenueTrend.value,
                          style: TextStyle(
                            color: controller.revenueTrendPositive.value
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
            Text(
              controller.todayRevenue.value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMD),
            Row(
              children: [
                _buildMetricPill(
                  '${controller.totalOrders.value} Orders',
                  Icons.receipt,
                ),
                const SizedBox(width: AppTheme.spacingSM),
                _buildMetricPill(
                  '${controller.totalCustomers.value} Customers',
                  Icons.people,
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(delay: 50.ms).scale(begin: const Offset(0.95, 0.95)),
    );
  }

  Widget _buildMetricPill(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Smart Alerts
  Widget _buildSmartAlerts(BuildContext context) {
    return Obx(() {
      if (controller.smartAlerts.isEmpty) {
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
          ...controller.smartAlerts.asMap().entries.map((entry) {
            final index = entry.key;
            final alert = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingSM),
              child: _buildAlertCard(alert, index),
            );
          }),
        ],
      );
    });
  }

  Widget _buildAlertCard(Map<String, dynamic> alert, int index) {
    final type = alert['type'] as String;
    Color color;
    Color bgColor;
    Color borderColor;

    switch (type) {
      case 'urgent':
        color = AppTheme.error;
        break;
      case 'warning':
        color = AppTheme.warning;
        break;
      case 'success':
        color = AppTheme.success;
        break;
      default:
        color = AppTheme.info;
    }

    bgColor = color.withValues(alpha: 0.08);
    borderColor = color.withValues(alpha: 0.2);

    return Container(
          padding: const EdgeInsets.all(AppTheme.spacingMD),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusLG),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
                child: Icon(
                  _getAlertIcon(alert['icon']),
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert['message'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryLight,
                      ),
                    ),
                    if (alert['actionLabel'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        alert['actionLabel'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color),
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn()
        .slideX(begin: -0.1);
  }

  IconData _getAlertIcon(String? iconName) {
    switch (iconName) {
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'inventory':
        return Icons.inventory_2_outlined;
      case 'trending_up':
        return Icons.trending_up_rounded;
      case 'receipt':
        return Icons.receipt_long_outlined;
      default:
        return Icons.info_outline_rounded;
    }
  }

  /// Revenue Trend Chart
  Widget _buildRevenueTrend(BuildContext context) {
    return Obx(
      () => PremiumCard(
        padding: const EdgeInsets.all(AppTheme.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revenue Trend (7 Days)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryLight,
              ),
            ),
            const SizedBox(height: AppTheme.spacingLG),
            SizedBox(
              height: 180,
              child: controller.last7DaysRevenue.isEmpty
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
                          show: true,
                          drawVerticalLine: false,
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
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >=
                                    controller.last7DaysLabels.length) {
                                  return const SizedBox();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    controller.last7DaysLabels[value.toInt()],
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
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '\u20b9${_formatNumber(value)}',
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
                        maxX: (controller.last7DaysRevenue.length - 1)
                            .toDouble(),
                        minY: 0,
                        maxY: _getMaxY(controller.last7DaysRevenue),
                        lineBarsData: [
                          LineChartBarData(
                            spots: controller.last7DaysRevenue
                                .asMap()
                                .entries
                                .map((e) => FlSpot(e.key.toDouble(), e.value))
                                .toList(),
                            isCurved: true,
                            color: AppTheme.primaryColor,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: true),
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
                    ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1),
    );
  }

  /// Top Products Chart
  Widget _buildTopProducts(BuildContext context) {
    return Obx(
      () => PremiumCard(
        padding: const EdgeInsets.all(AppTheme.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Products',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryLight,
              ),
            ),
            const SizedBox(height: AppTheme.spacingLG),
            controller.topProducts.isEmpty
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
                    children: controller.topProducts.asMap().entries.map((
                      entry,
                    ) {
                      final index = entry.key;
                      final product = entry.value;
                      return _buildProductBar(product, index);
                    }).toList(),
                  ),
          ],
        ),
      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
    );
  }

  Widget _buildProductBar(Map<String, dynamic> product, int index) {
    final count = product['count'] as int;
    final name = product['name'] as String;
    final colors = [
      const Color(0xFFE57373),
      const Color(0xFFFFB74D),
      const Color(0xFFFFF176),
      const Color(0xFFA5D6A7),
      const Color(0xFFFF8A65),
    ];
    final color = colors[index % colors.length];
    final maxValue = controller.topProducts.isEmpty
        ? 10.0
        : controller.topProducts
              .map((p) => p['count'] as int)
              .reduce((a, b) => a > b ? a : b)
              .toDouble();
    final percentage = (count / maxValue) * 100;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSM),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryLight,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppTheme.spacingSM),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percentage / 100,
                  child:
                      Container(
                            height: 28,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [color, color.withValues(alpha: 0.7)],
                              ),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusSM,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '$count orders',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                          .animate(delay: Duration(milliseconds: 100 * index))
                          .scaleX(begin: 0, alignment: Alignment.centerLeft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Quick Stats (Condensed)
  Widget _buildQuickStats(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Stats',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSM),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppTheme.spacingSM,
          crossAxisSpacing: AppTheme.spacingSM,
          childAspectRatio: 2,
          children: [
            _buildQuickStatCard(
              'Low Stock',
              controller.lowStockCount.value,
              Icons.inventory_2_outlined,
              AppTheme.warning,
            ),
            _buildQuickStatCard(
              'Out of Stock',
              controller.outOfStockCount.value,
              Icons.remove_shopping_cart_outlined,
              AppTheme.error,
            ),
            _buildQuickStatCard(
              'Products',
              controller.productCount.value,
              Icons.eco,
              AppTheme.primaryColor,
            ),
            _buildQuickStatCard(
              'Prices Set',
              controller.pricesSetCount.value,
              Icons.price_change,
              AppTheme.success,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return PremiumCard(
      padding: const EdgeInsets.all(AppTheme.spacingSM),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: AppTheme.spacingSM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _formatNumber(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(0);
  }

  double _getMaxY(List<double> data) {
    if (data.isEmpty) return 100;
    final max = data.reduce((a, b) => a > b ? a : b);
    return (max * 1.2).ceilToDouble();
  }

  /// Home Page Skeleton that matches actual layout
  Widget _buildHomeSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero Revenue Card Skeleton
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          ),
          padding: const EdgeInsets.all(AppTheme.spacingLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkeletonItem(height: 14, width: 120),
              const SizedBox(height: AppTheme.spacingMD),
              const SkeletonItem(height: 36, width: 180),
              const SizedBox(height: AppTheme.spacingMD),
              Row(
                children: [
                  SkeletonItem(
                    height: 32,
                    width: 100,
                    borderRadius: AppTheme.radiusMD,
                  ),
                  const SizedBox(width: AppTheme.spacingSM),
                  SkeletonItem(
                    height: 32,
                    width: 120,
                    borderRadius: AppTheme.radiusMD,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacingLG),

        // Quick Actions Skeleton
        const SkeletonItem(height: 16, width: 100),
        const SizedBox(height: AppTheme.spacingSM),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                  boxShadow: AppTheme.cardShadow,
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingSM),
            Expanded(
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                  boxShadow: AppTheme.cardShadow,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingLG),

        // Chart Skeleton
        const SkeletonItem(height: 16, width: 150),
        const SizedBox(height: AppTheme.spacingSM),
        Container(
          height: 220,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusXL),
            boxShadow: AppTheme.cardShadow,
          ),
          padding: const EdgeInsets.all(AppTheme.spacingMD),
          child: Column(
            children: [
              const SkeletonItem(height: 14, width: 120),
              const SizedBox(height: AppTheme.spacingLG),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    7,
                    (index) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 60 + (index * 15.0),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}
