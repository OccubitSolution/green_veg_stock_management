/// Home Controller
library;

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/price_repository.dart';
import '../../../data/repositories/purchase_repository.dart';
import '../../../data/repositories/inventory_repository.dart';
import '../../../data/repositories/sales_repository.dart';
import '../../../data/repositories/order_repository.dart';

class HomeController extends GetxController {
  // Direct instantiation - repositories are stateless services
  final ProductRepository _productRepository = ProductRepository();
  final PriceRepository _priceRepository = PriceRepository();
  final PurchaseRepository _purchaseRepository = PurchaseRepository();
  final InventoryRepository _inventoryRepository = InventoryRepository();
  final SalesRepository _salesRepository = SalesRepository();
  final OrderRepository _orderRepository = OrderRepository();
  final _storage = GetStorage();

  // Observable States
  final vendorName = ''.obs;
  final todayDate = ''.obs;
  final productCount = '0'.obs;
  final categoryCount = '0'.obs;
  final pricesSetCount = '0'.obs;

  // Phase 2 Stats
  final todayPurchases = '0'.obs;
  final todayPurchaseAmount = '₹0'.obs;
  final lowStockCount = '0'.obs;
  final outOfStockCount = '0'.obs;
  final todaySales = '₹0'.obs;
  final todaySalesCount = '0'.obs;
  final pendingOrders = '0'.obs;
  final pendingDeliveries = '0'.obs;

  final currentNavIndex = 0.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserInfo();
    _loadTodayDate();
    fetchDashboardData();
  }

  void _loadUserInfo() {
    vendorName.value = _storage.read('vendor_name') ?? 'Guest';
  }

  void _loadTodayDate() {
    final now = DateTime.now();
    final lang = _storage.read('language') ?? 'gu';

    if (lang == 'gu') {
      todayDate.value = DateFormat('dd MMMM, yyyy', 'en').format(now);
    } else {
      todayDate.value = DateFormat('MMMM dd, yyyy').format(now);
    }
  }

  Future<void> fetchDashboardData() async {
    isLoading.value = true;

    try {
      final vendorId = _storage.read('vendor_id');
      if (vendorId == null) return;

      // Phase 1 Stats
      // Fetch product count
      final products = await _productRepository.getProducts(vendorId);
      productCount.value = products.length.toString();

      // Fetch today's prices count
      final prices = await _priceRepository.getTodayPrices(vendorId);
      pricesSetCount.value = prices.length.toString();

      // Fetch categories count
      final categories = await _productRepository.getCategories(vendorId);
      categoryCount.value = categories.length.toString();

      // Phase 2 Stats
      final today = DateTime.now();

      // Purchase Stats
      try {
        final purchaseStats = await _purchaseRepository.getPurchaseStats(
          vendorId,
          today,
        );
        todayPurchases.value = purchaseStats['totalPurchases'].toString();
        todayPurchaseAmount.value =
            '₹${purchaseStats['totalAmount'].toStringAsFixed(0)}';
      } catch (e) {
        todayPurchases.value = '0';
        todayPurchaseAmount.value = '₹0';
      }

      // Inventory Stats
      try {
        final inventoryStats = await _inventoryRepository.getInventoryStats(
          vendorId,
        );
        lowStockCount.value = inventoryStats['lowStock'].toString();
        outOfStockCount.value = inventoryStats['outOfStock'].toString();
      } catch (e) {
        lowStockCount.value = '0';
        outOfStockCount.value = '0';
      }

      // Sales Stats
      try {
        final salesStats = await _salesRepository.getSalesStats(
          vendorId,
          today,
        );
        todaySalesCount.value = salesStats['totalSales'].toString();
        todaySales.value = '₹${salesStats['totalRevenue'].toStringAsFixed(0)}';
      } catch (e) {
        todaySalesCount.value = '0';
        todaySales.value = '₹0';
      }

      // Pending Orders
      try {
        final orders = await _orderRepository.getOrdersByDate(vendorId, today);
        pendingOrders.value = orders.length.toString();
      } catch (e) {
        pendingOrders.value = '0';
      }

      // Pending Deliveries
      try {
        final pendingSales = await _salesRepository.getPendingDeliveries(
          vendorId,
        );
        pendingDeliveries.value = pendingSales.length.toString();
      } catch (e) {
        pendingDeliveries.value = '0';
      }
    } catch (e) {
      // Error fetching dashboard data - values remain at defaults
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await fetchDashboardData();
  }
}
