/// Database Provider
///
/// Thin wrapper around the Supabase REST client.
/// Previously used the `postgres` raw socket package; now uses
/// `supabase_flutter` so all traffic goes over HTTPS (port 443) and
/// is never blocked by mobile-network firewalls.
library;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/cache_service.dart';
import '../services/connectivity_service.dart';

class DatabaseProvider {
  DatabaseProvider._();
  static final DatabaseProvider instance = DatabaseProvider._();

  final _cache = CacheService();
  // ignore: unused_field
  final _connectivity = ConnectivityService();

  /// The underlying Supabase client (initialised in main.dart).
  SupabaseClient get client => Supabase.instance.client;

  /// Always "connected" – Supabase manages HTTP sessions internally.
  bool get isConnected => true;

  /// No-op: Supabase is initialised once in main.dart via
  /// `Supabase.initialize(...)`.
  Future<void> initialize() async {
    debugPrint('✅ Supabase REST client ready');
  }

  // ─── Cache helpers ──────────────────────────────────────────────────

  String _boxForTable(String table) {
    if (table.contains('product') || table.contains('unit')) {
      return CacheService.productsBox;
    } else if (table.contains('categor')) {
      return CacheService.categoriesBox;
    } else if (table.contains('customer')) {
      return CacheService.customersBox;
    } else if (table.contains('price')) {
      return CacheService.pricesBox;
    } else if (table.contains('order')) {
      return CacheService.ordersBox;
    }
    return CacheService.analyticsBox;
  }

  List<Map<String, dynamic>>? _fromCache(String table, String key) {
    switch (_boxForTable(table)) {
      case CacheService.productsBox:
        return _cache.getCachedProducts(key);
      case CacheService.categoriesBox:
        return _cache.getCachedCategories(key);
      case CacheService.customersBox:
        return _cache.getCachedCustomers(key);
      case CacheService.pricesBox:
        return _cache.getCachedPrices(key);
      case CacheService.ordersBox:
        return _cache.getCachedOrders(key);
      default:
        return null;
    }
  }

  void _toCache(String table, String key, List<Map<String, dynamic>> data) {
    switch (_boxForTable(table)) {
      case CacheService.productsBox:
        _cache.cacheProducts(key, data);
      case CacheService.categoriesBox:
        _cache.cacheCategories(key, data);
      case CacheService.customersBox:
        _cache.cacheCustomers(key, data);
      case CacheService.pricesBox:
        _cache.cachePrices(key, data);
      case CacheService.ordersBox:
        _cache.cacheOrders(key, data);
      default:
        _cache.cacheAnalytics(key, 'query', data);
    }
  }

  // ─── CRUD wrappers ───────────────────────────────────────────────────

  /// SELECT rows from [table] where every key in [match] equals its value.
  /// Falls back to cache when offline.
  Future<List<Map<String, dynamic>>> query(
    String table, {
    Map<String, dynamic>? match,
    bool useCache = false,
    String? cacheKey,
    int cacheMinutes = 30,
  }) async {
    if (useCache && cacheKey != null) {
      final box = _boxForTable(table);
      if (_cache.isCacheValid(box, cacheKey, maxAgeMinutes: cacheMinutes)) {
        final cached = _fromCache(table, cacheKey);
        if (cached != null) {
          debugPrint('📦 Cache hit: $cacheKey');
          return cached;
        }
      }
    }

    try {
      var q = client.from(table).select();
      if (match != null) {
        for (final entry in match.entries) {
          q = q.eq(entry.key, entry.value);
        }
      }
      final rows = await q;
      final data = List<Map<String, dynamic>>.from(rows);
      if (useCache && cacheKey != null) {
        _toCache(table, cacheKey, data);
      }
      return data;
    } catch (e) {
      debugPrint('❌ query($table) failed: $e');
      if (useCache && cacheKey != null) {
        final cached = _fromCache(table, cacheKey);
        if (cached != null) return cached;
      }
      rethrow;
    }
  }

  /// INSERT a single row and return it.
  Future<Map<String, dynamic>?> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    final rows = await client.from(table).insert(data).select();
    return rows.isNotEmpty ? rows.first : null;
  }

  /// UPDATE rows where every key in [match] equals its value.
  Future<List<Map<String, dynamic>>> update(
    String table,
    Map<String, dynamic> data, {
    required Map<String, dynamic> match,
  }) async {
    var q = client.from(table).update(data);
    for (final entry in match.entries) {
      q = q.eq(entry.key, entry.value);
    }
    return List<Map<String, dynamic>>.from(await q.select());
  }

  /// Soft-delete: sets `is_active = false`.
  Future<void> softDelete(
    String table, {
    required Map<String, dynamic> match,
  }) async {
    await update(table, {'is_active': false}, match: match);
  }

  /// Hard DELETE.
  Future<void> delete(
    String table, {
    required Map<String, dynamic> match,
  }) async {
    var q = client.from(table).delete();
    for (final entry in match.entries) {
      q = q.eq(entry.key, entry.value);
    }
    await q;
  }

  // ─── Dashboard helpers (called by HomeController) ────────────────────

  Future<Map<String, dynamic>> getDashboardStats(String vendorId) async {
    try {
      final results = await Future.wait([
        client
            .from('products')
            .select('id')
            .eq('vendor_id', vendorId)
            .eq('is_active', true),
        client
            .from('categories')
            .select('id')
            .eq('vendor_id', vendorId)
            .eq('is_active', true),
        client
            .from('customers')
            .select('id')
            .eq('vendor_id', vendorId)
            .eq('is_active', true),
        client.from('sales').select('total_amount').eq('vendor_id', vendorId),
        client
            .from('purchases')
            .select('total_amount')
            .eq('vendor_id', vendorId),
        client
            .from('orders')
            .select('id')
            .eq('vendor_id', vendorId)
            .eq('status', 'pending'),
      ]);

      final today = DateTime.now().toIso8601String().split('T')[0];

      final todaySales = (results[3] as List).where((s) {
        final d = (s['sale_date'] ?? '').toString();
        return d.startsWith(today);
      }).toList();

      final todayPurchases = (results[4] as List).where((p) {
        final d = (p['purchase_date'] ?? '').toString();
        return d.startsWith(today);
      }).toList();

      double todayRevenue = todaySales.fold(
        0.0,
        (s, r) => s + (r['total_amount'] ?? 0),
      );
      double todayPurchaseAmt = todayPurchases.fold(
        0.0,
        (s, r) => s + (r['total_amount'] ?? 0),
      );

      return {
        'product_count': (results[0] as List).length,
        'category_count': (results[1] as List).length,
        'customer_count': (results[2] as List).length,
        'today_revenue': todayRevenue,
        'today_sales_count': todaySales.length,
        'today_purchase_amount': todayPurchaseAmt,
        'today_purchase_count': todayPurchases.length,
        'pending_orders': (results[5] as List).length,
        'confirmed_orders': 0,
        'out_of_stock': 0,
        'low_stock': 0,
      };
    } catch (e) {
      debugPrint('❌ getDashboardStats failed: $e');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> getWeeklySalesStats(
    String vendorId,
  ) async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 6));
      final dateStr = sevenDaysAgo.toIso8601String().split('T')[0];

      final rows = await client
          .from('sales')
          .select('sale_date, total_amount')
          .eq('vendor_id', vendorId)
          .gte('sale_date', dateStr)
          .order('sale_date');

      // Group by date
      final Map<String, Map<String, dynamic>> grouped = {};
      for (final row in rows) {
        final date = row['sale_date'].toString();
        grouped[date] ??= {'date': date, 'order_count': 0, 'revenue': 0.0};
        grouped[date]!['order_count'] =
            (grouped[date]!['order_count'] as int) + 1;
        grouped[date]!['revenue'] =
            (grouped[date]!['revenue'] as double) + (row['total_amount'] ?? 0);
      }
      return grouped.values.toList();
    } catch (e) {
      debugPrint('❌ getWeeklySalesStats failed: $e');
      return [];
    }
  }

  Future<void> clearVendorCache(String vendorId) async {
    debugPrint('🗑️ Clearing cache for vendor: $vendorId');
  }
}
