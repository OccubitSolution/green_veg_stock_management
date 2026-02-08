import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:green_veg_stock_management/app/data/models/customer_order_models.dart';
import 'package:green_veg_stock_management/app/data/models/product_model.dart';
import 'package:green_veg_stock_management/app/modules/orders/controllers/order_controller.dart';
import 'package:green_veg_stock_management/app/widgets/common_widgets.dart';

class OrdersView extends GetView<OrderController> {
  const OrdersView({super.key});

  // Exact sizing specifications
  static const double _dateSelectorHeight = 56.0;
  static const double _cardBorderRadius = 16.0;
  static const double _iconSize = 24.0;
  static const double _spacingXS = 4.0;
  static const double _spacingSM = 8.0;
  static const double _spacingMD = 16.0;
  static const double _spacingLG = 24.0;
  static const double _spacingXL = 32.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      body: Column(
        children: [
          // Header Section
          _buildHeader(context),

          // Date Selector
          _buildDateSelector(context),

          // Main Content
          Expanded(
            child: Obx(() {
              if (controller.selectedCustomer.value == null) {
                return _buildCustomerSelection(context);
              }
              return _buildOrderEntry(context);
            }),
          ),
        ],
      ),
      bottomNavigationBar: Obx(() {
        if (controller.selectedCustomer.value != null) {
          return _buildBottomBar(context);
        }
        return const SizedBox.shrink();
      }),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00897B), Color(0xFF004D40)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(_cardBorderRadius),
          bottomRight: Radius.circular(_cardBorderRadius),
        ),
      ),
      constraints: const BoxConstraints(maxHeight: 250),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(_spacingMD),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button if customer selected
                  Obx(
                    () => controller.selectedCustomer.value != null
                        ? IconButton(
                            onPressed: () => controller.clearCurrentOrder(),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          )
                        : const SizedBox(width: 48),
                  ),

                  // Title
                  Text(
                    'daily_orders'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),

                  // Purchase List Button
                  IconButton(
                    onPressed: () => Get.toNamed('/purchase-list'),
                    icon: Container(
                      padding: const EdgeInsets.all(_spacingSM),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: _spacingMD),

              // Stats Row
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      Icons.receipt_long,
                      controller.todayOrders.length.toString(),
                      'orders'.tr,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    _buildStatItem(
                      Icons.people,
                      controller.orderStats['totalCustomers'].toString(),
                      'customers'.tr,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    _buildStatItem(
                      Icons.inventory,
                      (controller.orderStats['totalItems'] ?? 0)
                          .toStringAsFixed(1),
                      'items'.tr,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: _spacingSM),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: _iconSize),
        const SizedBox(height: _spacingXS),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(_spacingMD),
      padding: const EdgeInsets.symmetric(
        horizontal: _spacingSM,
        vertical: _spacingXS,
      ),
      height: _dateSelectorHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(
        () => Row(
          children: [
            IconButton(
              onPressed: () {
                final newDate = controller.selectedDate.value.subtract(
                  const Duration(days: 1),
                );
                controller.setDate(newDate);
              },
              icon: const Icon(Icons.chevron_left, color: Color(0xFF00695C)),
              padding: EdgeInsets.zero,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => _selectDate(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Color(0xFF00695C),
                    ),
                    const SizedBox(width: _spacingSM),
                    Text(
                      DateFormat(
                        'EEE, dd MMM yyyy',
                      ).format(controller.selectedDate.value),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                final newDate = controller.selectedDate.value.add(
                  const Duration(days: 1),
                );
                controller.setDate(newDate);
              },
              icon: const Icon(Icons.chevron_right, color: Color(0xFF00695C)),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF00695C)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.setDate(picked);
    }
  }

  Widget _buildCustomerSelection(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _spacingMD),
          child: TextField(
            onChanged: controller.filterOrders,
            decoration: InputDecoration(
              hintText: 'search_customers'.tr,
              prefixIcon: const Icon(Icons.search, color: Color(0xFF00695C)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF00695C),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: _spacingMD,
                vertical: _spacingMD,
              ),
            ),
          ),
        ),

        const SizedBox(height: _spacingMD),

        // Today's Orders List
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const SkeletonList(count: 5);
            }

            if (controller.todayOrders.isEmpty) {
              return _buildEmptyOrdersState();
            }

            if (controller.filteredTodayOrders.isEmpty) {
              return Center(child: Text('no_orders_found'.tr));
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: _spacingMD),
              itemCount: controller.filteredTodayOrders.length,
              itemBuilder: (context, index) {
                final order = controller.filteredTodayOrders[index];
                return _buildOrderCard(order, index);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildEmptyOrdersState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF00695C).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 56,
              color: Color(0xFF00695C),
            ),
          ),
          const SizedBox(height: _spacingLG),
          Text(
            'no_orders_today'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: _spacingSM),
          Text(
            'select_customer_to_add_order'.tr,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: _spacingXL),
          ElevatedButton.icon(
            onPressed: () => _showCustomerPicker(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00695C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: _spacingLG,
                vertical: _spacingMD,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add),
            label: Text('add_new_order'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: _spacingMD),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        child: InkWell(
          onTap: () {
            // View order details
          },
          borderRadius: BorderRadius.circular(_cardBorderRadius),
          child: Padding(
            padding: const EdgeInsets.all(_spacingMD),
            child: Row(
              children: [
                // Customer Type Icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: (order.customerType?.color ?? Colors.grey)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    order.customerType?.icon ?? Icons.business,
                    color: order.customerType?.color ?? Colors.grey,
                    size: 28,
                  ),
                ),
                const SizedBox(width: _spacingMD),

                // Order Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.customerName ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: _spacingXS),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: order.status.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              order.status.getName(
                                Get.locale?.languageCode ?? 'en',
                              ),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: order.status.color,
                              ),
                            ),
                          ),
                          const SizedBox(width: _spacingSM),
                          Text(
                            '${controller.orderStats['totalItems']?.toStringAsFixed(0) ?? '0'} items',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: (index * 50).ms).fadeIn().slideX(begin: 0.1);
  }

  Widget _buildOrderEntry(BuildContext context) {
    return Column(
      children: [
        // Selected Customer Header
        Container(
          margin: const EdgeInsets.symmetric(horizontal: _spacingMD),
          padding: const EdgeInsets.all(_spacingMD),
          decoration: BoxDecoration(
            color: const Color(0xFF00695C).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF00695C).withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color:
                      (controller.selectedCustomer.value?.type.color ??
                              Colors.grey)
                          .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  controller.selectedCustomer.value?.type.icon ??
                      Icons.business,
                  color:
                      controller.selectedCustomer.value?.type.color ??
                      Colors.grey,
                ),
              ),
              const SizedBox(width: _spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.selectedCustomer.value?.name ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      controller.selectedCustomer.value?.type.getName(
                            Get.locale?.languageCode ?? 'en',
                          ) ??
                          '',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: _spacingMD),

        // Product Search
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _spacingMD),
          child: TextField(
            onChanged: controller.filterProducts,
            decoration: InputDecoration(
              hintText: 'search_products'.tr,
              prefixIcon: const Icon(Icons.search, color: Color(0xFF00695C)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF00695C),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: _spacingMD,
                vertical: _spacingMD,
              ),
            ),
          ),
        ),

        const SizedBox(height: _spacingMD),

        // Current Order Items or Product List
        Expanded(
          child: Obx(() {
            if (controller.productSearchQuery.value.isNotEmpty) {
              return _buildProductList();
            }
            return _buildCurrentOrderItems();
          }),
        ),
      ],
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: _spacingMD),
      itemCount: controller.filteredProducts.length,
      itemBuilder: (context, index) {
        final product = controller.filteredProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: _spacingMD),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        child: InkWell(
          onTap: () => _showQuantityDialog(product),
          borderRadius: BorderRadius.circular(_cardBorderRadius),
          child: Padding(
            padding: const EdgeInsets.all(_spacingMD),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF00897B).withValues(alpha: 0.15),
                        const Color(0xFF00897B).withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.eco,
                    color: Color(0xFF00897B),
                    size: 24,
                  ),
                ),
                const SizedBox(width: _spacingMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.getName(Get.locale?.languageCode ?? 'en'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        '${'unit'.tr}: ${product.unitSymbol}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showQuantityDialog(product),
                  icon: Container(
                    padding: const EdgeInsets.all(_spacingSM),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00695C).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Color(0xFF00695C),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentOrderItems() {
    if (controller.currentOrderItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_basket_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: _spacingMD),
            Text(
              'no_items_added'.tr,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: _spacingSM),
            Text(
              'search_and_add_products'.tr,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: _spacingMD),
      itemCount: controller.currentOrderItems.length,
      itemBuilder: (context, index) {
        final item = controller.currentOrderItems[index];
        return _buildOrderItemCard(item, index);
      },
    );
  }

  Widget _buildOrderItemCard(OrderItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: _spacingMD),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(_spacingMD),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF00897B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.eco, color: Color(0xFF00897B), size: 22),
            ),
            const SizedBox(width: _spacingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.getProductName(Get.locale?.languageCode ?? 'en'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    '${item.quantity} ${item.unitSymbol}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF00897B),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                _buildQuantityButton(
                  Icons.remove,
                  () =>
                      controller.updateItemQuantity(index, item.quantity - 0.5),
                ),
                Container(
                  width: 56,
                  alignment: Alignment.center,
                  child: Text(
                    item.quantity.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildQuantityButton(
                  Icons.add,
                  () =>
                      controller.updateItemQuantity(index, item.quantity + 0.5),
                ),
                const SizedBox(width: _spacingSM),
                IconButton(
                  onPressed: () => controller.removeOrderItem(index),
                  icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFF00695C).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF00695C), size: 18),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_spacingMD),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${controller.currentOrderItems.length} ${'items'.tr}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  Obx(
                    () => Text(
                      'Total: ₹${controller.currentOrderTotal.value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => controller.saveOrder(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00695C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: _spacingLG,
                  vertical: _spacingMD,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.check),
              label: Text('save_order'.tr),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCustomerPicker() async {
    // Navigate to customers list for selection
    final result = await Get.toNamed(
      '/customers',
      arguments: {'isSelectionMode': true},
    );

    if (result != null && result is Customer) {
      controller.selectCustomer(result);
    }
  }

  void _showQuantityDialog(Product product) {
    final quantityController = TextEditingController(text: '1.0');
    final notesController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(_spacingLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00897B), Color(0xFF00695C)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.eco, color: Colors.white),
                  ),
                  const SizedBox(width: _spacingMD),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.getName(Get.locale?.languageCode ?? 'en'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${'unit'.tr}: ${product.unitSymbol}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: _spacingLG),

              // Quantity Input
              Text(
                'quantity'.tr,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: _spacingSM),
              TextField(
                controller: quantityController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: 'enter_quantity'.tr,
                  suffixText: product.unitSymbol,
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF00695C),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: _spacingMD),

              // Notes Input
              Text(
                'notes'.tr,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: _spacingSM),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  hintText: 'optional_notes'.tr,
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
              ),
              const SizedBox(height: _spacingLG),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: _spacingMD,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('cancel'.tr),
                    ),
                  ),
                  const SizedBox(width: _spacingMD),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        final quantity =
                            double.tryParse(quantityController.text) ?? 1.0;
                        controller.addOrderItem(
                          product,
                          quantity,
                          notes: notesController.text.isEmpty
                              ? null
                              : notesController.text,
                        );
                        Get.back();
                        controller.filterProducts('');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00695C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: _spacingMD,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('add_to_order'.tr),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
