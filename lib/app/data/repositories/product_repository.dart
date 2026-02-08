/// Product Repository
///
/// Handles product CRUD operations
library;

import 'package:flutter/foundation.dart' hide Category;
import '../providers/database_provider.dart';
import '../models/product_model.dart';
import '../models/models.dart';

class ProductRepository {
  final _db = DatabaseProvider.instance;

  /// Get all products for a vendor
  Future<List<Product>> getProducts(
    String vendorId, {
    String? search,
    String? categoryId,
    bool activeOnly = true,
  }) async {
    try {
      String whereClause = 'p.vendor_id = @vendor_id';
      final params = <String, dynamic>{'vendor_id': vendorId};

      if (activeOnly) {
        whereClause += ' AND p.is_active = true';
      }

      if (categoryId != null) {
        whereClause += ' AND p.category_id = @category_id';
        params['category_id'] = categoryId;
      }

      if (search != null && search.isNotEmpty) {
        whereClause +=
            ' AND (p.name_gu ILIKE @search OR p.name_en ILIKE @search)';
        params['search'] = '%$search%';
      }

      final result = await _db.query('''
        SELECT 
          p.*,
          c.name_gu as category_name,
          u.name_gu as unit_name,
          u.symbol as unit_symbol,
          dp.price as current_price
        FROM products p
        LEFT JOIN categories c ON p.category_id = c.id
        LEFT JOIN units u ON p.unit_id = u.id
        LEFT JOIN daily_prices dp ON p.id = dp.product_id 
          AND dp.price_date = CURRENT_DATE
        WHERE $whereClause
        ORDER BY p.sort_order, p.name_gu
      ''', parameters: params);

      return result.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Get products failed: $e');
      rethrow;
    }
  }

  /// Get single product
  Future<Product?> getProduct(String productId) async {
    try {
      final result = await _db.query(
        '''
        SELECT 
          p.*,
          c.name_gu as category_name,
          u.name_gu as unit_name,
          u.symbol as unit_symbol,
          dp.price as current_price
        FROM products p
        LEFT JOIN categories c ON p.category_id = c.id
        LEFT JOIN units u ON p.unit_id = u.id
        LEFT JOIN daily_prices dp ON p.id = dp.product_id 
          AND dp.price_date = CURRENT_DATE
        WHERE p.id = @id
      ''',
        parameters: {'id': productId},
      );

      if (result.isNotEmpty) {
        return Product.fromJson(result.first);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Get product failed: $e');
      return null;
    }
  }

  /// Create product
  Future<Product?> createProduct(Product product) async {
    try {
      final result = await _db.insert('products', product.toJson());
      if (result != null) {
        return Product.fromJson(result);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Create product failed: $e');
      rethrow;
    }
  }

  /// Update product
  Future<Product?> updateProduct(
    String productId,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await _db.update(
        'products',
        data,
        where: 'id = @id',
        whereParams: {'id': productId},
      );

      if (result.isNotEmpty) {
        return Product.fromJson(result.first);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Update product failed: $e');
      rethrow;
    }
  }

  /// Soft delete product
  Future<bool> deleteProduct(String productId) async {
    try {
      return await _db.softDelete(
        'products',
        where: 'id = @id',
        whereParams: {'id': productId},
      );
    } catch (e) {
      debugPrint('❌ Delete product failed: $e');
      return false;
    }
  }

  /// Get all units
  Future<List<ProductUnit>> getUnits() async {
    try {
      final result = await _db.query('SELECT * FROM units ORDER BY name_gu');
      return result.map((json) => ProductUnit.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Get units failed: $e');
      return [];
    }
  }

  /// Get categories for vendor
  Future<List<Category>> getCategories(String vendorId) async {
    try {
      final result = await _db.query(
        '''
        SELECT * FROM categories 
        WHERE vendor_id = @vendor_id AND is_active = true
        ORDER BY sort_order, name_gu
      ''',
        parameters: {'vendor_id': vendorId},
      );

      return result.map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Get categories failed: $e');
      return [];
    }
  }

  /// Create category
  Future<Category?> createCategory(Category category) async {
    try {
      final result = await _db.insert('categories', category.toJson());
      if (result != null) {
        return Category.fromJson(result);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Create category failed: $e');
      rethrow;
    }
  }
}
