/// Helper to parse DateTime from PostgreSQL (returns DateTime or String)
DateTime parseDateTime(dynamic value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.parse(value);
  return DateTime.now();
}

/// Daily Price Model
class DailyPrice {
  final String id;
  final String productId;
  final DateTime priceDate;
  final double price;
  final String? notes;
  final DateTime createdAt;

  // Joined fields
  final String? productNameGu;
  final String? productNameEn;

  DailyPrice({
    required this.id,
    required this.productId,
    required this.priceDate,
    required this.price,
    this.notes,
    required this.createdAt,
    this.productNameGu,
    this.productNameEn,
  });

  factory DailyPrice.fromJson(Map<String, dynamic> json) {
    return DailyPrice(
      id: json['id'].toString(),
      productId: json['product_id'].toString(),
      priceDate: parseDateTime(json['price_date']),
      price: double.parse(json['price'].toString()),
      notes: json['notes'] as String?,
      createdAt: parseDateTime(json['created_at']),
      productNameGu: json['product_name_gu'] as String?,
      productNameEn: json['product_name_en'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'price_date': priceDate.toIso8601String().split('T')[0],
      'price': price,
      'notes': notes,
    };
  }
}

/// Unit Model
class ProductUnit {
  final String id;
  final String nameGu;
  final String nameEn;
  final String symbol;

  ProductUnit({
    required this.id,
    required this.nameGu,
    required this.nameEn,
    required this.symbol,
  });

  factory ProductUnit.fromJson(Map<String, dynamic> json) {
    return ProductUnit(
      id: json['id'].toString(),
      nameGu: json['name_gu'] as String,
      nameEn: json['name_en'] as String,
      symbol: json['symbol'] as String,
    );
  }

  String getName(String lang) {
    return lang == 'en' ? nameEn : nameGu;
  }
}

/// Category Model
class Category {
  final String id;
  final String vendorId;
  final String nameGu;
  final String nameEn;
  final String color;
  final String icon;
  final int sortOrder;
  final bool isActive;

  Category({
    required this.id,
    required this.vendorId,
    required this.nameGu,
    required this.nameEn,
    this.color = '#00897B',
    this.icon = 'category',
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'].toString(),
      vendorId: json['vendor_id'].toString(),
      nameGu: json['name_gu'] as String,
      nameEn: json['name_en'] as String,
      color: json['color'] as String? ?? '#00897B',
      icon: json['icon'] as String? ?? 'category',
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vendor_id': vendorId,
      'name_gu': nameGu,
      'name_en': nameEn,
      'color': color,
      'icon': icon,
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }

  String getName(String lang) {
    return lang == 'en' ? nameEn : nameGu;
  }
}

/// Vendor Model
class Vendor {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final Map<String, dynamic> settings;
  final bool isActive;
  final DateTime createdAt;
  final String? role;
  final String? invitedBy;
  final String? inviteCode;

  Vendor({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.settings = const {},
    this.isActive = true,
    required this.createdAt,
    this.role,
    this.invitedBy,
    this.inviteCode,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'].toString(),
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      settings: json['settings'] as Map<String, dynamic>? ?? {},
      isActive: json['is_active'] as bool? ?? true,
      createdAt: parseDateTime(json['created_at']),
      role: json['role'] as String?,
      invitedBy: json['invited_by'] as String?,
      inviteCode: json['invite_code'] as String?,
    );
  }
}
