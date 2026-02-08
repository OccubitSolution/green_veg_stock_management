import 'package:green_veg_stock_management/app/data/models/phase2_models.dart';
import 'package:green_veg_stock_management/app/data/providers/database_provider.dart';

/// Sales Repository
/// Handles sales recording and delivery management
class SalesRepository {
  final DatabaseProvider _db = DatabaseProvider.instance;

  /// Get sales by date range
  Future<List<Sale>> getSales(
    String vendorId, {
    DateTime? startDate,
    DateTime? endDate,
    SaleStatus? status,
    int limit = 100,
  }) async {
    final conn = await _db.connection;

    String query = '''
      SELECT 
        s.*,
        c.name as customer_name,
        c.type as customer_type
      FROM sales s
      JOIN customers c ON s.customer_id = c.id
      WHERE s.vendor_id = @vendorId
    ''';

    final Map<String, Object> params = {'vendorId': vendorId};

    if (startDate != null) {
      query += ' AND s.sale_date >= @startDate';
      params['startDate'] = startDate.toIso8601String().split('T')[0];
    }

    if (endDate != null) {
      query += ' AND s.sale_date <= @endDate';
      params['endDate'] = endDate.toIso8601String().split('T')[0];
    }

    if (status != null) {
      query += ' AND s.status = @status';
      params['status'] = status.value;
    }

    query += ' ORDER BY s.sale_date DESC, s.created_at DESC LIMIT @limit';
    params['limit'] = limit;

    final result = await conn.execute(query, parameters: params);
    return result.map((row) => Sale.fromJson(row.toColumnMap())).toList();
  }

  /// Get sale by ID with items
  Future<Sale?> getSaleById(String saleId) async {
    final conn = await _db.connection;

    final result = await conn.execute(
      '''
      SELECT 
        s.*,
        c.name as customer_name,
        c.type as customer_type
      FROM sales s
      JOIN customers c ON s.customer_id = c.id
      WHERE s.id = @saleId
    ''',
      parameters: {'saleId': saleId},
    );

    if (result.isEmpty) return null;
    return Sale.fromJson(result.first.toColumnMap());
  }

  /// Get sale items
  Future<List<SaleItem>> getSaleItems(String saleId) async {
    final conn = await _db.connection;

    final result = await conn.execute(
      '''
      SELECT 
        si.*,
        p.name_gu as product_name_gu,
        p.name_en as product_name_en,
        u.symbol as unit_symbol
      FROM sale_items si
      JOIN products p ON si.product_id = p.id
      JOIN units u ON p.unit_id = u.id
      WHERE si.sale_id = @saleId
      ORDER BY p.name_en
    ''',
      parameters: {'saleId': saleId},
    );

    return result.map((row) => SaleItem.fromJson(row.toColumnMap())).toList();
  }

  /// Create sale from order
  Future<Sale> createSaleFromOrder(
    String orderId,
    String vendorId,
    List<SaleItem> items, {
    String? deliveryNotes,
  }) async {
    final conn = await _db.connection;

    return await conn.runTx((tx) async {
      // Get order details
      final orderResult = await tx.execute(
        'SELECT customer_id FROM orders WHERE id = @orderId',
        parameters: {'orderId': orderId},
      );

      if (orderResult.isEmpty) {
        throw Exception('Order not found');
      }

      final customerId = orderResult.first[0] as String;

      // Calculate total
      double totalAmount = 0;
      for (final item in items) {
        totalAmount += (item.totalPrice ?? 0);
      }

      // Create sale
      final saleResult = await tx.execute(
        '''
        INSERT INTO sales (
          order_id, customer_id, vendor_id, sale_date, 
          total_amount, status, delivery_notes
        ) VALUES (
          @orderId, @customerId, @vendorId, CURRENT_DATE,
          @totalAmount, 'pending', @deliveryNotes
        )
        RETURNING *
      ''',
        parameters: {
          'orderId': orderId,
          'customerId': customerId,
          'vendorId': vendorId,
          'totalAmount': totalAmount,
          'deliveryNotes': deliveryNotes,
        },
      );

      final newSale = Sale.fromJson(saleResult.first.toColumnMap());

      // Insert items and deduct stock
      for (final item in items) {
        await tx.execute(
          '''
          INSERT INTO sale_items (
            sale_id, product_id, quantity, price_per_unit, total_price, notes
          ) VALUES (
            @saleId, @productId, @quantity, @pricePerUnit, @totalPrice, @notes
          )
        ''',
          parameters: {
            'saleId': newSale.id,
            'productId': item.productId,
            'quantity': item.quantity,
            'pricePerUnit': item.pricePerUnit,
            'totalPrice': item.totalPrice,
            'notes': item.notes,
          },
        );

        // Deduct from stock
        await _deductStock(tx, vendorId, item.productId, item.quantity);
      }

      // Update order status
      await tx.execute(
        "UPDATE orders SET status = 'confirmed' WHERE id = @orderId",
        parameters: {'orderId': orderId},
      );

      return newSale;
    });
  }

  /// Deduct stock after sale
  Future<void> _deductStock(
    dynamic tx,
    String vendorId,
    String productId,
    double quantity,
  ) async {
    // Get stock
    final stockResult = await tx.execute(
      '''
      SELECT id, quantity FROM stock 
      WHERE vendor_id = @vendorId AND product_id = @productId
    ''',
      parameters: {'vendorId': vendorId, 'productId': productId},
    );

    if (stockResult.isEmpty) {
      // Create negative stock (oversold)
      final newStock = await tx.execute(
        '''
        INSERT INTO stock (vendor_id, product_id, quantity)
        VALUES (@vendorId, @productId, @quantity)
        RETURNING id
      ''',
        parameters: {
          'vendorId': vendorId,
          'productId': productId,
          'quantity': -quantity,
        },
      );

      // Record movement
      await tx.execute(
        '''
        INSERT INTO stock_movements (stock_id, movement_type, quantity, reference_type, notes)
        VALUES (@stockId, 'sale', @quantity, 'sale', 'Sale - insufficient stock')
      ''',
        parameters: {'stockId': newStock.first[0], 'quantity': -quantity},
      );
    } else {
      final stockId = stockResult.first[0] as String;

      // Update stock
      await tx.execute(
        '''
        UPDATE stock 
        SET quantity = quantity - @quantity,
            last_updated = CURRENT_TIMESTAMP
        WHERE id = @stockId
      ''',
        parameters: {'stockId': stockId, 'quantity': quantity},
      );

      // Record movement
      await tx.execute(
        '''
        INSERT INTO stock_movements (stock_id, movement_type, quantity, reference_type, notes)
        VALUES (@stockId, 'sale', @quantity, 'sale', 'Sale completed')
      ''',
        parameters: {'stockId': stockId, 'quantity': -quantity},
      );
    }
  }

  /// Mark sale as delivered
  Future<void> markDelivered(String saleId) async {
    final conn = await _db.connection;

    await conn.execute(
      '''
      UPDATE sales 
      SET status = 'delivered', updated_at = CURRENT_TIMESTAMP
      WHERE id = @saleId
    ''',
      parameters: {'saleId': saleId},
    );
  }

  /// Record payment
  Future<void> recordPayment(String saleId, double amount) async {
    final conn = await _db.connection;

    await conn.execute(
      '''
      UPDATE sales 
      SET paid_amount = paid_amount + @amount,
          updated_at = CURRENT_TIMESTAMP
      WHERE id = @saleId
    ''',
      parameters: {'saleId': saleId, 'amount': amount},
    );
  }

  /// Get sales stats
  Future<Map<String, dynamic>> getSalesStats(
    String vendorId,
    DateTime date,
  ) async {
    final conn = await _db.connection;
    final dateStr = date.toIso8601String().split('T')[0];

    final result = await conn.execute(
      '''
      SELECT 
        COUNT(*) as total_sales,
        COALESCE(SUM(total_amount), 0) as total_revenue,
        COALESCE(SUM(paid_amount), 0) as total_paid,
        COALESCE(SUM(total_amount - paid_amount), 0) as total_pending
      FROM sales
      WHERE vendor_id = @vendorId AND sale_date = @dateStr
    ''',
      parameters: {'vendorId': vendorId, 'dateStr': dateStr},
    );

    final row = result.first.toColumnMap();
    return {
      'totalSales': int.parse(row['total_sales'].toString()),
      'totalRevenue': double.parse(row['total_revenue'].toString()),
      'totalPaid': double.parse(row['total_paid'].toString()),
      'totalPending': double.parse(row['total_pending'].toString()),
    };
  }

  /// Get pending deliveries
  Future<List<Sale>> getPendingDeliveries(String vendorId) async {
    final conn = await _db.connection;

    final result = await conn.execute(
      '''
      SELECT 
        s.*,
        c.name as customer_name,
        c.type as customer_type
      FROM sales s
      JOIN customers c ON s.customer_id = c.id
      WHERE s.vendor_id = @vendorId
      AND s.status = 'pending'
      ORDER BY s.sale_date ASC
    ''',
      parameters: {'vendorId': vendorId},
    );

    return result.map((row) => Sale.fromJson(row.toColumnMap())).toList();
  }
}
