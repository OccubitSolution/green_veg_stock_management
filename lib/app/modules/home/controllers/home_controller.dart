/// Home Controller
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/price_repository.dart';
import '../../../data/repositories/purchase_repository.dart';
import '../../../data/repositories/inventory_repository.dart';
import '../../../data/repositories/sales_repository.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/providers/database_provider.dart';
import '../../../theme/app_theme.dart';

class HomeController extends GetxController {
  // Direct instantiation - repositories are stateless services
  final ProductRepository _productRepository = ProductRepository();
  final PriceRepository _priceRepository = PriceRepository();
  // ignore: unused_field
  final PurchaseRepository _purchaseRepository = PurchaseRepository();
  // ignore: unused_field
  final InventoryRepository _inventoryRepository = InventoryRepository();
  final SalesRepository _salesRepository = SalesRepository();
  final OrderRepository _orderRepository = OrderRepository();
  final _storage = GetStorage();

  // Observable States
  final vendorName = ''.obs;
  final todayDate = ''.obs;
  final productCount = '0'.obs;
  final categoryCount = '0'.obs;
  final pricesSetCount = '0'.obs;

  // Phase 2 Stats
  final todayPurchases = '0'.obs;
  final todayPurchaseAmount = '₹0'.obs;
  final lowStockCount = '0'.obs;
  final outOfStockCount = '0'.obs;
  final todaySales = '₹0'.obs;
  final todaySalesCount = '0'.obs;
  final pendingOrders = '0'.obs;
  final pendingDeliveries = '0'.obs;

  final currentNavIndex = 0.obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  final recentActivities = <Map<String, dynamic>>[].obs;

  // Dashboard Analytics (Phase 1 Redesign)
  final todayRevenue = '₹0'.obs;
  final revenueTrend = ''.obs;
  final revenueTrendPositive = true.obs;
  final totalOrders = '0'.obs;
  final totalCustomers = '0'.obs;
  final last7DaysRevenue = <double>[].obs;
  final last7DaysLabels = <String>[].obs;
  final topProducts = <Map<String, dynamic>>[].obs;
  final smartAlerts = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserInfo();
    _loadTodayDate();
    fetchDashboardData();
  }

  void _loadUserInfo() {
    vendorName.value = _storage.read('vendor_name') ?? 'Guest';
  }

  void _loadTodayDate() {
    final now = DateTime.now();
    final lang = _storage.read('language') ?? 'gu';

    if (lang == 'gu') {
      todayDate.value = DateFormat('dd MMMM, yyyy', 'en').format(now);
    } else {
      todayDate.value = DateFormat('MMMM dd, yyyy').format(now);
    }
  }

  Future<void> fetchDashboardData() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final vendorId = _storage.read('vendor_id');
      if (vendorId == null || vendorId.toString().isEmpty) {
        Get.snackbar('Error', 'Vendor ID not found');
        return;
      }

      // Use optimized batch query for dashboard stats (single query instead of 10+)
      try {
        final dashboardStats = await DatabaseProvider.instance.getDashboardStats(vendorId);
        
        productCount.value = (dashboardStats['product_count'] ?? 0).toString();
        categoryCount.value = (dashboardStats['category_count'] ?? 0).toString();
        todayPurchases.value = (dashboardStats['today_purchase_count'] ?? 0).toString();
        
        // Convert to double first, then format
        final purchaseAmount = (dashboardStats['today_purchase_amount'] is String) 
            ? double.tryParse(dashboardStats['today_purchase_amount']) ?? 0.0
            : (dashboardStats['today_purchase_amount'] ?? 0).toDouble();
        todayPurchaseAmount.value = '₹${purchaseAmount.toStringAsFixed(0)}';
        
        todaySalesCount.value = (dashboardStats['today_sales_count'] ?? 0).toString();
        
        final revenue = (dashboardStats['today_revenue'] is String)
            ? double.tryParse(dashboardStats['today_revenue']) ?? 0.0
            : (dashboardStats['today_revenue'] ?? 0).toDouble();
        todaySales.value = '₹${revenue.toStringAsFixed(0)}';
        todayRevenue.value = '₹${revenue.toStringAsFixed(0)}';
        
        pendingOrders.value = (dashboardStats['pending_orders'] ?? 0).toString();
        pendingDeliveries.value = (dashboardStats['confirmed_orders'] ?? 0).toString();
        lowStockCount.value = (dashboardStats['low_stock'] ?? 0).toString();
        outOfStockCount.value = (dashboardStats['out_of_stock'] ?? 0).toString();
      } catch (e) {
        debugPrint('⚠️ Dashboard stats error: $e');
      }

      // Get prices count separately
      try {
        final prices = await _priceRepository.getTodayPrices(vendorId);
        pricesSetCount.value = prices.length.toString();
      } catch (e) {
        debugPrint('⚠️ Prices error: $e');
        pricesSetCount.value = '0';
      }

      // Build recent activities from actual data
      _buildRecentActivities();

      // Calculate dashboard analytics
      await _calculateDashboardAnalytics(vendorId);
    } catch (e) {
      debugPrint('❌ Dashboard data error: $e');
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void _buildRecentActivities() {
    recentActivities.clear();

    if (int.tryParse(pricesSetCount.value) != null &&
        int.parse(pricesSetCount.value) > 0) {
      recentActivities.add({
        'icon': Icons.price_change_rounded,
        'title': 'prices_updated'.tr,
        'subtitle': 'today'.tr,
        'color': AppTheme.primaryColor,
      });
    }

    if (int.tryParse(todayPurchases.value) != null &&
        int.parse(todayPurchases.value) > 0) {
      recentActivities.add({
        'icon': Icons.shopping_cart_outlined,
        'title': 'new_purchase'.tr,
        'subtitle': 'today'.tr,
        'color': AppTheme.warmAccent,
      });
    }

    if (int.tryParse(todaySalesCount.value) != null &&
        int.parse(todaySalesCount.value) > 0) {
      recentActivities.add({
        'icon': Icons.point_of_sale_rounded,
        'title': 'new_sale'.tr,
        'subtitle': 'today'.tr,
        'color': AppTheme.success,
      });
    }

    if (int.tryParse(pendingOrders.value) != null &&
        int.parse(pendingOrders.value) > 0) {
      recentActivities.add({
        'icon': Icons.receipt_long_outlined,
        'title': 'pending_orders'.tr,
        'subtitle': '${pendingOrders.value} ${'pending'.tr}',
        'color': AppTheme.warning,
      });
    }
  }

  Future<void> refreshData() async {
    await fetchDashboardData();
  }

  // Calculate Dashboard Analytics for Phase 1 Redesign
  Future<void> _calculateDashboardAnalytics(String vendorId) async {
    try {
      final today = DateTime.now();

      // 1. Today's Revenue & Trend - use cached data if available
      final todayRevenueVal = double.tryParse(todayRevenue.value.replaceAll('₹', '')) ?? 0.0;

      // Calculate yesterday for trend
      final yesterday = today.subtract(const Duration(days: 1));
      final yesterdayStats = await _salesRepository.getSalesStats(
        vendorId,
        yesterday,
      );
      final yesterdayRevenue = yesterdayStats['totalRevenue'] as double? ?? 0.0;

      if (yesterdayRevenue > 0) {
        final change = ((todayRevenueVal - yesterdayRevenue) / yesterdayRevenue * 100);
        revenueTrendPositive.value = change >= 0;
        revenueTrend.value =
            '${change >= 0 ? "+" : ""}${change.toStringAsFixed(0)}%';
      }

      // Total orders and customers today
      final orders = await _orderRepository.getOrdersByDate(vendorId, today);
      totalOrders.value = orders.length.toString();

      // Count unique customers
      final uniqueCustomers = orders.map((o) => o.customerId).toSet().length;
      totalCustomers.value = uniqueCustomers.toString();

      // 2. Last 7 Days Revenue Trend - use optimized batch query (1 query instead of 7)
      final weeklyData = await DatabaseProvider.instance.getWeeklySalesStats(vendorId);
      
      final revenueData = <double>[];
      final labelData = <String>[];

      for (int i = 6; i >= 0; i--) {
        final date = today.subtract(Duration(days: i));
        
        // Find matching data from weekly query
        final dateStr = date.toIso8601String().split('T')[0];
        final dayData = weeklyData.where((d) => 
          d['date'].toString().split(' ')[0] == dateStr
        ).firstOrNull;
        
        // Safely convert revenue to double
        final revenueValue = dayData?['revenue'];
        final dayRevenue = (revenueValue is String)
            ? double.tryParse(revenueValue) ?? 0.0
            : (revenueValue ?? 0.0).toDouble();
        revenueData.add(dayRevenue);

        // Format label (e.g., "Mon", "Tue")
        final weekday = [
          'Sun',
          'Mon',
          'Tue',
          'Wed',
          'Thu',
          'Fri',
          'Sat',
        ][date.weekday % 7];
        labelData.add(weekday);
      }

      last7DaysRevenue.value = revenueData;
      last7DaysLabels.value = labelData;

      // 3. Top Products (simplified - using products count for now)
      final products = await _productRepository.getProducts(vendorId);
      final topProductsData = <Map<String, dynamic>>[];

      // Take top 5 products as placeholder (can be enhanced later with actual sales data)
      for (int i = 0; i < (products.length > 5 ? 5 : products.length); i++) {
        topProductsData.add({
          'id': products[i].id,
          // ignore: dead_null_aware_expression
          'name': products[i].nameEn ?? products[i].nameGu,
          'count': 10 - i,
        });
      }
      topProducts.value = topProductsData;

      // 4. Generate Smart Alerts
      final alerts = <Map<String, dynamic>>[];

      // Alert: Prices not set today
      final pricesSet = int.tryParse(pricesSetCount.value) ?? 0;
      final totalProducts = int.tryParse(productCount.value) ?? 0;
      if (pricesSet < totalProducts) {
        alerts.add({
          'type': 'urgent',
          'message': '${totalProducts - pricesSet} products need pricing',
          'actionLabel': 'Set prices now',
          'icon': 'warning',
        });
      }

      // Alert: Low stock items
      final lowStock = int.tryParse(lowStockCount.value) ?? 0;
      if (lowStock > 0) {
        alerts.add({
          'type': 'warning',
          'message': '$lowStock items running low on stock',
          'actionLabel': 'Review inventory',
          'icon': 'inventory',
        });
      }

      // Alert: Revenue trend
      if (revenueTrendPositive.value && revenueTrend.value.isNotEmpty) {
        alerts.add({
          'type': 'success',
          'message': 'Revenue up ${revenueTrend.value} from yesterday',
          'actionLabel': null,
          'icon': 'trending_up',
        });
      }

      // Alert: Pending orders
      final pending = int.tryParse(pendingOrders.value) ?? 0;
      if (pending > 3) {
        alerts.add({
          'type': 'info',
          'message': '$pending orders waiting to be processed',
          'actionLabel': 'View orders',
          'icon': 'receipt',
        });
      }

      smartAlerts.value = alerts;
    } catch (e) {
      debugPrint('⚠️ Analytics calculation error: $e');
      // Set safe defaults on error
      last7DaysRevenue.value = [0, 0, 0, 0, 0, 0, 0];
      last7DaysLabels.value = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      topProducts.value = [];
      smartAlerts.value = [];
    }
  }
}
