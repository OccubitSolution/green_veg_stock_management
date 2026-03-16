# Requirements Document

## Introduction

This feature configures GitHub Actions CI/CD pipelines and GitHub Releases for the `green_veg_stock_management` Flutter app. The goal is to automate APK builds triggered by version tags, publish releases to GitHub Releases, and ensure the existing in-app `UpdateService` can discover and download new APK versions seamlessly.

The app already has a fully implemented `UpdateService` (using `dio`, `package_info_plus`, `open_filex`, `permission_handler`, and `path_provider`) that queries the GitHub Releases API for the latest release and prompts the user to download and install the APK. The CI/CD pipeline must produce releases in a format compatible with that service.

## Glossary

- **CI_Pipeline**: The GitHub Actions workflow that builds and tests the Flutter APK on every push to `main`.
- **Release_Pipeline**: The GitHub Actions workflow that builds, signs, and publishes a release APK to GitHub Releases when a version tag is pushed.
- **UpdateService**: The existing Dart class in `lib/app/services/update_service.dart` that checks GitHub Releases for a newer APK and prompts the user to install it.
- **Version_Tag**: A Git tag following the format `v<major>.<minor>.<patch>` (e.g. `v1.2.0`) used to trigger a release.
- **Release_APK**: The signed Android APK artifact attached to a GitHub Release.
- **GitHub_Release**: A GitHub Releases entry created by the Release_Pipeline, containing a Version_Tag, release notes, and the Release_APK as an asset.
- **Build_Number**: The integer build number embedded in the APK, derived from the GitHub Actions run number.
- **Keystore**: The Android signing keystore used to sign the Release_APK, stored as a GitHub Actions secret.
- **Secrets**: GitHub repository secrets used to store sensitive values such as Keystore credentials and Supabase keys.

---

## Requirements

### Requirement 1: Continuous Integration on Push

**User Story:** As a developer, I want every push to `main` to automatically build the Flutter app, so that I can catch build-breaking changes early.

#### Acceptance Criteria

1. WHEN a commit is pushed to the `main` branch, THE CI_Pipeline SHALL trigger automatically.
2. THE CI_Pipeline SHALL run `flutter pub get` to restore dependencies before building.
3. THE CI_Pipeline SHALL run `flutter analyze` and fail the build if any errors are reported.
4. THE CI_Pipeline SHALL build a debug APK using `flutter build apk --debug` to verify the project compiles.
5. IF the `flutter analyze` step reports errors, THEN THE CI_Pipeline SHALL exit with a non-zero status code and mark the workflow run as failed.

---

### Requirement 2: Automated Release on Version Tag

**User Story:** As a developer, I want pushing a version tag to automatically build and publish a signed release APK, so that I don't have to manually build or upload APKs.

#### Acceptance Criteria

1. WHEN a tag matching the pattern `v*.*.*` is pushed to the repository, THE Release_Pipeline SHALL trigger automatically.
2. THE Release_Pipeline SHALL extract the version name from the tag (stripping the leading `v`) and the build number from the GitHub Actions run number.
3. THE Release_Pipeline SHALL build a release APK using `flutter build apk --release --build-name=<version> --build-number=<run_number>`.
4. THE Release_Pipeline SHALL sign the Release_APK using the Keystore stored in Secrets before uploading.
5. THE Release_Pipeline SHALL create a GitHub_Release with the Version_Tag as the release title.
6. THE Release_Pipeline SHALL attach the signed Release_APK as an asset to the GitHub_Release, named `green_veg_v<version>.apk`.
7. THE Release_Pipeline SHALL populate the GitHub_Release body with the Git commit messages since the previous tag as release notes.
8. IF the Keystore secret is missing or invalid, THEN THE Release_Pipeline SHALL fail the signing step and exit with a non-zero status code.

---

### Requirement 3: GitHub Release Asset Compatibility with UpdateService

**User Story:** As a developer, I want the GitHub Release format to be compatible with the existing UpdateService, so that in-app update checks work without modifying the service logic.

#### Acceptance Criteria

1. THE Release_Pipeline SHALL attach exactly one `.apk` file as an asset to each GitHub_Release.
2. THE GitHub_Release SHALL use the Version_Tag (e.g. `v1.2.0`) as the `tag_name` field, so that THE UpdateService can parse the version by stripping the leading `v`.
3. THE GitHub_Release SHALL be published (not a draft), so that the GitHub Releases API `/releases/latest` endpoint returns it.
4. WHEN THE UpdateService calls `https://api.github.com/repos/<owner>/<repo>/releases/latest`, THE GitHub_Release SHALL be the response for the most recently published release.
5. THE Release_Pipeline SHALL set the `_githubOwner` and `_githubRepo` values in `UpdateService` to match the actual repository, so that the API URL resolves correctly.

---

### Requirement 4: Secure Secret Management

**User Story:** As a developer, I want all sensitive credentials stored as GitHub Secrets, so that they are never exposed in the repository or workflow logs.

#### Acceptance Criteria

1. THE Release_Pipeline SHALL read the Keystore file from a base64-encoded GitHub Secret named `KEYSTORE_BASE64`.
2. THE Release_Pipeline SHALL read the keystore password from a GitHub Secret named `KEY_STORE_PASSWORD`.
3. THE Release_Pipeline SHALL read the key alias from a GitHub Secret named `KEY_ALIAS`.
4. THE Release_Pipeline SHALL read the key password from a GitHub Secret named `KEY_PASSWORD`.
5. THE CI_Pipeline SHALL NOT require any signing secrets, as it only builds a debug APK.
6. IF any required signing secret is absent during the Release_Pipeline, THEN THE Release_Pipeline SHALL fail before attempting to sign the APK.

---

### Requirement 5: Flutter Environment Setup

**User Story:** As a developer, I want the CI/CD environment to use a consistent Flutter version, so that builds are reproducible across runs.

#### Acceptance Criteria

1. THE CI_Pipeline SHALL use the `subosito/flutter-action` GitHub Action to install Flutter.
2. THE Release_Pipeline SHALL use the `subosito/flutter-action` GitHub Action to install Flutter.
3. THE CI_Pipeline SHALL pin the Flutter channel to `stable` to ensure reproducible builds.
4. THE Release_Pipeline SHALL pin the Flutter channel to `stable` to ensure reproducible builds.
5. WHILE the Flutter environment is being set up, THE CI_Pipeline SHALL cache Flutter and pub dependencies to reduce build time on subsequent runs.
6. WHILE the Flutter environment is being set up, THE Release_Pipeline SHALL cache Flutter and pub dependencies to reduce build time on subsequent runs.

---

### Requirement 6: UpdateService Configuration

**User Story:** As a developer, I want the UpdateService to be configured with the correct repository details, so that it can locate the GitHub Releases API endpoint at runtime.

#### Acceptance Criteria

1. THE UpdateService SHALL have `_githubOwner` set to the actual GitHub username or organisation that owns the repository.
2. THE UpdateService SHALL have `_githubRepo` set to the actual repository name where releases are published.
3. WHEN THE UpdateService calls the GitHub Releases API and receives a 200 response, THE UpdateService SHALL compare `tag_name` (with `v` stripped) against the current app version from `PackageInfo`.
4. WHEN the latest release version is greater than the current app version, THE UpdateService SHALL display the update dialog to the user.
5. IF THE UpdateService receives a non-200 response or a network error, THEN THE UpdateService SHALL silently return without showing any error to the user.
