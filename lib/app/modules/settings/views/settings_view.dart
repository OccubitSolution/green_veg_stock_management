/// Settings View — Premium Design
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Gradient Header
          SliverToBoxAdapter(child: _buildGradientHeader(context)),

          // Settings Content
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMD),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppTheme.spacingMD),

                // Profile Card
                _buildProfileCard(context),
                const SizedBox(height: AppTheme.spacingLG),

                // Language Section
                _buildSectionTitle(
                  context,
                  'language'.tr,
                  Icons.translate_rounded,
                ),
                const SizedBox(height: AppTheme.spacingSM),
                _buildLanguageCard(context),
                const SizedBox(height: AppTheme.spacingLG),

                // Invite Staff Section
                _buildSectionTitle(
                  context,
                  'invite_staff'.tr,
                  Icons.person_add_outlined,
                ),
                const SizedBox(height: AppTheme.spacingSM),
                _buildInviteCard(context),
                const SizedBox(height: AppTheme.spacingLG),

                // App Info Section
                _buildSectionTitle(
                  context,
                  'about'.tr,
                  Icons.info_outline_rounded,
                ),
                const SizedBox(height: AppTheme.spacingSM),
                _buildAboutCard(context),
                const SizedBox(height: AppTheme.spacingXL),

                // Logout Button
                _buildLogoutButton(context),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppTheme.spacingMD,
        left: AppTheme.spacingMD,
        right: AppTheme.spacingMD,
        bottom: AppTheme.spacingLG,
      ),
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppTheme.radiusXL),
          bottomRight: Radius.circular(AppTheme.radiusXL),
        ),
      ),
      child: Column(
        children: [
          // Top row with back button and title
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingMD),
              Text(
                'settings'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2);
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          ),
          child: Icon(icon, size: 18, color: AppTheme.primaryColor),
        ),
        const SizedBox(width: AppTheme.spacingSM),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryLight,
          ),
        ),
      ],
    ).animate().fadeIn().slideX(begin: -0.1);
  }

  Widget _buildProfileCard(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(AppTheme.spacingLG),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusLG),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Obx(
                () => Text(
                  controller.vendorName.value.isNotEmpty
                      ? controller.vendorName.value[0].toUpperCase()
                      : 'G',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    controller.vendorName.value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Obx(
                  () => Text(
                    controller.vendorEmail.value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            ),
            child: const Icon(
              Icons.edit_outlined,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildLanguageCard(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'select_language'.tr,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMD),
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: _buildLanguageOption(
                    context,
                    'gu',
                    ' Gujarati',
                    '  ',
                    controller.currentLang.value == 'gu',
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSM),
                Expanded(
                  child: _buildLanguageOption(
                    context,
                    'en',
                    'English',
                    '  ',
                    controller.currentLang.value == 'en',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String langCode,
    String label,
    String flag,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => controller.changeLanguage(langCode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : AppTheme.textTertiaryLight.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondaryLight,
                fontSize: 14,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.check_circle_rounded,
                color: AppTheme.primaryColor,
                size: 18,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInviteCard(BuildContext context) {
    return PremiumCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'invite_staff_desc'.tr,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMD),
                Obx(() {
                  if (controller.inviteCode.value.isEmpty) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: controller.generateInviteCode,
                        icon: const Icon(Icons.qr_code),
                        label: Text('generate_invite_code'.tr),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppTheme.spacingMD,
                          ),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppTheme.spacingMD),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                          border: Border.all(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'invite_code'.tr,
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacingSM),
                            Text(
                              controller.inviteCode.value,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 4,
                                color: AppTheme.primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMD),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: controller.copyInviteCode,
                              icon: const Icon(Icons.copy),
                              label: Text('copy'.tr),
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingSM),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: controller.shareInviteCode,
                              icon: const Icon(Icons.share),
                              label: Text('share'.tr),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildAboutCard(BuildContext context) {
    return PremiumCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildSettingsRow(
            context,
            icon: Icons.info_outline_rounded,
            iconColor: AppTheme.info,
            title: 'version'.tr,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusRound),
              ),
              child: const Text(
                '1.0.0',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          Divider(
            height: 1,
            color: AppTheme.textTertiaryLight.withValues(alpha: 0.2),
          ),
          _buildSettingsRow(
            context,
            icon: Icons.help_outline_rounded,
            iconColor: AppTheme.warmAccent,
            title: 'help'.tr,
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textTertiaryLight,
            ),
            onTap: () {
              // TODO: Help
            },
          ),
          Divider(
            height: 1,
            color: AppTheme.textTertiaryLight.withValues(alpha: 0.2),
          ),
          _buildSettingsRow(
            context,
            icon: Icons.privacy_tip_outlined,
            iconColor: AppTheme.primaryColor,
            title: 'privacy_policy'.tr,
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textTertiaryLight,
            ),
            onTap: () {
              // TODO: Privacy
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildSettingsRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMD,
          vertical: 14,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: AppTheme.spacingMD),
            Expanded(
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: controller.logout,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          border: Border.all(color: AppTheme.error.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: AppTheme.error, size: 20),
            const SizedBox(width: AppTheme.spacingSM),
            Text(
              'logout'.tr,
              style: TextStyle(
                color: AppTheme.error,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1);
  }
}