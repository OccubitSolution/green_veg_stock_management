/// Product Repository
///
/// Handles product and category CRUD via Supabase REST.
library;

import 'package:flutter/foundation.dart' hide Category;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/database_provider.dart';
import '../models/product_model.dart';
import '../models/models.dart';

class ProductRepository {
  final _db = DatabaseProvider.instance;
  SupabaseClient get _client => _db.client;

  Future<List<Product>> getProducts(
    String vendorId, {
    String? search,
    String? categoryId,
    bool activeOnly = true,
    bool forceRefresh = false,
  }) async {
    try {
      // All filters MUST come before .order() in Supabase Flutter
      var q = _client
          .from('products')
          .select('*, categories(name_gu), units(name_en, symbol)')
          .eq('vendor_id', vendorId);

      if (activeOnly) q = q.eq('is_active', true);
      if (categoryId != null) q = q.eq('category_id', categoryId);

      final rows = await q.order('sort_order');
      var products = rows.map((r) {
        final cat = r['categories'] as Map<String, dynamic>? ?? {};
        final unit = r['units'] as Map<String, dynamic>? ?? {};
        return Product.fromJson({
          ...r,
          'category_name': cat['name_gu'],
          'unit_name': unit['name_en'],
          'unit_symbol': unit['symbol'],
        });
      }).toList();

      // Client-side search filter
      if (search != null && search.isNotEmpty) {
        final s = search.toLowerCase();
        products = products
            .where(
              (p) =>
                  p.nameGu.toLowerCase().contains(s) ||
                  (p.nameEn?.toLowerCase().contains(s) ?? false),
            )
            .toList();
      }

      return products;
    } catch (e) {
      debugPrint('❌ getProducts failed: $e');
      rethrow;
    }
  }

  Future<Product?> getProduct(String productId) async {
    try {
      final rows = await _client
          .from('products')
          .select('*, categories(name_gu), units(name_en, symbol)')
          .eq('id', productId)
          .limit(1);
      if ((rows).isEmpty) return null;
      final r = rows.first as Map<String, dynamic>;
      final cat = r['categories'] as Map<String, dynamic>? ?? {};
      final unit = r['units'] as Map<String, dynamic>? ?? {};
      return Product.fromJson({
        ...r,
        'category_name': cat['name_gu'],
        'unit_name': unit['name_en'],
        'unit_symbol': unit['symbol'],
      });
    } catch (e) {
      debugPrint('❌ getProduct failed: $e');
      return null;
    }
  }

  Future<Product?> createProduct(Product product) async {
    try {
      final result = await _db.insert('products', product.toJson());
      return result != null ? Product.fromJson(result) : null;
    } catch (e) {
      debugPrint('❌ createProduct failed: $e');
      rethrow;
    }
  }

  Future<Product?> updateProduct(
    String productId,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await _db.update(
        'products',
        data,
        match: {'id': productId},
      );
      return result.isNotEmpty ? Product.fromJson(result.first) : null;
    } catch (e) {
      debugPrint('❌ updateProduct failed: $e');
      rethrow;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      await _db.softDelete('products', match: {'id': productId});
      return true;
    } catch (e) {
      debugPrint('❌ deleteProduct failed: $e');
      return false;
    }
  }

  Future<List<ProductUnit>> getUnits() async {
    try {
      final rows = await _client.from('units').select().order('name_gu');
      return rows
          .map((r) => ProductUnit.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ getUnits failed: $e');
      return [];
    }
  }

  Future<List<Category>> getCategories(
    String vendorId, {
    bool forceRefresh = false,
  }) async {
    try {
      final rows = await _client
          .from('categories')
          .select()
          .eq('vendor_id', vendorId)
          .eq('is_active', true)
          .order('sort_order');
      return rows
          .map((r) => Category.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ getCategories failed: $e');
      return [];
    }
  }

  Future<Category?> createCategory(Category category) async {
    try {
      final result = await _db.insert('categories', category.toJson());
      return result != null ? Category.fromJson(result) : null;
    } catch (e) {
      debugPrint('❌ createCategory failed: $e');
      rethrow;
    }
  }
}
