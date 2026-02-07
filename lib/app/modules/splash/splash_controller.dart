/// Splash Controller
library;

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  final _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    debugPrint('🚀 SplashController initialized');
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    try {
      debugPrint('⏳ Waiting for splash animation...');
      // Wait for splash animation
      await Future.delayed(const Duration(seconds: 2));

      final isLoggedIn = _storage.read('is_logged_in') ?? false;
      final pinEnabled = _storage.read('pin_enabled') ?? false;

      debugPrint('📊 isLoggedIn: $isLoggedIn, pinEnabled: $pinEnabled');

      if (isLoggedIn) {
        if (pinEnabled) {
          debugPrint('🔐 Navigating to PIN Lock...');
          Get.offAllNamed(AppRoutes.pinLock);
        } else {
          debugPrint('🏠 Navigating to Dashboard...');
          Get.offAllNamed(AppRoutes.dashboard);
        }
      } else {
        debugPrint('🔑 Navigating to Login...');
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      debugPrint('❌ Navigation error: $e');
      // Fallback to login on any error
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
