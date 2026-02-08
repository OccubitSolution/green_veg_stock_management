/// Products Controller
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/product_repository.dart';

class ProductsController extends GetxController {
  late final ProductRepository _productRepository;
  final _storage = GetStorage();

  // Controllers
  final searchController = TextEditingController();

  // Observable States
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final selectedCategory = ''.obs;
  final products = <Product>[].obs;
  final filteredProducts = <Product>[].obs;
  final categories = <Category>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initRepository();
    fetchData();
  }

  void _initRepository() {
    try {
      _productRepository = Get.find<ProductRepository>();
    } catch (e) {
      debugPrint('Error initializing product repository: $e');
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchData() async {
    isLoading.value = true;

    try {
      final vendorId = _storage.read('vendor_id');
      debugPrint('🛒 Fetching products for vendor: $vendorId');
      if (vendorId == null || vendorId.toString().isEmpty) {
        debugPrint('❌ No vendor ID found in storage');
        Get.snackbar('Error', 'Vendor ID not found. Please login again.');
        isLoading.value = false;
        return;
      }

      // Fetch categories
      debugPrint('📦 Fetching categories...');
      final categoryList = await _productRepository.getCategories(vendorId);
      debugPrint('✅ Categories fetched: ${categoryList.length}');
      categories.value = categoryList;

      // Fetch products
      debugPrint('🍎 Fetching products...');
      final productList = await _productRepository.getProducts(vendorId);
      debugPrint('✅ Products fetched: ${productList.length}');
      products.value = productList;
      filteredProducts.value = productList;
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching data: $e');
      debugPrint('Stack trace: $stackTrace');
      Get.snackbar('error'.tr, 'something_went_wrong'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  void searchProducts(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    _applyFilters();
  }

  void filterByCategory(String categoryId) {
    selectedCategory.value = categoryId;
    _applyFilters();
  }

  void _applyFilters() {
    final lang = Get.locale?.languageCode ?? 'gu';

    filteredProducts.value = products.where((product) {
      // Search filter
      if (searchQuery.value.isNotEmpty) {
        final name = product.getName(lang).toLowerCase();
        if (!name.contains(searchQuery.value.toLowerCase())) {
          return false;
        }
      }

      // Category filter
      if (selectedCategory.value.isNotEmpty) {
        if (product.categoryId != selectedCategory.value) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Future<void> refreshProducts() async {
    await fetchData();
  }
}
