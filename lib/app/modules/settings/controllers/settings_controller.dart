/// Settings Controller
library;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import '../../../controllers/app_controller.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_routes.dart';

class SettingsController extends GetxController {
  final _storage = GetStorage();
  final AppController _appController = Get.find<AppController>();
  final AuthRepository _authRepository = AuthRepository();

  // Observable States
  final vendorName = ''.obs;
  final vendorEmail = ''.obs;
  final currentLang = 'gu'.obs;
  final darkMode = false.obs;
  final inviteCode = ''.obs;
  final appVersion = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    loadInviteCode();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    appVersion.value = info.version;
  }

  void _loadSettings() {
    vendorName.value = _storage.read('vendor_name') ?? '';
    vendorEmail.value = _storage.read('vendor_email') ?? '';
    currentLang.value = _storage.read('language') ?? 'gu';
    darkMode.value = _storage.read('dark_mode') ?? false;
  }

  void changeLanguage(String lang) {
    currentLang.value = lang;
    Get.updateLocale(Locale(lang));
    _storage.write('language', lang);
    _appController.changeLanguage(lang);
  }

  void toggleDarkMode(bool value) {
    darkMode.value = value;
    _storage.write('dark_mode', value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> generateInviteCode() async {
    try {
      final vendorId = _appController.vendorId.value;
      if (vendorId.isEmpty) {
        Get.snackbar('error'.tr, 'vendor_id_not_found'.tr);
        return;
      }

      final code = await _authRepository.generateInviteCode(vendorId);
      if (code != null) {
        inviteCode.value = code;
        Get.snackbar('success'.tr, 'invite_code_generated'.tr);
      } else {
        Get.snackbar('error'.tr, 'failed_to_generate_invite'.tr);
      }
    } catch (e) {
      Get.snackbar('error'.tr, 'something_went_wrong'.tr);
    }
  }

  Future<void> loadInviteCode() async {
    try {
      final vendorId = _appController.vendorId.value;
      if (vendorId.isEmpty) return;

      final vendor = await _authRepository.getVendor(vendorId);
      if (vendor != null && vendor.inviteCode != null) {
        inviteCode.value = vendor.inviteCode!;
      }
    } catch (e) {
      debugPrint('Error loading invite code: $e');
    }
  }

  void shareInviteCode() {
    if (inviteCode.value.isEmpty) {
      Get.snackbar('error'.tr, 'generate_invite_first'.tr);
      return;
    }
    Share.share(
      '${'invite_share_message'.tr} ${inviteCode.value}',
      subject: 'invite_share_subject'.tr,
    );
  }

  void copyInviteCode() {
    if (inviteCode.value.isEmpty) {
      Get.snackbar('error'.tr, 'generate_invite_first'.tr);
      return;
    }
    Clipboard.setData(ClipboardData(text: inviteCode.value));
    Get.snackbar('copied'.tr, 'invite_code_copied'.tr);
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