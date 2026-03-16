import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:green_veg_stock_management/app/data/models/customer_order_models.dart';
import 'package:green_veg_stock_management/app/data/providers/database_provider.dart';

/// Customer Repository – all database operations for customers via Supabase REST.
class CustomerRepository {
  final DatabaseProvider _db = DatabaseProvider.instance;
  SupabaseClient get _client => _db.client;

  Future<List<Customer>> getCustomers(
    String vendorId, {
    bool activeOnly = true,
    bool forceRefresh = false,
  }) async {  
    try {
      var q = _client.from('customers').select().eq('vendor_id', vendorId);
      if (activeOnly) q = q.eq('is_active', true);

      final rows = await q;
      final customers = rows
          .map((r) => Customer.fromJson(r as Map<String, dynamic>))
          .toList();
      customers.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
      return customers;
    } catch (e) {
      debugPrint('❌ getCustomers failed: $e');
      return [];
    }
  }

  Future<Customer?> getCustomerById(String id) async {
    try {
      final rows = await _client
          .from('customers')
          .select()
          .eq('id', id)
          .limit(1);
      if (rows.isEmpty) return null;
      return Customer.fromJson(rows.first as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ getCustomerById failed: $e');
      return null;
    }
  }

  Future<Customer> createCustomer(Customer customer) async {
    final result = await _db.insert('customers', {
      'vendor_id': customer.vendorId,
      'name': customer.name,
      'contact_person': customer.contactPerson,
      'phone': customer.phone,
      'email': customer.email,
      'address': customer.address,
      'type': customer.type.value,
      'notes': customer.notes,
      'is_active': customer.isActive,
    });
    return Customer.fromJson(result!);
  }

  Future<Customer> updateCustomer(Customer customer) async {
    final result = await _db.update(
      'customers',
      {
        'name': customer.name,
        'contact_person': customer.contactPerson,
        'phone': customer.phone,
        'email': customer.email,
        'address': customer.address,
        'type': customer.type.value,
        'notes': customer.notes,
        'is_active': customer.isActive,
      },
      match: {'id': customer.id},
    );
    return Customer.fromJson(result.first);
  }

  Future<void> deleteCustomer(String id) async {
    await _db.softDelete('customers', match: {'id': id});
  }

  Future<List<Customer>> searchCustomers(String vendorId, String query) async {
    try {
      final rows = await _client
          .from('customers')
          .select()
          .eq('vendor_id', vendorId)
          .eq('is_active', true);

      final s = query.toLowerCase();
      final all = rows
          .map((r) => Customer.fromJson(r as Map<String, dynamic>))
          .toList();
      final filtered = all
          .where(
            (c) =>
                c.name.toLowerCase().contains(s) ||
                (c.phone?.toLowerCase().contains(s) ?? false) ||
                (c.contactPerson?.toLowerCase().contains(s) ?? false),
          )
          .toList();
      filtered.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
      return filtered;
    } catch (e) {
      debugPrint('❌ searchCustomers failed: $e');
      return [];
    }
  }

  Future<int> getCustomerCount(String vendorId) async {
    try {
      final rows = await _client
          .from('customers')
          .select('id')
          .eq('vendor_id', vendorId)
          .eq('is_active', true);
      return rows.length;
    } catch (e) {
      debugPrint('❌ getCustomerCount failed: $e');
      return 0;
    }
  }
}
