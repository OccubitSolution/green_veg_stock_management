import 'package:get/get.dart';
import 'package:green_veg_stock_management/app/modules/orders/controllers/order_controller.dart';

class OrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderController>(() => OrderController(), fenix: true);
  }
}
