import 'package:green_veg_stock_management/app/data/models/phase2_models.dart';
import 'package:green_veg_stock_management/app/data/providers/database_provider.dart';

/// Inventory Repository
/// Handles stock management and tracking
class InventoryRepository {
  final DatabaseProvider _db = DatabaseProvider.instance;

  /// Get current stock for vendor
  Future<List<Stock>> getStock(String vendorId) async {
    final conn = await _db.connection;

    final result = await conn.execute(
      '''
      SELECT 
        s.*,
        p.name_gu as product_name_gu,
        p.name_en as product_name_en,
        u.symbol as unit_symbol,
        CASE 
          WHEN s.quantity <= 0 THEN 'out_of_stock'
          WHEN s.quantity <= s.min_stock_level THEN 'low_stock'
          ELSE 'in_stock'
        END as stock_status
      FROM stock s
      JOIN products p ON s.product_id = p.id
      JOIN units u ON p.unit_id = u.id
      WHERE s.vendor_id = @vendorId
      ORDER BY 
        CASE 
          WHEN s.quantity <= 0 THEN 0
          WHEN s.quantity <= s.min_stock_level THEN 1
          ELSE 2
        END,
        p.name_en
    ''',
      parameters: {'vendorId': vendorId},
    );

    return result.map((row) => Stock.fromJson(row.toColumnMap())).toList();
  }

  /// Get low stock items
  Future<List<Stock>> getLowStock(String vendorId) async {
    final conn = await _db.connection;

    final result = await conn.execute(
      '''
      SELECT 
        s.*,
        p.name_gu as product_name_gu,
        p.name_en as product_name_en,
        u.symbol as unit_symbol,
        'low_stock' as stock_status
      FROM stock s
      JOIN products p ON s.product_id = p.id
      JOIN units u ON p.unit_id = u.id
      WHERE s.vendor_id = @vendorId
      AND s.quantity <= s.min_stock_level
      AND s.quantity > 0
      ORDER BY s.quantity ASC
    ''',
      parameters: {'vendorId': vendorId},
    );

    return result.map((row) => Stock.fromJson(row.toColumnMap())).toList();
  }

  /// Get out of stock items
  Future<List<Stock>> getOutOfStock(String vendorId) async {
    final conn = await _db.connection;

    final result = await conn.execute(
      '''
      SELECT 
        s.*,
        p.name_gu as product_name_gu,
        p.name_en as product_name_en,
        u.symbol as unit_symbol,
        'out_of_stock' as stock_status
      FROM stock s
      JOIN products p ON s.product_id = p.id
      JOIN units u ON p.unit_id = u.id
      WHERE s.vendor_id = @vendorId
      AND s.quantity <= 0
      ORDER BY p.name_en
    ''',
      parameters: {'vendorId': vendorId},
    );

    return result.map((row) => Stock.fromJson(row.toColumnMap())).toList();
  }

  /// Get stock movement history
  Future<List<StockMovement>> getStockMovements(
    String stockId, {
    int limit = 50,
  }) async {
    final conn = await _db.connection;

    final result = await conn.execute(
      '''
      SELECT * FROM stock_movements
      WHERE stock_id = @stockId
      ORDER BY created_at DESC
      LIMIT @limit
    ''',
      parameters: {'stockId': stockId, 'limit': limit},
    );

    return result
        .map((row) => StockMovement.fromJson(row.toColumnMap()))
        .toList();
  }

  /// Update stock quantity (for adjustments)
  Future<void> adjustStock(
    String vendorId,
    String productId,
    double newQuantity,
    String reason,
  ) async {
    final conn = await _db.connection;

    await conn.runTx((tx) async {
      // Get or create stock
      final existing = await tx.execute(
        '''
        SELECT id, quantity FROM stock 
        WHERE vendor_id = @vendorId AND product_id = @productId
      ''',
        parameters: {'vendorId': vendorId, 'productId': productId},
      );

      String stockId;
      double oldQuantity;

      if (existing.isEmpty) {
        // Create new stock entry
        final result = await tx.execute(
          '''
          INSERT INTO stock (vendor_id, product_id, quantity)
          VALUES (@vendorId, @productId, @quantity)
          RETURNING id
        ''',
          parameters: {
            'vendorId': vendorId,
            'productId': productId,
            'quantity': newQuantity,
          },
        );
        stockId = result.first[0] as String;
        oldQuantity = 0;
      } else {
        stockId = existing.first[0] as String;
        oldQuantity = double.parse(existing.first[1].toString());

        // Update stock
        await tx.execute(
          '''
          UPDATE stock 
          SET quantity = @quantity,
              last_updated = CURRENT_TIMESTAMP
          WHERE id = @stockId
        ''',
          parameters: {'stockId': stockId, 'quantity': newQuantity},
        );
      }

      // Record movement
      final difference = newQuantity - oldQuantity;
      await tx.execute(
        '''
        INSERT INTO stock_movements (
          stock_id, movement_type, quantity, reference_type, notes
        ) VALUES (
          @stockId, 'adjustment', @quantity, 'adjustment', @notes
        )
      ''',
        parameters: {
          'stockId': stockId,
          'quantity': difference,
          'notes': reason,
        },
      );
    });
  }

  /// Record waste/damage
  Future<void> recordWaste(
    String stockId,
    double quantity,
    String reason,
  ) async {
    final conn = await _db.connection;

    await conn.runTx((tx) async {
      // Reduce stock
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
        INSERT INTO stock_movements (
          stock_id, movement_type, quantity, reference_type, notes
        ) VALUES (
          @stockId, 'waste', @quantity, 'waste', @notes
        )
      ''',
        parameters: {
          'stockId': stockId,
          'quantity': -quantity,
          'notes': reason,
        },
      );
    });
  }

  /// Get inventory stats
  Future<Map<String, dynamic>> getInventoryStats(String vendorId) async {
    final conn = await _db.connection;

    final result = await conn.execute(
      '''
      SELECT 
        COUNT(*) as total_products,
        COUNT(CASE WHEN quantity <= 0 THEN 1 END) as out_of_stock,
        COUNT(CASE WHEN quantity <= min_stock_level AND quantity > 0 THEN 1 END) as low_stock,
        COUNT(CASE WHEN quantity > min_stock_level THEN 1 END) as in_stock
      FROM stock
      WHERE vendor_id = @vendorId
    ''',
      parameters: {'vendorId': vendorId},
    );

    final row = result.first.toColumnMap();
    return {
      'totalProducts': int.parse(row['total_products'].toString()),
      'outOfStock': int.parse(row['out_of_stock'].toString()),
      'lowStock': int.parse(row['low_stock'].toString()),
      'inStock': int.parse(row['in_stock'].toString()),
    };
  }
}
