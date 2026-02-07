import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/reports_controller.dart';
import 'widgets/reports_chart.dart';
import '../../../widgets/common_widgets.dart';
import '../../../theme/app_theme.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'reports'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchReportData,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.fetchReportData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                _buildSummaryCards(),
                const SizedBox(height: AppTheme.spacingLG),

                // Price Trends Chart
                _buildChartSection(context),
                const SizedBox(height: AppTheme.spacingLG),

                // Product List
                SectionHeader(
                  title: 'product_performance'.tr,
                  icon: Icons.analytics_outlined,
                ),
                _buildProductList(context),

                const SizedBox(height: 80), // Bottom padding
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: AnimatedStatCard(
            label: 'total_products'.tr,
            value: controller.totalProducts.value.toString(),
            icon: Icons.inventory_2_outlined,
            color: AppTheme.primaryColor,
            gradient: [AppTheme.primaryLight, AppTheme.primaryColor],
          ),
        ),
        const SizedBox(width: AppTheme.spacingMD),
        Expanded(
          child: AnimatedStatCard(
            label: 'prices_set_today'.tr,
            value: controller.pricesSetToday.value.toString(),
            icon: Icons.price_check,
            color: AppTheme.accentColor,
            gradient: [AppTheme.accentLight, AppTheme.accentColor],
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }

  Widget _buildChartSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'price_trends'.tr,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              // Period Selector (Mock for now)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
                child: Text(
                  'Last 7 Days',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLG),
          SizedBox(
            height: 200,
            child: ReportsChart(
              data: controller.averagePriceHistory,
              isLoading: false,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.2, end: 0, delay: 200.ms);
  }

  Widget _buildProductList(BuildContext context) {
    if (controller.products.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.inventory_2_outlined,
        message: 'no_products_found'.tr,
      );
    }

    // Show top 10 active products
    final activeProducts = controller.products.take(10).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activeProducts.length,
      itemBuilder: (context, index) {
        final product = activeProducts[index];
        return ModernProductCard(
          name: product.getName(Get.locale?.languageCode ?? 'gu'),
          subtitle: product.unitSymbol ?? '',
          price: product.currentPrice != null
              ? '₹${product.currentPrice}'
              : 'not_set'.tr,
          icon: Icons.eco, // Can be dynamic based on category if available
          onTap: () {
            // TODO: Navigate to Product Detail History
          },
        ).animate().fadeIn().slideY(
          begin: 0.2,
          end: 0,
          delay: (300 + (index * 50)).ms,
        );
      },
    );
  }
}
