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
    String query =
        '''
      SELECT * FROM customers 
      WHERE vendor_id = @vendorId
      ${activeOnly ? 'AND is_active = true' : ''}
      ORDER BY name ASC
    ''';

    final result = await _db.query(query, parameters: {'vendorId': vendorId});

    return result.map((row) => Customer.fromJson(row)).toList();
  }

  /// Get customer by ID
  Future<Customer?> getCustomerById(String id) async {
    final result = await _db.query(
      'SELECT * FROM customers WHERE id = @id',
      parameters: {'id': id},
    );

    if (result.isEmpty) return null;
    return Customer.fromJson(result.first);
  }

  /// Create new customer
  Future<Customer> createCustomer(Customer customer) async {
    final data = {
      'vendor_id': customer.vendorId,
      'name': customer.name,
      'contact_person': customer.contactPerson,
      'phone': customer.phone,
      'email': customer.email,
      'address': customer.address,
      'type': customer.type.value,
      'notes': customer.notes,
      'is_active': customer.isActive,
    };

    final result = await _db.insert('customers', data);
    return Customer.fromJson(result!);
  }

  /// Update customer
  Future<Customer> updateCustomer(Customer customer) async {
    final data = {
      'name': customer.name,
      'contact_person': customer.contactPerson,
      'phone': customer.phone,
      'email': customer.email,
      'address': customer.address,
      'type': customer.type.value,
      'notes': customer.notes,
      'is_active': customer.isActive,
    };

    final result = await _db.update(
      'customers',
      data,
      where: 'id = @id',
      whereParams: {'id': customer.id},
    );

    return Customer.fromJson(result.first);
  }

  /// Soft delete customer (set is_active = false)
  Future<void> deleteCustomer(String id) async {
    await _db.softDelete(
      'customers',
      where: 'id = @id',
      whereParams: {'id': id},
    );
  }

  /// Search customers by name or phone
  Future<List<Customer>> searchCustomers(String vendorId, String query) async {
    final result = await _db.query(
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

    return result.map((row) => Customer.fromJson(row)).toList();
  }

  /// Get customer count
  Future<int> getCustomerCount(String vendorId) async {
    final result = await _db.query(
      'SELECT COUNT(*) as count FROM customers WHERE vendor_id = @vendorId AND is_active = true',
      parameters: {'vendorId': vendorId},
    );

    return int.parse(result.first['count'].toString());
  }
}
