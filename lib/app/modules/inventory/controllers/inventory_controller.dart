import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:green_veg_stock_management/app/controllers/app_controller.dart';
import 'package:green_veg_stock_management/app/data/models/phase2_models.dart';
import 'package:green_veg_stock_management/app/data/repositories/inventory_repository.dart';

class InventoryController extends GetxController {
  final InventoryRepository _repository = InventoryRepository();
  final AppController _appController = Get.find<AppController>();

  // Observables
  final RxList<Stock> stockItems = <Stock>[].obs;
  final RxList<Stock> lowStockItems = <Stock>[].obs;
  final RxList<Stock> outOfStockItems = <Stock>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt selectedTab = 0.obs;

  // Stats
  final RxInt totalProducts = 0.obs;
  final RxInt inStockCount = 0.obs;
  final RxInt lowStockCount = 0.obs;
  final RxInt outOfStockCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadInventory();
  }

  Future<void> loadInventory() async {
    isLoading.value = true;
    try {
      final vendorId = _appController.vendorId.value;
      if (vendorId.isEmpty) return;

      // Load all stock
      final stock = await _repository.getStock(vendorId);
      stockItems.value = stock;

      // Load low stock
      final lowStock = await _repository.getLowStock(vendorId);
      lowStockItems.value = lowStock;

      // Load out of stock
      final outOfStock = await _repository.getOutOfStock(vendorId);
      outOfStockItems.value = outOfStock;

      // Load stats
      final stats = await _repository.getInventoryStats(vendorId);
      totalProducts.value = stats['totalProducts'];
      inStockCount.value = stats['inStock'];
      lowStockCount.value = stats['lowStock'];
      outOfStockCount.value = stats['outOfStock'];
    } catch (e) {
      Get.snackbar('error'.tr, 'failed_to_load_inventory'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> adjustStock(
    String productId,
    double newQuantity,
    String reason,
  ) async {
    try {
      final vendorId = _appController.vendorId.value;
      if (vendorId.isEmpty) return;

      await _repository.adjustStock(vendorId, productId, newQuantity, reason);
      await loadInventory();
      Get.snackbar('success'.tr, 'stock_adjusted'.tr);
    } catch (e) {
      Get.snackbar('error'.tr, 'failed_to_adjust_stock'.tr);
    }
  }

  Future<void> recordWaste(
    String stockId,
    double quantity,
    String reason,
  ) async {
    try {
      await _repository.recordWaste(stockId, quantity, reason);
      await loadInventory();
      Get.snackbar('success'.tr, 'waste_recorded'.tr);
    } catch (e) {
      Get.snackbar('error'.tr, 'failed_to_record_waste'.tr);
    }
  }

  List<Stock> get filteredStock {
    switch (selectedTab.value) {
      case 1:
        return lowStockItems;
      case 2:
        return outOfStockItems;
      default:
        return stockItems;
    }
  }

  String getStockStatusText(Stock stock) {
    if (stock.isOutOfStock) return 'out_of_stock'.tr;
    if (stock.isLowStock) return 'low_stock'.tr;
    return 'in_stock'.tr;
  }

  Color getStockStatusColor(Stock stock) {
    if (stock.isOutOfStock) return const Color(0xFFE53935);
    if (stock.isLowStock) return const Color(0xFFFF9800);
    return const Color(0xFF4CAF50);
  }
}
