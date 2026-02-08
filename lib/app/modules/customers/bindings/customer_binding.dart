import 'package:get/get.dart';
import 'package:green_veg_stock_management/app/modules/customers/controllers/customer_controller.dart';

class CustomerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerController>(() => CustomerController());
  }
}
