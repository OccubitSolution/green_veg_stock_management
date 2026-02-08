import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/home_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../../theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/common_widgets.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header & Welcome Section
            _buildHeader(context),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMD,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Grid
                    _buildStatsGrid(context),

                    const SizedBox(height: AppTheme.spacingLG),

                    // Quick Actions
                    SectionHeader(
                      title: 'quick_actions'.tr,
                      icon: Icons.flash_on_rounded,
                    ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                    const SizedBox(height: AppTheme.spacingMD),
                    _buildQuickActionsGrid(context),

                    const SizedBox(height: AppTheme.spacingLG),

                    // Recent Activity
                    SectionHeader(
                      title: 'recent_activity'.tr,
                      icon: Icons.history_rounded,
                      onViewAll: () {
                        // TODO: Navigate to history
                      },
                    ).animate().fadeIn().slideX(
                      begin: -0.2,
                      end: 0,
                      delay: 200.ms,
                    ),
                    const SizedBox(height: AppTheme.spacingMD),
                    _buildRecentActivityList(context),

                    const SizedBox(height: 80), // Bottom padding for FAB/Nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: _buildBottomNav(context), // Removed: Dashboard handles nav
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      child: Column(
        children: [
          // Top Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Greeting
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
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              // Settings & Profile
              Row(
                children: [
                  IconButton(
                    onPressed: () => Get.toNamed(AppRoutes.settings),
                    icon: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                      ),
                      child: const Icon(
                        Icons.settings_outlined,
                        color: AppTheme.primaryColor,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ).animate().fadeIn().slideY(begin: -0.5, end: 0),
          const SizedBox(height: AppTheme.spacingLG),
          // Main Welcome Card with Gradient
          _buildWelcomeCard(context).animate().fadeIn().scale(delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return GradientCard(
      gradientColors: AppTheme.primaryGradient.colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Vegetable illustration placeholder
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                ),
                child: const Icon(Icons.eco, color: Colors.white, size: 32),
              ),
              const SizedBox(width: AppTheme.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'app_name'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(
                      () => Text(
                        controller.todayDate.value,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLG),
          // Quick stat row
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            decoration: AppTheme.glassDecoration(opacity: 0.2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniStat(
                  Icons.inventory_2,
                  'products'.tr,
                  controller.productCount,
                ),
                Container(width: 1, height: 30, color: Colors.white24),
                _buildMiniStat(
                  Icons.attach_money,
                  'prices_set'.tr,
                  controller.pricesSetCount,
                ),
                Container(width: 1, height: 30, color: Colors.white24),
                _buildMiniStat(
                  Icons.shopping_cart,
                  'sales'.tr,
                  controller.todaySales,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String label, RxString value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Obx(
          () => Text(
            value.value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Obx(
            () => AnimatedStatCard(
              label: 'total_products'.tr,
              value: controller.productCount.value,
              icon: Icons.inventory_2_outlined,
              color: AppTheme.primaryColor,
              gradient: [AppTheme.primaryLight, AppTheme.primaryColor],
              onTap: () {
                // Switch to Products tab
                try {
                  final dashboard = Get.find<DashboardController>();
                  dashboard.changePage(2);
                } catch (e) {
                  Get.toNamed(AppRoutes.products);
                }
              },
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacingMD),
        Expanded(
          child: Obx(
            () => AnimatedStatCard(
              label: 'categories'.tr,
              value: controller.categoryCount.value,
              icon: Icons.category_outlined,
              color: AppTheme.accentColor,
              gradient: [AppTheme.accentLight, AppTheme.accentColor],
              onTap: () {
                // TODO: Navigate to categories
              },
            ),
          ),
        ),
      ],
    ).animate().fadeIn().slideX(begin: 0.2, end: 0, delay: 300.ms);
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    final actions = [
      {
        'icon': Icons.edit_calendar,
        'label': 'daily_prices'.tr,
        'index': 1, // Dashboard Index
        'color': Colors.blue,
      },
      {
        'icon': Icons.inventory,
        'label': 'products'.tr,
        'index': 2, // Dashboard Index
        'color': Colors.green,
      },
      {
        'icon': Icons.shopping_bag,
        'label': 'purchases'.tr,
        'route': AppRoutes.purchases,
        'color': Colors.orange,
      },
      {
        'icon': Icons.point_of_sale,
        'label': 'sales'.tr,
        'route': AppRoutes.sales,
        'color': Colors.purple,
      },
      {
        'icon': Icons.people,
        'label': 'customers'.tr,
        'route': AppRoutes.customers,
        'color': Colors.teal,
      },
      {
        'icon': Icons.local_shipping,
        'label': 'suppliers'.tr,
        'route': AppRoutes.suppliers,
        'color': Colors.indigo,
      },
      {
        'icon': Icons.bar_chart,
        'label': 'reports'.tr,
        'index': 3, // Dashboard Index
        'color': Colors.red,
      },
      {
        'icon': Icons.analytics,
        'label': 'analytics'.tr,
        'route': AppRoutes.analytics,
        'color': Colors.amber,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.85,
        crossAxisSpacing: AppTheme.spacingMD,
        mainAxisSpacing: AppTheme.spacingMD,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return QuickActionTile(
          icon: action['icon'] as IconData,
          label: action['label'] as String,
          color: action['color'] as Color,
          onTap: () {
            if (action.containsKey('index')) {
              try {
                final dashboard = Get.find<DashboardController>();
                dashboard.changePage(action['index'] as int);
              } catch (e) {
                // Fallback if DashboardController not found
                if (action['label'] == 'daily_prices'.tr)
                  Get.toNamed(AppRoutes.dailyPrices);
                if (action['label'] == 'products'.tr)
                  Get.toNamed(AppRoutes.products);
                if (action['label'] == 'reports'.tr)
                  Get.toNamed(AppRoutes.reports);
              }
            } else if (action['route'] != null) {
              Get.toNamed(action['route'] as String);
            }
          },
        ).animate().fadeIn().slideY(
          begin: 0.2,
          end: 0,
          delay: (400 + (index * 50)).ms,
        );
      },
    );
  }

  Widget _buildRecentActivityList(BuildContext context) {
    // Placeholder for recent activity
    return Center(
      child: Column(
        children: [
          Icon(Icons.history, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Text(
            'no_recent_activity'.tr,
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 4),
          Text(
            'activity_hint'.tr,
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'good_morning'.tr;
    if (hour < 17) return 'good_afternoon'.tr;
    return 'good_evening'.tr;
  }
}
