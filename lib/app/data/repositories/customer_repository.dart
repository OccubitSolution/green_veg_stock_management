import 'package:green_veg_stock_management/app/data/models/customer_order_models.dart';
import 'package:green_veg_stock_management/app/data/providers/database_provider.dart';

/// Customer Repository
/// Handles all database operations for customers
class CustomerRepository {
  final DatabaseProvider _db = DatabaseProvider.instance;

  /// Get all customers for a vendor
  Future<List<Customer>> getCustomers(
    String vendorId, {
    bool activeOnly = true,
  }) async {
    final conn = await _db.connection;

    String query =
        '''
      SELECT * FROM customers 
      WHERE vendor_id = @vendorId
      ${activeOnly ? 'AND is_active = true' : ''}
      ORDER BY name ASC
    ''';

    final result = await conn.execute(
      query,
      parameters: {'vendorId': vendorId},
    );

    return result.map((row) => Customer.fromJson(row.toColumnMap())).toList();
  }

  /// Get customer by ID
  Future<Customer?> getCustomerById(String id) async {
    final conn = await _db.connection;

    final result = await conn.execute(
      'SELECT * FROM customers WHERE id = @id',
      parameters: {'id': id},
    );

    if (result.isEmpty) return null;
    return Customer.fromJson(result.first.toColumnMap());
  }

  /// Create new customer
  Future<Customer> createCustomer(Customer customer) async {
    final conn = await _db.connection;

    final result = await conn.execute(
      '''
      INSERT INTO customers (
        vendor_id, name, contact_person, phone, email, 
        address, type, notes, is_active
      ) VALUES (
        @vendorId, @name, @contactPerson, @phone, @email,
        @address, @type, @notes, @isActive
      )
      RETURNING *
    ''',
      parameters: {
        'vendorId': customer.vendorId,
        'name': customer.name,
        'contactPerson': customer.contactPerson,
        'phone': customer.phone,
        'email': customer.email,
        'address': customer.address,
        'type': customer.type.value,
        'notes': customer.notes,
        'isActive': customer.isActive,
      },
    );

    return Customer.fromJson(result.first.toColumnMap());
  }

  /// Update customer
  Future<Customer> updateCustomer(Customer customer) async {
    final conn = await _db.connection;

    final result = await conn.execute(
      '''
      UPDATE customers SET
        name = @name,
        contact_person = @contactPerson,
        phone = @phone,
        email = @email,
        address = @address,
        type = @type,
        notes = @notes,
        is_active = @isActive,
        updated_at = CURRENT_TIMESTAMP
      WHERE id = @id
      RETURNING *
    ''',
      parameters: {
        'id': customer.id,
        'name': customer.name,
        'contactPerson': customer.contactPerson,
        'phone': customer.phone,
        'email': customer.email,
        'address': customer.address,
        'type': customer.type.value,
        'notes': customer.notes,
        'isActive': customer.isActive,
      },
    );

    return Customer.fromJson(result.first.toColumnMap());
  }

  /// Soft delete customer (set is_active = false)
  Future<void> deleteCustomer(String id) async {
    final conn = await _db.connection;

    await conn.execute(
      'UPDATE customers SET is_active = false, updated_at = CURRENT_TIMESTAMP WHERE id = @id',
      parameters: {'id': id},
    );
  }

  /// Search customers by name or phone
  Future<List<Customer>> searchCustomers(String vendorId, String query) async {
    final conn = await _db.connection;

    final result = await conn.execute(
      '''
      SELECT * FROM customers 
      WHERE vendor_id = @vendorId 
      AND is_active = true
      AND (
        name ILIKE @query 
        OR phone ILIKE @query 
        OR contact_person ILIKE @query
      )
      ORDER BY name ASC
    ''',
      parameters: {'vendorId': vendorId, 'query': '%$query%'},
    );

    return result.map((row) => Customer.fromJson(row.toColumnMap())).toList();
  }

  /// Get customer count
  Future<int> getCustomerCount(String vendorId) async {
    final conn = await _db.connection;

    final result = await conn.execute(
      'SELECT COUNT(*) as count FROM customers WHERE vendor_id = @vendorId AND is_active = true',
      parameters: {'vendorId': vendorId},
    );

    return int.parse(result.first[0].toString());
  }
}
