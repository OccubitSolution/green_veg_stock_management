import 'package:flutter/material.dart';
import 'models.dart';
import 'customer_order_models.dart';

/// Purchase Model
/// Records purchases made from farms/suppliers
class Purchase {
  final String id;
  final String vendorId;
  final String? supplierName;
  final DateTime purchaseDate;
  final double? totalAmount;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Purchase({
    required this.id,
    required this.vendorId,
    this.supplierName,
    required this.purchaseDate,
    this.totalAmount,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'] as String,
      vendorId: json['vendor_id'] as String,
      supplierName: json['supplier_name'] as String?,
      purchaseDate: parseDateTime(json['purchase_date']),
      totalAmount: json['total_amount'] != null
          ? double.parse(json['total_amount'].toString())
          : null,
      notes: json['notes'] as String?,
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vendor_id': vendorId,
      'supplier_name': supplierName,
      'purchase_date': purchaseDate.toIso8601String().split('T')[0],
      'total_amount': totalAmount,
      'notes': notes,
    };
  }
}

/// Purchase Item Model
/// Individual items within a purchase
class PurchaseItem {
  final String id;
  final String purchaseId;
  final String productId;
  final double quantity;
  final double? pricePerUnit;
  final double? totalPrice;
  final String? notes;
  final DateTime createdAt;

  // Joined fields
  final String? productNameGu;
  final String? productNameEn;
  final String? unitSymbol;

  PurchaseItem({
    required this.id,
    required this.purchaseId,
    required this.productId,
    required this.quantity,
    this.pricePerUnit,
    this.totalPrice,
    this.notes,
    required this.createdAt,
    this.productNameGu,
    this.productNameEn,
    this.unitSymbol,
  });

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      id: json['id'] as String,
      purchaseId: json['purchase_id'] as String,
      productId: json['product_id'] as String,
      quantity: double.parse(json['quantity'].toString()),
      pricePerUnit: json['price_per_unit'] != null
          ? double.parse(json['price_per_unit'].toString())
          : null,
      totalPrice: json['total_price'] != null
          ? double.parse(json['total_price'].toString())
          : null,
      notes: json['notes'] as String?,
      createdAt: parseDateTime(json['created_at']),
      productNameGu: json['product_name_gu'] as String?,
      productNameEn: json['product_name_en'] as String?,
      unitSymbol: json['unit_symbol'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'purchase_id': purchaseId,
      'product_id': productId,
      'quantity': quantity,
      'price_per_unit': pricePerUnit,
      'total_price': totalPrice,
      'notes': notes,
    };
  }

  String getProductName(String lang) {
    return lang == 'en' ? (productNameEn ?? '') : (productNameGu ?? '');
  }
}

/// Stock Model
/// Current inventory levels
class Stock {
  final String id;
  final String vendorId;
  final String productId;
  final double quantity;
  final double minStockLevel;
  final DateTime lastUpdated;
  final DateTime createdAt;

  // Joined fields
  final String? productNameGu;
  final String? productNameEn;
  final String? unitSymbol;
  final String? stockStatus;

  Stock({
    required this.id,
    required this.vendorId,
    required this.productId,
    required this.quantity,
    this.minStockLevel = 0,
    required this.lastUpdated,
    required this.createdAt,
    this.productNameGu,
    this.productNameEn,
    this.unitSymbol,
    this.stockStatus,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      id: json['id'] as String,
      vendorId: json['vendor_id'] as String,
      productId: json['product_id'] as String,
      quantity: double.parse(json['quantity'].toString()),
      minStockLevel: double.parse(json['min_stock_level']?.toString() ?? '0'),
      lastUpdated: parseDateTime(json['last_updated']),
      createdAt: parseDateTime(json['created_at']),
      productNameGu: json['product_name_gu'] as String?,
      productNameEn: json['product_name_en'] as String?,
      unitSymbol: json['unit_symbol'] as String?,
      stockStatus: json['stock_status'] as String?,
    );
  }

  bool get isLowStock => quantity <= minStockLevel && quantity > 0;
  bool get isOutOfStock => quantity <= 0;
  bool get isInStock => quantity > minStockLevel;

  String getProductName(String lang) {
    return lang == 'en' ? (productNameEn ?? '') : (productNameGu ?? '');
  }
}

/// Stock Movement Model
/// Tracks all stock changes (purchases, sales, adjustments)
class StockMovement {
  final String id;
  final String stockId;
  final MovementType movementType;
  final double quantity;
  final String? referenceType;
  final String? referenceId;
  final String? notes;
  final DateTime createdAt;

  StockMovement({
    required this.id,
    required this.stockId,
    required this.movementType,
    required this.quantity,
    this.referenceType,
    this.referenceId,
    this.notes,
    required this.createdAt,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id'] as String,
      stockId: json['stock_id'] as String,
      movementType: MovementType.fromString(json['movement_type'] as String),
      quantity: double.parse(json['quantity'].toString()),
      referenceType: json['reference_type'] as String?,
      referenceId: json['reference_id'] as String?,
      notes: json['notes'] as String?,
      createdAt: parseDateTime(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stock_id': stockId,
      'movement_type': movementType.value,
      'quantity': quantity,
      'reference_type': referenceType,
      'reference_id': referenceId,
      'notes': notes,
    };
  }
}

/// Movement Types
enum MovementType {
  purchase(
    'purchase',
    'ખરીદી',
    'Purchase',
    Icons.shopping_cart,
    Color(0xFF4CAF50),
  ),
  sale('sale', 'વેચાણ', 'Sale', Icons.point_of_sale, Color(0xFF2196F3)),
  adjustment(
    'adjustment',
    'એડજસ્ટમેન્ટ',
    'Adjustment',
    Icons.tune,
    Color(0xFFFF9800),
  ),
  waste('waste', 'વેસ્ટ', 'Waste', Icons.delete_outline, Color(0xFFE53935));

  final String value;
  final String nameGu;
  final String nameEn;
  final IconData icon;
  final Color color;

  const MovementType(
    this.value,
    this.nameGu,
    this.nameEn,
    this.icon,
    this.color,
  );

  String getName(String lang) => lang == 'en' ? nameEn : nameGu;

  static MovementType fromString(String value) {
    return MovementType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MovementType.adjustment,
    );
  }
}

/// Sale Model
/// Records actual sales/deliveries to customers
class Sale {
  final String id;
  final String? orderId;
  final String customerId;
  final String vendorId;
  final DateTime saleDate;
  final double? totalAmount;
  final double paidAmount;
  final SaleStatus status;
  final String? deliveryNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined fields
  final String? customerName;
  final CustomerType? customerType;

  Sale({
    required this.id,
    this.orderId,
    required this.customerId,
    required this.vendorId,
    required this.saleDate,
    this.totalAmount,
    this.paidAmount = 0,
    this.status = SaleStatus.pending,
    this.deliveryNotes,
    required this.createdAt,
    required this.updatedAt,
    this.customerName,
    this.customerType,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'] as String,
      orderId: json['order_id'] as String?,
      customerId: json['customer_id'] as String,
      vendorId: json['vendor_id'] as String,
      saleDate: parseDateTime(json['sale_date']),
      totalAmount: json['total_amount'] != null
          ? double.parse(json['total_amount'].toString())
          : null,
      paidAmount: double.parse(json['paid_amount']?.toString() ?? '0'),
      status: SaleStatus.fromString(json['status'] as String? ?? 'pending'),
      deliveryNotes: json['delivery_notes'] as String?,
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
      customerName: json['customer_name'] as String?,
      customerType: json['customer_type'] != null
          ? CustomerType.fromString(json['customer_type'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'customer_id': customerId,
      'vendor_id': vendorId,
      'sale_date': saleDate.toIso8601String().split('T')[0],
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'status': status.value,
      'delivery_notes': deliveryNotes,
    };
  }

  double get pendingAmount => (totalAmount ?? 0) - paidAmount;
  bool get isFullyPaid => pendingAmount <= 0;
}

/// Sale Status
enum SaleStatus {
  pending('pending', 'બાકી', 'Pending', Icons.pending, Color(0xFFFF9800)),
  delivered(
    'delivered',
    'ડિલિવર થયું',
    'Delivered',
    Icons.check_circle,
    Color(0xFF4CAF50),
  ),
  cancelled(
    'cancelled',
    'રદ કર્યું',
    'Cancelled',
    Icons.cancel,
    Color(0xFFE53935),
  );

  final String value;
  final String nameGu;
  final String nameEn;
  final IconData icon;
  final Color color;

  const SaleStatus(this.value, this.nameGu, this.nameEn, this.icon, this.color);

  String getName(String lang) => lang == 'en' ? nameEn : nameGu;

  static SaleStatus fromString(String value) {
    return SaleStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SaleStatus.pending,
    );
  }
}

/// Sale Item Model
class SaleItem {
  final String id;
  final String saleId;
  final String productId;
  final double quantity;
  final double? pricePerUnit;
  final double? totalPrice;
  final String? notes;
  final DateTime createdAt;

  // Joined fields
  final String? productNameGu;
  final String? productNameEn;
  final String? unitSymbol;

  SaleItem({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.quantity,
    this.pricePerUnit,
    this.totalPrice,
    this.notes,
    required this.createdAt,
    this.productNameGu,
    this.productNameEn,
    this.unitSymbol,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      id: json['id'] as String,
      saleId: json['sale_id'] as String,
      productId: json['product_id'] as String,
      quantity: double.parse(json['quantity'].toString()),
      pricePerUnit: json['price_per_unit'] != null
          ? double.parse(json['price_per_unit'].toString())
          : null,
      totalPrice: json['total_price'] != null
          ? double.parse(json['total_price'].toString())
          : null,
      notes: json['notes'] as String?,
      createdAt: parseDateTime(json['created_at']),
      productNameGu: json['product_name_gu'] as String?,
      productNameEn: json['product_name_en'] as String?,
      unitSymbol: json['unit_symbol'] as String?,
    );
  }

  String getProductName(String lang) {
    return lang == 'en' ? (productNameEn ?? '') : (productNameGu ?? '');
  }
}
