/// Workflow Models
/// Models for purchase tracking, delivery bundles, payments, and staff roles
library;

import 'package:flutter/material.dart';
import 'models.dart';

// ============================================================================
// PURCHASE TRACKING MODELS
// ============================================================================

/// Purchase Status
/// Tracks whether items have been purchased from farm
class PurchaseStatus {
  final String productId;
  final bool isPurchased;
  final DateTime? purchasedAt;
  final String? purchaseId;
  final double? costPrice;
  final String? supplierName;

  PurchaseStatus({
    required this.productId,
    this.isPurchased = false,
    this.purchasedAt,
    this.purchaseId,
    this.costPrice,
    this.supplierName,
  });

  factory PurchaseStatus.fromJson(Map<String, dynamic> json) {
    return PurchaseStatus(
      productId: json['product_id'].toString(),
      isPurchased: json['is_purchased'] as bool? ?? false,
      purchasedAt: json['purchased_at'] != null
          ? parseDateTime(json['purchased_at'])
          : null,
      purchaseId: json['purchase_id']?.toString(),
      costPrice: json['cost_price'] != null
          ? double.parse(json['cost_price'].toString())
          : null,
      supplierName: json['supplier_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'is_purchased': isPurchased,
      'purchased_at': purchasedAt?.toIso8601String(),
      'purchase_id': purchaseId,
      'cost_price': costPrice,
      'supplier_name': supplierName,
    };
  }
}

/// Purchase Details
/// Details for recording a purchase from farm
class PurchaseDetails {
  final String productId;
  final double quantity;
  final double costPrice;
  final String? supplierName;
  final String? notes;

  PurchaseDetails({
    required this.productId,
    required this.quantity,
    required this.costPrice,
    this.supplierName,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'cost_price': costPrice,
      'supplier_name': supplierName,
      'notes': notes,
    };
  }
}

// ============================================================================
// DELIVERY BUNDLE MODELS
// ============================================================================

/// Delivery Bundle Status
enum DeliveryBundleStatus {
  pending('pending', 'બાકી', 'Pending', Icons.pending_actions, Color(0xFFFF9800)),
  inProgress(
    'in_progress',
    'ચાલુ',
    'In Progress',
    Icons.local_shipping,
    Color(0xFF2196F3),
  ),
  completed(
    'completed',
    'પૂર્ણ',
    'Completed',
    Icons.check_circle,
    Color(0xFF4CAF50),
  ),
  cancelled(
    'cancelled',
    'રદ',
    'Cancelled',
    Icons.cancel,
    Color(0xFFE53935),
  );

  final String value;
  final String nameGu;
  final String nameEn;
  final IconData icon;
  final Color color;

  const DeliveryBundleStatus(
    this.value,
    this.nameGu,
    this.nameEn,
    this.icon,
    this.color,
  );

  String getName(String lang) => lang == 'en' ? nameEn : nameGu;

  static DeliveryBundleStatus fromString(String value) {
    return DeliveryBundleStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DeliveryBundleStatus.pending,
    );
  }
}

/// Delivery Bundle
/// Groups orders for delivery routing
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
  final String? createdBy;

  // Joined fields
  final String? assignedToName;
  final int? totalOrders;
  final int? deliveredOrders;

  DeliveryBundle({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.deliveryDate,
    this.assignedTo,
    this.status = DeliveryBundleStatus.pending,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.assignedToName,
    this.totalOrders,
    this.deliveredOrders,
  });

  factory DeliveryBundle.fromJson(Map<String, dynamic> json) {
    return DeliveryBundle(
      id: json['id'].toString(),
      vendorId: json['vendor_id'].toString(),
      name: json['name'] as String,
      deliveryDate: parseDateTime(json['delivery_date']),
      assignedTo: json['assigned_to']?.toString(),
      status: DeliveryBundleStatus.fromString(
        json['status'] as String? ?? 'pending',
      ),
      notes: json['notes'] as String?,
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
      createdBy: json['created_by']?.toString(),
      assignedToName: json['assigned_to_name'] as String?,
      totalOrders: json['total_orders'] as int?,
      deliveredOrders: json['delivered_orders'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vendor_id': vendorId,
      'name': name,
      'delivery_date': deliveryDate.toIso8601String().split('T')[0],
      'assigned_to': assignedTo,
      'status': status.value,
      'notes': notes,
      'created_by': createdBy,
    };
  }

  // Computed properties
  double get completionPercentage {
    if (totalOrders == null || totalOrders == 0) return 0.0;
    return ((deliveredOrders ?? 0) / totalOrders!) * 100;
  }

  bool get isComplete => deliveredOrders == totalOrders && totalOrders! > 0;

  bool get canBeModified => status == DeliveryBundleStatus.pending;

  DeliveryBundle copyWith({
    String? name,
    DateTime? deliveryDate,
    String? assignedTo,
    DeliveryBundleStatus? status,
    String? notes,
  }) {
    return DeliveryBundle(
      id: id,
      vendorId: vendorId,
      name: name ?? this.name,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      assignedTo: assignedTo ?? this.assignedTo,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      createdBy: createdBy,
      assignedToName: assignedToName,
      totalOrders: totalOrders,
      deliveredOrders: deliveredOrders,
    );
  }
}

/// Bundle Order
/// Order within a delivery bundle
class BundleOrder {
  final String id;
  final String bundleId;
  final String orderId;
  final int? sequenceNumber;
  final DateTime? deliveredAt;
  final String? deliveryNotes;
  final DateTime createdAt;

  // Joined order fields
  final String? customerName;
  final String? customerAddress;
  final String? customerPhone;
  final double? totalAmount;

  BundleOrder({
    required this.id,
    required this.bundleId,
    required this.orderId,
    this.sequenceNumber,
    this.deliveredAt,
    this.deliveryNotes,
    required this.createdAt,
    this.customerName,
    this.customerAddress,
    this.customerPhone,
    this.totalAmount,
  });

  factory BundleOrder.fromJson(Map<String, dynamic> json) {
    return BundleOrder(
      id: json['id'].toString(),
      bundleId: json['bundle_id'].toString(),
      orderId: json['order_id'].toString(),
      sequenceNumber: json['sequence_number'] as int?,
      deliveredAt: json['delivered_at'] != null
          ? parseDateTime(json['delivered_at'])
          : null,
      deliveryNotes: json['delivery_notes'] as String?,
      createdAt: parseDateTime(json['created_at']),
      customerName: json['customer_name'] as String?,
      customerAddress: json['customer_address'] as String?,
      customerPhone: json['customer_phone'] as String?,
      totalAmount: json['total_amount'] != null
          ? double.parse(json['total_amount'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bundle_id': bundleId,
      'order_id': orderId,
      'sequence_number': sequenceNumber,
      'delivered_at': deliveredAt?.toIso8601String(),
      'delivery_notes': deliveryNotes,
    };
  }

  bool get isDelivered => deliveredAt != null;
}

// ============================================================================
// PAYMENT MODELS
// ============================================================================

/// Payment
/// Records payment received for an order
class Payment {
  final String id;
  final String orderId;
  final String vendorId;
  final double amount;
  final DateTime paymentDate;
  final String? paymentMethod;
  final String? notes;
  final DateTime createdAt;
  final String? createdBy;

  // Joined fields
  final String? customerName;

  Payment({
    required this.id,
    required this.orderId,
    required this.vendorId,
    required this.amount,
    required this.paymentDate,
    this.paymentMethod,
    this.notes,
    required this.createdAt,
    this.createdBy,
    this.customerName,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'].toString(),
      orderId: json['order_id'].toString(),
      vendorId: json['vendor_id'].toString(),
      amount: double.parse(json['amount'].toString()),
      paymentDate: parseDateTime(json['payment_date']),
      paymentMethod: json['payment_method'] as String?,
      notes: json['notes'] as String?,
      createdAt: parseDateTime(json['created_at']),
      createdBy: json['created_by']?.toString(),
      customerName: json['customer_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'vendor_id': vendorId,
      'amount': amount,
      'payment_date': paymentDate.toIso8601String().split('T')[0],
      'payment_method': paymentMethod,
      'notes': notes,
      'created_by': createdBy,
    };
  }
}

// ============================================================================
// STAFF ROLE MODELS
// ============================================================================

/// Staff Role
enum StaffRole {
  admin('admin', 'એડમિન', 'Admin'),
  manager('manager', 'મેનેજર', 'Manager'),
  deliveryStaff('delivery_staff', 'ડિલિવરી સ્ટાફ', 'Delivery Staff'),
  viewer('viewer', 'દર્શક', 'Viewer');

  final String value;
  final String nameGu;
  final String nameEn;

  const StaffRole(this.value, this.nameGu, this.nameEn);

  String getName(String lang) => lang == 'en' ? nameEn : nameGu;

  static StaffRole fromString(String value) {
    return StaffRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => StaffRole.viewer,
    );
  }
}

/// Staff Permissions
/// Defines what each role can do
class StaffPermissions {
  final bool canViewCosts;
  final bool canConfirmOrders;
  final bool canCancelOrders;
  final bool canMarkDelivered;
  final bool canManageProducts;
  final bool canManageCustomers;
  final bool canViewReports;
  final bool canManageStaff;
  final bool canViewAllOrders;

  const StaffPermissions({
    this.canViewCosts = false,
    this.canConfirmOrders = false,
    this.canCancelOrders = false,
    this.canMarkDelivered = false,
    this.canManageProducts = false,
    this.canManageCustomers = false,
    this.canViewReports = false,
    this.canManageStaff = false,
    this.canViewAllOrders = false,
  });

  factory StaffPermissions.forRole(StaffRole role) {
    switch (role) {
      case StaffRole.admin:
        return const StaffPermissions(
          canViewCosts: true,
          canConfirmOrders: true,
          canCancelOrders: true,
          canMarkDelivered: true,
          canManageProducts: true,
          canManageCustomers: true,
          canViewReports: true,
          canManageStaff: true,
          canViewAllOrders: true,
        );
      case StaffRole.manager:
        return const StaffPermissions(
          canViewCosts: true,
          canConfirmOrders: true,
          canCancelOrders: false,
          canMarkDelivered: true,
          canManageProducts: false,
          canManageCustomers: false,
          canViewReports: true,
          canManageStaff: false,
          canViewAllOrders: true,
        );
      case StaffRole.deliveryStaff:
        return const StaffPermissions(
          canViewCosts: false,
          canConfirmOrders: false,
          canCancelOrders: false,
          canMarkDelivered: true,
          canManageProducts: false,
          canManageCustomers: false,
          canViewReports: false,
          canManageStaff: false,
          canViewAllOrders: false,
        );
      case StaffRole.viewer:
        return const StaffPermissions(
          canViewCosts: false,
          canConfirmOrders: false,
          canCancelOrders: false,
          canMarkDelivered: false,
          canManageProducts: false,
          canManageCustomers: false,
          canViewReports: false,
          canManageStaff: false,
          canViewAllOrders: false,
        );
    }
  }
}

// ============================================================================
// DASHBOARD METRICS MODEL
// ============================================================================

/// Dashboard Metrics
/// Aggregated metrics for dashboard display
class DashboardMetrics {
  final int pendingOrders;
  final int confirmedOrders;
  final int deliveredOrders;
  final int unpurchasedItems;
  final double todayRevenue;
  final double todayCost;
  final double todayProfit;
  final double outstandingPayments;
  final int activeBundles;
  final int completedBundles;

  DashboardMetrics({
    this.pendingOrders = 0,
    this.confirmedOrders = 0,
    this.deliveredOrders = 0,
    this.unpurchasedItems = 0,
    this.todayRevenue = 0.0,
    this.todayCost = 0.0,
    this.todayProfit = 0.0,
    this.outstandingPayments = 0.0,
    this.activeBundles = 0,
    this.completedBundles = 0,
  });

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return DashboardMetrics(
      pendingOrders: json['pending_orders'] as int? ?? 0,
      confirmedOrders: json['confirmed_orders'] as int? ?? 0,
      deliveredOrders: json['delivered_orders'] as int? ?? 0,
      unpurchasedItems: json['unpurchased_items'] as int? ?? 0,
      todayRevenue: json['today_revenue'] != null
          ? double.parse(json['today_revenue'].toString())
          : 0.0,
      todayCost: json['today_cost'] != null
          ? double.parse(json['today_cost'].toString())
          : 0.0,
      todayProfit: json['today_profit'] != null
          ? double.parse(json['today_profit'].toString())
          : 0.0,
      outstandingPayments: json['outstanding_payments'] != null
          ? double.parse(json['outstanding_payments'].toString())
          : 0.0,
      activeBundles: json['active_bundles'] as int? ?? 0,
      completedBundles: json['completed_bundles'] as int? ?? 0,
    );
  }

  int get totalOrders => pendingOrders + confirmedOrders + deliveredOrders;

  double get profitMargin => todayRevenue > 0 ? (todayProfit / todayRevenue) * 100 : 0.0;
}
