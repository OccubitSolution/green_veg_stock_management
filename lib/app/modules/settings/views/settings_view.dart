/// Settings View
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../../../theme/app_theme.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: Text('settings'.tr)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          _buildSectionTitle(context, 'profile'.tr),
          _buildProfileCard(context),

          const SizedBox(height: 24),

          // Language Section
          _buildSectionTitle(context, 'language'.tr),
          _buildLanguageCard(context),

          const SizedBox(height: 24),

          // Security Section
          _buildSectionTitle(context, 'security'.tr),
          _buildSecurityCard(context),

          const SizedBox(height: 24),

          // App Info Section
          _buildSectionTitle(context, 'about'.tr),
          _buildAboutCard(context),

          const SizedBox(height: 24),

          // Logout Button
          ElevatedButton.icon(
            onPressed: controller.logout,
            icon: const Icon(Icons.logout),
            label: Text('logout'.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              child: const Icon(
                Icons.person,
                size: 32,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
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
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                // TODO: Edit profile
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'select_language'.tr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Obx(
              () => SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'gu',
                    label: Text('ગુજરાતી'),
                    icon: Icon(Icons.language),
                  ),
                  ButtonSegment(
                    value: 'en',
                    label: Text('English'),
                    icon: Icon(Icons.language),
                  ),
                ],
                selected: {controller.currentLang.value},
                onSelectionChanged: (Set<String> selected) {
                  controller.changeLanguage(selected.first);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: Text('change_pin'.tr),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Change PIN
            },
          ),
          const Divider(height: 1),
          Obx(
            () => SwitchListTile(
              secondary: const Icon(Icons.fingerprint),
              title: Text('pin_lock'.tr),
              value: controller.pinEnabled.value,
              onChanged: controller.togglePinLock,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text('version'.tr),
            trailing: const Text('1.0.0'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text('help'.tr),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Help
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text('privacy_policy'.tr),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Privacy
            },
          ),
        ],
      ),
    );
  }
}
