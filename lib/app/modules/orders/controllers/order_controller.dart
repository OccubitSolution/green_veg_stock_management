import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:green_veg_stock_management/app/controllers/app_controller.dart';
import 'package:green_veg_stock_management/app/data/models/customer_order_models.dart';
import 'package:green_veg_stock_management/app/data/models/product_model.dart';
import 'package:green_veg_stock_management/app/data/repositories/order_repository.dart';
import 'package:green_veg_stock_management/app/data/repositories/product_repository.dart';

/// Order Controller
/// Manages daily order collection and viewing
class OrderController extends GetxController {
  final OrderRepository _orderRepository = OrderRepository();
  final ProductRepository _productRepository = ProductRepository();
  final AppController _appController = Get.find<AppController>();

  // Observables
  final RxList<Order> todayOrders = <Order>[].obs;
  final RxList<OrderItem> currentOrderItems = <OrderItem>[].obs;
  final RxList<Product> availableProducts = <Product>[].obs;
  final RxList<Product> filteredProducts = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<Customer?> selectedCustomer = Rx<Customer?>(null);
  final RxString productSearchQuery = ''.obs;
  final RxDouble currentOrderTotal = 0.0.obs;

  // Form controllers
  final notesController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadTodayOrders();
    loadAvailableProducts();

    // Calculate total when items change
    ever(currentOrderItems, (_) => calculateOrderTotal());
  }

  @override
  void onClose() {
    notesController.dispose();
    super.onClose();
  }

  /// Load orders for selected date
  Future<void> loadTodayOrders() async {
    isLoading.value = true;
    try {
      final vendorId = _appController.vendorId.value;
      if (vendorId.isEmpty) return;

      final orders = await _orderRepository.getOrdersByDate(
        vendorId,
        selectedDate.value,
      );
      todayOrders.value = orders;
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_load_orders'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load available products for ordering
  Future<void> loadAvailableProducts() async {
    try {
      final vendorId = _appController.vendorId.value;
      if (vendorId.isEmpty) return;

      final products = await _productRepository.getProducts(vendorId);
      availableProducts.value = products;
      filteredProducts.value = products;
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  /// Filter products based on search query
  void filterProducts(String query) {
    productSearchQuery.value = query;
    if (query.isEmpty) {
      filteredProducts.value = availableProducts;
    } else {
      final lowerQuery = query.toLowerCase();
      filteredProducts.value = availableProducts.where((p) {
        final nameEn = p.nameEn?.toLowerCase() ?? '';
        final nameGu = p.nameGu.toLowerCase();
        return nameEn.contains(lowerQuery) || nameGu.contains(lowerQuery);
      }).toList();
    }
  }

  /// Select date
  void setDate(DateTime date) {
    selectedDate.value = date;
    loadTodayOrders();
  }

  /// Select customer for order
  void selectCustomer(Customer customer) {
    selectedCustomer.value = customer;
    // Clear previous items when selecting new customer
    currentOrderItems.clear();
    notesController.clear();
  }

  /// Add item to current order
  void addOrderItem(Product product, double quantity, {String? notes}) {
    final existingIndex = currentOrderItems.indexWhere(
      (item) => item.productId == product.id,
    );

    if (existingIndex >= 0) {
      // Update existing item
      final existing = currentOrderItems[existingIndex];
      currentOrderItems[existingIndex] = OrderItem(
        id: existing.id,
        orderId: existing.orderId,
        productId: existing.productId,
        quantity: existing.quantity + quantity,
        notes: notes ?? existing.notes,
        createdAt: existing.createdAt,
        productNameGu: existing.productNameGu,
        productNameEn: existing.productNameEn,
        unitSymbol: existing.unitSymbol,
      );
    } else {
      // Add new item
      currentOrderItems.add(
        OrderItem(
          id: '',
          orderId: '',
          productId: product.id,
          quantity: quantity,
          notes: notes,
          createdAt: DateTime.now(),
          productNameGu: product.nameGu,
          productNameEn: product.nameEn,
          unitSymbol: product.unitSymbol,
        ),
      );
    }
    currentOrderItems.refresh();
  }

  /// Update item quantity
  void updateItemQuantity(int index, double quantity) {
    if (quantity <= 0) {
      removeOrderItem(index);
      return;
    }

    final item = currentOrderItems[index];
    currentOrderItems[index] = OrderItem(
      id: item.id,
      orderId: item.orderId,
      productId: item.productId,
      quantity: quantity,
      pricePerUnit: item.pricePerUnit,
      totalPrice: item.totalPrice,
      notes: item.notes,
      createdAt: item.createdAt,
      productNameGu: item.productNameGu,
      productNameEn: item.productNameEn,
      unitSymbol: item.unitSymbol,
    );
    currentOrderItems.refresh();
  }

  /// Remove item from order
  void removeOrderItem(int index) {
    currentOrderItems.removeAt(index);
  }

  /// Calculate order total
  void calculateOrderTotal() {
    double total = 0;
    for (final item in currentOrderItems) {
      if (item.totalPrice != null) {
        total += item.totalPrice!;
      }
    }
    currentOrderTotal.value = total;
  }

  /// Clear current order
  void clearCurrentOrder() {
    selectedCustomer.value = null;
    currentOrderItems.clear();
    notesController.clear();
    currentOrderTotal.value = 0;
  }

  /// Save order
  Future<bool> saveOrder() async {
    if (selectedCustomer.value == null) {
      Get.snackbar(
        'error'.tr,
        'please_select_customer'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (currentOrderItems.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'please_add_items'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    isSaving.value = true;
    try {
      final vendorId = _appController.vendorId.value;
      if (vendorId.isEmpty) return false;

      final order = Order(
        id: '',
        customerId: selectedCustomer.value!.id,
        vendorId: vendorId,
        orderDate: selectedDate.value,
        status: OrderStatus.pending,
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _orderRepository.createOrder(order, currentOrderItems.toList());

      Get.snackbar(
        'success'.tr,
        'order_saved'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );

      // Refresh orders list
      await loadTodayOrders();
      clearCurrentOrder();
      return true;
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_save_order'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Delete order
  Future<void> deleteOrder(String orderId) async {
    try {
      await _orderRepository.deleteOrder(orderId);
      await loadTodayOrders();
      Get.snackbar(
        'success'.tr,
        'order_deleted'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_delete_order'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Get order statistics
  Map<String, dynamic> get orderStats {
    final totalOrders = todayOrders.length;
    final totalCustomers = todayOrders.map((o) => o.customerId).toSet().length;

    return {'totalOrders': totalOrders, 'totalCustomers': totalCustomers};
  }
}
