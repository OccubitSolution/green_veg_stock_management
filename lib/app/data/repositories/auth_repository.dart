/// Auth Repository
///
/// Handles vendor authentication operations
library;

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import '../providers/database_provider.dart';
import '../models/models.dart';

class AuthRepository {
  final _db = DatabaseProvider.instance;

  /// Hash password using SHA256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Register new vendor
  Future<Vendor?> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      final passwordHash = _hashPassword(password);

      final result = await _db.insert('vendors', {
        'email': email,
        'password_hash': passwordHash,
        'name': name,
        'phone': phone,
      });

      if (result != null) {
        return Vendor.fromJson(result);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Registration failed: $e');
      rethrow;
    }
  }

  /// Login vendor
  Future<Vendor?> login({
    required String email,
    required String password,
  }) async {
    try {
      final passwordHash = _hashPassword(password);

      final result = await _db.query(
        '''
        SELECT * FROM vendors 
        WHERE email = @email 
        AND password_hash = @password_hash 
        AND is_active = true
      ''',
        parameters: {'email': email, 'password_hash': passwordHash},
      );

      if (result.isNotEmpty) {
        return Vendor.fromJson(result.first);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Login failed: $e');
      rethrow;
    }
  }

  /// Check if email exists
  Future<bool> emailExists(String email) async {
    try {
      final result = await _db.query(
        '''
        SELECT id FROM vendors WHERE email = @email
      ''',
        parameters: {'email': email},
      );

      return result.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Email check failed: $e');
      return false;
    }
  }

  /// Set PIN for vendor
  Future<bool> setPin(String vendorId, String pin) async {
    try {
      final pinHash = _hashPassword(pin);

      await _db.update(
        'vendors',
        {'pin_hash': pinHash},
        where: 'id = @id',
        whereParams: {'id': vendorId},
      );

      return true;
    } catch (e) {
      debugPrint('❌ Set PIN failed: $e');
      return false;
    }
  }

  /// Verify PIN
  Future<bool> verifyPin(String vendorId, String pin) async {
    try {
      final pinHash = _hashPassword(pin);

      final result = await _db.query(
        '''
        SELECT id FROM vendors 
        WHERE id = @id AND pin_hash = @pin_hash
      ''',
        parameters: {'id': vendorId, 'pin_hash': pinHash},
      );

      return result.isNotEmpty;
    } catch (e) {
      debugPrint('❌ PIN verification failed: $e');
      return false;
    }
  }

  /// Get vendor by ID
  Future<Vendor?> getVendor(String vendorId) async {
    try {
      final result = await _db.query(
        '''
        SELECT * FROM vendors WHERE id = @id
      ''',
        parameters: {'id': vendorId},
      );

      if (result.isNotEmpty) {
        return Vendor.fromJson(result.first);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Get vendor failed: $e');
      return null;
    }
  }

  /// Update vendor settings
  Future<bool> updateSettings(
    String vendorId,
    Map<String, dynamic> settings,
  ) async {
    try {
      await _db.query(
        '''
        UPDATE vendors 
        SET settings = @settings, updated_at = NOW()
        WHERE id = @id
      ''',
        parameters: {'id': vendorId, 'settings': settings},
      );

      return true;
    } catch (e) {
      debugPrint('❌ Update settings failed: $e');
      return false;
    }
  }
}
