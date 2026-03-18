import 'package:flutter/material.dart';
import 'models.dart';

/// Customer Model
/// Represents cafes, hotels, restaurants, supermarkets who place orders
class Customer {
  final String id;
  final String vendorId;
  final String name;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? address;
  final CustomerType type;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    required this.id,
    required this.vendorId,
    required this.name,
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
    this.type = CustomerType.other,
    this.notes,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'].toString(),
      vendorId: json['vendor_id'].toString(),
      name: json['name'] as String,
      contactPerson: json['contact_person'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      type: CustomerType.fromString(json['type'] as String? ?? 'other'),
      notes: json['notes'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vendor_id': vendorId,
      'name': name,
      'contact_person': contactPerson,
      'phone': phone,
      'email': email,
      'address': address,
      'type': type.value,
      'notes': notes,
      'is_active': isActive,
    };
  }

  Customer copyWith({
    String? name,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
    CustomerType? type,
    String? notes,
    bool? isActive,
  }) {
    return Customer(
      id: id,
      vendorId: vendorId,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

/// Customer Types
enum CustomerType {
  hotel('hotel', 'હોટલ', 'Hotel', Icons.hotel, Color(0xFF5C6BC0)),
  cafe('cafe', 'કેફે', 'Cafe', Icons.coffee, Color(0xFF8D6E63)),
  restaurant(
    'restaurant',
    'રેસ્ટોરન્ટ',
    'Restaurant',
    Icons.restaurant,
    Color(0xFFEF5350),
  ),
  supermarket(
    'supermarket',
    'સુપરમાર્કેટ',
    'Supermarket',
    Icons.store,
    Color(0xFF42A5F5),
  ),
  mess('mess', 'મેસ', 'Mess', Icons.food_bank, Color(0xFF66BB6A)),
  catering(
    'catering',
    'કેટરિંગ',
    'Catering',
    Icons.celebration,
    Color(0xFFAB47BC),
  ),
  other('other', 'અન્ય', 'Other', Icons.business, Color(0xFF78909C));

  final String value;
  final String nameGu;
  final String nameEn;
  final IconData icon;
  final Color color;

  const CustomerType(
    this.value,
    this.nameGu,
    this.nameEn,
    this.icon,
    this.color,
  );

  String getName(String lang) => lang == 'en' ? nameEn : nameGu;

  static CustomerType fromString(String value) {
    return CustomerType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CustomerType.other,
    );
  }
}

/// Delivery Slot
enum DeliverySlot {
  morning('morning', 'સવાર', 'Morning', Icons.light_mode_rounded, Color(0xFFFFB74D)),
  evening('evening', 'સાંજ', 'Evening', Icons.wb_twilight_rounded, Color(0xFFFB8C00)),
  night('night', 'રાત', 'Night', Icons.nights_stay_rounded, Color(0xFF5C6BC0));

  final String value;
  final String nameGu;
  final String nameEn;
  final IconData icon;
  final Color color;

  const DeliverySlot(
    this.value,
    this.nameGu,
    this.nameEn,
    this.icon,
    this.color,
  );

  String getName(String lang) => lang == 'en' ? nameEn : nameGu;

  static DeliverySlot fromString(String value) {
    return DeliverySlot.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DeliverySlot.morning,
    );
  }
}

/// Order Model
/// Represents a daily order placed by a customer
class Order {
  final String id;
  final String customerId;
  final String vendorId;
  final DateTime orderDate;
  final OrderStatus status;
  final DeliverySlot deliverySlot; // Added delivery slot
  final double? totalAmount;
  final double? totalCost; // Optional: total cost price for profit tracking
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional fields (can be enabled when needed)
  final String? deliveryAddress; // Optional delivery address
  final PaymentStatus? paymentStatus; // Optional payment tracking
  final double? paidAmount; // Amount paid so far
  final String? contactPhone; // Contact for delivery

  // Workflow tracking fields
  final DateTime? deliveredAt;
  final String? deliveredBy;
  final String? cancellationReason;
  final DateTime? cancelledAt;
  final String? cancelledBy;

  // Joined fields
  final String? customerName;
  final CustomerType? customerType;
  final String? customerPhone;
  final String? customerAddress;

  Order({
    required this.id,
    required this.customerId,
    required this.vendorId,
    required this.orderDate,
    this.status = OrderStatus.pending,
    this.deliverySlot = DeliverySlot.morning, // Default delivery slot
    this.totalAmount,
    this.totalCost,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.deliveryAddress,
    this.paymentStatus,
    this.paidAmount,
    this.contactPhone,
    this.deliveredAt,
    this.deliveredBy,
    this.cancellationReason,
    this.cancelledAt,
    this.cancelledBy,
    this.customerName,
    this.customerType,
    this.customerPhone,
    this.customerAddress,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'].toString(),
      customerId: json['customer_id'].toString(),
      vendorId: json['vendor_id'].toString(),
      orderDate: parseDateTime(json['order_date']),
      status: OrderStatus.fromString(json['status'] as String? ?? 'pending'),
      deliverySlot: DeliverySlot.fromString(json['delivery_slot'] as String? ?? 'morning'),
      totalAmount: json['total_amount'] != null
          ? double.parse(json['total_amount'].toString())
          : null,
      totalCost: json['total_cost'] != null
          ? double.parse(json['total_cost'].toString())
          : null,
      notes: json['notes'] as String?,
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
      deliveryAddress: json['delivery_address'] as String?,
      paymentStatus: json['payment_status'] != null
          ? PaymentStatus.fromString(json['payment_status'] as String)
          : null,
      paidAmount: json['paid_amount'] != null
          ? double.parse(json['paid_amount'].toString())
          : null,
      contactPhone: json['contact_phone'] as String?,
      deliveredAt: json['delivered_at'] != null
          ? parseDateTime(json['delivered_at'])
          : null,
      deliveredBy: json['delivered_by']?.toString(),
      cancellationReason: json['cancellation_reason'] as String?,
      cancelledAt: json['cancelled_at'] != null
          ? parseDateTime(json['cancelled_at'])
          : null,
      cancelledBy: json['cancelled_by']?.toString(),
      customerName: json['customer_name'] as String?,
      customerType: json['customer_type'] != null
          ? CustomerType.fromString(json['customer_type'].toString())
          : null,
      customerPhone: json['customer_phone'] as String?,
      customerAddress: json['customer_address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'vendor_id': vendorId,
      'order_date': orderDate.toIso8601String().split('T')[0],
      'status': status.value,
      'delivery_slot': deliverySlot.value,
      'total_amount': totalAmount,
      'total_cost': totalCost,
      'notes': notes,
      'delivery_address': deliveryAddress,
      'payment_status': paymentStatus?.value,
      'paid_amount': paidAmount,
      'contact_phone': contactPhone,
      'delivered_at': deliveredAt?.toIso8601String(),
      'delivered_by': deliveredBy,
      'cancellation_reason': cancellationReason,
      'cancelled_at': cancelledAt?.toIso8601String(),
      'cancelled_by': cancelledBy,
    };
  }

  // Computed properties
  double get totalProfit => (totalAmount ?? 0) - (totalCost ?? 0);
  
  double get profitMargin => totalAmount != null && totalAmount! > 0
      ? (totalProfit / totalAmount!) * 100
      : 0.0;
  
  double get pendingAmount => (totalAmount ?? 0) - (paidAmount ?? 0);
  
  bool get isFullyPaid => pendingAmount <= 0;

  // Workflow validation
  bool get canBeConfirmed => status == OrderStatus.pending;
  
  bool get canBeDelivered => 
      status == OrderStatus.confirmed && totalAmount != null && totalAmount! > 0;
  
  bool get canBeCancelled => 
      status != OrderStatus.delivered && status != OrderStatus.cancelled;

  Order copyWith({
    OrderStatus? status,
    DeliverySlot? deliverySlot,
    double? totalAmount, 
    double? totalCost,
    String? notes,
    String? deliveryAddress,
    PaymentStatus? paymentStatus,
    double? paidAmount,
    String? contactPhone,
    DateTime? deliveredAt,
    String? deliveredBy,
    String? cancellationReason,
    DateTime? cancelledAt,
    String? cancelledBy,
  }) {
    return Order(
      id: id,
      customerId: customerId,
      vendorId: vendorId,
      orderDate: orderDate,
      status: status ?? this.status,
      deliverySlot: deliverySlot ?? this.deliverySlot,
      totalAmount: totalAmount ?? this.totalAmount,
      totalCost: totalCost ?? this.totalCost,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paidAmount: paidAmount ?? this.paidAmount,
      contactPhone: contactPhone ?? this.contactPhone,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      deliveredBy: deliveredBy ?? this.deliveredBy,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      customerName: customerName,
      customerType: customerType,
      customerPhone: customerPhone,
      customerAddress: customerAddress,
    );
  }
}

/// Order Status
enum OrderStatus {
  pending('pending', 'બાકી', 'Pending', Icons.pending, Color(0xFFFF9800)),
  confirmed(
    'confirmed',
    'પુષ્ટિ થઈ',
    'Confirmed',
    Icons.check_circle,
    Color(0xFF4CAF50),
  ),
  delivered(
    'delivered',
    'ડિલિવર થયું',
    'Delivered',
    Icons.delivery_dining,
    Color(0xFF2196F3),
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

  const OrderStatus(
    this.value,
    this.nameGu,
    this.nameEn,
    this.icon,
    this.color,
  );

  String getName(String lang) => lang == 'en' ? nameEn : nameGu;

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OrderStatus.pending,
    );
  }
}

/// Payment Status (optional tracking)
enum PaymentStatus {
  unpaid('unpaid', 'અબાધિત', 'Unpaid', Color(0xFFE53935)),
  partial('partial', 'અંશત:', 'Partial', Color(0xFFFF9800)),
  paid('paid', 'ચૂકવેલ', 'Paid', Color(0xFF4CAF50));

  final String value;
  final String nameGu;
  final String nameEn;
  final Color color;

  const PaymentStatus(this.value, this.nameGu, this.nameEn, this.color);

  String getName(String lang) => lang == 'en' ? nameEn : nameGu;

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentStatus.unpaid,
    );
  }
}

/// Order Item Model
/// Represents individual items within an order
class OrderItem {
  final String id;
  final String orderId;
  final String? productId; // Can be null for custom items
  final double quantity;
  final double? pricePerUnit; // Selling price per unit
  final double? costPrice; // Optional cost price for profit tracking
  final double? totalPrice;
  final String? notes;
  final bool isPurchased; // Added
  final DateTime createdAt;

  // For custom items (not from product list)
  final bool isCustomItem;
  final String? customItemName;

  // Joined fields
  final String? productNameGu;
  final String? productNameEn;
  final String? unitSymbol;
  final String? categoryName;

  OrderItem({
    required this.id,
    required this.orderId,
    this.productId,
    required this.quantity,
    this.pricePerUnit,
    this.costPrice,
    this.totalPrice,
    this.notes,
    this.isPurchased = false, // Default false
    required this.createdAt,
    this.isCustomItem = false,
    this.customItemName,
    this.productNameGu,
    this.productNameEn,
    this.unitSymbol,
    this.categoryName,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'].toString(),
      orderId: json['order_id'].toString(),
      productId: json['product_id']?.toString(),
      quantity: double.parse(json['quantity'].toString()),
      pricePerUnit: json['price_per_unit'] != null
          ? double.parse(json['price_per_unit'].toString())
          : null,
      costPrice: json['cost_price'] != null
          ? double.parse(json['cost_price'].toString())
          : null,
      totalPrice: json['total_price'] != null
          ? double.parse(json['total_price'].toString())
          : null,
      notes: json['notes'] as String?,
      isPurchased: json['is_purchased'] as bool? ?? false,
      createdAt: parseDateTime(json['created_at']),
      isCustomItem: json['is_custom_item'] as bool? ?? false,
      customItemName: json['custom_item_name'] as String?,
      productNameGu: json['product_name_gu'] as String?,
      productNameEn: json['product_name_en'] as String?,
      unitSymbol: json['unit_symbol'] as String?,
      categoryName: json['category_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'price_per_unit': pricePerUnit,
      'cost_price': costPrice,
      'total_price': totalPrice,
      'notes': notes,
      'is_purchased': isPurchased,
      'is_custom_item': isCustomItem,
      'custom_item_name': customItemName,
    };
  }

  double get totalCost => (costPrice ?? 0) * quantity;
  
  double get totalProfit => (totalPrice ?? 0) - totalCost;
  
  double get profitPerUnit => (pricePerUnit ?? 0) - (costPrice ?? 0);

  String getProductName(String lang) {
    if (isCustomItem) {
      return customItemName ?? 'Custom Item';
    }
    return lang == 'en' ? (productNameEn ?? '') : (productNameGu ?? '');
  }
}

/// Aggregated Order Item
/// Used for purchase list - sums quantities across all orders
class AggregatedOrderItem {
  final String productId;
  final String productNameGu;
  final String productNameEn;
  final String unitSymbol;
  final String? categoryName;
  final double totalQuantity;
  final int orderCount;
  final bool isPurchased; // Added: derived or directly set
  final List<OrderItemDetail> itemDetails;

  AggregatedOrderItem({
    required this.productId,
    required this.productNameGu,
    required this.productNameEn,
    required this.unitSymbol,
     this.categoryName,
    required this.totalQuantity,
    required this.orderCount,
    this.isPurchased = false,
    required this.itemDetails,
  });

  String getProductName(String lang) {
    return lang == 'en' ? productNameEn : productNameGu;
  }
}

/// Order Item Detail for aggregation
class OrderItemDetail {
  final String orderId;
  final String customerName;
  final double quantity;
  final String? notes;

  OrderItemDetail({
    required this.orderId,
    required this.customerName,
    required this.quantity,
    this.notes,
  });
}
