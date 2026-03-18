/// Price Repository
///
/// Handles daily price operations via Supabase REST.
library;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/database_provider.dart';
import '../models/models.dart';

class PriceRepository {
  final _db = DatabaseProvider.instance;
  SupabaseClient get _client => _db.client;

  /// Today's prices joined with product info.
  Future<List<Map<String, dynamic>>> getTodayPrices(
    String vendorId, {
    bool forceRefresh = false,
  }) async {
    try {
      final rows = await _client
          .from('products')
          .select(
            'id, name_gu, name_en, max_price, units(symbol), daily_prices(id, price, notes)',
          )
          .eq('vendor_id', vendorId)
          .eq('is_active', true)
          .order('sort_order');

      return rows.map((r) {
        final prices = (r['daily_prices'] as List?)?.where((dp) {
          // filter by today if the join returns multiple
          return true;
        }).toList();
        final latestPrice = prices != null && prices.isNotEmpty
            ? prices.last
            : null;
        return {
          'product_id': r['id'],
          'name_gu': r['name_gu'],
          'name_en': r['name_en'],
          'max_price': r['max_price'],
          'unit_symbol': (r['units'] as Map?)?['symbol'],
          'price_id': latestPrice?['id'],
          'price': latestPrice?['price'],
          'notes': latestPrice?['notes'],
        };
      }).toList();
    } catch (e) {
      debugPrint('❌ getTodayPrices failed: $e');
      rethrow;
    }
  }

  /// Prices for a specific date.
  Future<List<Map<String, dynamic>>> getPricesForDate(
    String vendorId,
    DateTime date,
  ) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final rows = await _client
          .from('products')
          .select('id, name_gu, name_en, max_price, units(symbol)')
          .eq('vendor_id', vendorId)
          .eq('is_active', true)
          .order('sort_order');

      final priceRows = await _client
          .from('daily_prices')
          .select('product_id, id, price, notes')
          .eq('price_date', dateStr);

      final priceMap = <String, Map>{};
      for (final p in priceRows) {
        priceMap[p['product_id'].toString()] = p;
      }

      return rows.map((r) {
        final pid = r['id'].toString();
        final dp = priceMap[pid];
        return {
          'product_id': pid,
          'name_gu': r['name_gu'],
          'name_en': r['name_en'],
          'max_price': r['max_price'],
          'unit_symbol': (r['units'] as Map?)?['symbol'],
          'price_id': dp?['id'],
          'price': dp?['price'],
          'notes': dp?['notes'],
        };
      }).toList();
    } catch (e) {
      debugPrint('❌ getPricesForDate failed: $e');
      rethrow;
    }
  }

  /// productId → price map for a date.
  Future<Map<String, double>> getPricesForDateMap(
    String vendorId,
    DateTime date,
  ) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final rows = await _client
          .from('daily_prices')
          .select('product_id, price')
          .eq('price_date', dateStr);

      final Map<String, double> result = {};
      for (final r in rows) {
        final pid = r['product_id']?.toString();
        final price = r['price'];
        if (pid != null && price != null) {
          result[pid] = double.tryParse(price.toString()) ?? 0;
        }
      }
      return result;
    } catch (e) {
      debugPrint('❌ getPricesForDateMap failed: $e');
      return {};
    }
  }

  Future<double?> getYesterdayPrice(
    String vendorId,
    String productId,
    DateTime date,
  ) async {
    try {
      final yesterday = date.subtract(const Duration(days: 1));
      final dateStr = yesterday.toIso8601String().split('T')[0];
      final rows = await _client
          .from('daily_prices')
          .select('price')
          .eq('product_id', productId)
          .eq('price_date', dateStr)
          .limit(1);
      if (rows.isEmpty || rows.first['price'] == null) return null;
      return double.tryParse(rows.first['price'].toString());
    } catch (e) {
      debugPrint('❌ getYesterdayPrice failed: $e');
      return null;
    }
  }

  /// Upsert a price record.
  Future<DailyPrice?> setPrice({
    required String productId,
    required DateTime date,
    required double price,
    String? notes,
  }) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final rows = await _client.from('daily_prices').upsert({
        'product_id': productId,
        'price_date': dateStr,
        'price': price,
        'notes': notes,
      }, onConflict: 'product_id,price_date').select();
      if (rows.isEmpty) return null;
      return DailyPrice.fromJson(rows.first);
    } catch (e) {
      debugPrint('❌ setPrice failed: $e');
      rethrow;
    }
  }

  Future<bool> bulkUpdatePrices(
    String vendorId,
    DateTime date,
    List<Map<String, dynamic>> prices,
  ) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final toUpsert = prices
          .where((p) => p['price'] != null && (p['price'] ?? 0) > 0)
          .map(
            (p) => {
              'product_id': p['product_id'],
              'price_date': dateStr,
              'price': p['price'],
              'notes': p['notes'],
            },
          )
          .toList();
      if (toUpsert.isEmpty) return true;
      await _client
          .from('daily_prices')
          .upsert(toUpsert, onConflict: 'product_id,price_date');
      return true;
    } catch (e) {
      debugPrint('❌ bulkUpdatePrices failed: $e');
      return false;
    }
  }

  Future<List<DailyPrice>> getPriceHistory(
    String productId, {
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 30,
  }) async {
    try {
      // All filters MUST come before .order()/.limit()
      var q = _client
          .from('daily_prices')
          .select('*, products(name_gu, name_en)')
          .eq('product_id', productId);
      if (fromDate != null) {
        q = q.gte('price_date', fromDate.toIso8601String().split('T')[0]);
      }
      if (toDate != null) {
        q = q.lte('price_date', toDate.toIso8601String().split('T')[0]);
      }
      final rows = await q.order('price_date', ascending: false).limit(limit);
      return rows.map((r) {
        final product = r['products'] as Map<String, dynamic>? ?? {};
        return DailyPrice.fromJson({
          ...r,
          'product_name_gu': product['name_gu'],
          'product_name_en': product['name_en'],
        });
      }).toList();
    } catch (e) {
      debugPrint('❌ getPriceHistory failed: $e');
      return [];
    }
  }

  Future<int> copyPreviousDayPrices(String vendorId, DateTime date) async {
    try {
      final targetDate = date.toIso8601String().split('T')[0];
      final previousDate = date
          .subtract(const Duration(days: 1))
          .toIso8601String()
          .split('T')[0];

      // Fetch previous day's prices for vendor's products
      final prods = await _client
          .from('products')
          .select('id')
          .eq('vendor_id', vendorId)
          .eq('is_active', true);
      final productIds = prods.map((p) => p['id'].toString()).toList();

      if (productIds.isEmpty) return 0;

      final prevPrices = await _client
          .from('daily_prices')
          .select('product_id, price')
          .eq('price_date', previousDate)
          .inFilter('product_id', productIds);

      // Check which target prices already exist
      final existingTargets = await _client
          .from('daily_prices')
          .select('product_id')
          .eq('price_date', targetDate)
          .inFilter('product_id', productIds);
      final existingIds = existingTargets
          .map((e) => e['product_id'].toString())
          .toSet();

      final toInsert = prevPrices
          .where((p) => !existingIds.contains(p['product_id'].toString()))
          .map(
            (p) => {
              'product_id': p['product_id'],
              'price_date': targetDate,
              'price': p['price'],
              'notes': 'Copied from previous day',
            },
          )
          .toList();

      if (toInsert.isNotEmpty) {
        await _client.from('daily_prices').insert(toInsert);
      }
      return toInsert.length;
    } catch (e) {
      debugPrint('❌ copyPreviousDayPrices failed: $e');
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> getPriceTrends(
    String vendorId, {
    int days = 7,
  }) async {
    try {
      final fromDate = DateTime.now()
          .subtract(Duration(days: days))
          .toIso8601String()
          .split('T')[0];
      final rows = await _client
          .from('daily_prices')
          .select('product_id, price_date, price, products(name_gu, name_en)')
          .gte('price_date', fromDate)
          .order('price_date');
      return rows.map((r) {
        final product = r['products'] as Map<String, dynamic>? ?? {};
        return {
          'product_id': r['product_id'],
          'price_date': r['price_date'],
          'price': r['price'],
          'name_gu': product['name_gu'],
          'name_en': product['name_en'],
        };
      }).toList();
    } catch (e) {
      debugPrint('❌ getPriceTrends failed: $e');
      return [];
    }
  }
}
