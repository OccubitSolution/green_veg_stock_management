/// Initial Binding
///
/// Global dependencies injected at app start
library;
import 'package:get/get.dart';
import '../data/providers/database_provider.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/product_repository.dart';
import '../data/repositories/price_repository.dart';
import '../controllers/app_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core Services
    Get.put(DatabaseProvider.instance, permanent: true);

    // Repositories
    Get.lazyPut(() => AuthRepository(), fenix: true);
    Get.lazyPut(() => ProductRepository(), fenix: true);
    Get.lazyPut(() => PriceRepository(), fenix: true);

    // Global Controllers
    Get.put(AppController(), permanent: true);
  }
}
