import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:green_veg_stock_management/app/data/models/phase2_models.dart';
import 'package:green_veg_stock_management/app/data/providers/database_provider.dart';

/// Purchase Repository – purchases and stock-in via Supabase REST.
class PurchaseRepository {
  final DatabaseProvider _db = DatabaseProvider.instance;
  SupabaseClient get _client => _db.client;

  /// Purchases for a vendor, optionally filtered by date range.
  Future<List<Purchase>> getPurchases(
    String vendorId, {
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    try {
      // Build all filters BEFORE order/limit (Supabase requires this)
      var q = _client.from('purchases').select().eq('vendor_id', vendorId);

      if (startDate != null) {
        q = q.gte('purchase_date', startDate.toIso8601String().split('T')[0]);
      }
      if (endDate != null) {
        q = q.lte('purchase_date', endDate.toIso8601String().split('T')[0]);
      }

      final rows = await q
          .order('purchase_date', ascending: false)
          .limit(limit);
      return rows
          .map((r) => Purchase.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ getPurchases failed: $e');
      return [];
    }
  }

  /// Single purchase by ID.
  Future<Purchase?> getPurchaseById(String purchaseId) async {
    try {
      final rows = await _client
          .from('purchases')
          .select()
          .eq('id', purchaseId)
          .limit(1);
      if (rows.isEmpty) return null;
      return Purchase.fromJson(rows.first as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ getPurchaseById failed: $e');
      return null;
    }
  }

  /// Line items for a purchase.
  Future<List<PurchaseItem>> getPurchaseItems(String purchaseId) async {
    try {
      final rows = await _client
          .from('purchase_items')
          .select('*, products(name_gu, name_en, units(symbol))')
          .eq('purchase_id', purchaseId);
      return rows.map((r) {
        final flat = _flattenItem(r as Map<String, dynamic>);
        return PurchaseItem.fromJson(flat);
      }).toList();
    } catch (e) {
      debugPrint('❌ getPurchaseItems failed: $e');
      return [];
    }
  }

  /// Create purchase + items + update stock.
  Future<Purchase> createPurchase(
    Purchase purchase,
    List<PurchaseItem> items,
  ) async {
    // Insert purchase
    final purchaseRows = await _client.from('purchases').insert({
      'vendor_id': purchase.vendorId,
      'supplier_name': purchase.supplierName,
      'purchase_date': purchase.purchaseDate.toIso8601String().split('T')[0],
      'total_amount': purchase.totalAmount,
      'notes': purchase.notes,
    }).select();

    final newPurchase = Purchase.fromJson(
      purchaseRows.first as Map<String, dynamic>,
    );

    // Insert items
    for (final item in items) {
      await _client.from('purchase_items').insert({
        'purchase_id': newPurchase.id,
        'product_id': item.productId,
        'quantity': item.quantity,
        'price_per_unit': item.pricePerUnit,
        'total_price': item.totalPrice,
        'notes': item.notes,
      });

      // Update stock
      await _increaseStock(purchase.vendorId, item.productId, item.quantity);
    }

    return newPurchase;
  }

  Future<void> _increaseStock(
    String vendorId,
    String productId,
    double quantity,
  ) async {
    final existing = await _client
        .from('stock')
        .select('id, quantity')
        .eq('vendor_id', vendorId)
        .eq('product_id', productId);

    if (existing.isEmpty) {
      final inserted = await _client
          .from('stock')
          .insert({
            'vendor_id': vendorId,
            'product_id': productId,
            'quantity': quantity,
          })
          .select('id');

      await _client.from('stock_movements').insert({
        'stock_id': inserted.first['id'],
        'movement_type': 'purchase',
        'quantity': quantity,
        'reference_type': 'purchase',
        'notes': 'Purchase received',
      });
    } else {
      final stockId = existing.first['id'].toString();
      final current = double.parse(existing.first['quantity'].toString());
      await _client
          .from('stock')
          .update({
            'quantity': current + quantity,
            'last_updated': DateTime.now().toIso8601String(),
          })
          .eq('id', stockId);

      await _client.from('stock_movements').insert({
        'stock_id': stockId,
        'movement_type': 'purchase',
        'quantity': quantity,
        'reference_type': 'purchase',
        'notes': 'Purchase received',
      });
    }
  }

  /// Delete purchase and reverse stock.
  Future<void> deletePurchase(String purchaseId) async {
    try {
      final items = await _client
          .from('purchase_items')
          .select('product_id, quantity')
          .eq('purchase_id', purchaseId);

      for (final item in items) {
        final existing = await _client
            .from('stock')
            .select('id, quantity')
            .eq('product_id', item['product_id']);
        if (existing.isNotEmpty) {
          final current = double.parse(existing.first['quantity'].toString());
          await _client
              .from('stock')
              .update({'quantity': current - (item['quantity'] ?? 0)})
              .eq('id', existing.first['id']);
        }
      }

      await _client.from('purchases').delete().eq('id', purchaseId);
    } catch (e) {
      debugPrint('❌ deletePurchase failed: $e');
    }
  }

  /// Purchase stats for a given date.
  Future<Map<String, dynamic>> getPurchaseStats(
    String vendorId,
    DateTime date,
  ) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final rows = await _client
          .from('purchases')
          .select('total_amount')
          .eq('vendor_id', vendorId)
          .eq('purchase_date', dateStr);
      final list = rows;
      final total = list.fold<double>(
        0,
        (s, r) => s + (r['total_amount'] ?? 0),
      );
      return {'totalPurchases': list.length, 'totalAmount': total};
    } catch (e) {
      debugPrint('❌ getPurchaseStats failed: $e');
      return {'totalPurchases': 0, 'totalAmount': 0.0};
    }
  }

  Map<String, dynamic> _flattenItem(Map<String, dynamic> r) {
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
