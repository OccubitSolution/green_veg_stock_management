# Design Document: Grocery Broker Workflow Enhancement

## Overview

This design document specifies the technical architecture and implementation approach for enhancing a Flutter-based grocery brokerage management application. The system currently provides basic order management but lacks critical workflow features for purchase tracking, order status management, delivery coordination, cost tracking, and role-based access control.

The enhancement will transform the application from a simple order recording system into a complete broker workflow management platform that supports:

- **Purchase workflow**: Track what has been purchased from farms with costs and suppliers
- **Order lifecycle**: Manage orders through pending → confirmed → purchased → delivered states
- **Staff access control**: Restrict staff visibility to confirmed orders only, hide cost/profit data
- **Delivery management**: Group orders into delivery bundles and track completion
- **Profit tracking**: Calculate and report profits at item, order, and daily levels
- **Payment tracking**: Monitor payment collection and outstanding balances

The design leverages the existing Flutter/GetX architecture with Supabase PostgreSQL backend, maintaining consistency with the current codebase while adding new capabilities.

## Architecture

### System Architecture

The application follows a layered architecture pattern:

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  (Flutter UI + GetX Controllers + Bindings)             │
└─────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────┐
│                    Business Logic Layer                  │
│  (Services + Repositories + State Management)           │
└─────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────┐
│                    Data Access Layer                     │
│  (Supabase Client + Data Providers)                     │
└─────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────┐
│                    Database Layer                        │
│  (PostgreSQL via Supabase)                              │
└─────────────────────────────────────────────────────────┘
```

### Technology Stack

- **Frontend**: Flutter 3.x with GetX for state management and routing
- **Backend**: Supabase (PostgreSQL + REST API + Realtime subscriptions)
- **Authentication**: Supabase Auth with PIN-based secondary authentication
- **State Management**: GetX (Reactive state management)
- **Local Storage**: SharedPreferences for user preferences
- **Internationalization**: GetX translations (Gujarati + English)

### Module Structure

The enhancement will add new modules and extend existing ones:

**New Modules:**
- `lib/app/modules/purchase_tracking/` - Purchase confirmation and history
- `lib/app/modules/delivery_bundles/` - Delivery route management
- `lib/app/modules/profit_reports/` - Cost and profit analytics
- `lib/app/modules/payment_tracking/` - Payment collection management

**Extended Modules:**
- `lib/app/modules/orders/` - Add status workflow and staff filtering
- `lib/app/modules/purchases/` - Enhance purchase list with persistence
- `lib/app/modules/dashboard/` - Add operations dashboard
- `lib/app/modules/settings/` - Add staff role management

## Components and Interfaces

### 1. Purchase Tracking Component

**Purpose**: Enable admins to mark products as purchased from farms and record purchase details.

**Key Classes:**

```dart
class PurchaseTrackingController extends GetxController {
  // Observable state
  final RxList<AggregatedOrderItem> purchaseList = <AggregatedOrderItem>[].obs;
  final RxMap<String, PurchaseStatus> purchaseStatuses = <String, PurchaseStatus>{}.obs;
  final RxBool isLoading = false.obs;
  
  // Methods
  Future<void> loadPurchaseList(DateTime date);
  Future<void> markAsPurchased(String productId, PurchaseDetails details);
  Future<void> loadPurchaseHistory(DateTime startDate, DateTime endDate);
  Future<void> updatePurchaseStatus(String purchaseItemId, PurchaseDetails details);
}

class PurchaseDetails {
  final double costPerUnit;
  final String? supplierName;
  final String? notes;
  final DateTime purchaseDate;
}

class PurchaseStatus {
  final bool isPurchased;
  final String? purchaseId;
  final String? purchaseItemId;
  final double? costPerUnit;
  final String? supplierName;
  final DateTime? purchasedAt;
}
```

**Database Changes:**

The existing `purchases` and `purchase_items` tables will be used. Add a new junction table to link purchase items to aggregated order items:

```sql
CREATE TABLE purchase_order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    purchase_item_id UUID NOT NULL REFERENCES purchase_items(id) ON DELETE CASCADE,
    order_item_id UUID NOT NULL REFERENCES order_items(id) ON DELETE CASCADE,
    quantity DECIMAL(10, 3) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(purchase_item_id, order_item_id)
);
```

**UI Components:**
- `PurchaseListView` - Display aggregated items with purchase checkboxes
- `PurchaseDetailsDialog` - Modal for entering cost and supplier info
- `PurchaseHistoryView` - List of past purchases with filtering

### 2. Order Status Workflow Component

**Purpose**: Manage orders through a defined lifecycle with proper state transitions.

**Key Classes:**

```dart
class OrderWorkflowService {
  // Status transition methods
  Future<bool> confirmOrder(String orderId);
  Future<bool> markAsPurchased(String orderId);
  Future<bool> markAsDelivered(String orderId, DeliveryDetails details);
  Future<bool> cancelOrder(String orderId, String reason);
  
  // Validation
  bool canTransitionTo(OrderStatus current, OrderStatus target);
  List<OrderStatus> getAvailableTransitions(OrderStatus current);
}

class DeliveryDetails {
  final DateTime deliveredAt;
  final String? deliveredBy;
  final String? notes;
}

class OrderStatusHistory {
  final String id;
  final String orderId;
  final OrderStatus fromStatus;
  final OrderStatus toStatus;
  final String changedBy;
  final DateTime changedAt;
  final String? notes;
}
```

**Database Changes:**

Add status history tracking:

```sql
CREATE TABLE order_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    from_status VARCHAR(50),
    to_status VARCHAR(50) NOT NULL,
    changed_by UUID NOT NULL REFERENCES vendors(id),
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

CREATE INDEX idx_order_status_history_order ON order_status_history(order_id);
CREATE INDEX idx_order_status_history_date ON order_status_history(changed_at);
```

Add delivery tracking fields to orders table:

```sql
ALTER TABLE orders ADD COLUMN delivered_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE orders ADD COLUMN delivered_by UUID REFERENCES vendors(id);
ALTER TABLE orders ADD COLUMN cancellation_reason TEXT;
ALTER TABLE orders ADD COLUMN cancelled_at TIMESTAMP WITH TIME ZONE;
```

**State Transition Rules:**

```
pending → confirmed (admin only)
confirmed → purchased (automatic when all items purchased)
purchased → delivered (admin or staff)
any → cancelled (admin only, with reason)
```

### 3. Staff Access Control Component

**Purpose**: Implement role-based access control to restrict staff visibility and permissions.

**Key Classes:**

```dart
enum StaffRole {
  admin,
  manager,
  deliveryStaff,
  viewer
}

class AccessControlService {
  // Permission checks
  bool canViewCosts(String userId);
  bool canConfirmOrders(String userId);
  bool canCancelOrders(String userId);
  bool canMarkDelivered(String userId);
  bool canManageProducts(String userId);
  bool canManageCustomers(String userId);
  bool canViewReports(String userId);
  
  // Data filtering
  List<Order> filterOrdersForUser(List<Order> orders, String userId, StaffRole role);
  List<AggregatedOrderItem> filterPurchaseListForUser(
    List<AggregatedOrderItem> items, 
    String userId, 
    StaffRole role
  );
}

class StaffPermissions {
  final bool canViewCosts;
  final bool canConfirmOrders;
  final bool canCancelOrders;
  final bool canMarkDelivered;
  final bool canManageProducts;
  final bool canManageCustomers;
  final bool canViewReports;
  
  static StaffPermissions forRole(StaffRole role) {
    switch (role) {
      case StaffRole.admin:
        return StaffPermissions(
          canViewCosts: true,
          canConfirmOrders: true,
          canCancelOrders: true,
          canMarkDelivered: true,
          canManageProducts: true,
          canManageCustomers: true,
          canViewReports: true,
        );
      case StaffRole.manager:
        return StaffPermissions(
          canViewCosts: false,
          canConfirmOrders: false,
          canCancelOrders: false,
          canMarkDelivered: true,
          canManageProducts: false,
          canManageCustomers: false,
          canViewReports: true,
        );
      case StaffRole.deliveryStaff:
        return StaffPermissions(
          canViewCosts: false,
          canConfirmOrders: false,
          canCancelOrders: false,
          canMarkDelivered: true,
          canManageProducts: false,
          canManageCustomers: false,
          canViewReports: false,
        );
      case StaffRole.viewer:
        return StaffPermissions(
          canViewCosts: false,
          canConfirmOrders: false,
          canCancelOrders: false,
          canMarkDelivered: false,
          canManageProducts: false,
          canManageCustomers: false,
          canViewReports: false,
        );
    }
  }
}
```

**Database Changes:**

Extend vendors table with role information:

```sql
ALTER TABLE vendors ADD COLUMN role VARCHAR(50) DEFAULT 'admin' 
  CHECK (role IN ('admin', 'manager', 'delivery_staff', 'viewer'));
ALTER TABLE vendors ADD COLUMN invited_by UUID REFERENCES vendors(id);
ALTER TABLE vendors ADD COLUMN invite_code VARCHAR(20) UNIQUE;

CREATE INDEX idx_vendors_role ON vendors(role);
CREATE INDEX idx_vendors_invited_by ON vendors(invited_by);
```

**Access Control Rules:**

- **Admin**: Full access to all features and data
- **Manager**: Can view confirmed orders, manage deliveries, record payments (no cost/profit visibility)
- **Delivery Staff**: Can view confirmed orders, mark deliveries complete (no cost/profit visibility)
- **Viewer**: Can view confirmed orders only (read-only, no cost/profit visibility)

### 4. Delivery Bundle Component

**Purpose**: Group orders by delivery route and assign to staff for efficient delivery management.

**Key Classes:**

```dart
class DeliveryBundle {
  final String id;
  final String vendorId;
  final String name;
  final DateTime deliveryDate;
  final String? assignedTo;
  final DeliveryBundleStatus status;
  final List<String> orderIds;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Computed properties
  int get totalOrders => orderIds.length;
  int get deliveredOrders;
  int get pendingOrders;
  bool get isComplete => deliveredOrders == totalOrders;
}

enum DeliveryBundleStatus {
  planned,
  inProgress,
  completed
}

class DeliveryBundleController extends GetxController {
  Future<DeliveryBundle> createBundle(
    String name,
    DateTime date,
    List<String> orderIds,
    String? assignedTo
  );
  Future<void> assignToStaff(String bundleId, String staffId);
  Future<void> addOrders(String bundleId, List<String> orderIds);
  Future<void> removeOrders(String bundleId, List<String> orderIds);
  Future<void> markOrderDelivered(String bundleId, String orderId, DeliveryDetails details);
  Future<List<DeliveryBundle>> getBundlesForStaff(String staffId);
  Future<String> generateDeliverySheet(String bundleId);
}
```

**Database Changes:**

```sql
CREATE TABLE delivery_bundles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id UUID NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    delivery_date DATE NOT NULL,
    assigned_to UUID REFERENCES vendors(id),
    status VARCHAR(50) DEFAULT 'planned' CHECK (status IN ('planned', 'in_progress', 'completed')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE delivery_bundle_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bundle_id UUID NOT NULL REFERENCES delivery_bundles(id) ON DELETE CASCADE,
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    sequence INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(bundle_id, order_id)
);

CREATE INDEX idx_delivery_bundles_vendor ON delivery_bundles(vendor_id);
CREATE INDEX idx_delivery_bundles_assigned ON delivery_bundles(assigned_to);
CREATE INDEX idx_delivery_bundles_date ON delivery_bundles(delivery_date);
CREATE INDEX idx_delivery_bundle_orders_bundle ON delivery_bundle_orders(bundle_id);
CREATE INDEX idx_delivery_bundle_orders_order ON delivery_bundle_orders(order_id);
```

**UI Components:**
- `DeliveryBundleListView` - List of all bundles with status
- `CreateDeliveryBundleView` - Select orders and create bundle
- `DeliveryBundleDetailView` - View bundle details with delivery tracking
- `DeliverySheetView` - Printable/shareable delivery sheet

### 5. Cost and Profit Tracking Component

**Purpose**: Calculate and display profit margins at various levels (item, order, daily).

**Key Classes:**

```dart
class ProfitCalculationService {
  // Item-level calculations
  double calculateItemProfit(OrderItem item);
  double calculateItemProfitMargin(OrderItem item);
  
  // Order-level calculations
  double calculateOrderCost(String orderId);
  double calculateOrderRevenue(String orderId);
  double calculateOrderProfit(String orderId);
  double calculateOrderProfitMargin(String orderId);
  
  // Daily calculations
  Future<DailySummary> calculateDailySummary(DateTime date);
  
  // Period calculations
  Future<PeriodSummary> calculatePeriodSummary(DateTime start, DateTime end);
}

class DailySummary {
  final DateTime date;
  final int totalOrders;
  final int deliveredOrders;
  final double totalRevenue;
  final double totalCost;
  final double totalProfit;
  final double profitMargin;
  final Map<String, double> profitByCustomer;
  final Map<String, double> profitByProduct;
}

class PeriodSummary {
  final DateTime startDate;
  final DateTime endDate;
  final int totalOrders;
  final double totalRevenue;
  final double totalCost;
  final double totalProfit;
  final double averageProfitMargin;
  final List<DailySummary> dailyBreakdown;
}

class ProfitReportController extends GetxController {
  final Rx<DailySummary?> todaySummary = Rx<DailySummary?>(null);
  final RxList<DailySummary> weekSummary = <DailySummary>[].obs;
  
  Future<void> loadTodaySummary();
  Future<void> loadPeriodSummary(DateTime start, DateTime end);
  Future<void> exportReport(PeriodSummary summary, ExportFormat format);
}
```

**Calculation Logic:**

```dart
// Item profit
itemProfit = (pricePerUnit - costPrice) * quantity

// Item profit margin
itemProfitMargin = ((pricePerUnit - costPrice) / pricePerUnit) * 100

// Order profit
orderProfit = sum(itemProfit for all items in order)

// Order profit margin
orderProfitMargin = (orderProfit / orderRevenue) * 100

// Daily profit
dailyProfit = sum(orderProfit for all delivered orders on date)
```

**UI Components:**
- `ProfitDashboardView` - Overview of today's profits
- `ProfitReportView` - Detailed profit analysis with filters
- `ProfitChartView` - Visual profit trends over time

### 6. Payment Tracking Component

**Purpose**: Track payment collection from customers and manage accounts receivable.

**Key Classes:**

```dart
class Payment {
  final String id;
  final String orderId;
  final double amount;
  final DateTime paymentDate;
  final String? paymentMethod;
  final String? notes;
  final String recordedBy;
  final DateTime createdAt;
}

class PaymentTrackingService {
  Future<void> recordPayment(String orderId, Payment payment);
  Future<List<Payment>> getPaymentsForOrder(String orderId);
  Future<double> getOutstandingBalance(String customerId);
  Future<Map<String, double>> getAllOutstandingBalances();
  Future<List<Order>> getUnpaidOrders(String? customerId);
}

class PaymentTrackingController extends GetxController {
  final RxMap<String, double> outstandingBalances = <String, double>{}.obs;
  
  Future<void> recordPayment(String orderId, double amount, String? notes);
  Future<void> loadOutstandingBalances();
  Future<void> loadPaymentHistory(String customerId);
}
```

**Database Changes:**

```sql
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
    payment_date DATE NOT NULL DEFAULT CURRENT_DATE,
    payment_method VARCHAR(50),
    notes TEXT,
    recorded_by UUID NOT NULL REFERENCES vendors(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_payments_order ON payments(order_id);
CREATE INDEX idx_payments_date ON payments(payment_date);
```

**Payment Status Logic:**

```dart
// Calculate payment status based on total payments
double totalPaid = sum(all payments for order);
double totalAmount = order.totalAmount;

if (totalPaid >= totalAmount) {
  paymentStatus = PaymentStatus.paid;
} else if (totalPaid > 0) {
  paymentStatus = PaymentStatus.partial;
} else {
  paymentStatus = PaymentStatus.unpaid;
}
```

### 7. Dashboard Component

**Purpose**: Provide at-a-glance view of daily operations and key metrics.

**Key Classes:**

```dart
class DashboardMetrics {
  final int pendingOrders;
  final int confirmedOrders;
  final int purchasedOrders;
  final int deliveredOrders;
  final int unpurchasedItems;
  final double todayRevenue;
  final double todayCost;
  final double todayProfit;
  final Map<String, double> outstandingPayments;
  final List<DeliveryBundle> activeDeliveryBundles;
}

class DashboardController extends GetxController {
  final Rx<DashboardMetrics?> metrics = Rx<DashboardMetrics?>(null);
  final RxBool isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadMetrics();
    // Refresh every 5 minutes
    ever(metrics, (_) => Future.delayed(Duration(minutes: 5), loadMetrics));
  }
  
  Future<void> loadMetrics();
  Future<void> refresh();
}
```

**UI Layout:**

```
┌─────────────────────────────────────────────┐
│  Dashboard - Today's Operations             │
├─────────────────────────────────────────────┤
│  Orders Status                              │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐      │
│  │  5   │ │  12  │ │  8   │ │  15  │      │
│  │Pending│ │Confirmed│ │Purchased│ │Delivered│ │
│  └──────┘ └──────┘ └──────┘ └──────┘      │
├─────────────────────────────────────────────┤
│  Purchase List                              │
│  ┌──────────────────────────────────────┐  │
│  │  23 items unpurchased                │  │
│  │  View Purchase List →                │  │
│  └──────────────────────────────────────┘  │
├─────────────────────────────────────────────┤
│  Today's Profit                             │
│  Revenue: ₹45,000                           │
│  Cost: ₹32,000                              │
│  Profit: ₹13,000 (28.9%)                    │
├─────────────────────────────────────────────┤
│  Outstanding Payments                       │
│  Hotel ABC: ₹5,000                          │
│  Cafe XYZ: ₹3,500                           │
│  View All →                                 │
├─────────────────────────────────────────────┤
│  Active Delivery Bundles                    │
│  Route A: 5/8 delivered                     │
│  Route B: 2/6 delivered                     │
│  View All →                                 │
└─────────────────────────────────────────────┘
```

## Data Models

### Enhanced Order Model

```dart
class Order {
  final String id;
  final String customerId;
  final String vendorId;
  final DateTime orderDate;
  final OrderStatus status;
  final double? totalAmount;
  final double? totalCost;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // New fields
  final DateTime? deliveredAt;
  final String? deliveredBy;
  final String? cancellationReason;
  final DateTime? cancelledAt;
  
  // Payment tracking
  final PaymentStatus paymentStatus;
  final double paidAmount;
  
  // Computed properties
  double get totalProfit => (totalAmount ?? 0) - (totalCost ?? 0);
  double get profitMargin => totalAmount != null && totalAmount! > 0 
    ? (totalProfit / totalAmount!) * 100 
    : 0;
  double get pendingAmount => (totalAmount ?? 0) - paidAmount;
  bool get isFullyPaid => pendingAmount <= 0;
  bool get canBeConfirmed => status == OrderStatus.pending;
  bool get canBeDelivered => status == OrderStatus.purchased;
  bool get canBeCancelled => status != OrderStatus.delivered && status != OrderStatus.cancelled;
}
```

### Purchase Status Model

```dart
class PurchaseStatusInfo {
  final String productId;
  final bool isPurchased;
  final String? purchaseId;
  final String? purchaseItemId;
  final double? costPerUnit;
  final String? supplierName;
  final DateTime? purchasedAt;
  final String? purchasedBy;
  
  bool get isNotPurchased => !isPurchased;
}
```

### Delivery Bundle Model

```dart
class DeliveryBundle {
  final String id;
  final String vendorId;
  final String name;
  final DateTime deliveryDate;
  final String? assignedTo;
  final DeliveryBundleStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Joined data
  final List<BundleOrder> orders;
  final String? assignedToName;
  
  int get totalOrders => orders.length;
  int get deliveredOrders => orders.where((o) => o.isDelivered).length;
  int get pendingOrders => totalOrders - deliveredOrders;
  bool get isComplete => deliveredOrders == totalOrders;
  double get completionPercentage => totalOrders > 0 
    ? (deliveredOrders / totalOrders) * 100 
    : 0;
}

class BundleOrder {
  final String orderId;
  final String customerName;
  final String? customerAddress;
  final String? customerPhone;
  final OrderStatus orderStatus;
  final int sequence;
  final bool isDelivered;
  final DateTime? deliveredAt;
}
```

### Staff Member Model

```dart
class StaffMember {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final StaffRole role;
  final String invitedBy;
  final String? inviteCode;
  final bool isActive;
  final DateTime createdAt;
  
  StaffPermissions get permissions => StaffPermissions.forRole(role);
}
```

## Error Handling

### Error Types

```dart
enum WorkflowErrorType {
  invalidStatusTransition,
  insufficientPermissions,
  orderNotFound,
  purchaseNotFound,
  deliveryBundleNotFound,
  invalidPaymentAmount,
  orderAlreadyCancelled,
  orderAlreadyDelivered,
  cannotModifyDeliveredOrder,
  staffNotFound,
  invalidRole,
}

class WorkflowException implements Exception {
  final WorkflowErrorType type;
  final String message;
  final String? details;
  
  WorkflowException(this.type, this.message, [this.details]);
  
  @override
  String toString() => 'WorkflowException: $message${details != null ? ' ($details)' : ''}';
}
```

### Error Handling Strategy

1. **Validation Errors**: Display user-friendly messages in the UI with specific guidance
2. **Permission Errors**: Show clear messages explaining required permissions
3. **Network Errors**: Implement retry logic with exponential backoff
4. **Database Errors**: Log errors and show generic message to user
5. **State Transition Errors**: Prevent invalid transitions in UI, show error if attempted

### Error Messages (Bilingual)

```dart
class WorkflowErrorMessages {
  static String getMessage(WorkflowErrorType type, String lang) {
    final messages = {
      WorkflowErrorType.invalidStatusTransition: {
        'en': 'Cannot change order status. Invalid transition.',
        'gu': 'ઓર્ડર સ્ટેટસ બદલી શકાતું નથી. અમાન્ય સંક્રમણ.',
      },
      WorkflowErrorType.insufficientPermissions: {
        'en': 'You do not have permission to perform this action.',
        'gu': 'તમને આ ક્રિયા કરવાની પરવાનગી નથી.',
      },
      // ... more error messages
    };
    
    return messages[type]?[lang] ?? 'An error occurred';
  }
}
```

### Retry Logic

```dart
class RetryPolicy {
  static const int maxRetries = 3;
  static const Duration initialDelay = Duration(seconds: 1);
  
  static Future<T> executeWithRetry<T>(
    Future<T> Function() operation,
    {bool Function(dynamic error)? shouldRetry}
  ) async {
    int attempts = 0;
    Duration delay = initialDelay;
    
    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries || (shouldRetry != null && !shouldRetry(e))) {
          rethrow;
        }
        await Future.delayed(delay);
        delay *= 2; // Exponential backoff
      }
    }
    
    throw Exception('Max retries exceeded');
  }
}
```

## Testing Strategy

The testing strategy employs a dual approach combining unit tests for specific scenarios and property-based tests for universal correctness properties.

### Testing Framework

- **Unit Testing**: Flutter's built-in `test` package
- **Widget Testing**: Flutter's `flutter_test` package
- **Property-Based Testing**: `glados` package for Dart
- **Mocking**: `mockito` for creating test doubles
- **Integration Testing**: Flutter integration tests for end-to-end flows

### Test Configuration

All property-based tests will run a minimum of 100 iterations to ensure comprehensive coverage through randomization. Each property test will be tagged with a comment referencing its corresponding design property.

### Unit Testing Approach

Unit tests will focus on:
- Specific examples demonstrating correct behavior
- Edge cases (empty lists, null values, boundary conditions)
- Error conditions and exception handling
- Integration points between components
- UI widget behavior and user interactions

### Property-Based Testing Approach

Property tests will focus on:
- Universal properties that hold for all valid inputs
- Invariants that must be maintained across operations
- Round-trip properties (serialize/deserialize, encode/decode)
- Metamorphic properties (relationships between operations)
- Comprehensive input coverage through randomization

### Test Organization

Tests will be organized by module:
```
test/
  unit/
    purchase_tracking_test.dart
    order_workflow_test.dart
    access_control_test.dart
    delivery_bundle_test.dart
    profit_calculation_test.dart
    payment_tracking_test.dart
  property/
    purchase_tracking_properties_test.dart
    order_workflow_properties_test.dart
    access_control_properties_test.dart
    delivery_bundle_properties_test.dart
    profit_calculation_properties_test.dart
  widget/
    purchase_list_widget_test.dart
    order_status_widget_test.dart
    delivery_bundle_widget_test.dart
  integration/
    complete_workflow_test.dart
```


## Correctness Properties

A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.

### Property Reflection

After analyzing all acceptance criteria, I identified several redundant properties that can be consolidated:

- **Access Control Properties**: Properties 3.1 and 3.2 (staff filtering) can be combined into one comprehensive property about staff seeing only confirmed/purchased/delivered orders
- **Access Control Properties**: Properties 3.4 and 3.5 (cost visibility) can be combined into one property about role-based cost visibility
- **Purchase List Filtering**: Properties 6.3, 6.4, and 6.5 can be combined into one property about filtering by purchase status
- **Order Cancellation**: Properties 6.8 and 12.5 are identical (removing cancelled orders from purchase list)
- **Bilingual Output**: Properties 13.3 and 15.5 are identical (including both language names in purchase list)

### Purchase Tracking Properties

**Property 1: Purchase persistence**
*For any* product marked as purchased with cost and supplier details, persisting the purchase should create a Purchase record and associated Purchase_Item record in the database with all provided details.
**Validates: Requirements 1.3, 1.4**

**Property 2: Purchase history completeness**
*For any* set of purchases in the database, the purchase history view should display all purchases with their dates, products, quantities, costs, and suppliers.
**Validates: Requirements 1.6**

**Property 3: Profit calculation correctness**
*For any* order with recorded cost prices, the calculated profit should equal the sum of (selling price - cost price) × quantity for all items.
**Validates: Requirements 1.7, 5.3**

**Property 4: Time-based purchase edit permissions**
*For any* purchase record, edit and delete operations should be allowed if and only if the purchase was created less than 24 hours ago.
**Validates: Requirements 1.8**

### Order Workflow Properties

**Property 5: New order default status**
*For any* newly created order, the initial status should be set to pending.
**Validates: Requirements 2.1**

**Property 6: Order confirmation transition**
*For any* order with status pending, confirming the order should change its status to confirmed.
**Validates: Requirements 2.2**

**Property 7: Automatic purchase status transition**
*For any* order with status confirmed, if all items in the order are marked as purchased, the order status should automatically change to purchased.
**Validates: Requirements 2.3**

**Property 8: Delivery status transition with timestamp**
*For any* order with status purchased, marking it as delivered should change its status to delivered and record the current timestamp and user ID.
**Validates: Requirements 2.4, 7.1, 7.3**

**Property 9: Cancellation with reason**
*For any* order that is not already delivered or cancelled, cancelling it should change its status to cancelled and store the provided cancellation reason.
**Validates: Requirements 2.5, 12.4**

**Property 10: Invalid state transition rejection**
*For any* order status transition that violates the workflow rules (pending→confirmed→purchased→delivered), the system should reject the transition and return an error.
**Validates: Requirements 2.6**

**Property 11: Status change audit trail**
*For any* order status change, an audit log entry should be created containing the old status, new status, timestamp, user ID, and optional notes.
**Validates: Requirements 2.8, 12.7**

### Access Control Properties

**Property 12: Staff purchase list filtering**
*For any* staff user (non-admin) viewing the purchase list, only items from orders with status confirmed, purchased, or delivered should be included.
**Validates: Requirements 3.1, 3.2**

**Property 13: Admin purchase list visibility**
*For any* admin user viewing the purchase list, items from all orders should be included regardless of status.
**Validates: Requirements 3.3**

**Property 14: Role-based cost visibility**
*For any* user viewing order details, cost prices and profit information should be visible if and only if the user has admin role.
**Validates: Requirements 3.4, 3.5, 9.5**

**Property 15: Staff delivery permission**
*For any* staff user attempting to change order status, only the transition to delivered status should be allowed; all other status changes should be rejected.
**Validates: Requirements 3.6**

**Property 16: Staff purchase cost restriction**
*For any* staff user attempting to access purchase cost entry or editing features, the operation should be rejected with an insufficient permissions error.
**Validates: Requirements 3.7**

**Property 17: Staff role permissions enforcement**
*For any* staff user with a specific role (viewer, delivery_staff, manager), only operations permitted by that role should succeed; all other operations should be rejected.
**Validates: Requirements 9.2, 9.3, 9.4, 9.6, 9.7**

### Delivery Bundle Properties

**Property 18: Bundle order status validation**
*For any* delivery bundle being created, all selected orders should have status purchased; orders with any other status should be rejected from the bundle.
**Validates: Requirements 4.1**

**Property 19: Bundle order association**
*For any* created delivery bundle, all selected orders should be associated with the bundle in the database.
**Validates: Requirements 4.3**

**Property 20: Bundle customer information completeness**
*For any* delivery bundle, viewing the bundle should display all associated orders with their customer names, addresses, and contact information.
**Validates: Requirements 4.4**

**Property 21: Staff bundle filtering**
*For any* staff member viewing delivery bundles, only bundles assigned to that staff member should be visible.
**Validates: Requirements 4.6**

**Property 22: Bundle order delivery tracking**
*For any* order in a delivery bundle that is marked as delivered, the order status should be updated to delivered and the delivery timestamp should be recorded.
**Validates: Requirements 4.7**

**Property 23: Bundle completion status**
*For any* delivery bundle, if all orders in the bundle have status delivered, the bundle status should be marked as complete.
**Validates: Requirements 4.8**

**Property 24: Bundle reassignment**
*For any* delivery bundle, changing the assigned staff member should update the assignment in the database.
**Validates: Requirements 4.9**

**Property 25: Bundle modification before delivery**
*For any* delivery bundle where no orders have been marked as delivered, adding or removing orders should be allowed; if any order has been delivered, modifications should be rejected.
**Validates: Requirements 4.10**

### Cost and Profit Tracking Properties

**Property 26: Purchase cost persistence**
*For any* purchase record, the cost price per unit for each product should be stored in the database.
**Validates: Requirements 5.1**

**Property 27: Order item dual pricing**
*For any* order item, both the selling price and cost price should be recorded in the database.
**Validates: Requirements 5.2**

**Property 28: Order total aggregation**
*For any* order, the total cost should equal the sum of (cost price × quantity) for all items, and the total revenue should equal the sum of (selling price × quantity) for all items.
**Validates: Requirements 5.4**

**Property 29: Daily profit aggregation**
*For any* date, the daily summary should aggregate all orders for that date, and the total profit should equal the sum of (total revenue - total cost) for all orders.
**Validates: Requirements 5.5**

**Property 30: Profit report filtering**
*For any* profit report with filter criteria (date range, customer, or product), only orders matching all specified criteria should be included in the results.
**Validates: Requirements 5.6**

**Property 31: Historical cost price preservation**
*For any* historical order, the cost price used in profit calculations should be the cost price recorded at the time of the order, not the current cost price.
**Validates: Requirements 5.7**

### Purchase List Persistence Properties

**Property 32: Purchase status persistence**
*For any* item marked as purchased in the purchase list, the purchase status should be immediately persisted to the database.
**Validates: Requirements 6.1**

**Property 33: Purchase status round-trip**
*For any* item marked as purchased, closing and reopening the purchase list should display the same purchase status.
**Validates: Requirements 6.2**

**Property 34: Purchase list filtering**
*For any* purchase list with mixed purchase statuses, applying a filter (unpurchased, purchased, or all) should display only items matching the filter criteria.
**Validates: Requirements 6.3, 6.4, 6.5**

**Property 35: Purchase list share formatting**
*For any* purchase list being shared, the formatted output should include purchase status indicators for each item.
**Validates: Requirements 6.6**

**Property 36: Purchase list real-time aggregation**
*For any* new order added for a date, the purchase list for that date should immediately reflect the new items in the aggregation.
**Validates: Requirements 6.7**

**Property 37: Cancelled order removal from purchase list**
*For any* order that is cancelled, its items should be removed from the purchase list aggregation.
**Validates: Requirements 6.8, 12.5**

### Delivery Tracking Properties

**Property 38: Delivery information completeness**
*For any* delivered order, viewing the order should display the delivery timestamp, delivery notes (if provided), and the user who completed the delivery.
**Validates: Requirements 7.4**

**Property 39: Daily delivery report completeness**
*For any* date, the daily delivery report should include all orders with status delivered and delivery timestamp on that date.
**Validates: Requirements 7.6**

**Property 40: Delivery status filtering**
*For any* order list with delivery status filter (not delivered, delivered today, delivered in date range), only orders matching the filter criteria should be displayed.
**Validates: Requirements 7.7**

**Property 41: Failed delivery tracking**
*For any* order marked as delivery failed, the system should record the failure reason and allow the order to be rescheduled.
**Validates: Requirements 7.8**

### Payment Tracking Properties

**Property 42: New order payment status**
*For any* newly created order, the payment status should be set to unpaid and paid amount should be zero.
**Validates: Requirements 8.1**

**Property 43: Partial payment status calculation**
*For any* order where a payment is recorded and the total paid amount is greater than zero but less than the total order amount, the payment status should be set to partial.
**Validates: Requirements 8.3**

**Property 44: Full payment status calculation**
*For any* order where the total paid amount equals or exceeds the total order amount, the payment status should be set to paid.
**Validates: Requirements 8.4**

**Property 45: Customer outstanding balance aggregation**
*For any* customer, the outstanding balance should equal the sum of (total amount - paid amount) for all orders with payment status unpaid or partial.
**Validates: Requirements 8.6**

**Property 46: Payment collection report filtering**
*For any* payment collection report with filter criteria (date range or customer), only payments matching all specified criteria should be included.
**Validates: Requirements 8.7**

**Property 47: Multiple payments tracking**
*For any* order, recording multiple partial payments should create separate payment records with timestamps, and the order's paid amount should equal the sum of all payment amounts.
**Validates: Requirements 8.8**

**Property 48: Cancelled order payment handling**
*For any* order that is cancelled after payments have been recorded, the system should preserve the payment records and allow refund tracking.
**Validates: Requirements 8.9**

### Dashboard Metrics Properties

**Property 49: Dashboard order counts**
*For any* date, the dashboard should display correct counts for pending, confirmed, purchased, and delivered orders for that date.
**Validates: Requirements 10.1, 10.2, 10.3**

**Property 50: Dashboard profit aggregation**
*For any* date, the dashboard should display today's total revenue, total cost, and total profit, where profit equals revenue minus cost.
**Validates: Requirements 10.4**

**Property 51: Dashboard unpurchased items count**
*For any* date, the dashboard should display the count of items in the purchase list that have not been marked as purchased.
**Validates: Requirements 10.5**

**Property 52: Dashboard outstanding payments**
*For any* set of customers, the dashboard should display the outstanding payment amount for each customer, calculated as the sum of unpaid and partially paid order balances.
**Validates: Requirements 10.6**

**Property 53: Dashboard bundle completion status**
*For any* set of active delivery bundles, the dashboard should display each bundle with its completion percentage calculated as (delivered orders / total orders) × 100.
**Validates: Requirements 10.7**

### Purchase History Properties

**Property 54: Purchase history date grouping**
*For any* set of purchases, the purchase history view should group purchases by date with all purchases for each date displayed together.
**Validates: Requirements 11.1**

**Property 55: Purchase history filtering**
*For any* purchase history with filter criteria (date range, product, or supplier), only purchases matching all specified criteria should be displayed.
**Validates: Requirements 11.2**

**Property 56: Product purchase history completeness**
*For any* product, viewing its purchase history should display all past purchases of that product with dates, quantities, costs, and suppliers.
**Validates: Requirements 11.3**

**Property 57: Average cost calculation**
*For any* set of purchases for a product, the average cost per unit should equal the sum of (cost per unit × quantity) divided by the sum of quantities.
**Validates: Requirements 11.4**

**Property 58: Supplier product aggregation**
*For any* supplier, viewing supplier details should display all products purchased from that supplier with total quantities and total amounts correctly aggregated.
**Validates: Requirements 11.7**

### Order Modification Properties

**Property 59: Pending order modification permission**
*For any* order with status pending, admin users should be able to modify order items, quantities, and prices.
**Validates: Requirements 12.1**

**Property 60: Delivered order modification restriction**
*For any* order with status purchased or delivered, attempts to modify order items should be rejected.
**Validates: Requirements 12.3**

**Property 61: Post-purchase cancellation flagging**
*For any* order that is cancelled after items have been purchased, the system should flag the cancellation for inventory adjustment.
**Validates: Requirements 12.6**

**Property 62: Cancelled order information display**
*For any* cancelled order, viewing the order should display the cancellation reason and cancellation timestamp.
**Validates: Requirements 12.8**

### Purchase List Sharing Properties

**Property 63: Purchase list category grouping**
*For any* purchase list being formatted for sharing, items should be grouped by category.
**Validates: Requirements 13.2**

**Property 64: Purchase list bilingual names**
*For any* purchase list being formatted for sharing, each product should include both Gujarati and English names.
**Validates: Requirements 13.3, 15.5**

**Property 65: Purchase list quantity formatting**
*For any* purchase list being formatted for sharing, each item should include the quantity with the appropriate unit symbol.
**Validates: Requirements 13.4**

**Property 66: Purchase list default filtering**
*For any* purchase list being shared, only unpurchased items should be included by default unless the admin explicitly includes purchased items.
**Validates: Requirements 13.5**

**Property 67: Purchase list header information**
*For any* purchase list being formatted for sharing, the header should include the date and the total count of items in the list.
**Validates: Requirements 13.7**

### Delivery Route Properties

**Property 68: Delivery bundle customer ordering**
*For any* delivery bundle, customers should be displayed in a defined sequence order.
**Validates: Requirements 14.5**

**Property 69: Incomplete address flagging**
*For any* customer with an incomplete address (missing required fields), the system should flag the customer when creating delivery bundles.
**Validates: Requirements 14.7**

### Localization Properties

**Property 70: Status name localization**
*For any* order status being displayed, the status name should be shown in the currently selected language (Gujarati or English).
**Validates: Requirements 15.1**

**Property 71: UI label localization**
*For any* UI element (labels, instructions, column headers) in delivery bundles and profit reports, the text should be displayed in the currently selected language.
**Validates: Requirements 15.2, 15.3**

**Property 72: Error message localization**
*For any* error message related to staff permissions, the message should be displayed in the currently selected language.
**Validates: Requirements 15.4**

**Property 73: Date format localization**
*For any* date or time being displayed, the format should match the conventions of the currently selected language.
**Validates: Requirements 15.7**

