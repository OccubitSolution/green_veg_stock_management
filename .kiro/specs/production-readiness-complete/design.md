# Design Document: Production Readiness Complete

## Overview

This design document outlines the technical approach for making the Grocery Broker Flutter application production-ready. The application is built using Flutter with GetX for state management and Supabase for the backend database.

The design addresses 80+ identified issues across four priority levels:
- **Critical**: Incomplete view files, missing core functionality, validation, and workflow issues
- **High**: Missing translations, payment tracking, settings features, error handling, and data consistency
- **Medium**: Reports/analytics, inventory management, financial features, performance optimization, and access control
- **Testing & Security**: Comprehensive test suite and security hardening

The implementation is organized into four phases over an 8-week timeline, with each phase building upon the previous one. The design maintains the existing architecture while completing incomplete features, adding missing functionality, and improving overall quality.

## Architecture

### System Architecture

The application follows a layered architecture pattern:

```
┌─────────────────────────────────────────────────────────┐
│                     Presentation Layer                   │
│  (Views, Controllers, Widgets)                          │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                     Business Logic Layer                 │
│  (Services, Validators, Workflow Engines)               │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                     Data Access Layer                    │
│  (Repositories, Providers, Models)                      │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                     Backend Layer                        │
│  (Supabase Database, Storage, Auth)                     │
└─────────────────────────────────────────────────────────┘
```

### Technology Stack

- **Frontend**: Flutter 3.x with Dart
- **State Management**: GetX
- **Backend**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth
- **Storage**: Supabase Storage (for product images)
- **Internationalization**: GetX translations (English, Gujarati)
- **Testing**: flutter_test, mockito, integration_test

## Components and Interfaces

### 1. View Completion Components

#### OrdersView (Complete Implementation)

```dart
class OrdersView extends GetView<OrdersController> {
  // Complete customer selection UI
  Widget _buildCustomerSelection() {
    return Column(
      children: [
        SearchBar(
          hintText: 'search_customers'.tr,
          onChanged: controller.filterCustomers,
        ),
        Expanded(
          child: ListView.builder(
            itemCount: controller.filteredCustomers.length,
            itemBuilder: (context, index) {
              final customer = controller.filteredCustomers[index];
              return CustomerTile(
                customer: customer,
                onTap: () => controller.selectCustomer(customer),
              );
            },
          ),
        ),
      ],
    );
  }

  // Complete order entry form
  Widget _buildOrderEntryForm() {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          _buildProductSearch(),
          _buildSelectedProducts(),
          _buildCustomItemsSection(),
          _buildOrderSummary(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  // Complete order list display
  Widget _buildOrderList() {
    return ListView.builder(
      itemCount: controller.orders.length,
      itemBuilder: (context, index) {
        final order = controller.orders[index];
        return OrderCard(
          order: order,
          onTap: () => controller.viewOrderDetails(order),
          onEdit: () => controller.editOrder(order),
          onDelete: () => controller.deleteOrder(order),
        );
      },
    );
  }
}
```

#### CustomersView (Complete Implementation)

```dart
class CustomersView extends GetView<CustomersController> {
  // Complete customer orders sheet
  Widget _buildCustomerOrdersSheet(Customer customer) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      builder: (context, scrollController) {
        return Column(
          children: [
            _buildSheetHeader(customer),
            _buildOrderFilters(),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: controller.customerOrders.length,
                itemBuilder: (context, index) {
                  final order = controller.customerOrders[index];
                  return OrderSummaryCard(order: order);
                },
              ),
            ),
            _buildOrderStatistics(customer),
          ],
        );
      },
    );
  }

  // Complete customer detail view
  Widget _buildCustomerDetailView(Customer customer) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildCustomerInfo(customer),
          _buildContactInfo(customer),
          _buildPaymentSummary(customer),
          _buildRecentOrders(customer),
          _buildActionButtons(customer),
        ],
      ),
    );
  }
}
```

### 2. Product Management Component

```dart
class ProductFormView extends GetView<ProductFormController> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('add_product'.tr)),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            _buildImageUpload(),
            _buildNameField(),
            _buildCategoryDropdown(),
            _buildUnitDropdown(),
            _buildPriceField(),
            _buildDescriptionField(),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUpload() {
    return GestureDetector(
      onTap: controller.pickImage,
      child: Obx(() => Container(
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: controller.selectedImage.value != null
            ? Image.file(controller.selectedImage.value!)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate, size: 48),
                  SizedBox(height: 8),
                  Text('tap_to_add_image'.tr),
                ],
              ),
      )),
    );
  }
}

class ProductFormController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  
  final selectedImage = Rx<File?>(null);
  final selectedCategory = Rx<String?>(null);
  final selectedUnit = Rx<String?>(null);
  
  final ProductRepository _productRepository;
  final ValidationService _validationService;
  
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }
  
  Future<void> saveProduct() async {
    if (!formKey.currentState!.validate()) return;
    
    try {
      String? imageUrl;
      if (selectedImage.value != null) {
        imageUrl = await _productRepository.uploadImage(selectedImage.value!);
      }
      
      final product = Product(
        name: nameController.text,
        category: selectedCategory.value!,
        unit: selectedUnit.value!,
        price: double.parse(priceController.text),
        description: descriptionController.text,
        imageUrl: imageUrl,
      );
      
      await _productRepository.create(product);
      Get.back();
      Get.snackbar('success'.tr, 'product_added_successfully'.tr);
    } catch (e) {
      Get.snackbar('error'.tr, 'failed_to_add_product'.tr);
    }
  }
}
```

### 3. Validation Service

```dart
class ValidationService {
  // Email validation
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'email_required'.tr;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'invalid_email_format'.tr;
    }
    return null;
  }

  // Phone validation
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'phone_required'.tr;
    }
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'invalid_phone_format'.tr;
    }
    return null;
  }

  // Positive number validation
  String? validatePositiveNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName ${'is_required'.tr}';
    }
    final number = double.tryParse(value);
    if (number == null) {
      return 'invalid_number_format'.tr;
    }
    if (number <= 0) {
      return '$fieldName ${'must_be_positive'.tr}';
    }
    return null;
  }

  // Quantity validation
  String? validateQuantity(String? value) {
    return validatePositiveNumber(value, 'quantity'.tr);
  }

  // Price validation
  String? validatePrice(String? value) {
    return validatePositiveNumber(value, 'price'.tr);
  }

  // Required field validation
  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName ${'is_required'.tr}';
    }
    return null;
  }
}
```

### 4. Order Workflow Service

```dart
class OrderWorkflowService {
  final OrderRepository _orderRepository;
  final OrderStatusHistoryRepository _historyRepository;
  
  // Load order for editing
  Future<OrderEditData> loadOrderForEditing(String orderId) async {
    final order = await _orderRepository.getById(orderId);
    final items = await _orderRepository.getOrderItems(orderId);
    final customItems = await _orderRepository.getCustomItems(orderId);
    
    return OrderEditData(
      order: order,
      items: items,
      customItems: customItems,
    );
  }
  
  // Save order modifications
  Future<void> saveOrderModifications(Order order, List<OrderItem> items, List<CustomItem> customItems) async {
    await _orderRepository.update(order);
    await _orderRepository.updateOrderItems(order.id, items);
    await _orderRepository.updateCustomItems(order.id, customItems);
    
    // Create audit trail
    await _historyRepository.create(OrderStatusHistory(
      orderId: order.id,
      fromStatus: order.previousStatus,
      toStatus: order.status,
      changedBy: order.updatedBy,
      notes: 'Order modified',
    ));
  }
  
  // Confirm order before saving
  Future<bool> confirmOrderCreation(Order order) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('confirm_order'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('customer'.tr + ': ${order.customerName}'),
            Text('total'.tr + ': ${order.total}'),
            Text('items'.tr + ': ${order.itemCount}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text('confirm'.tr),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }
  
  // Transition order status
  Future<void> transitionStatus(String orderId, OrderStatus newStatus, String userId) async {
    final order = await _orderRepository.getById(orderId);
    
    // Validate transition
    if (!_isValidTransition(order.status, newStatus)) {
      throw InvalidStatusTransitionException(order.status, newStatus);
    }
    
    // Update order
    order.status = newStatus;
    if (newStatus == OrderStatus.delivered) {
      order.deliveredAt = DateTime.now();
      order.deliveredBy = userId;
    }
    
    await _orderRepository.update(order);
    
    // Record history
    await _historyRepository.create(OrderStatusHistory(
      orderId: orderId,
      fromStatus: order.previousStatus,
      toStatus: newStatus,
      changedBy: userId,
    ));
  }
  
  bool _isValidTransition(OrderStatus from, OrderStatus to) {
    const validTransitions = {
      OrderStatus.pending: [OrderStatus.confirmed, OrderStatus.cancelled],
      OrderStatus.confirmed: [OrderStatus.inTransit, OrderStatus.cancelled],
      OrderStatus.inTransit: [OrderStatus.delivered, OrderStatus.cancelled],
      OrderStatus.delivered: [],
      OrderStatus.cancelled: [],
    };
    
    return validTransitions[from]?.contains(to) ?? false;
  }
}
```

### 5. Payment Tracking Service

```dart
class PaymentTrackingService {
  final PaymentRepository _paymentRepository;
  final OrderRepository _orderRepository;
  
  // Record payment
  Future<void> recordPayment(Payment payment) async {
    await _paymentRepository.create(payment);
    await _updateOutstandingBalance(payment.orderId);
  }
  
  // Get outstanding balance for customer
  Future<double> getOutstandingBalance(String customerId) async {
    final orders = await _orderRepository.getByCustomer(customerId);
    final payments = await _paymentRepository.getByCustomer(customerId);
    
    final totalOrders = orders.fold<double>(0, (sum, order) => sum + order.total);
    final totalPayments = payments.fold<double>(0, (sum, payment) => sum + payment.amount);
    
    return totalOrders - totalPayments;
  }
  
  // Get payment history
  Future<List<Payment>> getPaymentHistory(String customerId, {DateTimeRange? dateRange}) async {
    var payments = await _paymentRepository.getByCustomer(customerId);
    
    if (dateRange != null) {
      payments = payments.where((p) => 
        p.paymentDate.isAfter(dateRange.start) && 
        p.paymentDate.isBefore(dateRange.end)
      ).toList();
    }
    
    return payments..sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
  }
  
  // Get payment status for order
  PaymentStatus getPaymentStatus(Order order, List<Payment> payments) {
    final totalPaid = payments
        .where((p) => p.orderId == order.id)
        .fold<double>(0, (sum, p) => sum + p.amount);
    
    if (totalPaid >= order.total) {
      return PaymentStatus.paid;
    } else if (totalPaid > 0) {
      return PaymentStatus.partial;
    } else {
      return PaymentStatus.unpaid;
    }
  }
  
  Future<void> _updateOutstandingBalance(String orderId) async {
    final order = await _orderRepository.getById(orderId);
    final payments = await _paymentRepository.getByOrder(orderId);
    
    final totalPaid = payments.fold<double>(0, (sum, p) => sum + p.amount);
    order.paidAmount = totalPaid;
    order.outstandingAmount = order.total - totalPaid;
    
    await _orderRepository.update(order);
  }
}
```

### 6. Access Control Service

```dart
class AccessControlService {
  final VendorRepository _vendorRepository;
  
  // Get current user permissions
  Future<StaffPermissions> getCurrentUserPermissions() async {
    final userId = Get.find<AppController>().currentUserId;
    final vendor = await _vendorRepository.getById(userId);
    return StaffPermissions.forRole(vendor.role);
  }
  
  // Check if user has permission
  Future<bool> hasPermission(Permission permission) async {
    final permissions = await getCurrentUserPermissions();
    
    switch (permission) {
      case Permission.viewCosts:
        return permissions.canViewCosts;
      case Permission.confirmOrders:
        return permissions.canConfirmOrders;
      case Permission.cancelOrders:
        return permissions.canCancelOrders;
      case Permission.markDelivered:
        return permissions.canMarkDelivered;
      case Permission.manageProducts:
        return permissions.canManageProducts;
      case Permission.manageCustomers:
        return permissions.canManageCustomers;
      case Permission.viewReports:
        return permissions.canViewReports;
      case Permission.manageStaff:
        return permissions.canManageStaff;
      case Permission.viewAllOrders:
        return permissions.canViewAllOrders;
    }
  }
  
  // Enforce permission check
  Future<void> requirePermission(Permission permission) async {
    if (!await hasPermission(permission)) {
      throw PermissionDeniedException(permission);
    }
  }
  
  // Filter UI based on permissions
  Future<List<Widget>> filterMenuItems(List<MenuItem> items) async {
    final permissions = await getCurrentUserPermissions();
    
    return items.where((item) {
      if (item.requiredPermission == null) return true;
      return _checkPermission(permissions, item.requiredPermission!);
    }).map((item) => item.widget).toList();
  }
  
  bool _checkPermission(StaffPermissions permissions, Permission permission) {
    switch (permission) {
      case Permission.viewCosts:
        return permissions.canViewCosts;
      case Permission.confirmOrders:
        return permissions.canConfirmOrders;
      // ... other cases
    }
  }
}
```

### 7. Report Generator Service

```dart
class ReportGeneratorService {
  final OrderRepository _orderRepository;
  final ProductRepository _productRepository;
  final CustomerRepository _customerRepository;
  
  // Generate sales report
  Future<SalesReport> generateSalesReport(DateTimeRange dateRange, ReportPeriod period) async {
    final orders = await _orderRepository.getByDateRange(dateRange);
    
    final groupedData = _groupByPeriod(orders, period);
    
    return SalesReport(
      period: period,
      dateRange: dateRange,
      totalRevenue: orders.fold<double>(0, (sum, o) => sum + o.total),
      totalOrders: orders.length,
      averageOrderValue: orders.isEmpty ? 0 : orders.fold<double>(0, (sum, o) => sum + o.total) / orders.length,
      dataPoints: groupedData,
    );
  }
  
  // Generate product performance report
  Future<ProductPerformanceReport> generateProductPerformance(DateTimeRange dateRange) async {
    final orders = await _orderRepository.getByDateRange(dateRange);
    final items = orders.expand((o) => o.items).toList();
    
    final productStats = <String, ProductStats>{};
    
    for (final item in items) {
      if (!productStats.containsKey(item.productId)) {
        productStats[item.productId] = ProductStats(productId: item.productId);
      }
      
      productStats[item.productId]!.totalQuantity += item.quantity;
      productStats[item.productId]!.totalRevenue += item.total;
      productStats[item.productId]!.orderCount += 1;
    }
    
    return ProductPerformanceReport(
      dateRange: dateRange,
      products: productStats.values.toList()..sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue)),
    );
  }
  
  // Export report to PDF
  Future<File> exportToPDF(Report report) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          children: [
            pw.Header(level: 0, text: report.title),
            pw.Text('Period: ${report.dateRange}'),
            pw.Divider(),
            ...report.buildPDFContent(),
          ],
        ),
      ),
    );
    
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/${report.filename}.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }
  
  // Export report to CSV
  Future<File> exportToCSV(Report report) async {
    final csv = const ListToCsvConverter().convert(report.toCSVData());
    
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/${report.filename}.csv');
    await file.writeAsString(csv);
    
    return file;
  }
}
```

### 8. Error Handling Service

```dart
class ErrorHandlingService {
  final LoggingService _loggingService;
  
  // Handle network errors
  Future<T> handleNetworkOperation<T>(Future<T> Function() operation) async {
    try {
      return await operation().timeout(
        Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Request timed out'),
      );
    } on TimeoutException {
      _showErrorDialog('network_timeout'.tr, 'network_timeout_message'.tr);
      rethrow;
    } on SocketException {
      _showErrorDialog('no_internet'.tr, 'no_internet_message'.tr);
      rethrow;
    } catch (e) {
      _loggingService.logError('Network operation failed', e);
      _showErrorDialog('error'.tr, 'network_error_message'.tr);
      rethrow;
    }
  }
  
  // Check offline status
  Future<bool> isOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  // Retry mechanism
  Future<T> retryOperation<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 2),
  }) async {
    int attempts = 0;
    
    while (attempts < maxAttempts) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts >= maxAttempts) {
          rethrow;
        }
        await Future.delayed(delay);
      }
    }
    
    throw Exception('Max retry attempts reached');
  }
  
  void _showErrorDialog(String title, String message) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('ok'.tr),
          ),
        ],
      ),
    );
  }
}
```

## Data Models

### Custom Item Model

```dart
class CustomItem {
  final String id;
  final String orderId;
  final String name;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final double total;
  final DateTime createdAt;

  CustomItem({
    required this.id,
    required this.orderId,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.total,
    required this.createdAt,
  });

  factory CustomItem.fromJson(Map<String, dynamic> json) {
    return CustomItem(
      id: json['id'].toString(),
      orderId: json['order_id'].toString(),
      name: json['name'] as String,
      quantity: double.parse(json['quantity'].toString()),
      unit: json['unit'] as String,
      pricePerUnit: double.parse(json['price_per_unit'].toString()),
      total: double.parse(json['total'].toString()),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'price_per_unit': pricePerUnit,
      'total': total,
    };
  }
}
```

### Order Edit Data Model

```dart
class OrderEditData {
  final Order order;
  final List<OrderItem> items;
  final List<CustomItem> customItems;

  OrderEditData({
    required this.order,
    required this.items,
    required this.customItems,
  });

  double get calculatedTotal {
    final itemsTotal = items.fold<double>(0, (sum, item) => sum + item.total);
    final customTotal = customItems.fold<double>(0, (sum, item) => sum + item.total);
    return itemsTotal + customTotal;
  }
}
```

### Payment Status Enum

```dart
enum PaymentStatus {
  paid('paid', 'ચૂકવેલ', 'Paid', Colors.green),
  partial('partial', 'આંશિક', 'Partial', Colors.orange),
  unpaid('unpaid', 'બાકી', 'Unpaid', Colors.red);

  final String value;
  final String nameGu;
  final String nameEn;
  final Color color;

  const PaymentStatus(this.value, this.nameGu, this.nameEn, this.color);

  String getName(String lang) => lang == 'en' ? nameEn : nameGu;
}
```

### Report Models

```dart
class SalesReport {
  final ReportPeriod period;
  final DateTimeRange dateRange;
  final double totalRevenue;
  final int totalOrders;
  final double averageOrderValue;
  final List<DataPoint> dataPoints;

  SalesReport({
    required this.period,
    required this.dateRange,
    required this.totalRevenue,
    required this.totalOrders,
    required this.averageOrderValue,
    required this.dataPoints,
  });
}

class ProductPerformanceReport {
  final DateTimeRange dateRange;
  final List<ProductStats> products;

  ProductPerformanceReport({
    required this.dateRange,
    required this.products,
  });
}

class ProductStats {
  final String productId;
  double totalQuantity = 0;
  double totalRevenue = 0;
  int orderCount = 0;

  ProductStats({required this.productId});

  double get averagePrice => orderCount > 0 ? totalRevenue / totalQuantity : 0;
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*


### Property Reflection

After analyzing all acceptance criteria, I identified the following redundancies:

- **5.4 and 5.5**: Both test that quantities must be positive numbers. Combined into one property.
- **12.3 and 12.7**: Both test status transition validation. Combined into one property.
- **15.3 and 15.4**: Both test invoice completeness. Combined into one property.
- **Translation properties (6.2-6.6)**: All test that UI text is translated. Combined into one comprehensive property.

### Correctness Properties

Property 1: Product submission persistence
*For any* valid product data (name, category, unit, price), submitting the product should result in the product being saved to the database and retrievable by its ID.
**Validates: Requirements 2.2**

Property 2: Image upload association
*For any* valid image file and product, uploading the image should result in the image being stored and the product's imageUrl field containing a valid reference to the stored image.
**Validates: Requirements 2.3**

Property 3: Product edit round-trip
*For any* existing product, loading it for editing should populate all form fields with the current values, and saving without changes should result in an equivalent product in the database.
**Validates: Requirements 2.6, 2.7**

Property 4: Order edit field population
*For any* existing order, loading it for editing should populate all form fields with values that match the order's current state in the database.
**Validates: Requirements 3.1**

Property 5: Order items completeness
*For any* order with both regular items and custom items, loading the order for editing should return all items of both types.
**Validates: Requirements 3.2**

Property 6: Order total invariant
*For any* order with items and custom items, the order total should always equal the sum of all item totals plus the sum of all custom item totals.
**Validates: Requirements 3.3, 4.5**

Property 7: Order modification round-trip
*For any* order modification (items added, removed, or quantities changed), saving the changes should result in the database reflecting all modifications when the order is subsequently loaded.
**Validates: Requirements 3.4**

Property 8: Soft delete preservation
*For any* order that is deleted, the order record should still exist in the database with a deleted flag set to true, and the order should not appear in normal queries.
**Validates: Requirements 3.6, 11.3**

Property 9: Custom item persistence
*For any* custom item added to an order, the custom item should be saved to the database and retrievable when the order is loaded.
**Validates: Requirements 4.1, 4.2**

Property 10: Custom item modification
*For any* custom item in an order, modifying the item's properties and saving should result in the database reflecting the new values.
**Validates: Requirements 4.3**

Property 11: Custom item deletion
*For any* custom item in an order, deleting the item should result in the item no longer appearing when the order is loaded.
**Validates: Requirements 4.4**

Property 12: Email validation correctness
*For any* string, the email validator should return null (valid) if and only if the string matches the standard email format pattern (local@domain.tld).
**Validates: Requirements 5.1**

Property 13: Phone validation correctness
*For any* string, the phone validator should return null (valid) if and only if the string contains at least 10 digits and matches valid phone number patterns.
**Validates: Requirements 5.2**

Property 14: Positive number validation
*For any* numeric input field (price, quantity), the validator should reject any value that is less than or equal to zero.
**Validates: Requirements 5.3, 5.4**

Property 15: Form validation prevents submission
*For any* form with validation errors, attempting to submit should prevent the submission and return false from the form validation method.
**Validates: Requirements 5.6**

Property 16: Required field validation
*For any* form with required fields, the form should only validate successfully if all required fields contain non-empty, non-whitespace values.
**Validates: Requirements 5.7**

Property 17: Validation error translation
*For any* validation error, the error message should be available in all supported languages (English and Gujarati) and should use the translation system.
**Validates: Requirements 5.8**

Property 18: UI text translation completeness
*For any* UI text element (error messages, success messages, labels, buttons, placeholders), the text should be available in all supported languages through the translation system.
**Validates: Requirements 6.2, 6.3, 6.4, 6.5, 6.6**

Property 19: Translation fallback
*For any* translation key that does not exist in the translation map, the translation system should return the key itself as the fallback text.
**Validates: Requirements 6.7**

Property 20: Migration data preservation
*For any* existing data in the database before migration, applying the migration should not delete or corrupt any existing records.
**Validates: Requirements 7.6**

Property 21: Payment persistence
*For any* valid payment (positive amount, valid order ID, valid date), recording the payment should result in the payment being saved to the database and retrievable by payment ID.
**Validates: Requirements 8.1**

Property 22: Outstanding balance invariant
*For any* customer, the outstanding balance should always equal the sum of all order totals minus the sum of all payment amounts for that customer.
**Validates: Requirements 8.2, 8.4**

Property 23: Payment history completeness
*For any* customer, retrieving payment history should return all payments recorded for that customer's orders.
**Validates: Requirements 8.3**

Property 24: Payment status correctness
*For any* order, the payment status should be "paid" if total payments >= order total, "partial" if 0 < total payments < order total, and "unpaid" if total payments = 0.
**Validates: Requirements 8.5**

Property 25: Payment filtering
*For any* payment filter criteria (date range, payment method), only payments matching all specified criteria should be returned.
**Validates: Requirements 8.6**

Property 26: PIN validation before change
*For any* PIN change attempt, the change should only succeed if the provided current PIN matches the user's actual current PIN.
**Validates: Requirements 9.2**

Property 27: Settings persistence round-trip
*For any* settings change, saving the setting should result in the new value being persisted to local storage and retrievable on subsequent app launches.
**Validates: Requirements 9.6**

Property 28: Database error handling
*For any* database operation that fails, the application should display a user-friendly error message (not a technical stack trace) and log the technical details.
**Validates: Requirements 10.3**

Property 29: Retry mechanism availability
*For any* operation that fails with a transient error (network timeout, temporary database unavailability), the application should provide a retry mechanism.
**Validates: Requirements 10.4**

Property 30: Error logging completeness
*For any* error that occurs, the error details (message, stack trace, timestamp, user context) should be logged to the logging system.
**Validates: Requirements 10.5**

Property 31: Error message translation
*For any* error message displayed to the user, the message should be translated to the user's current language and use user-friendly terminology.
**Validates: Requirements 10.7**

Property 32: Order aggregation includes custom items
*For any* order aggregation operation (totals, counts, statistics), custom items should be included in all calculations alongside regular items.
**Validates: Requirements 11.1**

Property 33: Order total persistence invariant
*For any* order saved to the database, the persisted total field should equal the calculated sum of all item totals and custom item totals.
**Validates: Requirements 11.2**

Property 34: Audit trail creation
*For any* order modification (status change, item change, deletion), an audit trail entry should be created with the change details, timestamp, and user ID.
**Validates: Requirements 11.4**

Property 35: Order confirmation status
*For any* order that is confirmed, the order's status field should be set to "confirmed" in the database.
**Validates: Requirements 12.2**

Property 36: Status transition validation
*For any* order status change, the transition should only succeed if it follows the valid transition rules (pending→confirmed→in_transit→delivered, with cancellation allowed from any non-delivered state).
**Validates: Requirements 12.3**

Property 37: Delivery timestamp recording
*For any* order marked as delivered, the order's deliveredAt field should be set to the current timestamp and the deliveredBy field should be set to the current user ID.
**Validates: Requirements 12.4**

Property 38: Status history completeness
*For any* order, retrieving the status history should return all status changes in chronological order with timestamps and user IDs.
**Validates: Requirements 12.5**

Property 39: Sales report accuracy
*For any* date range and period (daily, weekly, monthly), the generated sales report should include all orders within the date range with correct revenue totals and order counts.
**Validates: Requirements 13.1**

Property 40: Product performance calculation
*For any* date range, the product performance report should correctly calculate total quantity sold, total revenue, and order count for each product.
**Validates: Requirements 13.2**

Property 41: Customer analysis completeness
*For any* customer, the customer analysis should include all orders placed by that customer with accurate totals and patterns.
**Validates: Requirements 13.3**

Property 42: Price trend accuracy
*For any* product, the price trend report should display all historical prices with correct dates and values.
**Validates: Requirements 13.4**

Property 43: Report export format validity
*For any* report and export format (PDF, CSV, Excel), the exported file should be a valid file of the specified format that can be opened by standard applications.
**Validates: Requirements 13.5**

Property 44: Report filtering correctness
*For any* report with filters (date range, customer, product), only data matching all specified filters should be included in the report.
**Validates: Requirements 13.6**

Property 45: Stock decrease on sale
*For any* product sale, the product's stock level should decrease by the quantity sold.
**Validates: Requirements 14.1**

Property 46: Stock increase on purchase
*For any* product purchase, the product's stock level should increase by the quantity purchased.
**Validates: Requirements 14.2**

Property 47: Low stock alert triggering
*For any* product with stock level below its threshold, a low stock alert should be displayed or flagged.
**Validates: Requirements 14.3**

Property 48: Inventory display accuracy
*For any* product, the displayed stock level should match the calculated stock level (initial stock + purchases - sales + adjustments).
**Validates: Requirements 14.4**

Property 49: Stock adjustment recording
*For any* manual stock adjustment, the adjustment should be recorded with the adjustment amount, reason, timestamp, and user ID.
**Validates: Requirements 14.6**

Property 50: Stock movement history completeness
*For any* product, the stock movement history should include all sales, purchases, and adjustments in chronological order.
**Validates: Requirements 14.7**

Property 51: Profit calculation invariant
*For any* order, the profit should equal the total revenue (selling price × quantity) minus the total cost (purchase price × quantity) for all items.
**Validates: Requirements 15.1**

Property 52: Profit aggregation accuracy
*For any* grouping (by product, customer, or time period), the aggregated profit should equal the sum of individual order profits in that group.
**Validates: Requirements 15.2**

Property 53: Invoice completeness
*For any* order, the generated invoice should include customer information, all order items with quantities and prices, subtotals, and the total amount.
**Validates: Requirements 15.3**

Property 54: Financial dashboard accuracy
*For any* time period, the financial dashboard should display total revenue, total costs, and total profit that match the sum of all orders in that period.
**Validates: Requirements 15.5**

Property 55: Invoice PDF validity
*For any* invoice export, the generated PDF should be a valid PDF file that can be opened and printed.
**Validates: Requirements 15.6**

Property 56: Payment reminder inclusion
*For any* customer with outstanding balance > 0, the customer should appear in the payment reminders list.
**Validates: Requirements 15.7**

Property 57: Pagination limits data transfer
*For any* paginated list request, the response should contain at most the page size number of items, not the entire dataset.
**Validates: Requirements 16.2**

Property 58: Cache reduces database queries
*For any* cached data, accessing the data a second time within the cache validity period should not trigger a database query.
**Validates: Requirements 16.3**

Property 59: Loading indicator display
*For any* asynchronous operation (network request, database query), a loading indicator should be displayed while the operation is in progress.
**Validates: Requirements 16.6, 20.3**

Property 60: Cache invalidation on data change
*For any* data modification operation, the cache for that data should be invalidated, causing the next access to fetch fresh data.
**Validates: Requirements 16.7**

Property 61: User role and permissions loading
*For any* user login, the user's role and associated permissions should be correctly loaded from the database.
**Validates: Requirements 17.1**

Property 62: Permission verification before access
*For any* feature access attempt, the user's permissions should be checked, and access should only be granted if the user has the required permission.
**Validates: Requirements 17.2**

Property 63: Access denial for unauthorized users
*For any* feature access attempt by a user without the required permission, access should be denied and an appropriate message should be displayed.
**Validates: Requirements 17.3**

Property 64: UI feature visibility based on permissions
*For any* user viewing the UI, only features for which the user has permission should be visible or enabled.
**Validates: Requirements 17.4**

Property 65: Sensitive data access restriction
*For any* non-admin user attempting to access sensitive financial data, access should be denied or the data should be hidden.
**Validates: Requirements 17.5**

Property 66: Role-based permission assignment
*For any* user role (owner, manager, staff, viewer), the correct set of permissions should be assigned according to the role's permission matrix.
**Validates: Requirements 17.7**

Property 67: Session timeout enforcement
*For any* user session, if the user is inactive for longer than the timeout period, the session should be automatically terminated and the user logged out.
**Validates: Requirements 19.1**

Property 68: PIN strength enforcement
*For any* PIN creation or change, the PIN should only be accepted if it meets the minimum strength requirements (length, complexity).
**Validates: Requirements 19.2**

Property 69: Rate limiting on failed logins
*For any* series of failed login attempts from the same user or IP, rate limiting should be applied after a threshold number of failures.
**Validates: Requirements 19.3**

Property 70: Audit logging for sensitive operations
*For any* sensitive operation (order deletion, payment recording, user role change), an audit log entry should be created with the operation details, user ID, and timestamp.
**Validates: Requirements 19.4**

Property 71: Sensitive data encryption
*For any* sensitive data field (PINs, payment information), the data should be encrypted before being stored in the database.
**Validates: Requirements 19.5**

Property 72: Audit log completeness
*For any* audit log query, all logged actions matching the query criteria should be returned with full context (user, timestamp, action, details).
**Validates: Requirements 19.6**

Property 73: Destructive action confirmation
*For any* destructive action (delete order, delete customer, cancel order), a confirmation dialog should be displayed before the action is executed.
**Validates: Requirements 20.1**

Property 74: Empty state display
*For any* list view with zero items, an empty state illustration and helpful message should be displayed instead of a blank screen.
**Validates: Requirements 20.5**

Property 75: Form error highlighting
*For any* form with validation errors, all fields with errors should be visually highlighted and display descriptive error messages.
**Validates: Requirements 20.6**

Property 76: Success message display
*For any* successful operation (order created, payment recorded, product added), a brief success message should be displayed to the user.
**Validates: Requirements 20.7**

## Error Handling

### Error Categories

1. **Network Errors**
   - Timeout: Display timeout message with retry option
   - No connection: Display offline message, queue operations for later
   - Server errors: Display generic error, log details

2. **Validation Errors**
   - Display field-specific errors inline
   - Prevent form submission
   - Highlight error fields in red

3. **Database Errors**
   - Display user-friendly message
   - Log technical details
   - Provide retry option for transient failures

4. **Permission Errors**
   - Display "Access Denied" message
   - Hide unauthorized features
   - Log unauthorized access attempts

5. **Business Logic Errors**
   - Display specific error message (e.g., "Cannot delete order with payments")
   - Provide guidance on how to resolve
   - Log error for analysis

### Error Recovery Strategies

```dart
class ErrorRecoveryService {
  // Retry with exponential backoff
  Future<T> retryWithBackoff<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    Duration delay = initialDelay;
    
    while (attempts < maxAttempts) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts >= maxAttempts) rethrow;
        
        await Future.delayed(delay);
        delay *= 2; // Exponential backoff
      }
    }
    
    throw Exception('Max retry attempts reached');
  }
  
  // Queue operations for offline execution
  Future<void> queueForOffline(Operation operation) async {
    await _offlineQueue.add(operation);
  }
  
  // Sync queued operations when online
  Future<void> syncOfflineQueue() async {
    if (!await _errorHandlingService.isOnline()) return;
    
    final operations = await _offlineQueue.getAll();
    for (final operation in operations) {
      try {
        await operation.execute();
        await _offlineQueue.remove(operation.id);
      } catch (e) {
        _loggingService.logError('Failed to sync operation', e);
      }
    }
  }
}
```

## Testing Strategy

### Dual Testing Approach

The application requires both unit testing and property-based testing for comprehensive coverage:

- **Unit tests**: Verify specific examples, edge cases, and error conditions
- **Property tests**: Verify universal properties across all inputs
- Both are complementary and necessary

### Unit Testing

Unit tests focus on:
- Specific examples that demonstrate correct behavior
- Integration points between components
- Edge cases (empty lists, null values, boundary conditions)
- Error conditions (network failures, invalid inputs)

Unit tests should NOT try to cover all possible inputs - that's what property tests are for.

### Property-Based Testing

Property-based testing will use the **fast_check** library (if using TypeScript/JavaScript) or **check** library (if using Dart).

Configuration:
- Minimum 100 iterations per property test
- Each test tagged with: **Feature: production-readiness-complete, Property {number}: {property_text}**
- Each correctness property implemented by a SINGLE property-based test

Example property test structure:

```dart
import 'package:test/test.dart';
import 'package:check/check.dart';

void main() {
  group('Order Total Invariant', () {
    test('Feature: production-readiness-complete, Property 6: Order total invariant', () {
      // Property: For any order with items and custom items, 
      // the order total should equal sum of all item totals
      
      check(
        arbitrary: Arbitrary.combine2(
          Arbitrary.list(orderItemArbitrary),
          Arbitrary.list(customItemArbitrary),
          (items, customItems) => (items, customItems),
        ),
        property: (data) {
          final (items, customItems) = data;
          final order = Order(items: items, customItems: customItems);
          
          final expectedTotal = items.fold<double>(0, (sum, item) => sum + item.total) +
                               customItems.fold<double>(0, (sum, item) => sum + item.total);
          
          return order.total == expectedTotal;
        },
        iterations: 100,
      );
    });
  });
}
```

### Test Coverage Goals

- **Critical business logic**: 80% minimum code coverage
- **Repositories**: 100% method coverage with unit tests
- **Controllers**: 80% coverage with unit tests
- **Services**: 80% coverage with unit tests
- **Validators**: 100% coverage with property tests
- **UI widgets**: Critical user journeys with integration tests

### Integration Testing

Integration tests verify:
- Complete user workflows (create order → add items → confirm → deliver → record payment)
- Database operations with real Supabase connection (test environment)
- Authentication and authorization flows
- File upload and download operations

### UI Testing

UI tests verify:
- Main user journeys work end-to-end
- Navigation flows
- Form submissions
- Error message display
- Loading states

## Implementation Phases

### Phase 1: Critical Fixes (Weeks 1-2)

**Focus**: Complete truncated files, add core functionality, implement validation

Tasks:
1. Complete orders_view.dart and customers_view.dart
2. Implement functional product add/edit feature
3. Fix order editing and custom items persistence
4. Add comprehensive input validation
5. Add missing translations
6. Apply database migration

**Success Criteria**:
- All view files render completely
- Products can be added and edited
- Orders can be edited with custom items
- All forms validate inputs
- No hardcoded English strings
- Database schema updated

### Phase 2: High Priority (Weeks 3-4)

**Focus**: Payment tracking, settings, error handling, data consistency

Tasks:
1. Implement payment tracking UI and service
2. Complete settings features (Change PIN, Help, Privacy)
3. Add comprehensive error handling
4. Fix data consistency issues
5. Implement complete order workflow

**Success Criteria**:
- Payments can be recorded and tracked
- Outstanding balances calculated correctly
- Settings features functional
- Errors handled gracefully with retry
- Order workflow enforces status transitions
- Audit trail created for all changes

### Phase 3: Medium Priority (Weeks 5-6)

**Focus**: Reports, inventory, financial features, performance, access control

Tasks:
1. Implement reports and analytics with export
2. Add inventory management
3. Create financial features UI
4. Optimize database queries and implement caching
5. Implement role-based access control

**Success Criteria**:
- Reports generate accurately and export to PDF/CSV
- Inventory tracks stock levels and movements
- Profit calculations accurate
- Queries optimized with indexes
- Caching reduces database load
- Access control enforces permissions

### Phase 4: Testing & Polish (Weeks 7-8)

**Focus**: Comprehensive testing, security, performance, UX improvements

Tasks:
1. Write comprehensive test suite (unit, property, integration, UI)
2. Add security hardening
3. Performance optimization
4. UI polish and UX improvements

**Success Criteria**:
- 80% code coverage achieved
- All 76 properties tested
- Security features implemented
- Performance meets targets
- UI polished with confirmations, loading states, empty states

## Dependencies and Constraints

### External Dependencies

- Flutter SDK 3.x
- GetX state management
- Supabase client
- Image picker plugin
- PDF generation library (pdf package)
- CSV generation library (csv package)
- Property-based testing library (check package for Dart)

### Technical Constraints

- Must maintain backward compatibility with existing data
- Must support offline operation for critical features
- Must support both English and Gujarati languages
- Must work on Android and iOS
- Must handle poor network conditions gracefully

### Business Constraints

- Cannot break existing functionality during implementation
- Must prioritize critical fixes before enhancements
- Must maintain data integrity at all times
- Must comply with data privacy requirements

## Deployment Strategy

### Database Migration

1. Backup production database
2. Test migration on staging environment
3. Apply migration during low-traffic period
4. Verify all tables, columns, indexes, and policies created
5. Run data integrity checks
6. Monitor for errors

### Application Deployment

1. Deploy Phase 1 changes first (critical fixes)
2. Monitor for issues for 1 week
3. Deploy Phase 2 changes (high priority)
4. Monitor for issues for 1 week
5. Deploy Phase 3 changes (medium priority)
6. Monitor for issues for 1 week
7. Deploy Phase 4 changes (testing & polish)

### Rollback Plan

- Keep previous version APK/IPA available
- Database migration includes rollback script
- Can revert to previous version if critical issues found
- Data changes are backward compatible

## Monitoring and Maintenance

### Logging

- Log all errors with stack traces
- Log all sensitive operations (audit trail)
- Log performance metrics
- Log user actions for analytics

### Monitoring

- Monitor error rates
- Monitor API response times
- Monitor database query performance
- Monitor user engagement metrics

### Maintenance

- Regular database backups
- Regular security updates
- Regular dependency updates
- Regular performance optimization

## Conclusion

This design provides a comprehensive approach to making the Grocery Broker application production-ready. By addressing all critical, high, and medium priority issues systematically across four phases, the application will be transformed from a prototype with incomplete features into a robust, tested, and production-quality application.

The design maintains the existing architecture while completing incomplete features, adding missing functionality, and improving overall quality. The dual testing approach (unit tests + property-based tests) ensures comprehensive coverage and correctness guarantees.

Implementation will proceed incrementally, with each phase building upon the previous one, allowing for continuous validation and user feedback throughout the 8-week timeline.
