import 'package:flutter/foundation.dart';
import 'package:green_veg_stock_management/app/data/models/phase2_models.dart';
import 'package:green_veg_stock_management/app/data/providers/database_provider.dart';

/// Inventory Repository – stock management and tracking via Supabase REST.
class InventoryRepository {
  final DatabaseProvider _db = DatabaseProvider.instance;

  /// All stock rows for a vendor, enriched with product + unit names.
  Future<List<Stock>> getStock(String vendorId) async {
    try {
      final rows = await _db.client
          .from('stock')
          .select('*, products(name_gu, name_en, units(symbol))')
          .eq('vendor_id', vendorId);
      return rows.map((r) => Stock.fromJson(_flattenStock(r))).toList();
    } catch (e) {
      debugPrint('❌ getStock failed: $e');
      return [];
    }
  }

  /// Stock rows where quantity <= min_stock_level.
  Future<List<Stock>> getLowStock(String vendorId) async {
    try {
      final rows = await _db.client
          .from('stock')
          .select('*, products(name_gu, name_en, units(symbol))')
          .eq('vendor_id', vendorId)
          .gt('quantity', 0);
      // Filter client-side because PostgREST can't compare two columns easily
      final lowRows = rows
          .where((r) => (r['quantity'] ?? 0) <= (r['min_stock_level'] ?? 0))
          .toList();
      return lowRows.map((r) => Stock.fromJson(_flattenStock(r))).toList();
    } catch (e) {
      debugPrint('❌ getLowStock failed: $e');
      return [];
    }
  }

  /// Stock rows where quantity <= 0.
  Future<List<Stock>> getOutOfStock(String vendorId) async {
    try {
      final rows = await _db.client
          .from('stock')
          .select('*, products(name_gu, name_en, units(symbol))')
          .eq('vendor_id', vendorId)
          .lte('quantity', 0);
      return rows.map((r) => Stock.fromJson(_flattenStock(r))).toList();
    } catch (e) {
      debugPrint('❌ getOutOfStock failed: $e');
      return [];
    }
  }

  /// Most-recent stock movements for a given stock record.
  Future<List<StockMovement>> getStockMovements(
    String stockId, {
    int limit = 50,
  }) async {
    try {
      final rows = await _db.client
          .from('stock_movements')
          .select()
          .eq('stock_id', stockId)
          .order('created_at', ascending: false)
          .limit(limit);
      return rows
          .map((r) => StockMovement.fromJson(r))
          .toList();
    } catch (e) {
      debugPrint('❌ getStockMovements failed: $e');
      return [];
    }
  }

  /// Set stock to [newQuantity] (creates entry if missing) and records movement.
  Future<void> adjustStock(
    String vendorId,
    String productId,
    double newQuantity,
    String reason,
  ) async {
    try {
      final existing = await _db.client
          .from('stock')
          .select('id, quantity')
          .eq('vendor_id', vendorId)
          .eq('product_id', productId);

      String stockId;
      double oldQuantity = 0;

      if (existing.isEmpty) {
        final inserted = await _db.client
            .from('stock')
            .insert({
              'vendor_id': vendorId,
              'product_id': productId,
              'quantity': newQuantity,
            })
            .select('id');
        stockId = inserted.first['id'].toString();
      } else {
        stockId = existing.first['id'].toString();
        oldQuantity = double.parse(existing.first['quantity'].toString());
        await _db.client
            .from('stock')
            .update({
              'quantity': newQuantity,
              'last_updated': DateTime.now().toIso8601String(),
            })
            .eq('id', stockId);
      }

      await _db.client.from('stock_movements').insert({
        'stock_id': stockId,
        'movement_type': 'adjustment',
        'quantity': newQuantity - oldQuantity,
        'reference_type': 'adjustment',
        'notes': reason,
      });
    } catch (e) {
      debugPrint('❌ adjustStock failed: $e');
    }
  }

  /// Reduce stock and record a "waste" movement.
  Future<void> recordWaste(
    String stockId,
    double quantity,
    String reason,
  ) async {
    try {
      final existing = await _db.client
          .from('stock')
          .select('quantity')
          .eq('id', stockId);
      if (existing.isEmpty) return;
      final current = double.parse(existing.first['quantity'].toString());
      await _db.client
          .from('stock')
          .update({
            'quantity': current - quantity,
            'last_updated': DateTime.now().toIso8601String(),
          })
          .eq('id', stockId);
      await _db.client.from('stock_movements').insert({
        'stock_id': stockId,
        'movement_type': 'waste',
        'quantity': -quantity,
        'reference_type': 'waste',
        'notes': reason,
      });
    } catch (e) {
      debugPrint('❌ recordWaste failed: $e');
    }
  }

  /// Aggregate inventory stats for the vendor.
  Future<Map<String, dynamic>> getInventoryStats(String vendorId) async {
    try {
      final rows = await _db.client
          .from('stock')
          .select('quantity, min_stock_level')
          .eq('vendor_id', vendorId);
      final list = rows;
      int outOfStock = 0, lowStock = 0, inStock = 0;
      for (final r in list) {
        final qty = (r['quantity'] ?? 0) as num;
        final min = (r['min_stock_level'] ?? 0) as num;
        if (qty <= 0) {
          outOfStock++;
        } else if (qty <= min) {
          lowStock++;
        } else {
          inStock++;
        }
      }
      return {
        'totalProducts': list.length,
        'outOfStock': outOfStock,
        'lowStock': lowStock,
        'inStock': inStock,
      };
    } catch (e) {
      debugPrint('❌ getInventoryStats failed: $e');
      return {};
    }
  }

  // Flatten nested Supabase join result into a flat map expected by Stock.fromJson
  Map<String, dynamic> _flattenStock(Map<String, dynamic> r) {
    final product = r['products'] as Map<String, dynamic>? ?? {};
    final unit = product['units'] as Map<String, dynamic>? ?? {};
    return {
      ...r,
      'product_name_gu': product['name_gu'],
      'product_name_en': product['name_en'],
      'unit_symbol': unit['symbol'],
    };
  }
}
