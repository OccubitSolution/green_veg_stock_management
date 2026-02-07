/// Home Controller
library;

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/price_repository.dart';
// import '../../../routes/app_routes.dart';

class HomeController extends GetxController {
  final ProductRepository _productRepository = Get.find<ProductRepository>();
  final PriceRepository _priceRepository = Get.find<PriceRepository>();
  final _storage = GetStorage();

  // Observable States
  final vendorName = ''.obs;
  final todayDate = ''.obs;
  final productCount = '0'.obs;
  final categoryCount = '0'.obs;
  final pricesSetCount = '0'.obs;
  final todaySales = '₹0'.obs;
  final currentNavIndex = 0.obs;
  final isLoading = false.obs;

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

    try {
      final vendorId = _storage.read('vendor_id');
      if (vendorId == null) return;

      // Fetch product count
      final products = await _productRepository.getProducts(vendorId);
      productCount.value = products.length.toString();

      // Fetch today's prices count
      final prices = await _priceRepository.getTodayPrices(vendorId);
      pricesSetCount.value = prices.length.toString();

      // Fetch categories count
      final categories = await _productRepository.getCategories(vendorId);
      categoryCount.value = categories.length.toString();

      // TODO: Fetch today's sales total
      todaySales.value = '₹0';
    } catch (e) {
      print('Error fetching dashboard data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await fetchDashboardData();
  }
}
