import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:green_veg_stock_management/app/data/models/customer_order_models.dart';
import 'package:green_veg_stock_management/app/data/providers/database_provider.dart';

/// Order Repository – all database operations for orders via Supabase REST.
class OrderRepository {
  final DatabaseProvider _db = DatabaseProvider.instance;
  SupabaseClient get _client => _db.client;

  Future<List<Order>> getOrdersByDate(String vendorId, DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final rows = await _client
          .from('orders')
          .select('*, customers(name, type)')
          .eq('vendor_id', vendorId)
          .eq('order_date', dateStr)
          .order('order_date');
      return rows
          .map((r) => Order.fromJson(_flattenOrder(r as Map<String, dynamic>)))
          .toList();
    } catch (e) {
      debugPrint('❌ getOrdersByDate failed: $e');
      return [];
    }
  }

  Future<List<Order>> getOrdersByCustomer(
    String customerId, {
    int limit = 50,
  }) async {
    try {
      final rows = await _client
          .from('orders')
          .select('*, customers(name, type)')
          .eq('customer_id', customerId)
          .order('order_date', ascending: false)
          .limit(limit);
      return rows
          .map((r) => Order.fromJson(_flattenOrder(r as Map<String, dynamic>)))
          .toList();
    } catch (e) {
      debugPrint('❌ getOrdersByCustomer failed: $e');
      return [];
    }
  }

  Future<Order?> getOrderById(String orderId) async {
    try {
      final rows = await _client
          .from('orders')
          .select('*, customers(name, type)')
          .eq('id', orderId)
          .limit(1);
      if (rows.isEmpty) return null;
      return Order.fromJson(_flattenOrder(rows.first as Map<String, dynamic>));
    } catch (e) {
      debugPrint('❌ getOrderById failed: $e');
      return null;
    }
  }

  Future<List<OrderItem>> getOrderItems(String orderId) async {
    try {
      final rows = await _client
          .from('order_items')
          .select(
            '*, products(name_gu, name_en, units(symbol), categories(name_en))',
          )
          .eq('order_id', orderId);
      return rows.map((r) {
        final product = r['products'] as Map<String, dynamic>? ?? {};
        final unit = product['units'] as Map<String, dynamic>? ?? {};
        final cat = product['categories'] as Map<String, dynamic>? ?? {};
        return OrderItem.fromJson({
          ...r,
          'product_name_gu': product['name_gu'],
          'product_name_en': product['name_en'],
          'unit_symbol': unit['symbol'],
          'category_name': cat['name_en'],
        });
      }).toList();
    } catch (e) {
      debugPrint('❌ getOrderItems failed: $e');
      return [];
    }
  }

  Future<Order> createOrder(Order order, List<OrderItem> items) async {
    final orderRows = await _client.from('orders').insert({
      'customer_id': order.customerId,
      'vendor_id': order.vendorId,
      'order_date': order.orderDate.toIso8601String().split('T')[0],
      'status': order.status.value,
      'notes': order.notes,
    }).select();
    final newOrder = Order.fromJson(orderRows.first as Map<String, dynamic>);

    for (final item in items) {
      await _client.from('order_items').insert({
        'order_id': newOrder.id,
        'product_id': item.productId,
        'quantity': item.quantity,
        'price_per_unit': item.pricePerUnit,
        'notes': item.notes,
      });
    }
    return newOrder;
  }

  Future<Order> updateOrder(
    String orderId,
    Order order,
    List<OrderItem> items,
  ) async {
    final orderRows = await _client
        .from('orders')
        .update({
          'customer_id': order.customerId,
          'order_date': order.orderDate.toIso8601String().split('T')[0],
          'status': order.status.value,
          'notes': order.notes,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', orderId)
        .select();
    if (orderRows.isEmpty) throw Exception('Order not found');
    final updatedOrder = Order.fromJson(
      orderRows.first as Map<String, dynamic>,
    );

    // Replace items
    await _client.from('order_items').delete().eq('order_id', orderId);
    for (final item in items) {
      await _client.from('order_items').insert({
        'order_id': orderId,
        'product_id': item.productId,
        'quantity': item.quantity,
        'price_per_unit': item.pricePerUnit,
        'notes': item.notes,
      });
    }
    return updatedOrder;
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _db.update(
      'orders',
      {'status': status.value},
      match: {'id': orderId},
    );
  }

  Future<void> deleteOrder(String orderId) async {
    await _client.from('order_items').delete().eq('order_id', orderId);
    await _client.from('orders').delete().eq('id', orderId);
  }

  /// Aggregated order items for a date (purchase list view).
  Future<List<AggregatedOrderItem>> getAggregatedOrders(
    String vendorId,
    DateTime date, {
    String? inviterVendorId,
  }) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final effectiveVendorId = inviterVendorId ?? vendorId;

      // Get orders for the date
      final orders = await _client
          .from('orders')
          .select('id, customer_id, customers(name)')
          .eq('vendor_id', effectiveVendorId)
          .eq('order_date', dateStr)
          .neq('status', 'cancelled');

      if ((orders as List).isEmpty) return [];

      final orderIds = orders.map((o) => o['id'].toString()).toList();

      final items = await _client
          .from('order_items')
          .select(
            '*, products(id, name_gu, name_en, units(symbol), categories(name_en, sort_order))',
          )
          .inFilter('order_id', orderIds);

      // Build customer map
      final customerMap = <String, String>{};
      for (final o in orders) {
        final name = (o['customers'] as Map?)?['name']?.toString() ?? '';
        customerMap[o['id'].toString()] = name;
      }

      // Aggregate by product
      final Map<String, Map<String, dynamic>> agg = {};
      for (final item in (items as List)) {
        final product = item['products'] as Map<String, dynamic>? ?? {};
        final pid = product['id']?.toString() ?? '';
        if (!agg.containsKey(pid)) {
          final unit = product['units'] as Map<String, dynamic>? ?? {};
          final cat = product['categories'] as Map<String, dynamic>? ?? {};
          agg[pid] = {
            'product_id': pid,
            'product_name_gu': product['name_gu'],
            'product_name_en': product['name_en'],
            'unit_symbol': unit['symbol'],
            'category_name': cat['name_en'],
            'category_sort': cat['sort_order'] ?? 0,
            'total_quantity': 0.0,
            'order_count': 0,
            'item_details': <OrderItemDetail>[],
          };
        }
        agg[pid]!['total_quantity'] =
            (agg[pid]!['total_quantity'] as double) + (item['quantity'] ?? 0);
        agg[pid]!['order_count'] = (agg[pid]!['order_count'] as int) + 1;
        (agg[pid]!['item_details'] as List<OrderItemDetail>).add(
          OrderItemDetail(
            orderId: item['order_id']?.toString() ?? '',
            customerName: customerMap[item['order_id']?.toString()] ?? '',
            quantity: double.tryParse(item['quantity']?.toString() ?? '0') ?? 0,
            notes: item['notes'],
          ),
        );
      }

      final result = agg.values.map((json) {
        return AggregatedOrderItem(
          productId: json['product_id'],
          productNameGu: json['product_name_gu'],
          productNameEn: json['product_name_en'],
          unitSymbol: json['unit_symbol'],
          categoryName: json['category_name'],
          totalQuantity: json['total_quantity'],
          orderCount: json['order_count'],
          itemDetails: json['item_details'],
        );
      }).toList();

      result.sort((a, b) {
        final catA = agg[a.productId]!['category_sort'] as int;
        final catB = agg[b.productId]!['category_sort'] as int;
        if (catA != catB) return catA.compareTo(catB);
        return (a.productNameEn ?? '').compareTo(b.productNameEn ?? '');
      });
      return result;
    } catch (e) {
      debugPrint('❌ getAggregatedOrders failed: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getOrderStats(
    String vendorId,
    DateTime date, {
    String? inviterVendorId,
  }) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final effectiveVendorId = inviterVendorId ?? vendorId;

      final orders = await _client
          .from('orders')
          .select('id, customer_id')
          .eq('vendor_id', effectiveVendorId)
          .eq('order_date', dateStr)
          .neq('status', 'cancelled');

      if ((orders as List).isEmpty) {
        return {'totalOrders': 0, 'totalCustomers': 0, 'totalItems': 0.0};
      }

      final orderIds = orders.map((o) => o['id'].toString()).toList();
      final items = await _client
          .from('order_items')
          .select('quantity')
          .inFilter('order_id', orderIds);

      final totalItems = (items as List).fold<double>(
        0,
        (s, i) => s + (i['quantity'] ?? 0),
      );
      final distinctCustomers = orders
          .map((o) => o['customer_id'].toString())
          .toSet()
          .length;

      return {
        'totalOrders': orders.length,
        'totalCustomers': distinctCustomers,
        'totalItems': totalItems,
      };
    } catch (e) {
      debugPrint('❌ getOrderStats failed: $e');
      return {'totalOrders': 0, 'totalCustomers': 0, 'totalItems': 0.0};
    }
  }

  Map<String, dynamic> _flattenOrder(Map<String, dynamic> r) {
    final customer = r['customers'] as Map<String, dynamic>? ?? {};
    return {
      ...r,
      'customer_name': customer['name'],
      'customer_type': customer['type'],
    };
  }
}
