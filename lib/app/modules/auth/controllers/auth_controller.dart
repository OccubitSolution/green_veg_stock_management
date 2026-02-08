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

  // Observable States
  final isLoading = false.obs;
  final showPassword = false.obs;
  final currentLang = 'gu'.obs;

  // PIN States
  final pin = ''.obs;
  final confirmPin = ''.obs;
  final pinError = ''.obs;
  final isConfirmingPin = false.obs;

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
        await _appController.setVendor(
          id: vendor.id,
          name: vendor.name,
          email: vendor.email,
        );

        // Check if PIN is set
        final pinEnabled = vendor.settings['pin_enabled'] ?? false;
        _storage.write('pin_enabled', pinEnabled);
        if (pinEnabled) {
          Get.offAllNamed(AppRoutes.pinLock);
        } else {
          Get.offAllNamed(AppRoutes.pinSetup);
        }
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

      final vendor = await _authRepository.register(
        email: emailController.text.trim(),
        password: passwordController.text,
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
      );

      if (vendor != null) {
        await _appController.setVendor(
          id: vendor.id,
          name: vendor.name,
          email: vendor.email,
        );
        Get.offAllNamed(AppRoutes.pinSetup);
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

  // PIN Lock Methods
  void addPinDigit(String digit) {
    if (pin.value.length < 4) {
      pin.value += digit;
      pinError.value = '';

      if (pin.value.length == 4) {
        verifyPin();
      }
    }
  }

  void deletePin() {
    if (pin.value.isNotEmpty) {
      pin.value = pin.value.substring(0, pin.value.length - 1);
    }
  }

  Future<void> verifyPin() async {
    final vendorId = _storage.read('vendor_id');
    if (vendorId == null) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    final isValid = await _authRepository.verifyPin(vendorId, pin.value);

    if (isValid) {
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      pinError.value = 'invalid_pin'.tr;
      pin.value = '';
    }
  }

  // PIN Setup Methods
  void addPinSetupDigit(String digit) {
    if (!isConfirmingPin.value) {
      if (pin.value.length < 4) {
        pin.value += digit;
        pinError.value = '';

        if (pin.value.length == 4) {
          isConfirmingPin.value = true;
        }
      }
    } else {
      if (confirmPin.value.length < 4) {
        confirmPin.value += digit;
        pinError.value = '';

        if (confirmPin.value.length == 4) {
          savePin();
        }
      }
    }
  }

  void deletePinSetup() {
    if (isConfirmingPin.value) {
      if (confirmPin.value.isNotEmpty) {
        confirmPin.value = confirmPin.value.substring(
          0,
          confirmPin.value.length - 1,
        );
      } else {
        isConfirmingPin.value = false;
        pin.value = '';
      }
    } else {
      if (pin.value.isNotEmpty) {
        pin.value = pin.value.substring(0, pin.value.length - 1);
      }
    }
  }

  Future<void> savePin() async {
    if (pin.value != confirmPin.value) {
      pinError.value = 'pin_mismatch'.tr;
      confirmPin.value = '';
      return;
    }

    final vendorId = _storage.read('vendor_id');
    if (vendorId == null) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    final success = await _authRepository.setPin(vendorId, pin.value);

    if (success) {
      _storage.write('pin_enabled', true);
      Get.snackbar(
        'success'.tr,
        'pin_set_success'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
      );
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      pinError.value = 'something_went_wrong'.tr;
      resetPinSetup();
    }
  }

  void resetPinSetup() {
    pin.value = '';
    confirmPin.value = '';
    isConfirmingPin.value = false;
    pinError.value = '';
  }
}
