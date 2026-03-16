/// GreenVeg Stock Management App
///
/// A multi-vendor vegetable stock management application
/// with daily pricing, inventory tracking, and bilingual support.
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/io_client.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'app/translations/app_translations.dart';
import 'app/bindings/initial_binding.dart';
import 'core/constants/app_constants.dart';
import 'app/data/services/cache_service.dart';
import 'app/data/services/connectivity_service.dart';
import 'app/services/update_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  await GetStorage.init();
  await Hive.initFlutter();

  // Initialize local cache
  await CacheService().init();

  // Initialize connectivity monitoring
  await ConnectivityService().init();

  // Initialize date formatting
  await initializeDateFormatting();

  // ─── CRITICAL: Supabase MUST be initialized before any repository accesses ───
  // Use IOClient with a 60-second connection timeout to handle Android
  // networks that are slow on IPv6→IPv4 fallback (errno = 110 ETIMEDOUT).
  final ioClient = HttpClient()
    ..connectionTimeout = const Duration(seconds: 60);
  final httpClient = IOClient(ioClient);

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
    httpClient: httpClient,
  );
  debugPrint('✅ Supabase initialized');

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

  // Check for updates after app is running (non-blocking)
  Future.delayed(const Duration(seconds: 3), () {
    UpdateService.checkForUpdate();
  });
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
