/// Product Model

/// Helper to parse DateTime from PostgreSQL (returns DateTime or String)
DateTime _parseDateTime(dynamic value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.parse(value);
  return DateTime.now();
}

DateTime? _parseDateTimeNullable(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.parse(value);
  return null;
}

class Product {
  final String id;
  final String vendorId;
  final String? categoryId;
  final String? unitId;
  final String nameGu;
  final String? nameEn;
  final double? maxPrice;
  final String? imageUrl;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Joined fields
  final String? categoryName;
  final String? unitName;
  final String? unitSymbol;
  final double? currentPrice;

  Product({
    required this.id,
    required this.vendorId,
    this.categoryId,
    this.unitId,
    required this.nameGu,
    this.nameEn,
    this.maxPrice,
    this.imageUrl,
    this.isActive = true,
    this.sortOrder = 0,
    required this.createdAt,
    this.updatedAt,
    this.categoryName,
    this.unitName,
    this.unitSymbol,
    this.currentPrice,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      vendorId: json['vendor_id'] as String,
      categoryId: json['category_id'] as String?,
      unitId: json['unit_id'] as String?,
      nameGu: json['name_gu'] as String,
      nameEn: json['name_en'] as String?,
      maxPrice: json['max_price'] != null
          ? double.tryParse(json['max_price'].toString())
          : null,
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTimeNullable(json['updated_at']),
      categoryName: json['category_name'] as String?,
      unitName: json['unit_name'] as String?,
      unitSymbol: json['unit_symbol'] as String?,
      currentPrice: json['current_price'] != null
          ? double.tryParse(json['current_price'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vendor_id': vendorId,
      'category_id': categoryId,
      'unit_id': unitId,
      'name_gu': nameGu,
      'name_en': nameEn,
      'max_price': maxPrice,
      'image_url': imageUrl,
      'is_active': isActive,
      'sort_order': sortOrder,
    };
  }

  /// Get display name based on language
  String getName(String lang) {
    if (lang == 'en' && nameEn != null && nameEn!.isNotEmpty) {
      return nameEn!;
    }
    return nameGu;
  }

  Product copyWith({
    String? id,
    String? vendorId,
    String? categoryId,
    String? unitId,
    String? nameGu,
    String? nameEn,
    double? maxPrice,
    String? imageUrl,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? categoryName,
    String? unitName,
    String? unitSymbol,
    double? currentPrice,
  }) {
    return Product(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      categoryId: categoryId ?? this.categoryId,
      unitId: unitId ?? this.unitId,
      nameGu: nameGu ?? this.nameGu,
      nameEn: nameEn ?? this.nameEn,
      maxPrice: maxPrice ?? this.maxPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryName: categoryName ?? this.categoryName,
      unitName: unitName ?? this.unitName,
      unitSymbol: unitSymbol ?? this.unitSymbol,
      currentPrice: currentPrice ?? this.currentPrice,
    );
  }
}
