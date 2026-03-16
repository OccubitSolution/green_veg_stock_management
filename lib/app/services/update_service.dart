/// In-App Update Service
/// Checks GitHub Releases for a newer APK and prompts the user to download + install.
library;

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';

class UpdateService {
  // ── CONFIGURE THESE ──────────────────────────────────────────────────────
  // Your GitHub username and repo name
  static const String _githubOwner = 'YOUR_GITHUB_USERNAME';
  static const String _githubRepo = 'YOUR_REPO_NAME';
  // ─────────────────────────────────────────────────────────────────────────

  static const String _apiUrl =
      'https://api.github.com/repos/$_githubOwner/$_githubRepo/releases/latest';

  static final Dio _dio = Dio();

  /// Call this on app launch (e.g. in main.dart after init)
  static Future<void> checkForUpdate({bool silent = true}) async {
    if (!Platform.isAndroid) return;
    try {
      final info = await PackageInfo.fromPlatform();
      final currentVersion = info.version; // e.g. "1.0.0"

      final response = await _dio.get(
        _apiUrl,
        options: Options(
          headers: {'Accept': 'application/vnd.github+json'},
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode != 200) return;

      final data = response.data as Map<String, dynamic>;
      final latestTag = (data['tag_name'] as String).replaceAll('v', '');
      final releaseNotes = data['body'] as String? ?? '';

      // Find the APK asset
      final assets = data['assets'] as List<dynamic>;
      final apkAsset = assets.firstWhereOrNull(
        (a) => (a['name'] as String).endsWith('.apk'),
      );
      if (apkAsset == null) return;

      final downloadUrl = apkAsset['browser_download_url'] as String;

      if (_isNewer(latestTag, currentVersion)) {
        _showUpdateDialog(
          currentVersion: currentVersion,
          latestVersion: latestTag,
          downloadUrl: downloadUrl,
          releaseNotes: releaseNotes,
        );
      }
    } catch (e) {
      // Silent fail — don't interrupt the user if update check fails
      debugPrint('UpdateService: check failed — $e');
    }
  }

  static bool _isNewer(String latest, String current) {
    final l = latest.split('.').map(int.tryParse).toList();
    final c = current.split('.').map(int.tryParse).toList();
    for (int i = 0; i < 3; i++) {
      final lv = (i < l.length ? l[i] : 0) ?? 0;
      final cv = (i < c.length ? c[i] : 0) ?? 0;
      if (lv > cv) return true;
      if (lv < cv) return false;
    }
    return false;
  }

  static void _showUpdateDialog({
    required String currentVersion,
    required String latestVersion,
    required String downloadUrl,
    required String releaseNotes,
  }) {
    final progress = 0.0.obs;
    final isDownloading = false.obs;
    final statusText = ''.obs;

    Get.dialog(
      WillPopScope(
        onWillPop: () async => !isDownloading.value,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.system_update_rounded,
                  color: AppTheme.primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Update Available',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'v$currentVersion  →  v$latestVersion',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                  fontSize: 15,
                ),
              ),
              if (releaseNotes.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  releaseNotes.length > 200
                      ? '${releaseNotes.substring(0, 200)}...'
                      : releaseNotes,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
              if (isDownloading.value) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: progress.value,
                  backgroundColor: Colors.grey[200],
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(4),
                  minHeight: 6,
                ),
                const SizedBox(height: 6),
                Text(
                  statusText.value,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ],
          )),
          actions: [
            Obx(() => isDownloading.value
                ? const SizedBox.shrink()
                : TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Later'),
                  )),
            Obx(() => isDownloading.value
                ? const SizedBox.shrink()
                : ElevatedButton.icon(
                    onPressed: () => _startDownload(
                      downloadUrl: downloadUrl,
                      latestVersion: latestVersion,
                      progress: progress,
                      isDownloading: isDownloading,
                      statusText: statusText,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('Update Now'),
                  )),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  static Future<void> _startDownload({
    required String downloadUrl,
    required String latestVersion,
    required RxDouble progress,
    required RxBool isDownloading,
    required RxString statusText,
  }) async {
    // Request install permission on Android 8+
    if (!await Permission.requestInstallPackages.isGranted) {
      final status = await Permission.requestInstallPackages.request();
      if (!status.isGranted) {
        Get.snackbar(
          'Permission Required',
          'Please allow installing from unknown sources in Settings.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    isDownloading.value = true;
    statusText.value = 'Starting download...';

    try {
      final dir = await getExternalStorageDirectory() ??
          await getApplicationCacheDirectory();
      final savePath = '${dir.path}/green_veg_v$latestVersion.apk';

      await _dio.download(
        downloadUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            progress.value = received / total;
            final mb = (received / 1024 / 1024).toStringAsFixed(1);
            final totalMb = (total / 1024 / 1024).toStringAsFixed(1);
            statusText.value = '$mb MB / $totalMb MB';
          }
        },
        options: Options(
          receiveTimeout: const Duration(minutes: 5),
        ),
      );

      statusText.value = 'Installing...';
      Get.back(); // close dialog
      await OpenFilex.open(savePath);
    } catch (e) {
      isDownloading.value = false;
      Get.back();
      Get.snackbar(
        'Download Failed',
        'Could not download update. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
      );
      debugPrint('UpdateService: download failed — $e');
    }
  }
}
