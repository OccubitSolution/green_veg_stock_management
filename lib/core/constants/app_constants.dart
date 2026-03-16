/// App Constants
///
/// Central location for all app-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'GreenVeg';
  static const String appVersion = '1.0.0';

  // Database - Supabase REST API
  static const String supabaseUrl = 'https://ncxzouaovurdiwvcuuqk.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_kARHb543GwleTISaqPXmhQ_s0Ohhy2k';

  // Storage Keys
  static const String keyLanguage = 'language';
  static const String keyTheme = 'theme';
  static const String keyVendorId = 'vendor_id';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyPinEnabled = 'pin_enabled';

  // Pagination
  static const int defaultPageSize = 20;

  // Date Formats
  static const String dateFormat = 'dd-MM-yyyy';
  static const String dateTimeFormat = 'dd-MM-yyyy HH:mm';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);
}
