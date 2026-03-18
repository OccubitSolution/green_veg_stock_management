/// Splash Controller
library;

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../routes/app_routes.dart';
import '../../services/update_service.dart';

class SplashController extends GetxController {
  final _storage = GetStorage();
  final RxString appVersion = '...'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadVersion();
    _navigateToNextScreen();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    appVersion.value = info.version;
  }

  Future<void> _navigateToNextScreen() async {
    try {
      debugPrint('⏳ Waiting for splash animation...');
      await Future.delayed(const Duration(seconds: 2));

      final isLoggedIn = _storage.read('is_logged_in') ?? false;

      debugPrint('📊 isLoggedIn: $isLoggedIn');

      if (isLoggedIn) {
        debugPrint('🏠 Navigating to Dashboard...');
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        debugPrint('🔑 Navigating to Login...');
        Get.offAllNamed(AppRoutes.login);
      }

      // Check for update after navigation (non-blocking)
      UpdateService.checkForUpdate();
    } catch (e) {
      debugPrint('❌ Navigation error: $e');
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
