/// Auth Repository
///
/// Handles vendor authentication operations via Supabase REST.
library;

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/database_provider.dart';
import '../models/models.dart';

class AuthRepository {
  final DatabaseProvider _db = DatabaseProvider.instance;
  SupabaseClient get _client => _db.client;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<Vendor?> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      final result = await _db.insert('vendors', {
        'email': email,
        'password_hash': _hashPassword(password),
        'name': name,
        'phone': phone,
      });
      return result != null ? Vendor.fromJson(result) : null;
    } catch (e) {
      debugPrint('❌ Registration failed: $e');
      rethrow;
    }
  }

  Future<Vendor?> login({
    required String email,
    required String password,
  }) async {
    try {
      final rows = await _client
          .from('vendors')
          .select()
          .eq('email', email)
          .eq('password_hash', _hashPassword(password))
          .eq('is_active', true)
          .limit(1);
      if (rows.isEmpty) return null;
      return Vendor.fromJson(rows.first);
    } catch (e) {
      debugPrint('❌ Login failed: $e');
      rethrow;
    }
  }

  Future<bool> emailExists(String email) async {
    try {
      final rows = await _client
          .from('vendors')
          .select('id')
          .eq('email', email)
          .limit(1);
      return rows.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Email check failed: $e');
      return false;
    }
  }

  Future<bool> setPin(String vendorId, String pin) async {
    try {
      await _db.update(
        'vendors',
        {'pin_hash': _hashPassword(pin)},
        match: {'id': vendorId},
      );
      return true;
    } catch (e) {
      debugPrint('❌ Set PIN failed: $e');
      return false;
    }
  }

  Future<bool> verifyPin(String vendorId, String pin) async {
    try {
      final rows = await _client
          .from('vendors')
          .select('id')
          .eq('id', vendorId)
          .eq('pin_hash', _hashPassword(pin))
          .limit(1);
      return rows.isNotEmpty;
    } catch (e) {
      debugPrint('❌ PIN verification failed: $e');
      return false;
    }
  }

  Future<Vendor?> getVendor(String vendorId) async {
    try {
      final rows = await _client
          .from('vendors')
          .select()
          .eq('id', vendorId)
          .limit(1);
      if (rows.isEmpty) return null;
      return Vendor.fromJson(rows.first);
    } catch (e) {
      debugPrint('❌ Get vendor failed: $e');
      return null;
    }
  }

  Future<bool> updateSettings(
    String vendorId,
    Map<String, dynamic> settings,
  ) async {
    try {
      await _db.update(
        'vendors',
        {'settings': settings},
        match: {'id': vendorId},
      );
      return true;
    } catch (e) {
      debugPrint('❌ Update settings failed: $e');
      return false;
    }
  }

  Future<String?> generateInviteCode(String adminVendorId) async {
    try {
      final code = DateTime.now().millisecondsSinceEpoch.toString().substring(
        5,
      );
      await _db.update(
        'vendors',
        {'invite_code': code},
        match: {'id': adminVendorId},
      );
      return code;
    } catch (e) {
      if (e.toString().contains('invite_code')) {
        debugPrint('⚠️ invite_code column missing, run migration SQL.');
        return null;
      }
      debugPrint('❌ Generate invite code failed: $e');
      return null;
    }
  }

  Future<Vendor?> getVendorByInviteCode(String code) async {
    try {
      final rows = await _client
          .from('vendors')
          .select()
          .eq('invite_code', code)
          .eq('is_active', true)
          .limit(1);
      if (rows.isEmpty) return null;
      return Vendor.fromJson(rows.first);
    } catch (e) {
      debugPrint('❌ Get vendor by invite code failed: $e');
      return null;
    }
  }

  Future<Vendor?> registerWithInvite({
    required String email,
    required String password,
    required String name,
    String? phone,
    required String inviteCode,
  }) async {
    try {
      final inviter = await getVendorByInviteCode(inviteCode);
      if (inviter == null) throw Exception('Invalid invite code');
      final result = await _db.insert('vendors', {
        'email': email,
        'password_hash': _hashPassword(password),
        'name': name,
        'phone': phone,
        'role': 'staff',
        'invited_by': inviter.id,
      });
      return result != null ? Vendor.fromJson(result) : null;
    } catch (e) {
      debugPrint('❌ Registration with invite failed: $e');
      rethrow;
    }
  }

  Future<Vendor?> getInviter(String vendorId) async {
    try {
      final staffRows = await _client
          .from('vendors')
          .select('invited_by')
          .eq('id', vendorId)
          .limit(1);
      if ((staffRows as List).isEmpty) return null;
      final invitedBy = staffRows.first['invited_by']?.toString();
      if (invitedBy == null) return null;
      return getVendor(invitedBy);
    } catch (e) {
      debugPrint('❌ Get inviter failed: $e');
      return null;
    }
  }
}
