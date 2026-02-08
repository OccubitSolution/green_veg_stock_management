/// GreenVeg Stock Management App
///
/// A multi-vendor vegetable stock management application
/// with daily pricing, inventory tracking, and bilingual support.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'app/translations/app_translations.dart';
import 'app/bindings/initial_binding.dart';
import 'core/constants/app_constants.dart';
import 'app/data/providers/database_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  await GetStorage.init();
  await Hive.initFlutter();

  // Initialize date formatting for intl package
  await initializeDateFormatting();

  // Initialize database connection (don't block on failure)
  try {
    await DatabaseProvider.instance.initialize();
  } catch (e) {
    debugPrint('⚠️ Database connection failed, app will work offline: $e');
  }

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const GreenVegApp());
}

class GreenVegApp extends StatelessWidget {
  const GreenVegApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();
    final savedLocale = storage.read<String>('language') ?? 'gu';

    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      // Translations
      translations: AppTranslations(),
      locale: Locale(savedLocale),
      fallbackLocale: const Locale('en'),

      // Routes
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,

      // Initial bindings
      initialBinding: InitialBinding(),

      // Default transition
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
