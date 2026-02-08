import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:green_veg_stock_management/app/controllers/app_controller.dart';
import 'package:green_veg_stock_management/app/data/models/phase2_models.dart';
import 'package:green_veg_stock_management/app/data/models/product_model.dart';
import 'package:green_veg_stock_management/app/data/repositories/purchase_repository.dart';
import 'package:green_veg_stock_management/app/data/repositories/product_repository.dart';

class PurchaseController extends GetxController {
  final PurchaseRepository _repository = PurchaseRepository();
  final ProductRepository _productRepository = ProductRepository();
  final AppController _appController = Get.find<AppController>();

  // Observables
  final RxList<Purchase> purchases = <Purchase>[].obs;
  final RxList<PurchaseItem> currentItems = <PurchaseItem>[].obs;
  final RxList<Product> availableProducts = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxDouble totalAmount = 0.0.obs;

  // Form controllers
  final supplierController = TextEditingController();
  final notesController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadPurchases();
    loadProducts();
  }

  @override
  void onClose() {
    supplierController.dispose();
    notesController.dispose();
    super.onClose();
  }

  Future<void> loadPurchases() async {
    isLoading.value = true;
    try {
      final vendorId = _appController.vendorId.value;
      if (vendorId.isEmpty) return;

      final data = await _repository.getPurchases(
        vendorId,
        startDate: selectedDate.value.subtract(const Duration(days: 30)),
        endDate: selectedDate.value,
      );
      purchases.value = data;
    } catch (e) {
      Get.snackbar('error'.tr, 'failed_to_load_purchases'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadProducts() async {
    try {
      final vendorId = _appController.vendorId.value;
      if (vendorId.isEmpty) return;

      final products = await _productRepository.getProducts(vendorId);
      availableProducts.value = products;
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  void addItem(Product product, double quantity, double pricePerUnit) {
    final existingIndex = currentItems.indexWhere(
      (item) => item.productId == product.id,
    );

    final totalPrice = quantity * pricePerUnit;

    if (existingIndex >= 0) {
      final existing = currentItems[existingIndex];
      currentItems[existingIndex] = PurchaseItem(
        id: existing.id,
        purchaseId: existing.purchaseId,
        productId: existing.productId,
        quantity: existing.quantity + quantity,
        pricePerUnit: pricePerUnit,
        totalPrice: (existing.totalPrice ?? 0) + totalPrice,
        notes: existing.notes,
        createdAt: existing.createdAt,
        productNameGu: existing.productNameGu,
        productNameEn: existing.productNameEn,
        unitSymbol: existing.unitSymbol,
      );
    } else {
      currentItems.add(
        PurchaseItem(
          id: '',
          purchaseId: '',
          productId: product.id,
          quantity: quantity,
          pricePerUnit: pricePerUnit,
          totalPrice: totalPrice,
          createdAt: DateTime.now(),
          productNameGu: product.nameGu,
          productNameEn: product.nameEn,
          unitSymbol: product.unitSymbol,
        ),
      );
    }
    calculateTotal();
  }

  void updateItemQuantity(int index, double quantity) {
    if (quantity <= 0) {
      removeItem(index);
      return;
    }

    final item = currentItems[index];
    final totalPrice = quantity * (item.pricePerUnit ?? 0);

    currentItems[index] = PurchaseItem(
      id: item.id,
      purchaseId: item.purchaseId,
      productId: item.productId,
      quantity: quantity,
      pricePerUnit: item.pricePerUnit,
      totalPrice: totalPrice,
      notes: item.notes,
      createdAt: item.createdAt,
      productNameGu: item.productNameGu,
      productNameEn: item.productNameEn,
      unitSymbol: item.unitSymbol,
    );
    calculateTotal();
  }

  void removeItem(int index) {
    currentItems.removeAt(index);
    calculateTotal();
  }

  void calculateTotal() {
    double total = 0;
    for (final item in currentItems) {
      total += (item.totalPrice ?? 0);
    }
    totalAmount.value = total;
  }

  Future<bool> savePurchase() async {
    if (currentItems.isEmpty) {
      Get.snackbar('error'.tr, 'please_add_items'.tr);
      return false;
    }

    isSaving.value = true;
    try {
      final vendorId = _appController.vendorId.value;
      if (vendorId.isEmpty) return false;

      final purchase = Purchase(
        id: '',
        vendorId: vendorId,
        supplierName: supplierController.text.trim().isEmpty
            ? null
            : supplierController.text.trim(),
        purchaseDate: DateTime.now(),
        totalAmount: totalAmount.value,
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.createPurchase(purchase, currentItems.toList());

      Get.snackbar('success'.tr, 'purchase_saved'.tr);
      await loadPurchases();
      clearForm();
      return true;
    } catch (e) {
      Get.snackbar('error'.tr, 'failed_to_save_purchase'.tr);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  void clearForm() {
    supplierController.clear();
    notesController.clear();
    currentItems.clear();
    totalAmount.value = 0;
  }

  Future<void> deletePurchase(String purchaseId) async {
    try {
      await _repository.deletePurchase(purchaseId);
      await loadPurchases();
      Get.snackbar('success'.tr, 'purchase_deleted'.tr);
    } catch (e) {
      Get.snackbar('error'.tr, 'failed_to_delete_purchase'.tr);
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }
}
