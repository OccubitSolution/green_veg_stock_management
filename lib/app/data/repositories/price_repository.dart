/// Price Repository
///
/// Handles daily price operations
library;

import 'package:flutter/foundation.dart';

import '../providers/database_provider.dart';
import '../models/models.dart';

class PriceRepository {
  final _db = DatabaseProvider.instance;

  /// Get today's prices for all products
  Future<List<Map<String, dynamic>>> getTodayPrices(String vendorId) async {
    try {
      final result = await _db.query(
        '''
        SELECT 
          p.id as product_id,
          p.name_gu,
          p.name_en,
          p.max_price,
          u.symbol as unit_symbol,
          dp.id as price_id,
          dp.price,
          dp.notes
        FROM products p
        LEFT JOIN units u ON p.unit_id = u.id
        LEFT JOIN daily_prices dp ON p.id = dp.product_id 
          AND dp.price_date = CURRENT_DATE
        WHERE p.vendor_id = @vendor_id AND p.is_active = true
        ORDER BY p.sort_order, p.name_gu
      ''',
        parameters: {'vendor_id': vendorId},
      );

      return result;
    } catch (e) {
      debugPrint('❌ Get today prices failed: $e');
      rethrow;
    }
  }

  /// Get prices for a specific date
  Future<List<Map<String, dynamic>>> getPricesForDate(
    String vendorId,
    DateTime date,
  ) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      debugPrint(
        '🔍 [PriceRepo] Fetching prices for date: $dateStr, vendor: $vendorId',
      );

      final result = await _db.query(
        '''
        SELECT 
          p.id as product_id,
          p.name_gu,
          p.name_en,
          p.max_price,
          u.symbol as unit_symbol,
          dp.id as price_id,
          dp.price,
          dp.notes
        FROM products p
        LEFT JOIN units u ON p.unit_id = u.id
        LEFT JOIN daily_prices dp ON p.id = dp.product_id 
          AND dp.price_date = @price_date::date
        WHERE p.vendor_id = @vendor_id AND p.is_active = true
        ORDER BY p.sort_order, p.name_gu
      ''',
        parameters: {'vendor_id': vendorId, 'price_date': dateStr},
      );

      debugPrint('✅ [PriceRepo] Found ${result.length} products with prices');

      // Debug: Print first few results
      if (result.isNotEmpty) {
        for (var i = 0; i < result.length && i < 3; i++) {
          debugPrint(
            '📊 [PriceRepo] Product ${result[i]['product_id']}: Price = ${result[i]['price']}',
          );
        }
      }

      return result;
    } catch (e) {
      debugPrint('❌ Get prices for date failed: $e');
      rethrow;
    }
  }

  /// Get prices for a specific date as a Map of productId -> price
  Future<Map<String, double>> getPricesForDateMap(
    String vendorId,
    DateTime date,
  ) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final result = await _db.query(
        '''
        SELECT product_id, price
        FROM daily_prices
        WHERE price_date = @price_date::date
        AND product_id IN (
          SELECT id FROM products WHERE vendor_id = @vendor_id
        )
      ''',
        parameters: {'vendor_id': vendorId, 'price_date': dateStr},
      );

      final Map<String, double> priceMap = {};
      for (final row in result) {
        final productId = row['product_id'] as String?;
        final price = row['price'];
        if (productId != null && price != null) {
          priceMap[productId] = double.tryParse(price.toString()) ?? 0.0;
        }
      }
      return priceMap;
    } catch (e) {
      debugPrint('❌ Get prices for date map failed: $e');
      return {};
    }
  }

  /// Get yesterday's price for a product
  Future<double?> getYesterdayPrice(
    String vendorId,
    String productId,
    DateTime date,
  ) async {
    try {
      final yesterday = date.subtract(const Duration(days: 1));
      final dateStr = yesterday.toIso8601String().split('T')[0];

      final result = await _db.query(
        '''
        SELECT dp.price
        FROM daily_prices dp
        JOIN products p ON dp.product_id = p.id
        WHERE dp.product_id = @product_id
        AND dp.price_date = @price_date::date
        AND p.vendor_id = @vendor_id
        LIMIT 1
      ''',
        parameters: {
          'product_id': productId,
          'price_date': dateStr,
          'vendor_id': vendorId,
        },
      );

      if (result.isNotEmpty && result.first['price'] != null) {
        final price = (result.first['price'] as num).toDouble();
        debugPrint('📅 [PriceRepo] Yesterday price for $productId: ₹$price');
        return price;
      }

      return null;
    } catch (e) {
      debugPrint('❌ Get yesterday price failed: $e');
      return null;
    }
  }

  /// Set price for a product on a specific date
  Future<DailyPrice?> setPrice({
    required String productId,
    required DateTime date,
    required double price,
    String? notes,
  }) async {
    try {
      // Use upsert (insert or update on conflict)
      final dateStr = date.toIso8601String().split('T')[0];

      final result = await _db.query(
        '''
        INSERT INTO daily_prices (product_id, price_date, price, notes)
        VALUES (@product_id, @price_date, @price, @notes)
        ON CONFLICT (product_id, price_date) 
        DO UPDATE SET price = @price, notes = @notes
        RETURNING *
      ''',
        parameters: {
          'product_id': productId,
          'price_date': dateStr,
          'price': price,
          'notes': notes,
        },
      );

      if (result.isNotEmpty) {
        return DailyPrice.fromJson(result.first);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Set price failed: $e');
      rethrow;
    }
  }

  /// Bulk update prices for a specific date
  Future<bool> bulkUpdatePrices(
    String vendorId,
    DateTime date,
    List<Map<String, dynamic>> prices,
  ) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];

      for (final priceData in prices) {
        if (priceData['price'] != null && priceData['price'] > 0) {
          await _db.query(
            '''
            INSERT INTO daily_prices (product_id, price_date, price, notes)
            VALUES (@product_id, @price_date, @price, @notes)
            ON CONFLICT (product_id, price_date) 
            DO UPDATE SET price = @price, notes = @notes
          ''',
            parameters: {
              'product_id': priceData['product_id'],
              'price_date': dateStr,
              'price': priceData['price'],
              'notes': priceData['notes'],
            },
          );
        }
      }

      return true;
    } catch (e) {
      debugPrint('❌ Bulk update prices failed: $e');
      return false;
    }
  }

  /// Get price history for a product
  Future<List<DailyPrice>> getPriceHistory(
    String productId, {
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 30,
  }) async {
    try {
      String whereClause = 'dp.product_id = @product_id';
      final params = <String, dynamic>{'product_id': productId};

      if (fromDate != null) {
        whereClause += ' AND dp.price_date >= @from_date';
        params['from_date'] = fromDate.toIso8601String().split('T')[0];
      }

      if (toDate != null) {
        whereClause += ' AND dp.price_date <= @to_date';
        params['to_date'] = toDate.toIso8601String().split('T')[0];
      }

      final result = await _db.query('''
        SELECT 
          dp.*,
          p.name_gu as product_name_gu,
          p.name_en as product_name_en
        FROM daily_prices dp
        JOIN products p ON dp.product_id = p.id
        WHERE $whereClause
        ORDER BY dp.price_date DESC
        LIMIT $limit
      ''', parameters: params);

      return result.map((json) => DailyPrice.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Get price history failed: $e');
      return [];
    }
  }

  /// Copy previous day's prices to a specific date
  Future<int> copyPreviousDayPrices(String vendorId, DateTime date) async {
    try {
      final targetDate = date.toIso8601String().split('T')[0];
      final previousDate = date
          .subtract(const Duration(days: 1))
          .toIso8601String()
          .split('T')[0];

      final result = await _db.query(
        '''
        INSERT INTO daily_prices (product_id, price_date, price, notes)
        SELECT dp.product_id, @target_date, dp.price, 'Copied from previous day'
        FROM daily_prices dp
        JOIN products p ON dp.product_id = p.id
        WHERE dp.price_date = @previous_date 
        AND p.vendor_id = @vendor_id
        AND NOT EXISTS (
          SELECT 1 FROM daily_prices 
          WHERE product_id = dp.product_id AND price_date = @target_date
        )
        RETURNING id
      ''',
        parameters: {
          'target_date': targetDate,
          'previous_date': previousDate,
          'vendor_id': vendorId,
        },
      );

      return result.length;
    } catch (e) {
      debugPrint('❌ Copy prices failed: $e');
      return 0;
    }
  }

  /// Get price trends for multiple products
  Future<List<Map<String, dynamic>>> getPriceTrends(
    String vendorId, {
    int days = 7,
  }) async {
    try {
      final fromDate = DateTime.now()
          .subtract(Duration(days: days))
          .toIso8601String()
          .split('T')[0];

      final result = await _db.query(
        '''
        SELECT 
          p.id as product_id,
          p.name_gu,
          p.name_en,
          dp.price_date,
          dp.price
        FROM products p
        JOIN daily_prices dp ON p.id = dp.product_id
        WHERE p.vendor_id = @vendor_id 
        AND dp.price_date >= @from_date
        ORDER BY p.name_gu, dp.price_date
      ''',
        parameters: {'vendor_id': vendorId, 'from_date': fromDate},
      );

      return result;
    } catch (e) {
      debugPrint('❌ Get price trends failed: $e');
      return [];
    }
  }
}
