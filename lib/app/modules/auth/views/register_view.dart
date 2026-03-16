/// Register View — Premium Design
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Branding
                _buildBranding(context),

                const SizedBox(height: 36),

                // Register Form Card
                _buildRegisterForm(context),

                const SizedBox(height: 24),

                // Login Link
                _buildLoginLink(context),

                const SizedBox(height: 24),

                // Language Toggle
                _buildLanguageToggle(context),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBranding(BuildContext context) {
    return Column(
      children: [
        // Back button + Logo
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              ),
              child: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            const Spacer(),
          ],
        ),

        const SizedBox(height: 20),

        // Logo
        Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: AppTheme.coloredShadow(AppTheme.primaryColor),
              ),
              child: const Icon(
                Icons.eco_rounded,
                size: 40,
                color: Colors.white,
              ),
            )
            .animate()
            .fadeIn(duration: 500.ms)
            .scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut),

        const SizedBox(height: 20),

        // Title
        Text(
          'create_account'.tr,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimaryLight,
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

        const SizedBox(height: 8),

        Text(
          'register'.tr,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondaryLight),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
      ],
    );
  }

  Widget _buildRegisterForm(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(AppTheme.spacingLG),
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Name Field
          _buildTextField(
            controller: controller.nameController,
            label: 'name'.tr,
            hint: 'enter_name'.tr,
            icon: Icons.person_outline_rounded,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
          ),

          const SizedBox(height: AppTheme.spacingMD),

          // Phone Field
          _buildTextField(
            controller: controller.phoneController,
            label: 'phone'.tr,
            hint: 'enter_phone'.tr,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),

          const SizedBox(height: AppTheme.spacingMD),

          // Email Field
          _buildTextField(
            controller: controller.emailController,
            label: 'email'.tr,
            hint: 'enter_email'.tr,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: AppTheme.spacingMD),

          // Password Field
          Obx(
            () => _buildTextField(
              controller: controller.passwordController,
              label: 'password'.tr,
              hint: 'enter_password'.tr,
              icon: Icons.lock_outline_rounded,
              obscureText: !controller.showPassword.value,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.showPassword.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.textSecondaryLight,
                ),
                onPressed: controller.togglePasswordVisibility,
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spacingMD),

          // Confirm Password Field
          Obx(
            () => _buildTextField(
              controller: controller.confirmPasswordController,
              label: 'confirm_password'.tr,
              hint: 'confirm_password'.tr,
              icon: Icons.lock_outline_rounded,
              obscureText: !controller.showPassword.value,
            ),
          ),

          const SizedBox(height: AppTheme.spacingMD),

          // Invite Code Field (Optional)
          _buildTextField(
            controller: controller.inviteCodeController,
            label: 'invite_code'.tr,
            hint: 'invite_code_hint'.tr,
            icon: Icons.qr_code,
            keyboardType: TextInputType.text,
          ),

          const SizedBox(height: AppTheme.spacingLG),

          // Register Button
          Obx(
            () => GradientButton(
              label: 'register'.tr,
              icon: Icons.person_add_rounded,
              onPressed: controller.register,
              isLoading: controller.isLoading.value,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppTheme.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          obscureText: obscureText,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppTheme.textTertiaryLight,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(icon, color: AppTheme.textSecondaryLight),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppTheme.backgroundLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLG),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLG),
              borderSide: const BorderSide(
                color: AppTheme.primaryColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'already_have_account'.tr,
          style: const TextStyle(
            color: AppTheme.textSecondaryLight,
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'login'.tr,
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildLanguageToggle(BuildContext context) {
    return Center(
      child: Obx(
        () => Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusRound),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLangChip(
                label: 'EN',
                isSelected: controller.currentLang.value == 'en',
                onTap: () => controller.changeLanguage('en'),
              ),
              _buildLangChip(
                label: 'ગુજ',
                isSelected: controller.currentLang.value == 'gu',
                onTap: () => controller.changeLanguage('gu'),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildLangChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppTheme.animNormal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          borderRadius: BorderRadius.circular(AppTheme.radiusRound),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textSecondaryLight,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
