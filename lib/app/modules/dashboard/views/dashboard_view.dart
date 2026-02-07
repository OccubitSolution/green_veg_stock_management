import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../theme/app_theme.dart';
import '../controllers/dashboard_controller.dart';
import '../../home/views/home_view.dart';
import '../../prices/views/daily_prices_view.dart';
import '../../products/views/products_view.dart';
import '../../reports/views/reports_view.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            HomeView(),
            DailyPricesView(),
            ProductsView(),
            ReportsView(),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () =>
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: NavigationBar(
                selectedIndex: controller.currentIndex.value,
                onDestinationSelected: controller.changePage,
                backgroundColor: AppTheme.surfaceLight,
                surfaceTintColor: Colors.transparent,
                indicatorColor: AppTheme.primaryColor.withOpacity(0.1),
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.home_outlined),
                    selectedIcon: const Icon(
                      Icons.home,
                      color: AppTheme.primaryColor,
                    ),
                    label: 'home'.tr,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.edit_calendar_outlined),
                    selectedIcon: const Icon(
                      Icons.edit_calendar,
                      color: AppTheme.primaryColor,
                    ),
                    label: 'daily_prices'.tr,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.inventory_2_outlined),
                    selectedIcon: const Icon(
                      Icons.inventory_2,
                      color: AppTheme.primaryColor,
                    ),
                    label: 'products'.tr,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.bar_chart_outlined),
                    selectedIcon: const Icon(
                      Icons.bar_chart,
                      color: AppTheme.primaryColor,
                    ),
                    label: 'reports'.tr,
                  ),
                ],
              ),
            ).animate().slideY(
              begin: 1.0,
              end: 0.0,
              duration: 500.ms,
              curve: Curves.easeOutQuart,
            ),
      ),
    );
  }
}
