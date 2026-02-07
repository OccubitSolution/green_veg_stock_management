/// Daily Prices Controller
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/price_repository.dart';

class DailyPricesController extends GetxController {
  final ProductRepository _productRepository = Get.find<ProductRepository>();
  final PriceRepository _priceRepository = Get.find<PriceRepository>();
  final _storage = GetStorage();

  // Controllers
  final searchController = TextEditingController();
  final Map<String, TextEditingController> priceControllers = {};

  // Observable States
  final isLoading = false.obs;
  final selectedDate = DateTime.now().obs;
  final formattedDate = ''.obs;
  final searchQuery = ''.obs;
  final products = <Product>[].obs;
  final filteredProducts = <Product>[].obs;
  final prices = <String, double>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _updateFormattedDate();
    fetchData();
  }

  @override
  void onClose() {
    searchController.dispose();
    for (var controller in priceControllers.values) {
      controller.dispose();
    }
    super.onClose();
  }

  void _updateFormattedDate() {
    final lang = _storage.read('language') ?? 'gu';
    if (lang == 'gu') {
      formattedDate.value = DateFormat(
        'dd MMMM, yyyy',
        'en',
      ).format(selectedDate.value);
    } else {
      formattedDate.value = DateFormat(
        'MMMM dd, yyyy',
      ).format(selectedDate.value);
    }
  }

  Future<void> fetchData() async {
    isLoading.value = true;

    try {
      final vendorId = _storage.read('vendor_id');
      print('🛒 [DailyPrices] Fetching data for vendor: $vendorId');
      if (vendorId == null) {
        print('❌ [DailyPrices] No vendor ID found');
        return;
      }

      // Fetch products
      print('📦 [DailyPrices] Fetching products...');
      final productList = await _productRepository.getProducts(vendorId);
      print('✅ [DailyPrices] Products fetched: ${productList.length}');
      products.value = productList;
      filteredProducts.value = productList;

      // Initialize price controllers
      for (var product in productList) {
        priceControllers[product.id] = TextEditingController();
      }

      // Fetch today's prices
      await fetchPricesForDate();
    } catch (e) {
      Get.snackbar('error'.tr, 'something_went_wrong'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPricesForDate() async {
    try {
      final vendorId = _storage.read('vendor_id');
      if (vendorId == null) return;

      final priceData = await _priceRepository.getPricesForDate(
        vendorId,
        selectedDate.value,
      );

      prices.clear();
      for (var item in priceData) {
        final productId = item['product_id'] as String;
        final price = (item['price'] as num).toDouble();
        prices[productId] = price;

        if (priceControllers.containsKey(productId)) {
          priceControllers[productId]!.text = price.toString();
        }
      }
    } catch (e) {
      print('Error fetching prices: $e');
    }
  }

  double? getPriceForProduct(String productId) {
    return prices[productId];
  }

  void updatePrice(String productId, String value) {
    final price = double.tryParse(value);
    if (price != null) {
      prices[productId] = price;
    } else {
      prices.remove(productId);
    }
  }

  void searchProducts(String query) {
    searchQuery.value = query;

    if (query.isEmpty) {
      filteredProducts.value = products;
    } else {
      final lang = Get.locale?.languageCode ?? 'gu';
      filteredProducts.value = products.where((product) {
        final name = product.getName(lang).toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
    }
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    filteredProducts.value = products;
  }

  void previousDay() {
    selectedDate.value = selectedDate.value.subtract(const Duration(days: 1));
    _updateFormattedDate();
    fetchPricesForDate();
  }

  void nextDay() {
    if (selectedDate.value.isBefore(DateTime.now())) {
      selectedDate.value = selectedDate.value.add(const Duration(days: 1));
      _updateFormattedDate();
      fetchPricesForDate();
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      selectedDate.value = picked;
      _updateFormattedDate();
      fetchPricesForDate();
    }
  }

  Future<void> copyPreviousDayPrices() async {
    try {
      final vendorId = _storage.read('vendor_id');
      if (vendorId == null) return;

      final count = await _priceRepository.copyPreviousDayPrices(
        vendorId,
        selectedDate.value,
      );

      if (count > 0) {
        await fetchPricesForDate();
        Get.snackbar(
          'success'.tr,
          'copied_prices'.trParams({'count': count.toString()}),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
        );
      } else {
        Get.snackbar(
          'info'.tr,
          'no_prices_to_copy'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar('error'.tr, 'something_went_wrong'.tr);
    }
  }

  Future<void> savePrices() async {
    try {
      final vendorId = _storage.read('vendor_id');
      if (vendorId == null) return;

      // Collect prices to save
      final pricesToSave = <Map<String, dynamic>>[];

      for (var entry in priceControllers.entries) {
        final productId = entry.key;
        final value = entry.value.text.trim();

        if (value.isNotEmpty) {
          final price = double.tryParse(value);
          if (price != null && price > 0) {
            pricesToSave.add({'product_id': productId, 'price': price});
          }
        }
      }

      if (pricesToSave.isEmpty) {
        Get.snackbar('info'.tr, 'no_prices_to_save'.tr);
        return;
      }

      final success = await _priceRepository.bulkUpdatePrices(
        vendorId,
        selectedDate.value,
        pricesToSave,
      );

      if (success) {
        Get.snackbar(
          'success'.tr,
          'prices_saved'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
        );
      }
    } catch (e) {
      Get.snackbar('error'.tr, 'something_went_wrong'.tr);
    }
  }
}
