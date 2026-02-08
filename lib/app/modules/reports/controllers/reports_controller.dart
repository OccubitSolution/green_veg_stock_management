import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/price_repository.dart';
import '../../../data/models/product_model.dart';

class ReportsController extends GetxController {
  late final ProductRepository _productRepository;
  late final PriceRepository _priceRepository;
  final _storage = GetStorage();

  final isLoading = false.obs;
  final products = <Product>[].obs;
  final priceTrends = <Map<String, dynamic>>[].obs;
  final selectedPeriod = '7_days'.obs; // 7_days, 30_days

  // Stats
  final totalProducts = 0.obs;
  final activeProducts = 0.obs;
  final pricesSetToday = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _initRepositories();
    fetchReportData();
  }

  void _initRepositories() {
    try {
      _productRepository = Get.find<ProductRepository>();
      _priceRepository = Get.find<PriceRepository>();
    } catch (e) {
      debugPrint('Error initializing repositories: $e');
    }
  }

  Future<void> fetchReportData({int? days}) async {
    isLoading.value = true;
    final int reportDays =
        days ??
        (selectedPeriod.value == '30_days'
            ? 30
            : selectedPeriod.value == '90_days'
            ? 90
            : 7);
    try {
      final vendorId = _storage.read('vendor_id');
      if (vendorId == null || vendorId.toString().isEmpty) {
        Get.snackbar('Error', 'Vendor ID not found');
        return;
      }

      // 1. Fetch Products for counts
      final allProducts = await _productRepository.getProducts(
        vendorId,
        activeOnly: false,
      );
      products.value = allProducts;

      totalProducts.value = allProducts.length;
      activeProducts.value = allProducts.where((p) => p.isActive).length;

      // 2. Fetch Price Trends (Based on selected period)
      final trends = await _priceRepository.getPriceTrends(
        vendorId,
        days: reportDays,
      );
      priceTrends.value = trends;

      // 3. Count prices set today (from products list as it joins daily_prices)
      pricesSetToday.value = allProducts
          .where((p) => p.currentPrice != null)
          .length;
    } catch (e) {
      debugPrint('Error fetching reports: $e');
      Get.snackbar('Error', 'Failed to load report data');
    } finally {
      isLoading.value = false;
    }
  }

  // Get average price per day
  List<Map<String, dynamic>> get averagePriceHistory {
    if (priceTrends.isEmpty) return [];

    final Map<String, List<double>> dailyPrices = {};

    for (var trend in priceTrends) {
      final date = trend['price_date'];
      String dateStr;
      if (date is DateTime) {
        dateStr = date.toIso8601String().split('T')[0];
      } else {
        dateStr = date.toString().split('T')[0];
      }

      final price = double.tryParse(trend['price'].toString()) ?? 0.0;

      if (!dailyPrices.containsKey(dateStr)) {
        dailyPrices[dateStr] = [];
      }
      dailyPrices[dateStr]!.add(price);
    }

    final List<Map<String, dynamic>> result = [];
    dailyPrices.forEach((date, prices) {
      if (prices.isNotEmpty) {
        final avg = prices.reduce((a, b) => a + b) / prices.length;
        result.add({'date': date, 'price': avg});
      }
    });

    // Sort by date
    result.sort((a, b) => a['date'].compareTo(b['date']));
    return result;
  }

  void onChangePeriod(String period) {
    selectedPeriod.value = period;
    int days = 7;
    if (period == '30_days') days = 30;
    if (period == '90_days') days = 90;
    fetchReportData(days: days);
  }

  /// Chart data for price trends visualization
  List<Map<String, dynamic>> get chartData {
    return averagePriceHistory.map((entry) {
      return {'date': entry['date'], 'value': entry['price']};
    }).toList();
  }

  /// Top products based on price or activity
  List<Product> get topProducts {
    final sorted = products.toList()
      ..sort((a, b) {
        final priceA = a.currentPrice ?? 0.0;
        final priceB = b.currentPrice ?? 0.0;
        return priceB.compareTo(priceA);
      });
    return sorted.take(5).toList();
  }

  /// Format date label for charts
  String getDateLabel(dynamic date) {
    if (date is DateTime) {
      return '${date.day}/${date.month}';
    } else if (date is String) {
      try {
        final parsed = DateTime.parse(date);
        return '${parsed.day}/${parsed.month}';
      } catch (_) {
        return date.toString().split('T')[0];
      }
    }
    return date.toString();
  }
}
