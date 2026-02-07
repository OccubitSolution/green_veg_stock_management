/// Settings Controller
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../controllers/app_controller.dart';
import '../../../routes/app_routes.dart';

class SettingsController extends GetxController {
  final _storage = GetStorage();
  final AppController _appController = Get.find<AppController>();

  // Observable States
  final vendorName = ''.obs;
  final vendorEmail = ''.obs;
  final currentLang = 'gu'.obs;
  final pinEnabled = false.obs;
  final darkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    vendorName.value = _storage.read('vendor_name') ?? '';
    vendorEmail.value = _storage.read('vendor_email') ?? '';
    currentLang.value = _storage.read('language') ?? 'gu';
    pinEnabled.value = _storage.read('pin_enabled') ?? false;
    darkMode.value = _storage.read('dark_mode') ?? false;
  }

  void changeLanguage(String lang) {
    currentLang.value = lang;
    Get.updateLocale(Locale(lang));
    _storage.write('language', lang);
    _appController.changeLanguage(lang);
  }

  void togglePinLock(bool value) {
    pinEnabled.value = value;
    _storage.write('pin_enabled', value);

    if (value) {
      // Navigate to PIN setup if enabling
      Get.toNamed(AppRoutes.pinSetup);
    }
  }

  void toggleDarkMode(bool value) {
    darkMode.value = value;
    _storage.write('dark_mode', value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> logout() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('logout'.tr),
        content: Text('logout_confirm'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('logout'.tr),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _appController.logout();
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
