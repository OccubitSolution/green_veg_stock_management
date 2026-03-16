import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:green_veg_stock_management/app/data/models/phase2_models.dart';
import 'package:green_veg_stock_management/app/data/providers/database_provider.dart';

/// Sales Repository – sales recording and delivery management via Supabase REST.
class SalesRepository {
  final DatabaseProvider _db = DatabaseProvider.instance;
  SupabaseClient get _client => _db.client;

  Future<List<Sale>> getSales(
    String vendorId, {
    DateTime? startDate,
    DateTime? endDate,
    SaleStatus? status,
    int limit = 100,
  }) async {
    try {
      // Build all filters BEFORE order/limit (Supabase requires this)
      var q = _client
          .from('sales')
          .select('*, customers(name, type)')
          .eq('vendor_id', vendorId);

      if (startDate != null) {
        q = q.gte('sale_date', startDate.toIso8601String().split('T')[0]);
      }
      if (endDate != null) {
        q = q.lte('sale_date', endDate.toIso8601String().split('T')[0]);
      }
      if (status != null) {
        q = q.eq('status', status.value);
      }

      final rows = await q.order('sale_date', ascending: false).limit(limit);
      return rows
          .map((r) => Sale.fromJson(_flattenSale(r as Map<String, dynamic>)))
          .toList();
    } catch (e) {
      debugPrint('❌ getSales failed: $e');
      return [];
    }
  }

  Future<Sale?> getSaleById(String saleId) async {
    try {
      final rows = await _client
          .from('sales')
          .select('*, customers(name, type)')
          .eq('id', saleId)
          .limit(1);
      if (rows.isEmpty) return null;
      return Sale.fromJson(_flattenSale(rows.first as Map<String, dynamic>));
    } catch (e) {
      debugPrint('❌ getSaleById failed: $e');
      return null;
    }
  }

  Future<List<SaleItem>> getSaleItems(String saleId) async {
    try {
      final rows = await _client
          .from('sale_items')
          .select('*, products(name_gu, name_en, units(symbol))')
          .eq('sale_id', saleId);
      return rows.map((r) {
        final flat = _flattenItem(r as Map<String, dynamic>);
        return SaleItem.fromJson(flat);
      }).toList();
    } catch (e) {
      debugPrint('❌ getSaleItems failed: $e');
      return [];
    }
  }

  /// Create a sale from an existing order.
  Future<Sale> createSaleFromOrder(
    String orderId,
    String vendorId,
    List<SaleItem> items, {
    String? deliveryNotes,
  }) async {
    // Fetch customer from the order
    final orderRows = await _client
        .from('orders')
        .select('customer_id')
        .eq('id', orderId)
        .limit(1);
    if (orderRows.isEmpty) throw Exception('Order not found');
    final customerId = orderRows.first['customer_id'].toString();

    double total = items.fold(0.0, (s, i) => s + (i.totalPrice ?? 0));

    // Create sale
    final saleRows = await _client.from('sales').insert({
      'order_id': orderId,
      'customer_id': customerId,
      'vendor_id': vendorId,
      'sale_date': DateTime.now().toIso8601String().split('T')[0],
      'total_amount': total,
      'status': 'pending',
      'delivery_notes': deliveryNotes,
    }).select();
    final newSale = Sale.fromJson(saleRows.first as Map<String, dynamic>);

    // Insert sale items & deduct stock
    for (final item in items) {
      await _client.from('sale_items').insert({
        'sale_id': newSale.id,
        'product_id': item.productId,
        'quantity': item.quantity,
        'price_per_unit': item.pricePerUnit,
        'total_price': item.totalPrice,
        'notes': item.notes,
      });
      await _deductStock(vendorId, item.productId, item.quantity);
    }

    // Mark order confirmed
    await _client
        .from('orders')
        .update({'status': 'confirmed'})
        .eq('id', orderId);

    return newSale;
  }

  Future<void> _deductStock(
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
            'quantity': -quantity,
          })
          .select('id');
      await _client.from('stock_movements').insert({
        'stock_id': inserted.first['id'],
        'movement_type': 'sale',
        'quantity': -quantity,
        'reference_type': 'sale',
        'notes': 'Sale - insufficient stock',
      });
    } else {
      final stockId = existing.first['id'].toString();
      final current = double.parse(existing.first['quantity'].toString());
      await _client
          .from('stock')
          .update({
            'quantity': current - quantity,
            'last_updated': DateTime.now().toIso8601String(),
          })
          .eq('id', stockId);
      await _client.from('stock_movements').insert({
        'stock_id': stockId,
        'movement_type': 'sale',
        'quantity': -quantity,
        'reference_type': 'sale',
        'notes': 'Sale completed',
      });
    }
  }

  Future<void> markDelivered(String saleId) async {
    await _client
        .from('sales')
        .update({
          'status': 'delivered',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', saleId);
  }

  Future<void> recordPayment(String saleId, double amount) async {
    final rows = await _client
        .from('sales')
        .select('paid_amount')
        .eq('id', saleId)
        .limit(1);
    if (rows.isEmpty) return;
    final current = double.parse(rows.first['paid_amount'].toString());
    await _client
        .from('sales')
        .update({
          'paid_amount': current + amount,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', saleId);
  }

  Future<Map<String, dynamic>> getSalesStats(
    String vendorId,
    DateTime date,
  ) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final rows = await _client
          .from('sales')
          .select('total_amount, paid_amount')
          .eq('vendor_id', vendorId)
          .eq('sale_date', dateStr);
      final list = rows;
      double revenue = list.fold(0.0, (s, r) => s + (r['total_amount'] ?? 0));
      double paid = list.fold(0.0, (s, r) => s + (r['paid_amount'] ?? 0));
      return {
        'totalSales': list.length,
        'totalRevenue': revenue,
        'totalPaid': paid,
        'totalPending': revenue - paid,
      };
    } catch (e) {
      debugPrint('❌ getSalesStats failed: $e');
      return {
        'totalSales': 0,
        'totalRevenue': 0.0,
        'totalPaid': 0.0,
        'totalPending': 0.0,
      };
    }
  }

  Future<List<Sale>> getPendingDeliveries(String vendorId) async {
    try {
      final rows = await _client
          .from('sales')
          .select('*, customers(name, type)')
          .eq('vendor_id', vendorId)
          .eq('status', 'pending')
          .order('sale_date');
      return rows
          .map((r) => Sale.fromJson(_flattenSale(r as Map<String, dynamic>)))
          .toList();
    } catch (e) {
      debugPrint('❌ getPendingDeliveries failed: $e');
      return [];
    }
  }

  Map<String, dynamic> _flattenSale(Map<String, dynamic> r) {
    final customer = r['customers'] as Map<String, dynamic>? ?? {};
    return {
      ...r,
      'customer_name': customer['name'],
      'customer_type': customer['type'],
    };
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
