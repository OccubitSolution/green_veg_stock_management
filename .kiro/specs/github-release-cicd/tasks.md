# Implementation Plan: GitHub Release CI/CD

## Overview

Implement the GitHub Actions CI/CD pipelines, Android signing configuration, and UpdateService wiring for the `green_veg_stock_management` Flutter app. Tasks progress from repository hygiene through Gradle signing config, workflow files, and finally Dart-level tests.

## Tasks

- [x] 1. Update .gitignore to protect signing artifacts
  - Add `android/app/key.properties` and `android/app/keystore.jks` entries to `.gitignore` so signing credentials are never committed
  - _Requirements: 4.6_

- [x] 2. Configure Android signing in build.gradle.kts
  - [x] 2.1 Add signing config to `android/app/build.gradle.kts`
    - Import `java.util.Properties` at the top of the file
    - Read `android/app/key.properties` into a `Properties` object (file may not exist locally)
    - Add a `signingConfigs.create("release")` block that reads `storeFile`, `storePassword`, `keyAlias`, `keyPassword` from the properties object when the file exists
    - Update the `release` build type to use `signingConfigs.getByName("release")` when `key.properties` exists, otherwise fall back to `signingConfigs.getByName("debug")`
    - _Requirements: 2.4, 4.1–4.4_

- [x] 3. Configure UpdateService constants
  - [x] 3.1 Fill in `_githubOwner` and `_githubRepo` in `lib/app/services/update_service.dart`
    - Set `_githubOwner = 'OccubitSolution'` (already set — verify it matches the actual GitHub org/user)
    - Set `_githubRepo = 'green_veg_stock_management'` (already set — verify it matches the actual repo name)
    - _Requirements: 3.5, 6.1, 6.2_

- [x] 4. Create CI workflow
  - [x] 4.1 Create `.github/workflows/ci.yml`
    - Trigger on `push` to `main` branch only
    - Use `actions/checkout@v4`
    - Use `subosito/flutter-action@v2` with `channel: stable` and `cache: true`
    - Run `flutter pub get`, `flutter analyze`, then `flutter build apk --debug` in order
    - Fail the workflow if `flutter analyze` reports any errors (default behaviour — no extra flags needed)
    - No secrets required
    - _Requirements: 1.1–1.5, 5.1, 5.3, 5.5_

- [x] 5. Create Release workflow
  - [x] 5.1 Create `.github/workflows/release.yml`
    - Trigger on `push` with tag pattern `v*.*.*`
    - Use `actions/checkout@v4` with `fetch-depth: 0` (needed for `git log` release notes)
    - Use `subosito/flutter-action@v2` with `channel: stable` and `cache: true`
    - Run `flutter pub get`
    - Extract `VERSION` from the tag by stripping the leading `v` (e.g. `${GITHUB_REF_NAME#v}`)
    - Decode `KEYSTORE_BASE64` secret to `android/app/keystore.jks` via `base64 -d`
    - Write `android/app/key.properties` from `KEY_STORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD` secrets and `storeFile=keystore.jks`
    - Build release APK: `flutter build apk --release --build-name=$VERSION --build-number=${{ github.run_number }}`
    - Rename output: `mv build/app/outputs/flutter-apk/app-release.apk green_veg_v$VERSION.apk`
    - Generate release notes: `git log $(git describe --tags --abbrev=0 HEAD^)..HEAD --pretty=format:"- %s"`
    - Create GitHub Release and upload APK using `softprops/action-gh-release@v2` with `files: green_veg_v$VERSION.apk`
    - Consume secrets: `KEYSTORE_BASE64`, `KEY_STORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`
    - _Requirements: 2.1–2.8, 3.1–3.4, 4.1–4.4, 5.2, 5.4, 5.6_

- [ ] 6. Checkpoint — verify workflow YAML is valid
  - Ensure all tests pass, ask the user if questions arise.
  - Optionally lint both workflow files with `actionlint` locally before pushing

- [x] 7. Add UpdateService unit and property tests
  - [x] 7.1 Add `fast_check` to `dev_dependencies` in `pubspec.yaml` and run `flutter pub get`
    - _Requirements: 6.3, 6.4_

  - [x] 7.2 Create `test/services/update_service_test.dart` with unit tests
    - Test `_isNewer('1.1.0', '1.0.0')` → `true`
    - Test `_isNewer('1.0.0', '1.0.0')` → `false`
    - Test `_isNewer('0.9.9', '1.0.0')` → `false`
    - Test `_isNewer('1.0.10', '1.0.9')` → `true` (integer, not lexicographic)
    - Test that `_githubOwner` and `_githubRepo` are not placeholder values (`'YOUR_GITHUB_USERNAME'` / `'YOUR_REPO_NAME'`)
    - Test that a release response with no `.apk` asset causes early return (no dialog shown)
    - _Requirements: 3.1, 6.1–6.5_

  - [ ]* 7.3 Write property test for version tag stripping round-trip (Property 1)
    - **Property 1: Version tag stripping is a left-inverse**
    - **Validates: Requirements 2.2**
    - Tag: `// Feature: github-release-cicd, Property 1: version tag stripping is a left-inverse`
    - Generate arbitrary non-negative integer triples `(major, minor, patch)`, build tag `v$major.$minor.$patch`, assert `'v' + tag.replaceAll('v', '') == tag`

  - [ ]* 7.4 Write property test for APK filename format (Property 2)
    - **Property 2: APK asset filename matches naming convention**
    - **Validates: Requirements 2.6**
    - Tag: `// Feature: github-release-cicd, Property 2: APK asset filename matches naming convention`
    - Generate arbitrary semver version strings, build filename `green_veg_v$version.apk`, assert it matches `RegExp(r'^green_veg_v\d+\.\d+\.\d+\.apk$')`

  - [ ]* 7.5 Write property test for asset discovery (Property 3)
    - **Property 3: UpdateService finds the APK asset in any valid release response**
    - **Validates: Requirements 3.1**
    - Tag: `// Feature: github-release-cicd, Property 3: UpdateService finds the APK asset in any valid release response`
    - Generate arbitrary version strings and download URLs, build a mock assets list with one `.apk` entry, assert `firstWhereOrNull` returns non-null and the URL matches

  - [ ]* 7.6 Write property test for version comparison ordering (Property 4)
    - **Property 4: Version comparison correctly orders semver triples**
    - **Validates: Requirements 6.3, 6.4**
    - Tag: `// Feature: github-release-cicd, Property 4: version comparison correctly orders semver triples`
    - Generate two arbitrary semver triples `(a, b)`, assert `_isNewer(a, b)` matches the expected boolean from a reference comparator; assert `_isNewer(a, a) == false`

- [ ] 8. Final checkpoint — ensure all tests pass
  - Run `flutter test` and confirm all unit and property tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for a faster MVP
- `_isNewer` and the asset-discovery logic are `static` private methods; expose them via a thin test-only wrapper or use `@visibleForTesting` to allow direct testing
- The `key.properties` file is generated at CI runtime and must never be committed — the `.gitignore` entry in task 1 enforces this
- Property tests use the `fast_check` package (Dart port of fast-check); minimum 100 iterations per property
- Each property test file must include the feature/property tag comment as specified in the design
