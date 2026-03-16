import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:green_veg_stock_management/app/services/update_service.dart';

void main() {
  // ── _isNewer unit tests ──────────────────────────────────────────────────

  group('UpdateService._isNewer', () {
    test('newer minor version returns true', () {
      expect(UpdateService.isNewer('1.1.0', '1.0.0'), isTrue);
    });

    test('same version returns false', () {
      expect(UpdateService.isNewer('1.0.0', '1.0.0'), isFalse);
    });

    test('older version returns false', () {
      expect(UpdateService.isNewer('0.9.9', '1.0.0'), isFalse);
    });

    test('integer patch comparison — not lexicographic', () {
      expect(UpdateService.isNewer('1.0.10', '1.0.9'), isTrue);
    });

    test('newer major version returns true', () {
      expect(UpdateService.isNewer('2.0.0', '1.9.9'), isTrue);
    });

    test('older major version returns false', () {
      expect(UpdateService.isNewer('1.0.0', '2.0.0'), isFalse);
    });
  });

  // ── Constants sanity check ───────────────────────────────────────────────

  group('UpdateService constants', () {
    test('_githubOwner is not a placeholder', () {
      final url = UpdateService.apiUrl;
      expect(url, isNot(contains('YOUR_GITHUB_USERNAME')));
    });

    test('_githubRepo is not a placeholder', () {
      final url = UpdateService.apiUrl;
      expect(url, isNot(contains('YOUR_REPO_NAME')));
    });

    test('apiUrl points to the correct GitHub Releases endpoint', () {
      const expected =
          'https://api.github.com/repos/OccubitSolution/green_veg_stock_management/releases/latest';
      expect(UpdateService.apiUrl, equals(expected));
    });
  });

  // ── APK asset discovery logic ────────────────────────────────────────────

  group('APK asset discovery', () {
    test('finds apk asset when present', () {
      final assets = <Map<String, dynamic>>[
        {
          'name': 'green_veg_v1.2.0.apk',
          'browser_download_url': 'https://example.com/green_veg_v1.2.0.apk',
        },
      ];
      final apkAsset = assets.firstWhereOrNull(
        (a) => (a['name'] as String).endsWith('.apk'),
      );
      expect(apkAsset, isNotNull);
      expect(
        apkAsset!['browser_download_url'],
        equals('https://example.com/green_veg_v1.2.0.apk'),
      );
    });

    test('returns null when no apk asset present', () {
      final assets = <Map<String, dynamic>>[
        {
          'name': 'checksums.txt',
          'browser_download_url': 'https://example.com/checksums.txt',
        },
      ];
      final apkAsset = assets.firstWhereOrNull(
        (a) => (a['name'] as String).endsWith('.apk'),
      );
      expect(apkAsset, isNull);
    });

    test('returns null for empty assets list', () {
      final assets = <Map<String, dynamic>>[];
      final apkAsset = assets.firstWhereOrNull(
        (a) => (a['name'] as String).endsWith('.apk'),
      );
      expect(apkAsset, isNull);
    });

    test('picks apk when multiple assets exist', () {
      final assets = <Map<String, dynamic>>[
        {
          'name': 'release-notes.md',
          'browser_download_url': 'https://example.com/notes.md',
        },
        {
          'name': 'green_veg_v1.2.0.apk',
          'browser_download_url': 'https://example.com/app.apk',
        },
      ];
      final apkAsset = assets.firstWhereOrNull(
        (a) => (a['name'] as String).endsWith('.apk'),
      );
      expect(apkAsset, isNotNull);
      expect(
        apkAsset!['browser_download_url'],
        equals('https://example.com/app.apk'),
      );
    });
  });
}
