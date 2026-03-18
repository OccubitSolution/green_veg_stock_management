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
  static const String _githubOwner = 'OccubitSolution';
  static const String _githubRepo = 'green_veg_stock_management';

  static const String _apiUrl =
      'https://api.github.com/repos/$_githubOwner/$_githubRepo/releases/latest';

  @visibleForTesting
  static String get apiUrl => _apiUrl;

  @visibleForTesting
  static bool isNewer(String latest, String current) =>
      _isNewer(latest, current);

  static final Dio _dio = Dio();

  static Future<void> checkForUpdate({bool silent = true}) async {
    if (!Platform.isAndroid) return;
    try {
      final info = await PackageInfo.fromPlatform();
      final currentVersion = info.version;

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
      Obx(() => PopScope(
        canPop: !isDownloading.value,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D9668), Color(0xFF34D399)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.system_update_rounded,
                          color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'update_available'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'v$currentVersion  →  v$latestVersion',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Body
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (releaseNotes.isNotEmpty) ...[
                      Text(
                        'whats_new'.tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          releaseNotes.length > 200
                              ? '${releaseNotes.substring(0, 200)}...'
                              : releaseNotes,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Progress
                    Obx(() {
                      if (!isDownloading.value) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('downloading'.tr,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500)),
                              Text(statusText.value,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress.value,
                              backgroundColor: Colors.grey[200],
                              color: AppTheme.primaryColor,
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }),

                    // Buttons
                    Obx(() => isDownloading.value
                        ? const SizedBox.shrink()
                        : Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Get.back(),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    side: BorderSide(color: Colors.grey.shade300),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text('later'.tr,
                                      style: TextStyle(color: Colors.grey[600])),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton.icon(
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
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                    elevation: 0,
                                  ),
                                  icon: const Icon(Icons.download_rounded, size: 18),
                                  label: Text('update_now'.tr,
                                      style: TextStyle(fontWeight: FontWeight.w700)),
                                ),
                              ),
                            ],
                          )),
                  ],
                ),
              ),
            ],
          ),
        ),
      )),
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
    // Request install permission
    final installStatus = await Permission.requestInstallPackages.status;
    if (!installStatus.isGranted) {
      final result = await Permission.requestInstallPackages.request();
      if (!result.isGranted) {
        Get.snackbar(
          'permission_required'.tr,
          'permission_required_msg'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    isDownloading.value = true;
    statusText.value = '0%';

    try {
      // Always save to app cache dir — avoids external storage permission issues
      final dir = await getApplicationCacheDirectory();
      final savePath = '${dir.path}/greenveg_v$latestVersion.apk';

      // Delete old APK if exists
      final file = File(savePath);
      if (await file.exists()) await file.delete();

      await _dio.download(
        downloadUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final pct = (received / total * 100).toInt();
            progress.value = received / total;
            final mb = (received / 1024 / 1024).toStringAsFixed(1);
            final totalMb = (total / 1024 / 1024).toStringAsFixed(1);
            statusText.value = '$pct% ($mb/$totalMb MB)';
          }
        },
        options: Options(receiveTimeout: const Duration(minutes: 10)),
      );

      statusText.value = 'installing'.tr;
      await Future.delayed(const Duration(milliseconds: 300));
      Get.back(); // close dialog

      final result = await OpenFilex.open(savePath);
      debugPrint('UpdateService: open result — ${result.type}: ${result.message}');

      if (result.type != ResultType.done) {
        Get.snackbar(
          'install_failed'.tr,
          '${'install_failed'.tr}: ${result.message}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
        );
      }
    } catch (e) {
      isDownloading.value = false;
      Get.back();
      Get.snackbar(
        'download_failed'.tr,
        'download_failed_msg'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
      );
      debugPrint('UpdateService: download failed — $e');
    }
  }
}
