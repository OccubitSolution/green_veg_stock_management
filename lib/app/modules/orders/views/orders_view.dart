/// Orders View — Premium Design
///
/// Daily order management with premium UI using AppTheme design system.
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:green_veg_stock_management/app/data/models/customer_order_models.dart';
import 'package:green_veg_stock_management/app/data/models/product_model.dart';
import 'package:green_veg_stock_management/app/modules/orders/controllers/order_controller.dart';
import 'package:green_veg_stock_management/app/widgets/common_widgets.dart';
import 'package:green_veg_stock_management/app/theme/app_theme.dart';
import 'package:green_veg_stock_management/app/routes/app_routes.dart';

class OrdersView extends GetView<OrderController> {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      resizeToAvoidBottomInset: true,
      body: Obx(() {
        // When adding order items, show full-screen order entry without main header
        if (controller.selectedCustomer.value != null) {
          return _buildOrderEntry(context);
        }
        // Otherwise show normal view with header and date selector
        return Column(
          children: [
            // Header Section
            _buildHeader(context),

            // Date Selector
            _buildDateSelector(context),

            // Main Content - Customer Selection
            Expanded(
              child: _buildCustomerSelection(context),
            ),
          ],
        );
      }),
      floatingActionButton: Obx(() {
        if (controller.selectedCustomer.value == null) {
          return FloatingActionButton(
            onPressed: () => _showCustomerPicker(),
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.add_rounded, color: Colors.white),
          );
        }
        return const SizedBox.shrink();
      }),
      bottomNavigationBar: Obx(() {
        if (controller.selectedCustomer.value != null) {
          return _buildBottomBar(context);
        }
        return const SizedBox.shrink();
      }),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppTheme.radiusXL),
          bottomRight: Radius.circular(AppTheme.radiusXL),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMD),
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
                        ? Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusMD,
                              ),
                            ),
                            child: IconButton(
                              onPressed: () => controller.clearCurrentOrder(),
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusMD,
                              ),
                            ),
                            child: IconButton(
                              onPressed: () => Get.back(),
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),

                  // Title
                  Text(
                    'daily_orders'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),

                  // Purchase List Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    ),
                    child: IconButton(
                      onPressed: () => Get.toNamed(AppRoutes.purchaseList),
                      icon: const Icon(
                        Icons.receipt_long_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn().slideY(begin: -0.2),

              const SizedBox(height: AppTheme.spacingMD),

              // Stats Row
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      Icons.receipt_long_rounded,
                      controller.todayOrders.length.toString(),
                      'orders'.tr,
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                    _buildStatItem(
                      Icons.people_rounded,
                      controller.orderStats['totalCustomers'].toString(),
                      'customers'.tr,
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                    _buildStatItem(
                      Icons.inventory_2_rounded,
                      (controller.orderStats['totalItems'] ?? 0)
                          .toStringAsFixed(0),
                      'items'.tr,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: AppTheme.spacingSM),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: 22),
        const SizedBox(height: 4),
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
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ─── Date Selector ───────────────────────────────────────────────────

  Widget _buildDateSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      child: Obx(
        () => ModernDateSelector(
          dateText: DateFormat(
            'EEE, dd MMM yyyy',
          ).format(controller.selectedDate.value),
          onPrevious: () {
            final newDate = controller.selectedDate.value.subtract(
              const Duration(days: 1),
            );
            controller.setDate(newDate);
          },
          onNext: () {
            final newDate = controller.selectedDate.value.add(
              const Duration(days: 1),
            );
            controller.setDate(newDate);
          },
          onTap: () => _selectDate(context),
        ),
      ),
    ).animate().fadeIn(delay: 100.ms);
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
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.setDate(picked);
    }
  }

  // ─── Customer Selection ──────────────────────────────────────────────

  Widget _buildCustomerSelection(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMD),
          child: ModernSearchBar(
            hintText: 'search_customers'.tr,
            onChanged: controller.filterOrders,
            onClear: () => controller.filterOrders(''),
          ),
        ).animate().fadeIn(delay: 150.ms),

        const SizedBox(height: AppTheme.spacingMD),

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
              return EmptyStateWidget(
                icon: Icons.search_off_rounded,
                message: 'no_orders_found'.tr,
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMD,
              ),
              physics: const BouncingScrollPhysics(),
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
    return EmptyStateWidget(
      icon: Icons.receipt_long_outlined,
      message: 'no_orders_today'.tr,
      actionLabel: 'add_new_order'.tr,
      onAction: () => _showCustomerPicker(),
    );
  }

  Widget _buildOrderCard(Order order, int index) {
    final delayMs = (index * 50).clamp(0, 300);
    return PremiumCard(
          margin: const EdgeInsets.only(bottom: AppTheme.spacingSM),
          padding: const EdgeInsets.all(AppTheme.spacingMD),
          child: InkWell(
            onTap: () => _editOrder(order),
            borderRadius: BorderRadius.circular(AppTheme.radiusLG),
            child: Row(
              children: [
                // Customer Type Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: (order.customerType?.color ?? AppTheme.primaryColor)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  ),
                  child: Icon(
                    order.customerType?.icon ?? Icons.business_rounded,
                    color: order.customerType?.color ?? AppTheme.primaryColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMD),

                // Order Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              order.customerName ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimaryLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Compact delivery slot icon in card
                          Icon(
                            order.deliverySlot.icon,
                            color: order.deliverySlot.color,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            order.deliverySlot.getName(Get.locale?.languageCode ?? 'en'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: order.deliverySlot.color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: order.status.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusSM,
                              ),
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
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.textTertiaryLight,
                  size: 22,
                ),
              ],
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: delayMs))
        .fadeIn()
        .slideX(begin: 0.08);
  }

  // ─── Order Entry ─────────────────────────────────────────────────────

  Widget _buildOrderEntry(BuildContext context) {
    return Column(
      children: [
        // Ultra-compact header with just customer name and search
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMD,
            vertical: AppTheme.spacingSM,
          ),
          color: AppTheme.surfaceLight,
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                // Back button
                GestureDetector(
                  onTap: () => controller.clearCurrentOrder(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSM),
                // Customer name only - compact
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        controller.selectedCustomer.value?.name ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Delivery slot selector
        Obx(() => Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMD,
            vertical: AppTheme.spacingXS,
          ),
          child: Row(
            children: DeliverySlot.values.map((slot) {
              final isSelected = controller.selectedDeliverySlot.value == slot;
              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.selectedDeliverySlot.value = slot,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? slot.color : Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                      border: Border.all(
                        color: isSelected 
                            ? slot.color 
                            : AppTheme.borderLight.withValues(alpha: 0.5),
                        width: 1,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: slot.color.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ] : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          slot.icon,
                          color: isSelected ? Colors.white : slot.color,
                          size: 18,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          slot.getName(Get.locale?.languageCode ?? 'en'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected 
                                ? Colors.white 
                                : AppTheme.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        )),

        // Search bar - inline, no extra container
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMD,
            vertical: AppTheme.spacingXS,
          ),
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusLG),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: AppTheme.borderLight.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.productSearchController,
                  onChanged: controller.filterProducts,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'search_products'.tr,
                    hintStyle: TextStyle(
                      color: AppTheme.textTertiaryLight,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    suffixIcon: Obx(() {
                      if (controller.productSearchQuery.value.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppTheme.textSecondaryLight,
                          size: 18,
                        ),
                        onPressed: () {
                          controller.productSearchController.clear();
                          controller.filterProducts('');
                        },
                      );
                    }),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              // Add custom item button
              GestureDetector(
                onTap: () => _showCustomItemDialog(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Custom',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Product List - maximum space
        Expanded(child: _buildProductList()),
      ],
    );
  }

  Widget _buildProductList() {
    return Obx(() {
      // Show all products by default, filtered products when searching
      final productsToShow = controller.productSearchQuery.value.isEmpty
          ? controller.availableProducts
          : controller.filteredProducts;

      if (productsToShow.isEmpty) {
        return EmptyStateWidget(
          icon: Icons.inventory_2_outlined,
          message: controller.productSearchQuery.value.isEmpty
              ? 'no_products'.tr
              : 'no_products_found'.tr,
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMD,
          vertical: AppTheme.spacingXS,
        ),
        physics: const BouncingScrollPhysics(),
        itemCount: productsToShow.length,
        itemBuilder: (context, index) {
          final product = productsToShow[index];
          return _buildInlineProductCard(product, index);
        },
      );
    });
  }

  Widget _buildInlineProductCard(Product product, int index) {
    final iconColor = AppTheme.getCategoryColor(product.categoryId);
    final delayMs = (index * 30).clamp(0, 200);

    return Obx(() {
      // Find existing order item for this product
      final existingItem = controller.currentOrderItems.firstWhereOrNull(
        (item) => item.productId == product.id,
      );
      final quantity = existingItem?.quantity ?? 0;
      final price = controller.todayPrices[product.id];
      final isAdded = quantity > 0;

      return GestureDetector(
        onTap: () => _showQuickEditDialog(product, quantity),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppTheme.spacingXS),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingSM,
            vertical: AppTheme.spacingSM,
          ),
          decoration: BoxDecoration(
            color: isAdded 
                ? AppTheme.primaryColor.withValues(alpha: 0.05)
                : Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            border: Border.all(
              color: isAdded
                  ? AppTheme.primaryColor.withValues(alpha: 0.3)
                  : AppTheme.borderLight.withValues(alpha: 0.5),
              width: isAdded ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              // Compact product icon
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: AppTheme.subtleGradient(iconColor),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                ),
                child: Icon(Icons.eco, color: iconColor, size: 20),
              ),
              const SizedBox(width: AppTheme.spacingSM),

              // Product info - single line layout
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.getName(Get.locale?.languageCode ?? 'en'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isAdded ? FontWeight.w700 : FontWeight.w600,
                        color: isAdded 
                            ? AppTheme.primaryColor 
                            : AppTheme.textPrimaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (price != null)
                      Text(
                        '₹${price.toStringAsFixed(1)} / ${product.unitSymbol}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondaryLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),

              // Compact quantity controls
              _buildCompactQuantityControl(product, quantity),
            ],
          ),
        ),
      )
          .animate(delay: Duration(milliseconds: delayMs))
          .fadeIn()
          .slideX(begin: 0.05);
    });
  }

  Widget _buildCompactQuantityControl(Product product, double quantity) {
    if (quantity == 0) {
      return GestureDetector(
        onTap: () => controller.incrementProduct(product),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement
          GestureDetector(
            onTap: () => controller.decrementProduct(product),
            child: Container(
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.remove_rounded,
                color: AppTheme.primaryColor,
                size: 18,
              ),
            ),
          ),
          // Quantity
          Container(
            constraints: const BoxConstraints(minWidth: 40),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusXS),
            ),
            child: Text(
              quantity.toStringAsFixed(quantity % 1 == 0 ? 0 : 1),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
                fontSize: 14,
              ),
            ),
          ),
          // Increment
          GestureDetector(
            onTap: () => controller.incrementProduct(product),
            child: Container(
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.add_rounded,
                color: AppTheme.primaryColor,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildCurrentOrderItems() {
    if (controller.currentOrderItems.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.shopping_basket_outlined,
        message: 'no_items_added'.tr,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMD),
      physics: const BouncingScrollPhysics(),
      itemCount: controller.currentOrderItems.length,
      itemBuilder: (context, index) {
        final item = controller.currentOrderItems[index];
        return _buildOrderItemCard(item, index);
      },
    );
  }

  Widget _buildOrderItemCard(OrderItem item, int index) {
    return PremiumCard(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSM),
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            ),
            child: const Icon(
              Icons.eco,
              color: AppTheme.primaryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.getProductName(Get.locale?.languageCode ?? 'en'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.quantity} ${item.unitSymbol}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildQuantityButton(
                Icons.remove_rounded,
                () => controller.updateItemQuantity(index, item.quantity - 0.5),
              ),
              Container(
                width: 50,
                alignment: Alignment.center,
                child: Text(
                  item.quantity.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
              ),
              _buildQuantityButton(
                Icons.add_rounded,
                () => controller.updateItemQuantity(index, item.quantity + 0.5),
              ),
              const SizedBox(width: AppTheme.spacingSM),
              GestureDetector(
                onTap: () => controller.removeOrderItem(index),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: AppTheme.error,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: (index * 50).ms).fadeIn().slideX(begin: 0.05);
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 18),
      ),
    );
  }

  // ─── Bottom Bar ──────────────────────────────────────────────────────

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
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
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Obx(
                    () => Text(
                      'Total: ₹${controller.currentOrderTotal.value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GradientButton(
              label: 'save_order'.tr,
              icon: Icons.check_rounded,
              onPressed: () => controller.saveOrder(),
              isLoading: controller.isSaving.value,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Dialogs ─────────────────────────────────────────────────────────

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

  /// Edit an existing order by selecting its customer and loading its items
  void _editOrder(Order order) {
    controller.loadOrderForEditing(order);
  }

  /// Quick edit dialog for precise quantity entry
  void _showQuickEditDialog(Product product, double currentQty) {
    final quantityController = TextEditingController(
      text: currentQty.toStringAsFixed(currentQty % 1 == 0 ? 0 : 1),
    );

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product name
              Text(
                product.getName(Get.locale?.languageCode ?? 'en'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMD),

              // Quantity field
              TextField(
                controller: quantityController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'quantity'.tr,
                  suffixText: product.unitSymbol ?? '',
                  filled: true,
                  fillColor: AppTheme.backgroundLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                ),
                onSubmitted: (value) {
                  final qty = double.tryParse(value) ?? 0;
                  if (qty > 0) {
                    final index = controller.currentOrderItems.indexWhere(
                      (item) => item.productId == product.id,
                    );
                    if (index >= 0) {
                      controller.updateItemQuantity(index, qty);
                    }
                  }
                  Get.back();
                },
              ),
              const SizedBox(height: AppTheme.spacingLG),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacingMD,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusLG,
                          ),
                        ),
                      ),
                      child: Text('cancel'.tr),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSM),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final qty =
                            double.tryParse(quantityController.text) ?? 0;
                        if (qty > 0) {
                          final index = controller.currentOrderItems.indexWhere(
                            (item) => item.productId == product.id,
                          );
                          if (index >= 0) {
                            controller.updateItemQuantity(index, qty);
                          }
                        }
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacingMD,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusLG,
                          ),
                        ),
                      ),
                      child: Text('update'.tr),
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

  // ignore: unused_element
  void _showQuantityDialog(Product product) {
    final quantityController = TextEditingController(text: '1.0');
    final notesController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingLG),
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
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                      ),
                      child: const Icon(Icons.eco, color: Colors.white),
                    ),
                    const SizedBox(width: AppTheme.spacingMD),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.getName(Get.locale?.languageCode ?? 'en'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimaryLight,
                            ),
                          ),
                          Text(
                            '${'unit'.tr}: ${product.unitSymbol}',
                            style: TextStyle(
                              color: AppTheme.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingLG),

                // Quantity Input
                Text(
                  'quantity'.tr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSM),
                TextField(
                  controller: quantityController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    hintText: 'enter_quantity'.tr,
                    hintStyle: const TextStyle(
                      color: AppTheme.textTertiaryLight,
                    ),
                    suffixText: product.unitSymbol,
                    filled: true,
                    fillColor: AppTheme.backgroundLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                      borderSide: const BorderSide(
                        color: AppTheme.primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMD),

                // Notes Input
                Text(
                  'notes'.tr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSM),
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(
                    hintText: 'optional_notes'.tr,
                    hintStyle: const TextStyle(
                      color: AppTheme.textTertiaryLight,
                    ),
                    filled: true,
                    fillColor: AppTheme.backgroundLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                      borderSide: const BorderSide(
                        color: AppTheme.primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLG),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusLG,
                            ),
                          ),
                          side: BorderSide(color: AppTheme.borderLight),
                        ),
                        child: Text(
                          'cancel'.tr,
                          style: TextStyle(color: AppTheme.textSecondaryLight),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMD),
                    Expanded(
                      flex: 2,
                      child: GradientButton(
                        label: 'add_to_order'.tr,
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
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCustomItemDialog() {
    final nameController = TextEditingController();
    final quantityController = TextEditingController(text: '1.0');
    final sellingPriceController = TextEditingController();
    final costPriceController = TextEditingController();
    final unitController = TextEditingController(text: 'kg');
    final notesController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingLG),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                      ),
                      child: const Icon(Icons.add_circle, color: Colors.white),
                    ),
                    const SizedBox(width: AppTheme.spacingMD),
                    Expanded(
                      child: Text(
                        'Add Custom Item',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingLG),

                // Item Name
                Text(
                  'Item Name *',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSM),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Potatoes, Onions, etc.',
                    filled: true,
                    fillColor: AppTheme.backgroundLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMD),

                // Quantity & Unit
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quantity',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingSM),
                          TextField(
                            controller: quantityController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              hintText: '1.0',
                              filled: true,
                              fillColor: AppTheme.backgroundLight,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMD),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Unit',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingSM),
                          TextField(
                            controller: unitController,
                            decoration: InputDecoration(
                              hintText: 'kg',
                              filled: true,
                              fillColor: AppTheme.backgroundLight,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingMD),

                // Selling Price
                Text(
                  'Selling Price *',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSM),
                TextField(
                  controller: sellingPriceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    prefixText: '₹ ',
                    filled: true,
                    fillColor: AppTheme.backgroundLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMD),

                // Cost Price (Optional)
                Text(
                  'Cost Price (Optional)',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSM),
                TextField(
                  controller: costPriceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'For profit tracking',
                    prefixText: '₹ ',
                    filled: true,
                    fillColor: AppTheme.backgroundLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMD),

                // Notes
                Text(
                  'Notes (Optional)',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSM),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Any special notes...',
                    filled: true,
                    fillColor: AppTheme.backgroundLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLG),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                          ),
                          side: BorderSide(color: AppTheme.borderLight),
                        ),
                        child: Text(
                          'cancel'.tr,
                          style: TextStyle(color: AppTheme.textSecondaryLight),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMD),
                    Expanded(
                      flex: 2,
                      child: GradientButton(
                        label: 'add_item'.tr,
                        onPressed: () {
                          if (nameController.text.isEmpty) {
                            Get.snackbar('error'.tr, 'field_required'.tr);
                            return;
                          }
                          final sellingPrice = double.tryParse(sellingPriceController.text);
                          if (sellingPrice == null || sellingPrice <= 0) {
                            Get.snackbar('error'.tr, 'invalid_number'.tr);
                            return;
                          }

                          final quantity = double.tryParse(quantityController.text) ?? 1.0;
                          final costPrice = double.tryParse(costPriceController.text);

                          controller.addCustomItem(
                            itemName: nameController.text,
                            quantity: quantity,
                            sellingPrice: sellingPrice,
                            costPrice: costPrice,
                            unitSymbol: unitController.text.isEmpty ? 'kg' : unitController.text,
                            notes: notesController.text.isEmpty ? null : notesController.text,
                          );
                          Get.back();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
