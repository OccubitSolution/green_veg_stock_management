/// Auth Controller
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../controllers/app_controller.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final AppController _appController = Get.find<AppController>();
  final _storage = GetStorage();

  // Text Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final inviteCodeController = TextEditingController();

  // Observable States
  final isLoading = false.obs;
  final showPassword = false.obs;
  final currentLang = 'gu'.obs;

  @override
  void onInit() {
    super.onInit();
    currentLang.value = _storage.read('language') ?? 'gu';
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    inviteCodeController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    showPassword.value = !showPassword.value;
  }

  void changeLanguage(String lang) {
    currentLang.value = lang;
    Get.updateLocale(Locale(lang));
    _storage.write('language', lang);
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'fill_all_fields'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
      return;
    }

    isLoading.value = true;

    try {
      final vendor = await _authRepository.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (vendor != null) {
        String? userRole;
        String? invitedBy;
        String? inviterName;
        
        if (vendor.invitedBy != null) {
          userRole = 'staff';
          // Get inviter info
          final inviter = await _authRepository.getVendor(vendor.invitedBy!);
          if (inviter != null) {
            invitedBy = inviter.id;
            inviterName = inviter.name;
          }
        }
        
        await _appController.setVendor(
          id: vendor.id,
          name: vendor.name,
          email: vendor.email,
          userRole: userRole,
          invitedBy: invitedBy,
          inviterName: inviterName,
        );

        // Navigate directly to dashboard (PIN removed)
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        Get.snackbar(
          'error'.tr,
          'invalid_credentials'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'something_went_wrong'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'fill_all_fields'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
        'error'.tr,
        'password_mismatch'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
      return;
    }

    if (passwordController.text.length < 6) {
      Get.snackbar(
        'error'.tr,
        'min_length'.trParams({'length': '6'}),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
      return;
    }

    isLoading.value = true;

    try {
      // Check if email exists
      final exists = await _authRepository.emailExists(
        emailController.text.trim(),
      );
      if (exists) {
        Get.snackbar(
          'error'.tr,
          'email_exists'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
        );
        isLoading.value = false;
        return;
      }

      final inviteCode = inviteCodeController.text.trim();
      dynamic vendor;

      if (inviteCode.isNotEmpty) {
        // Register with invite code (staff user)
        vendor = await _authRepository.registerWithInvite(
          email: emailController.text.trim(),
          password: passwordController.text,
          name: nameController.text.trim(),
          phone: phoneController.text.trim(),
          inviteCode: inviteCode,
        );
        if (vendor != null) {
          Get.snackbar(
            'success'.tr,
            'staff_registered'.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade100,
          );
        }
      } else {
        // Normal registration (admin)
        vendor = await _authRepository.register(
          email: emailController.text.trim(),
          password: passwordController.text,
          name: nameController.text.trim(),
          phone: phoneController.text.trim(),
        );
      }

      if (vendor != null) {
        String? userRole;
        String? invitedBy;
        String? inviterName;
        
        if (inviteCode.isNotEmpty) {
          // Get inviter info
          final inviter = await _authRepository.getVendorByInviteCode(inviteCode);
          userRole = 'staff';
          if (inviter != null) {
            invitedBy = inviter.id;
            inviterName = inviter.name;
          }
        }
        
        await _appController.setVendor(
          id: vendor.id,
          name: vendor.name,
          email: vendor.email,
          userRole: userRole,
          invitedBy: invitedBy,
          inviterName: inviterName,
        );
        // Navigate directly to dashboard (PIN removed)
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        Get.snackbar(
          'error'.tr,
          'registration_failed'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'something_went_wrong'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      isLoading.value = false;
    }
  }
}