import 'package:green_veg_stock_management/app/data/models/phase2_models.dart';
import 'package:green_veg_stock_management/app/data/providers/database_provider.dart';

/// Purchase Repository
/// Handles all database operations for purchases
class PurchaseRepository {
  final DatabaseProvider _db = DatabaseProvider.instance;

  /// Get purchases by date range
  Future<List<Purchase>> getPurchases(
    String vendorId, {
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    final conn = await _db.connection;

    String query = '''
      SELECT * FROM purchases 
      WHERE vendor_id = @vendorId
    ''';

    final Map<String, Object> params = {'vendorId': vendorId};

    if (startDate != null) {
      query += ' AND purchase_date >= @startDate';
      params['startDate'] = startDate.toIso8601String().split('T')[0];
    }

    if (endDate != null) {
      query += ' AND purchase_date <= @endDate';
      params['endDate'] = endDate.toIso8601String().split('T')[0];
    }

    query += ' ORDER BY purchase_date DESC, created_at DESC LIMIT @limit';
    params['limit'] = limit;

    final result = await conn.execute(query, parameters: params);
    return result.map((row) => Purchase.fromJson(row.toColumnMap())).toList();
  }

  /// Get purchase by ID with items
  Future<Purchase?> getPurchaseById(String purchaseId) async {
    final conn = await _db.connection;

    final result = await conn.execute(
      'SELECT * FROM purchases WHERE id = @purchaseId',
      parameters: {'purchaseId': purchaseId},
    );

    if (result.isEmpty) return null;
    return Purchase.fromJson(result.first.toColumnMap());
  }

  /// Get purchase items
  Future<List<PurchaseItem>> getPurchaseItems(String purchaseId) async {
    final conn = await _db.connection;

    final result = await conn.execute(
      '''
      SELECT 
        pi.*,
        p.name_gu as product_name_gu,
        p.name_en as product_name_en,
        u.symbol as unit_symbol
      FROM purchase_items pi
      JOIN products p ON pi.product_id = p.id
      JOIN units u ON p.unit_id = u.id
      WHERE pi.purchase_id = @purchaseId
      ORDER BY p.name_en
    ''',
      parameters: {'purchaseId': purchaseId},
    );

    return result
        .map((row) => PurchaseItem.fromJson(row.toColumnMap()))
        .toList();
  }

  /// Create purchase with items
  Future<Purchase> createPurchase(
    Purchase purchase,
    List<PurchaseItem> items,
  ) async {
    final conn = await _db.connection;

    return await conn.runTx((tx) async {
      // Insert purchase
      final purchaseResult = await tx.execute(
        '''
        INSERT INTO purchases (
          vendor_id, supplier_name, purchase_date, total_amount, notes
        ) VALUES (
          @vendorId, @supplierName, @purchaseDate, @totalAmount, @notes
        )
        RETURNING *
      ''',
        parameters: {
          'vendorId': purchase.vendorId,
          'supplierName': purchase.supplierName,
          'purchaseDate': purchase.purchaseDate.toIso8601String().split('T')[0],
          'totalAmount': purchase.totalAmount,
          'notes': purchase.notes,
        },
      );

      final newPurchase = Purchase.fromJson(purchaseResult.first.toColumnMap());

      // Insert items and update stock
      for (final item in items) {
        await tx.execute(
          '''
          INSERT INTO purchase_items (
            purchase_id, product_id, quantity, price_per_unit, total_price, notes
          ) VALUES (
            @purchaseId, @productId, @quantity, @pricePerUnit, @totalPrice, @notes
          )
        ''',
          parameters: {
            'purchaseId': newPurchase.id,
            'productId': item.productId,
            'quantity': item.quantity,
            'pricePerUnit': item.pricePerUnit,
            'totalPrice': item.totalPrice,
            'notes': item.notes,
          },
        );

        // Update stock
        await _updateStock(
          tx,
          purchase.vendorId,
          item.productId,
          item.quantity,
        );
      }

      return newPurchase;
    });
  }

  /// Update stock after purchase
  Future<void> _updateStock(
    dynamic tx,
    String vendorId,
    String productId,
    double quantity,
  ) async {
    // Check if stock exists
    final existing = await tx.execute(
      '''
      SELECT id FROM stock 
      WHERE vendor_id = @vendorId AND product_id = @productId
    ''',
      parameters: {'vendorId': vendorId, 'productId': productId},
    );

    if (existing.isEmpty) {
      // Create new stock entry
      await tx.execute(
        '''
        INSERT INTO stock (vendor_id, product_id, quantity)
        VALUES (@vendorId, @productId, @quantity)
      ''',
        parameters: {
          'vendorId': vendorId,
          'productId': productId,
          'quantity': quantity,
        },
      );
    } else {
      // Update existing stock
      await tx.execute(
        '''
        UPDATE stock 
        SET quantity = quantity + @quantity,
            last_updated = CURRENT_TIMESTAMP
        WHERE vendor_id = @vendorId AND product_id = @productId
      ''',
        parameters: {
          'vendorId': vendorId,
          'productId': productId,
          'quantity': quantity,
        },
      );
    }

    // Record stock movement
    final stockId = existing.isEmpty
        ? (await tx.execute(
            'SELECT id FROM stock WHERE vendor_id = @vendorId AND product_id = @productId',
            parameters: {'vendorId': vendorId, 'productId': productId},
          )).first[0]
        : existing.first[0];

    await tx.execute(
      '''
      INSERT INTO stock_movements (stock_id, movement_type, quantity, reference_type, notes)
      VALUES (@stockId, 'purchase', @quantity, 'purchase', 'Purchase received')
    ''',
      parameters: {'stockId': stockId, 'quantity': quantity},
    );
  }

  /// Delete purchase (and reverse stock)
  Future<void> deletePurchase(String purchaseId) async {
    final conn = await _db.connection;

    await conn.runTx((tx) async {
      // Get purchase items to reverse stock
      final items = await tx.execute(
        'SELECT product_id, quantity FROM purchase_items WHERE purchase_id = @purchaseId',
        parameters: {'purchaseId': purchaseId},
      );

      // Reverse stock for each item
      for (final row in items) {
        final productId = row[0] as String;
        final quantity = double.parse(row[1].toString());

        await tx.execute(
          '''
          UPDATE stock 
          SET quantity = quantity - @quantity
          WHERE product_id = @productId
        ''',
          parameters: {'productId': productId, 'quantity': quantity},
        );
      }

      // Delete purchase (cascade will delete items)
      await tx.execute(
        'DELETE FROM purchases WHERE id = @purchaseId',
        parameters: {'purchaseId': purchaseId},
      );
    });
  }

  /// Get purchase stats
  Future<Map<String, dynamic>> getPurchaseStats(
    String vendorId,
    DateTime date,
  ) async {
    final conn = await _db.connection;
    final dateStr = date.toIso8601String().split('T')[0];

    final result = await conn.execute(
      '''
      SELECT 
        COUNT(*) as total_purchases,
        COALESCE(SUM(total_amount), 0) as total_amount
      FROM purchases
      WHERE vendor_id = @vendorId AND purchase_date = @dateStr
    ''',
      parameters: {'vendorId': vendorId, 'dateStr': dateStr},
    );

    final row = result.first.toColumnMap();
    return {
      'totalPurchases': int.parse(row['total_purchases'].toString()),
      'totalAmount': double.parse(row['total_amount'].toString()),
    };
  }
}
