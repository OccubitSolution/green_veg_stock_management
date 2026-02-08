/// App Pages - GetX Routing
import 'package:get/get.dart';
import 'app_routes.dart';

// Splash
import '../modules/splash/splash_view.dart';
import '../modules/splash/splash_binding.dart';

// Auth
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/auth/views/pin_lock_view.dart';
import '../modules/auth/views/pin_setup_view.dart';
import '../modules/auth/bindings/auth_binding.dart';

// Home
// import '../modules/home/views/home_view.dart';
// import '../modules/home/bindings/home_binding.dart';

// Prices
import '../modules/prices/views/daily_prices_view.dart';
import '../modules/prices/bindings/prices_binding.dart';

// Settings
import '../modules/settings/views/settings_view.dart';
import '../modules/settings/bindings/settings_binding.dart';

// Dashboard
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';

// Reports
    import '../modules/reports/views/reports_view.dart';
    import '../modules/reports/bindings/reports_binding.dart';
    
    // Products
    import '../modules/products/views/products_view.dart';
    import '../modules/products/bindings/products_binding.dart';

    // Customers
    import '../modules/customers/views/customers_view.dart';
    import '../modules/customers/bindings/customer_binding.dart';

    // Orders
    import '../modules/orders/views/orders_view.dart';
    import '../modules/orders/views/purchase_list_view.dart';
    import '../modules/orders/bindings/order_binding.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final pages = <GetPage>[
    // Splash
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
    ),

    // Auth
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.pinLock,
      page: () => const PinLockView(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.pinSetup,
      page: () => const PinSetupView(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),

    // Dashboard (Main Shell)
    GetPage(
      name: AppRoutes.dashboard, // or AppRoutes.home if we want to replace it
      page: () => const DashboardView(),
      binding: DashboardBinding(),
      transition: Transition.fadeIn,
    ),

    // Home - keeping it for direct access if needed, or redirect to dashboard
    // Ideally, HomeView is now a child of DashboardView.
    // We can keep AppRoutes.home for internal navigation if needed,
    // but the main entry after login should be Dashboard.

// Products
    GetPage(
      name: AppRoutes.products,
      page: () => const ProductsView(),
      binding: ProductsBinding(),
      transition: Transition.rightToLeft,
    ),
    // TODO: Implement Add Product Page
    // GetPage(
    //   name: AppRoutes.addProduct,
    //   page: () => const AddProductView(),
    //   binding: ProductsBinding(),
    //   transition: Transition.rightToLeft,
    // ),

    // Daily Prices
    GetPage(
      name: AppRoutes.dailyPrices,
      page: () => const DailyPricesView(),
      binding: PricesBinding(),
      transition: Transition.rightToLeft,
    ),

    // Settings
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      transition: Transition.rightToLeft,
    ),

// Reports
    GetPage(
      name: AppRoutes.reports,
      page: () => const ReportsView(),
      binding: ReportsBinding(),
      transition: Transition.rightToLeft,
    ),

    // Customers
    GetPage(
      name: AppRoutes.customers,
      page: () => const CustomersView(),
      binding: CustomerBinding(),
      transition: Transition.rightToLeft,
    ),

    // Orders
    GetPage(
      name: AppRoutes.sales, // Using sales route for orders
      page: () => const OrdersView(),
      binding: OrderBinding(),
      transition: Transition.rightToLeft,
    ),

    // Purchase List
    GetPage(
      name: '/purchase-list',
      page: () => const PurchaseListView(),
      transition: Transition.rightToLeft,
    ),
  ];
}
