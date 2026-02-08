import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
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
        child: CustomScrollView(
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
                  // Hero Card
                  _buildHeroCard(context),

                  const SizedBox(height: AppTheme.spacingLG),

                  // Stats Grid
                  _buildStatsSection(context),

                  const SizedBox(height: AppTheme.spacingLG),

                  // Quick Actions
                  _buildQuickActions(context),

                  const SizedBox(height: AppTheme.spacingLG),

                  // Recent Activity
                  _buildRecentActivity(context),

                  // Bottom padding for nav bar
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
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

  Widget _buildHeroCard(BuildContext context) {
    return GradientHeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.spacingSM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'today_overview'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Obx(
                      () => Text(
                        controller.todayDate.value,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLG),
          Row(
            children: [
              _buildHeroStat('products'.tr, controller.productCount),
              const SizedBox(width: AppTheme.spacingMD),
              _buildHeroStat('categories'.tr, controller.categoryCount),
              const SizedBox(width: AppTheme.spacingMD),
              _buildHeroStat('prices_set'.tr, controller.pricesSetCount),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildHeroStat(String label, RxString value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        ),
        child: Column(
          children: [
            Obx(
              () => Text(
                value.value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'quick_stats'.tr,
          viewAllText: 'view_all'.tr,
          onViewAll: () => Get.toNamed(AppRoutes.reports),
        ),
        const SizedBox(height: AppTheme.spacingSM),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => PremiumStatCard(
                  icon: Icons.shopping_cart_outlined,
                  label: 'today_purchases'.tr,
                  value: controller.todayPurchases.value,
                  color: AppTheme.warmAccent,
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingSM),
            Expanded(
              child: Obx(
                () => PremiumStatCard(
                  icon: Icons.attach_money_rounded,
                  label: 'amount'.tr,
                  value: controller.todayPurchaseAmount.value,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
        const SizedBox(height: AppTheme.spacingSM),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => PremiumStatCard(
                  icon: Icons.warning_amber_rounded,
                  label: 'low_stock'.tr,
                  value: controller.lowStockCount.value,
                  color: AppTheme.warning,
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingSM),
            Expanded(
              child: Obx(
                () => PremiumStatCard(
                  icon: Icons.remove_shopping_cart_outlined,
                  label: 'out_of_stock'.tr,
                  value: controller.outOfStockCount.value,
                  color: AppTheme.error,
                ),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'quick_actions'.tr),
        const SizedBox(height: AppTheme.spacingSM),
        Row(
          children: [
            Expanded(
              child: FloatingActionTile(
                icon: Icons.price_change_rounded,
                label: 'set_prices'.tr,
                color: AppTheme.primaryColor,
                onTap: () => Get.toNamed(AppRoutes.dailyPrices),
              ),
            ),
            const SizedBox(width: AppTheme.spacingSM),
            Expanded(
              child: FloatingActionTile(
                icon: Icons.add_shopping_cart_rounded,
                label: 'new_purchase'.tr,
                color: AppTheme.warmAccent,
                onTap: () => Get.toNamed(AppRoutes.purchases),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
        const SizedBox(height: AppTheme.spacingSM),
        Row(
          children: [
            Expanded(
              child: FloatingActionTile(
                icon: Icons.point_of_sale_rounded,
                label: 'new_sale'.tr,
                color: AppTheme.success,
                onTap: () => Get.toNamed(AppRoutes.sales),
              ),
            ),
            const SizedBox(width: AppTheme.spacingSM),
            Expanded(
              child: FloatingActionTile(
                icon: Icons.inventory_2_outlined,
                label: 'stock'.tr,
                color: AppTheme.info,
                onTap: () => Get.toNamed(AppRoutes.stock),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'recent_activity'.tr,
          viewAllText: 'see_all'.tr,
          onViewAll: () {
            // TODO: Navigate to activity log
          },
        ),
        const SizedBox(height: AppTheme.spacingSM),
        PremiumCard(
          padding: const EdgeInsets.all(AppTheme.spacingMD),
          child: Column(
            children: [
              _buildActivityItem(
                icon: Icons.price_change_rounded,
                title: 'prices_updated'.tr,
                subtitle: 'today'.tr,
                color: AppTheme.primaryColor,
              ),
              const Divider(height: AppTheme.spacingLG),
              _buildActivityItem(
                icon: Icons.shopping_cart_outlined,
                title: 'new_purchase'.tr,
                subtitle: 'yesterday'.tr,
                color: AppTheme.warmAccent,
              ),
              const Divider(height: AppTheme.spacingLG),
              _buildActivityItem(
                icon: Icons.person_add_outlined,
                title: 'customer_added'.tr,
                subtitle: '2_days_ago'.tr,
                color: AppTheme.info,
              ),
            ],
          ),
        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: AppTheme.spacingMD),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.textSecondaryLight,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, color: AppTheme.textTertiaryLight),
      ],
    );
  }
}
