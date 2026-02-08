import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../../home/views/home_view.dart';
import '../../prices/views/daily_prices_view.dart';
import '../../products/views/products_view.dart';
import '../../reports/views/reports_view.dart';
import '../../../widgets/navigation_widgets.dart';
import '../../../theme/app_theme.dart';
import '../../../routes/app_routes.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      extendBody: true,
      body: Obx(
        () => AnimatedSwitcher(
          duration: AppTheme.animNormal,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.02, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _buildPage(controller.currentIndex.value),
        ),
      ),
      bottomNavigationBar: Obx(
        () =>
            FloatingNavBarWithFab(
              currentIndex: controller.currentIndex.value,
              onTap: controller.changePage,
              onFabPressed: () => Get.toNamed(AppRoutes.orders),
              fabIcon: Icons.add_shopping_cart_rounded,
              fabLabel: 'new_order'.tr,
              items: const [
                FloatingNavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: 'home',
                  activeColor: AppTheme.primaryColor,
                ),
                FloatingNavItem(
                  icon: Icons.attach_money_rounded,
                  selectedIcon: Icons.attach_money_rounded,
                  label: 'prices',
                  activeColor: AppTheme.accentColor,
                ),
                FloatingNavItem(
                  icon: Icons.inventory_2_outlined,
                  selectedIcon: Icons.inventory_2_rounded,
                  label: 'products',
                  activeColor: AppTheme.vegLeafy,
                ),
                FloatingNavItem(
                  icon: Icons.bar_chart_outlined,
                  selectedIcon: Icons.bar_chart_rounded,
                  label: 'reports',
                  activeColor: AppTheme.info,
                ),
              ],
            ).animate().slideY(
              begin: 1.0,
              end: 0.0,
              duration: 500.ms,
              delay: 200.ms,
              curve: Curves.easeOutCubic,
            ),
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const HomeView(key: ValueKey('home'));
      case 1:
        return const DailyPricesView(key: ValueKey('prices'));
      case 2:
        return const ProductsView(key: ValueKey('products'));
      case 3:
        return const ReportsView(key: ValueKey('reports'));
      default:
        return const HomeView(key: ValueKey('home'));
    }
  }
}
