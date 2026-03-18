import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:green_veg_stock_management/app/controllers/app_controller.dart';
import 'package:green_veg_stock_management/app/data/models/customer_order_models.dart';
import 'package:green_veg_stock_management/app/data/models/product_model.dart';
import 'package:green_veg_stock_management/app/data/repositories/order_repository.dart';
import 'package:green_veg_stock_management/app/data/repositories/product_repository.dart';
import 'package:green_veg_stock_management/app/data/repositories/price_repository.dart';

/// Order Controller
/// Manages daily order collection and viewing
class OrderController extends GetxController {
  final OrderRepository _orderRepository = OrderRepository();
  final ProductRepository _productRepository = ProductRepository();
  final PriceRepository _priceRepository = PriceRepository();
  final AppController _appController = Get.find<AppController>();

  // Observables
  final RxList<Order> todayOrders = <Order>[].obs;
  final RxList<Order> filteredTodayOrders =
      <Order>[].obs; // Added for search filtering
  final RxList<OrderItem> currentOrderItems = <OrderItem>[].obs;
  final RxList<Product> availableProducts = <Product>[].obs;
  final RxList<Product> filteredProducts = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<Customer?> selectedCustomer = Rx<Customer?>(null);
  final RxString productSearchQuery = ''.obs;
  final RxString orderSearchQuery = ''.obs; // Added for order search
  final RxDouble currentOrderTotal = 0.0.obs;
  final RxMap<String, double> todayPrices = <String, double>{}.obs;
  final RxString editingOrderId = ''.obs; // Track if editing existing order
  final Rx<DeliverySlot> selectedDeliverySlot = DeliverySlot.morning.obs; // Added delivery slot

  // Form controllers
  final notesController = TextEditingController();
  final productSearchController = TextEditingController();
  final deliveryAddressController = TextEditingController();
  final contactPhoneController = TextEditingController();
  final paidAmountController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadTodayOrders();
    loadAvailableProducts();
    loadTodayPrices();

    // Calculate total when items change
    ever(currentOrderItems, (_) => calculateOrderTotal());
    // Reload prices when date changes
    ever(selectedDate, (_) => loadTodayPrices());
  }

  @override
  void onClose() {
    notesController.dispose();
    productSearchController.dispose();
    deliveryAddressController.dispose();
    contactPhoneController.dispose();
    paidAmountController.dispose();
    super.onClose();
  }

  /// Load orders for selected date
  Future<void> loadTodayOrders() async {
    isLoading.value = true;
    try {
      final vendorId = _appController.vendorId.value;
      if (vendorId.isEmpty) {
        isLoading.value = false;
        return;
      }

      final orders = await _orderRepository.getOrdersByDate(
        vendorId,
        selectedDate.value,
      );
      todayOrders.value = orders;
      filterOrders(orderSearchQuery.value); // Apply current filter
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
      debugPrint('Error loading products: $e');
    }
  }

  /// Load today's prices for order calculations
  Future<void> loadTodayPrices() async {
    try {
      final vendorId = _appController.vendorId.value;
      if (vendorId.isEmpty) return;

      todayPrices.value = await _priceRepository.getPricesForDateMap(
        vendorId,
        selectedDate.value,
      );
    } catch (e) {
      debugPrint('Error loading prices: $e');
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

  /// Filter orders based on search query
  void filterOrders(String query) {
    orderSearchQuery.value = query;
    if (query.isEmpty) {
      filteredTodayOrders.value = todayOrders;
    } else {
      final lowerQuery = query.toLowerCase();
      filteredTodayOrders.value = todayOrders.where((o) {
        final customerName = o.customerName?.toLowerCase() ?? '';
        return customerName.contains(lowerQuery);
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
    deliveryAddressController.clear();
    contactPhoneController.clear();
  }

  /// Add item to current order
  void addOrderItem(Product product, double quantity, {String? notes, double? costPrice}) {
    final existingIndex = currentOrderItems.indexWhere(
      (item) => item.productId == product.id,
    );

    // Get price from today's prices
    final pricePerUnit = todayPrices[product.id] ?? 0.0;
    final newQuantity = existingIndex >= 0
        ? currentOrderItems[existingIndex].quantity + quantity
        : quantity;
    final totalPrice = newQuantity * pricePerUnit;

    if (existingIndex >= 0) {
      // Update existing item
      final existing = currentOrderItems[existingIndex];
      currentOrderItems[existingIndex] = OrderItem(
        id: existing.id,
        orderId: existing.orderId,
        productId: existing.productId,
        quantity: newQuantity,
        pricePerUnit: pricePerUnit,
        costPrice: costPrice ?? existing.costPrice,
        totalPrice: totalPrice,
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
          pricePerUnit: pricePerUnit,
          costPrice: costPrice,
          totalPrice: totalPrice,
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

  /// Add custom item (not from product list)
  void addCustomItem({
    required String itemName,
    required double quantity,
    required double sellingPrice,
    double? costPrice,
    String? unitSymbol,
    String? notes,
  }) {
    final totalPrice = quantity * sellingPrice;
    
    currentOrderItems.add(
      OrderItem(
        id: '',
        orderId: '',
        productId: null, // Custom item has no product ID
        quantity: quantity,
        pricePerUnit: sellingPrice,
        costPrice: costPrice,
        totalPrice: totalPrice,
        notes: notes,
        createdAt: DateTime.now(),
        isCustomItem: true,
        customItemName: itemName,
        unitSymbol: unitSymbol,
      ),
    );
    currentOrderItems.refresh();
  }

  /// Update custom item
  void updateCustomItem(int index, {
    String? itemName,
    double? quantity,
    double? sellingPrice,
    double? costPrice,
    String? unitSymbol,
    String? notes,
  }) {
    final item = currentOrderItems[index];
    final newQuantity = quantity ?? item.quantity;
    final newPrice = sellingPrice ?? item.pricePerUnit ?? 0;
    final totalPrice = newQuantity * newPrice;
    
    currentOrderItems[index] = OrderItem(
      id: item.id,
      orderId: item.orderId,
      productId: item.productId,
      quantity: newQuantity,
      pricePerUnit: newPrice,
      costPrice: costPrice,
      totalPrice: totalPrice,
      notes: notes ?? item.notes,
      createdAt: item.createdAt,
      isCustomItem: true,
      customItemName: itemName ?? item.customItemName,
      unitSymbol: unitSymbol ?? item.unitSymbol,
      productNameGu: item.productNameGu,
      productNameEn: item.productNameEn,
    );
    currentOrderItems.refresh();
  }

  /// Update item quantity
  void updateItemQuantity(int index, double quantity, {double? costPrice}) {
    if (quantity <= 0) {
      removeOrderItem(index);
      return;
    }

    final item = currentOrderItems[index];
    final pricePerUnit =
        item.pricePerUnit ?? todayPrices[item.productId] ?? 0.0;
    final totalPrice = quantity * pricePerUnit;

    currentOrderItems[index] = OrderItem(
      id: item.id,
      orderId: item.orderId,
      productId: item.productId,
      quantity: quantity,
      pricePerUnit: pricePerUnit,
      costPrice: costPrice ?? item.costPrice,
      totalPrice: totalPrice,
      notes: item.notes,
      createdAt: item.createdAt,
      isCustomItem: item.isCustomItem,
      customItemName: item.customItemName,
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

  /// Quick add 1 unit of a product (for inline + button)
  void incrementProduct(Product product) {
    addOrderItem(product, 1.0);
  }

  /// Decrement product quantity by 1 (for inline - button)
  void decrementProduct(Product product) {
    final existingIndex = currentOrderItems.indexWhere(
      (item) => item.productId == product.id,
    );

    if (existingIndex >= 0) {
      final currentQty = currentOrderItems[existingIndex].quantity;
      if (currentQty <= 1.0) {
        // Remove item if quantity would go to 0
        removeOrderItem(existingIndex);
      } else {
        // Decrement by 1
        updateItemQuantity(existingIndex, currentQty - 1.0);
      }
    }
  }

  /// Get product by ID (helper for UI)
  Product? getProductById(String productId) {
    try {
      return availableProducts.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  /// Calculate order total
  void calculateOrderTotal() {
    double total = 0;
    double totalCost = 0;
    for (final item in currentOrderItems) {
      if (item.totalPrice != null) {
        total += item.totalPrice!;
      }
      if (item.costPrice != null) {
        totalCost += item.costPrice! * item.quantity;
      }
    }
    currentOrderTotal.value = total;
    currentOrderTotalCost.value = totalCost;
  }

  /// Get total cost of current order
  final RxDouble currentOrderTotalCost = 0.0.obs;

  /// Clear current order
  void clearCurrentOrder() {
    selectedCustomer.value = null;
    currentOrderItems.clear();
    notesController.clear();
    productSearchController.clear();
    deliveryAddressController.clear();
    contactPhoneController.clear();
    paidAmountController.clear();
    productSearchQuery.value = '';
    filteredProducts.value = availableProducts;
    currentOrderTotal.value = 0;
    currentOrderTotalCost.value = 0;
    editingOrderId.value = ''; // Reset editing state
    selectedDeliverySlot.value = DeliverySlot.morning; // Reset delivery slot
  }

  /// Load an existing order for editing
  Future<void> loadOrderForEditing(Order order) async {
    // Store the order ID to track that we're editing
    editingOrderId.value = order.id;
    selectedDeliverySlot.value = order.deliverySlot; // Set delivery slot

    // Set customer from order data
    selectedCustomer.value = Customer(
      id: order.customerId,
      vendorId: order.vendorId,
      name: order.customerName ?? 'Unknown',
      type: order.customerType ?? CustomerType.other,
      createdAt: order.createdAt,
      updatedAt: order.updatedAt,
    );
    notesController.text = order.notes ?? '';

    // Load existing items for this order
    try {
      final items = await _orderRepository.getOrderItems(order.id);
      currentOrderItems.value = items;
      // Explicitly calculate total after loading items
      calculateOrderTotal();
    } catch (e) {
      debugPrint('Error loading order items: $e');
      currentOrderItems.clear();
      currentOrderTotal.value = 0;
    }
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
      if (vendorId.isEmpty) {
        Get.snackbar(
          'error'.tr,
          'user_session_expired'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      final order = Order(
        id: editingOrderId.value.isNotEmpty ? editingOrderId.value : '',
        customerId: selectedCustomer.value!.id,
        vendorId: vendorId,
        orderDate: selectedDate.value,
        status: OrderStatus.pending,
        deliverySlot: selectedDeliverySlot.value, // Added delivery slot
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Check if editing existing order or creating new
      if (editingOrderId.value.isNotEmpty) {
        // Update existing order
        await _orderRepository.updateOrder(
          editingOrderId.value,
          order,
          currentOrderItems.toList(),
        );
      } else {
        // Create new order
        await _orderRepository.createOrder(order, currentOrderItems.toList());
      }

      Get.snackbar(
        'success'.tr,
        editingOrderId.value.isNotEmpty ? 'order_updated'.tr : 'order_saved'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );

      // Refresh orders list
      await loadTodayOrders();
      clearCurrentOrder();
      return true;
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        '${'failed_to_save_order'.tr}: $e',
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

    // Calculate total items across all orders for the day
    double totalItems = 0;
    // Note: If orders don't store items directly, we might need to fetch them
    // but for the UI stat card, we just need a non-null value for now.

    return {
      'totalOrders': totalOrders,
      'totalCustomers': totalCustomers,
      'totalItems': totalItems,
    };
  }
}
