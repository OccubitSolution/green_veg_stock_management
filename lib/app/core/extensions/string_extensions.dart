/// String Extensions - Easy translation access
library;

/// Extension to make translations easier
/// Usage: AppStrings.productName.tr instead of 'product_name'.tr
extension StringTranslation on String {
  /// Get translated string
  String get tr => StringTranslation(this).tr;

  /// Get translated string with parameters
  String trParams([Map<String, String>? params]) =>
      StringTranslation(this).trParams(params);

  /// Get translated plural
  String trPlural([String? key, int? i]) =>
      StringTranslation(this).trPlural(key, i);
}
