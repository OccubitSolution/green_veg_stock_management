/// App Controller
///
/// Global app state management
library;

import 'dart:ui';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AppController extends GetxController {
  final _storage = GetStorage();

  // Observables
  final RxString vendorId = ''.obs;
  final RxString vendorName = ''.obs;
  final RxBool isLoggedIn = false.obs;
  final RxBool isPinEnabled = false.obs;
  final RxString currentLanguage = 'gu'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    vendorId.value = _storage.read('vendor_id') ?? '';
    vendorName.value = _storage.read('vendor_name') ?? '';
    isLoggedIn.value = _storage.read('is_logged_in') ?? false;
    isPinEnabled.value = _storage.read('pin_enabled') ?? false;
    currentLanguage.value = _storage.read('language') ?? 'gu';
  }

  /// Set logged in vendor
  Future<void> setVendor({
    required String id,
    required String name,
    required String email,
  }) async {
    vendorId.value = id;
    vendorName.value = name;
    isLoggedIn.value = true;

    await _storage.write('vendor_id', id);
    await _storage.write('vendor_name', name);
    await _storage.write('vendor_email', email);
    await _storage.write('is_logged_in', true);
  }

  /// Enable PIN
  Future<void> enablePin() async {
    isPinEnabled.value = true;
    await _storage.write('pin_enabled', true);
  }

  /// Change language
  Future<void> changeLanguage(String langCode) async {
    currentLanguage.value = langCode;
    await _storage.write('language', langCode);
    Get.updateLocale(Locale(langCode));
  }

  /// Logout
  Future<void> logout() async {
    vendorId.value = '';
    vendorName.value = '';
    isLoggedIn.value = false;

    await _storage.remove('vendor_id');
    await _storage.remove('vendor_name');
    await _storage.remove('vendor_email');
    await _storage.write('is_logged_in', false);
  }
}
