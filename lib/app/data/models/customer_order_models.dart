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

/// Order Model
/// Represents a daily order placed by a customer
class Order {
  final String id;
  final String customerId;
  final String vendorId;
  final DateTime orderDate;
  final OrderStatus status;
  final double? totalAmount;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined fields
  final String? customerName;
  final CustomerType? customerType;

  Order({
    required this.id,
    required this.customerId,
    required this.vendorId,
    required this.orderDate,
    this.status = OrderStatus.pending,
    this.totalAmount,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.customerName,
    this.customerType,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'].toString(),
      customerId: json['customer_id'].toString(),
      vendorId: json['vendor_id'].toString(),
      orderDate: parseDateTime(json['order_date']),
      status: OrderStatus.fromString(json['status'] as String? ?? 'pending'),
      totalAmount: json['total_amount'] != null
          ? double.parse(json['total_amount'].toString())
          : null,
      notes: json['notes'] as String?,
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
      customerName: json['customer_name'] as String?,
      customerType: json['customer_type'] != null
          ? CustomerType.fromString(json['customer_type'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'vendor_id': vendorId,
      'order_date': orderDate.toIso8601String().split('T')[0],
      'status': status.value,
      'total_amount': totalAmount,
      'notes': notes,
    };
  }

  Order copyWith({OrderStatus? status, double? totalAmount, String? notes}) {
    return Order(
      id: id,
      customerId: customerId,
      vendorId: vendorId,
      orderDate: orderDate,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      customerName: customerName,
      customerType: customerType,
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

/// Order Item Model
/// Represents individual items within an order
class OrderItem {
  final String id;
  final String orderId;
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
  final String? categoryName;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    this.pricePerUnit,
    this.totalPrice,
    this.notes,
    required this.createdAt,
    this.productNameGu,
    this.productNameEn,
    this.unitSymbol,
    this.categoryName,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'].toString(),
      orderId: json['order_id'].toString(),
      productId: json['product_id'].toString(),
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
      categoryName: json['category_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
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
  final List<OrderItemDetail> itemDetails;

  AggregatedOrderItem({
    required this.productId,
    required this.productNameGu,
    required this.productNameEn,
    required this.unitSymbol,
    this.categoryName,
    required this.totalQuantity,
    required this.orderCount,
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
