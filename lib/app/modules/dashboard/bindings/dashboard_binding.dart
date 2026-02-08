import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../prices/controllers/daily_prices_controller.dart';
import '../../products/controllers/products_controller.dart';
import '../../reports/controllers/reports_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Use put instead of lazyPut to ensure controllers are immediately available
    Get.put<DashboardController>(DashboardController());
    Get.put<HomeController>(HomeController());
    Get.put<DailyPricesController>(DailyPricesController());
    Get.put<ProductsController>(ProductsController());
    Get.put<ReportsController>(ReportsController());
  }
}
