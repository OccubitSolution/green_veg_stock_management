/// Simplified Orders View
/// Simple one-screen order creation
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:green_veg_stock_management/app/controllers/app_controller.dart';
import 'package:green_veg_stock_management/app/data/models/customer_order_models.dart';
import 'package:green_veg_stock_management/app/data/models/product_model.dart';
import 'package:green_veg_stock_management/app/data/repositories/customer_repository.dart';
import 'package:green_veg_stock_management/app/modules/orders/controllers/order_controller.dart';
import 'package:green_veg_stock_management/app/theme/app_theme.dart';

class SimpleOrdersView extends StatefulWidget {
  const SimpleOrdersView({super.key});

  @override
  State<SimpleOrdersView> createState() => _SimpleOrdersViewState();
}

class _SimpleOrdersViewState extends State<SimpleOrdersView> {
  final OrderController controller = Get.find<OrderController>();
  final AppController appController = Get.find<AppController>();
  final CustomerRepository _customerRepo = CustomerRepository();
  
  List<Customer> customers = [];
  bool isLoadingCustomers = false;
  Customer? selectedCustomer;
  CustomerType? selectedCategoryFilter;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() => isLoadingCustomers = true);
    try {
      final vendorId = appController.vendorId.value;
      if (vendorId.isNotEmpty) {
        customers = await _customerRepo.getCustomers(vendorId);
        if (controller.availableProducts.isEmpty) {
          await controller.loadAvailableProducts();
        }
      }
    } catch (e) {
      debugPrint('Error loading customers: $e');
    }
    setState(() => isLoadingCustomers = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        title: Obx(() => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'new_order'.tr,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.white),
                    const SizedBox(width: 5),
                    Text(
                      '${controller.selectedDate.value.day}/${controller.selectedDate.value.month}/${controller.selectedDate.value.year}',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const Icon(Icons.arrow_drop_down, size: 16, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        )),
        centerTitle: true,
        actions: [
          Obx(() {
            if (controller.currentOrderItems.isEmpty) {
              return const SizedBox.shrink();
            }
            return IconButton(
              onPressed: () {
                setState(() => selectedCustomer = null);
                controller.clearCurrentOrder();
              },
              icon: const Icon(Icons.clear_all),
              tooltip: 'retry'.tr,
            );
          }),
        ],
      ),
      body: selectedCustomer != null
          ? Column(
              children: [
                _buildSelectedCustomerBar(),
                _buildProductSearch(),
                _buildOrderTotalBar(),
                Expanded(child: _buildProductsList()),
              ],
            )
          : _buildCustomerSelectionScreen(),
      floatingActionButton: Obx(() {
        if (controller.currentOrderItems.isEmpty || selectedCustomer == null) {
          return const SizedBox.shrink();
        }
        return FloatingActionButton.extended(
          onPressed: _saveOrder,
          backgroundColor: AppTheme.primaryColor,
          icon: const Icon(Icons.check),
          label: Text(
            '${'save_order'.tr} (${controller.currentOrderItems.length})',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }),
    );
  }

  // Full screen shown when no customer is selected
  Widget _buildCustomerSelectionScreen() {
    final filtered = getFilteredCustomers();
    return CustomScrollView(
      slivers: [
        // Date + category filters (sticky header)
        SliverToBoxAdapter(
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date row
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        'purchase_date'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.primaryColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_today, size: 15, color: AppTheme.primaryColor),
                              const SizedBox(width: 6),
                              Text(
                                '${controller.selectedDate.value.day}/${controller.selectedDate.value.month}/${controller.selectedDate.value.year}',
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_drop_down, size: 18, color: AppTheme.primaryColor),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Category filter chips
                SizedBox(
                  height: 42,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      _buildCategoryFilterChip('All', null, true),
                      const SizedBox(width: 8),
                      _buildCategoryFilterChip('Hotel', CustomerType.hotel, false),
                      const SizedBox(width: 8),
                      _buildCategoryFilterChip('Cafe', CustomerType.cafe, false),
                      const SizedBox(width: 8),
                      _buildCategoryFilterChip('Restaurant', CustomerType.restaurant, false),
                      const SizedBox(width: 8),
                      _buildCategoryFilterChip('Other', CustomerType.other, false),
                    ],
                  ),
                ),
                // Header row
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        'please_select_customer'.tr,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${filtered.length} customers',
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
              ],
            ),
          ),
        ),

        // Customer grid
        if (filtered.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    'no_customers'.tr,
                    style: TextStyle(color: Colors.grey[500], fontSize: 15),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final customer = filtered[index];
                  return _buildCustomerGridCard(customer, index);
                },
                childCount: filtered.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCustomerGridCard(Customer customer, int index) {
    return GestureDetector(
      onTap: () {
        setState(() => selectedCustomer = customer);
        controller.selectCustomer(customer);
      },
      child: Container(
        decoration: BoxDecoration(
          color: customer.type.color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: customer.type.color.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: customer.type.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: customer.type.color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(customer.type.icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                customer.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              customer.type.getName('en'),
              style: TextStyle(
                fontSize: 10,
                color: customer.type.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: (30 * index).clamp(0, 300)));
  }

  // Compact bar shown at top when a customer is already selected
  Widget _buildSelectedCustomerBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: AppTheme.primaryColor.withValues(alpha: 0.08),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(selectedCustomer!.type.icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedCustomer!.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  selectedCustomer!.type.getName('en'),
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() => selectedCustomer = null);
              controller.clearCurrentOrder();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: Text('edit'.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // Keep for compatibility — unused but harmless
  // Widget _buildCustomerSelector() => _buildCustomerSelectionScreen();

  Widget _buildOrderTotalBar() {
    return Obx(() {
      final itemCount = controller.currentOrderItems.length;
      final total = controller.currentOrderTotal.value;
      if (itemCount == 0) return const SizedBox.shrink();
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.06),
          border: Border(
            bottom: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.15)),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$itemCount item${itemCount > 1 ? 's' : ''}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            Text(
              'Total: ',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Rs.${total.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildProductSearch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: TextField(
        controller: controller.productSearchController,
        decoration: InputDecoration(
          hintText: 'search_products'.tr,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onChanged: (value) {
          controller.filterProducts(value);
        },
      ),
    );
  }

  Widget _buildProductsList() {
    return Obx(() {
      if (controller.isLoading.value && controller.availableProducts.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppTheme.primaryColor),
              const SizedBox(height: 16),
              Text('loading'.tr),
            ],
          ),
        );
      }
      
      final searchText = controller.productSearchQuery.value;
      final products = searchText.isEmpty
          ? controller.availableProducts
          : controller.filteredProducts;
      
      if (products.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                searchText.isEmpty
                    ? 'no_products_available'.tr
                    : '${'no_products_found'.tr} "$searchText"',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }
      
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return _buildProductCard(product);
        },
      );
    });
  }

  Widget _buildProductCard(Product product) {
    return Obx(() {
      final existingIndex = controller.currentOrderItems
          .indexWhere((item) => item.productId == product.id);
      final isInOrder = existingIndex >= 0;
      final quantity = isInOrder 
          ? controller.currentOrderItems[existingIndex].quantity 
          : 0.0;
      final price = controller.todayPrices[product.id] ?? 0.0;

      final card = Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isInOrder ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isInOrder ? AppTheme.primaryColor : Colors.grey[200]!,
            width: isInOrder ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.eco,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.nameEn ?? product.nameGu,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rs.${price.toStringAsFixed(0)} / ${product.unitSymbol}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (isInOrder)
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (quantity <= 1) {
                          controller.removeOrderItem(existingIndex);
                        } else {
                          controller.updateItemQuantity(existingIndex, quantity - 1);
                        }
                      },
                      icon: Icon(
                        quantity <= 1 ? Icons.delete_outline : Icons.remove_circle_outline,
                        color: quantity <= 1 ? Colors.red : AppTheme.primaryColor,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    GestureDetector(
                      onTap: () => _showQuantityDialog(product, quantity),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          quantity.toStringAsFixed(quantity == quantity.toInt() ? 0 : 1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        controller.updateItemQuantity(existingIndex, quantity + 1);
                      },
                      icon: const Icon(
                        Icons.add_circle,
                        color: AppTheme.primaryColor,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: () => controller.addOrderItem(product, 1.0),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('add'.tr),
                ),
            ],
          ),
        ),
      );

      if (!isInOrder) {
        return card.animate().fadeIn().slideX(begin: 0.05);
      }

      return Dismissible(
        key: ValueKey('dismiss_${product.id}'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) async {
          controller.removeOrderItem(existingIndex);
          return false; // we handle removal ourselves, don't remove widget
        },
        background: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.red.shade500,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.refresh_rounded, color: Colors.white, size: 26),
              const SizedBox(height: 4),
              Text(
                'retry'.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        child: card.animate().fadeIn().slideX(begin: 0.05),
      );
    });
  }

  void _showQuantityDialog(Product product, double currentQty) {
    final qtyController = TextEditingController(
      text: currentQty.toStringAsFixed(1),
    );
    
    Get.dialog(
      AlertDialog(
        title: Text(product.nameEn ?? product.nameGu),
        content: TextField(
          controller: qtyController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'quantity'.tr,
            suffixText: product.unitSymbol,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final index = controller.currentOrderItems
                  .indexWhere((item) => item.productId == product.id);
              if (index >= 0) {
                controller.removeOrderItem(index);
              }
              Get.back();
            },
            child: Text('delete'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              final qty = double.tryParse(qtyController.text) ?? 0;
              if (qty > 0) {
                final index = controller.currentOrderItems
                    .indexWhere((item) => item.productId == product.id);
                if (index >= 0) {
                  controller.updateItemQuantity(index, qty);
                }
              }
              Get.back();
            },
            child: Text('save'.tr),
          ),
        ],
      ),
    );
  }

  Future<void> _saveOrder() async {
    if (selectedCustomer == null) {
      Get.snackbar(
        'error'.tr,
        'please_select_customer'.tr,
        backgroundColor: Colors.red[100],
      );
      return;
    }
    
    if (controller.currentOrderItems.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'please_add_items'.tr,
        backgroundColor: Colors.red[100],
      );
      return;
    }
    
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    
    try {
      await controller.saveOrder();
      Get.back();
      
      Get.snackbar(
        'success'.tr,
        'order_saved'.tr,
        backgroundColor: Colors.green[100],
        duration: const Duration(seconds: 2),
      );
      
      setState(() {
        selectedCustomer = null;
      });
      controller.clearCurrentOrder();
      
    } catch (e) {
      Get.back();
      Get.snackbar(
        'error'.tr,
        '${'failed_to_save_order'.tr}: $e',
        backgroundColor: Colors.red[100],
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textPrimaryLight,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != controller.selectedDate.value) {
      controller.setDate(picked);
    }
  }

  Widget _buildCategoryFilterChip(String label, CustomerType? type, bool isAll) {
    final isSelected = isAll 
        ? selectedCategoryFilter == null 
        : selectedCategoryFilter == type;
    final color = isAll ? AppTheme.primaryColor : (type?.color ?? AppTheme.primaryColor);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategoryFilter = isAll ? null : type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [color, color.withValues(alpha: 0.85)],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 0 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (type != null) ...[
              Icon(
                type.icon,
                size: 14,
                color: isSelected ? Colors.white : color,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Customer> getFilteredCustomers() {
    if (selectedCategoryFilter == null) {
      return customers;
    }
    return customers.where((c) => c.type == selectedCategoryFilter).toList();
  }
}