/// Products Binding
library;
import 'package:get/get.dart';
import '../../../data/repositories/product_repository.dart';
import '../controllers/products_controller.dart';
import '../controllers/product_form_controller.dart';

class ProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProductsController());
  }
}

class ProductFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => Get.find<ProductRepository>());
    Get.lazyPut(() => ProductFormController(Get.find<ProductRepository>()));
  }
}
