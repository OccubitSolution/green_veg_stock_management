/// Prices Binding
import 'package:get/get.dart';
import '../controllers/daily_prices_controller.dart';

class PricesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DailyPricesController());
  }
}
