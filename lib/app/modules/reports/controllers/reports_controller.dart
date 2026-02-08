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
      print('Error initializing repositories: $e');
    }
  }

  Future<void> fetchReportData() async {
    isLoading.value = true;
    try {
      final vendorId = _storage.read('vendor_id');
      if (vendorId == null) return;

      // 1. Fetch Products for counts
      final allProducts = await _productRepository.getProducts(
        vendorId,
        activeOnly: false,
      );
      products.value = allProducts;

      totalProducts.value = allProducts.length;
      activeProducts.value = allProducts.where((p) => p.isActive).length;

      // 2. Fetch Price Trends (Last 7 days by default)
      final trends = await _priceRepository.getPriceTrends(vendorId, days: 7);
      priceTrends.value = trends;

      // 3. Count prices set today (from products list as it joins daily_prices)
      pricesSetToday.value = allProducts
          .where((p) => p.currentPrice != null)
          .length;
    } catch (e) {
      print('❌ Error fetching reports: $e');
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
      // trend['price_date'] is DateTime (from postgres driver mapping) or String?
      // Repository query returns DateTime for timestamp usually.
      // Let's check repository... getPriceTrends uses _db.query.
      // DatabaseProvider maps row to ColumnMap.
      // Postgres 3.x returns DateTime for timestamp/date.

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
    // Reload with new period days
    // fetchReportData(); // Enhance later to support custom days
  }
}
