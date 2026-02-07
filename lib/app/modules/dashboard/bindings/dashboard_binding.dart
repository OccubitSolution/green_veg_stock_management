import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../prices/controllers/daily_prices_controller.dart';
import '../../products/controllers/products_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<DailyPricesController>(() => DailyPricesController());
    Get.lazyPut<ProductsController>(() => ProductsController());
  }
}
