import 'package:green_veg_stock_management/app/data/models/customer_order_models.dart';
import 'package:green_veg_stock_management/app/data/providers/database_provider.dart';
import 'package:postgres/postgres.dart';

/// Order Repository
/// Handles all database operations for orders and order items
class OrderRepository {
  final DatabaseProvider _db = DatabaseProvider.instance;

  /// Get orders for a specific date
  Future<List<Order>> getOrdersByDate(String vendorId, DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final result = await _db.query(
      '''
      SELECT 
        o.*,
        c.name as customer_name,
        c.type as customer_type
      FROM orders o
      JOIN customers c ON o.customer_id = c.id
      WHERE o.vendor_id = @vendorId 
      AND o.order_date = @dateStr
      ORDER BY c.name ASC
    ''',
      parameters: {'vendorId': vendorId, 'dateStr': dateStr},
    );

    return result.map((row) => Order.fromJson(row)).toList();
  }

  /// Get orders by customer
  Future<List<Order>> getOrdersByCustomer(
    String customerId, {
    int limit = 50,
  }) async {
    final result = await _db.query(
      '''
      SELECT 
        o.*,
        c.name as customer_name,
        c.type as customer_type
      FROM orders o
      JOIN customers c ON o.customer_id = c.id
      WHERE o.customer_id = @customerId
      ORDER BY o.order_date DESC
      LIMIT @limit
    ''',
      parameters: {'customerId': customerId, 'limit': limit},
    );

    return result.map((row) => Order.fromJson(row)).toList();
  }

  /// Get order by ID with items
  Future<Order?> getOrderById(String orderId) async {
    final result = await _db.query(
      '''
      SELECT 
        o.*,
        c.name as customer_name,
        c.type as customer_type
      FROM orders o
      JOIN customers c ON o.customer_id = c.id
      WHERE o.id = @orderId
    ''',
      parameters: {'orderId': orderId},
    );

    if (result.isEmpty) return null;
    return Order.fromJson(result.first);
  }

  /// Get order items for an order
  Future<List<OrderItem>> getOrderItems(String orderId) async {
    final result = await _db.query(
      '''
      SELECT 
        oi.*,
        p.name_gu as product_name_gu,
        p.name_en as product_name_en,
        u.symbol as unit_symbol,
        cat.name_en as category_name
      FROM order_items oi
      JOIN products p ON oi.product_id = p.id
      JOIN units u ON p.unit_id = u.id
      JOIN categories cat ON p.category_id = cat.id
      WHERE oi.order_id = @orderId
      ORDER BY cat.sort_order, p.name_en
    ''',
      parameters: {'orderId': orderId},
    );

    return result.map((row) => OrderItem.fromJson(row)).toList();
  }

  /// Create new order with items
  Future<Order> createOrder(Order order, List<OrderItem> items) async {
    return await _db.transaction((tx) async {
      // Insert order
      final orderResult = await tx.execute(
        Sql.named('''
        INSERT INTO orders (
          customer_id, vendor_id, order_date, status, notes
        ) VALUES (
          @customerId, @vendorId, @orderDate, @status, @notes
        )
        RETURNING *
      '''),
        parameters: {
          'customerId': order.customerId,
          'vendorId': order.vendorId,
          'orderDate': order.orderDate.toIso8601String().split('T')[0],
          'status': order.status.value,
          'notes': order.notes,
        },
      );

      final newOrder = Order.fromJson(orderResult.first.toColumnMap());

      // Insert order items
      for (final item in items) {
        await tx.execute(
          Sql.named('''
          INSERT INTO order_items (
            order_id, product_id, quantity, price_per_unit, notes
          ) VALUES (
            @orderId, @productId, @quantity, @pricePerUnit, @notes
          )
        '''),
          parameters: {
            'orderId': newOrder.id,
            'productId': item.productId,
            'quantity': item.quantity,
            'pricePerUnit': item.pricePerUnit,
            'notes': item.notes,
          },
        );
      }

      return newOrder;
    });
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _db.update(
      'orders',
      {'status': status.value},
      where: 'id = @orderId',
      whereParams: {'orderId': orderId},
    );
  }

  /// Delete order and its items
  Future<void> deleteOrder(String orderId) async {
    await _db.transaction((tx) async {
      await tx.execute(
        Sql.named('DELETE FROM order_items WHERE order_id = @orderId'),
        parameters: {'orderId': orderId},
      );
      await tx.execute(
        Sql.named('DELETE FROM orders WHERE id = @orderId'),
        parameters: {'orderId': orderId},
      );
    });
  }

  /// Get aggregated order items for a date
  /// This is the KEY function for generating purchase list
  Future<List<AggregatedOrderItem>> getAggregatedOrders(
    String vendorId,
    DateTime date,
  ) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final result = await _db.query(
      '''
      SELECT 
        p.id as product_id,
        p.name_gu as product_name_gu,
        p.name_en as product_name_en,
        u.symbol as unit_symbol,
        cat.name_en as category_name,
        SUM(oi.quantity) as total_quantity,
        COUNT(DISTINCT o.id) as order_count,
        json_agg(json_build_object(
          'order_id', o.id,
          'customer_name', c.name,
          'quantity', oi.quantity,
          'notes', oi.notes
        )) as item_details
      FROM orders o
      JOIN order_items oi ON o.id = oi.order_id
      JOIN products p ON oi.product_id = p.id
      JOIN units u ON p.unit_id = u.id
      JOIN categories cat ON p.category_id = cat.id
      JOIN customers c ON o.customer_id = c.id
      WHERE o.vendor_id = @vendorId 
      AND o.order_date = @dateStr
      AND o.status != 'cancelled'
      GROUP BY p.id, p.name_gu, p.name_en, u.symbol, cat.name_en
      ORDER BY cat.sort_order, p.name_en
    ''',
      parameters: {'vendorId': vendorId, 'dateStr': dateStr},
    );

    return result.map((row) {
      final json = row;
      final details = (json['item_details'] as List<dynamic>)
          .map(
            (d) => OrderItemDetail(
              orderId: d['order_id'],
              customerName: d['customer_name'],
              quantity: double.parse(d['quantity'].toString()),
              notes: d['notes'],
            ),
          )
          .toList();

      return AggregatedOrderItem(
        productId: json['product_id'],
        productNameGu: json['product_name_gu'],
        productNameEn: json['product_name_en'],
        unitSymbol: json['unit_symbol'],
        categoryName: json['category_name'],
        totalQuantity: double.parse(json['total_quantity'].toString()),
        orderCount: int.parse(json['order_count'].toString()),
        itemDetails: details,
      );
    }).toList();
  }

  /// Get order statistics for a date
  Future<Map<String, dynamic>> getOrderStats(
    String vendorId,
    DateTime date,
  ) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final result = await _db.query(
      '''
      SELECT 
        COUNT(DISTINCT o.id) as total_orders,
        COUNT(DISTINCT o.customer_id) as total_customers,
        SUM(oi.quantity) as total_items
      FROM orders o
      JOIN order_items oi ON o.id = oi.order_id
      WHERE o.vendor_id = @vendorId 
      AND o.order_date = @dateStr
      AND o.status != 'cancelled'
    ''',
      parameters: {'vendorId': vendorId, 'dateStr': dateStr},
    );

    final row = result.first;
    return {
      'totalOrders': int.parse(row['total_orders']?.toString() ?? '0'),
      'totalCustomers': int.parse(row['total_customers']?.toString() ?? '0'),
      'totalItems': double.parse(row['total_items']?.toString() ?? '0'),
    };
  }
}
