import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:green_veg_stock_management/app/controllers/app_controller.dart';
import 'package:green_veg_stock_management/app/data/models/customer_order_models.dart';
import 'package:green_veg_stock_management/app/data/models/phase2_models.dart';
import 'package:green_veg_stock_management/app/data/repositories/sales_repository.dart';
import 'package:green_veg_stock_management/app/data/repositories/order_repository.dart';

class SalesController extends GetxController {
  final SalesRepository _repository = SalesRepository();
  final OrderRepository _orderRepository = OrderRepository();
  final AppController _appController = Get.find<AppController>();

  // Observables
  final RxList<Sale> sales = <Sale>[].obs;
  final RxList<Sale> pendingDeliveries = <Sale>[].obs;
  final RxList<Order> pendingOrders = <Order>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isConverting = false.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  // Stats
  final RxInt totalSales = 0.obs;
  final RxDouble totalRevenue = 0.0.obs;
  final RxDouble totalPaid = 0.0.obs;
  final RxDouble totalPending = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadSales();
    loadPendingOrders();
  }

  Future<void> loadSales() async {
    isLoading.value = true;
    try {
      final vendorId = _appController.vendorId.value;
      if (vendorId.isEmpty) {
        Get.snackbar('Error', 'Vendor ID not found');
        return;
      }

      final data = await _repository.getSales(
        vendorId,
        startDate: selectedDate.value.subtract(const Duration(days: 30)),
        endDate: selectedDate.value,
      );
      sales.value = data;

      // Load stats
      final stats = await _repository.getSalesStats(
        vendorId,
        selectedDate.value,
      );
      totalSales.value = stats['totalSales'];
      totalRevenue.value = stats['totalRevenue'];
      totalPaid.value = stats['totalPaid'];
      totalPending.value = stats['totalPending'];
    } catch (e) {
      Get.snackbar('error'.tr, 'failed_to_load_sales'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadPendingOrders() async {
    try {
      final vendorId = _appController.vendorId.value;
      if (vendorId.isEmpty) return;

      final orders = await _orderRepository.getOrdersByDate(
        vendorId,
        selectedDate.value,
      );
      // Filter only confirmed/pending orders that don't have sales yet
      pendingOrders.value = orders
          .where(
            (o) =>
                o.status == OrderStatus.confirmed ||
                o.status == OrderStatus.pending,
          )
          .toList();
    } catch (e) {
      debugPrint('Error loading pending orders: $e');
    }
  }

  Future<void> convertOrderToSale(String orderId, List<SaleItem> items) async {
    isConverting.value = true;
    try {
      final vendorId = _appController.vendorId.value;
      if (vendorId.isEmpty) {
        Get.snackbar('Error', 'Vendor ID not found');
        return;
      }

      await _repository.createSaleFromOrder(orderId, vendorId, items);

      Get.snackbar('success'.tr, 'order_converted_to_sale'.tr);
      await loadSales();
      await loadPendingOrders();
    } catch (e) {
      Get.snackbar('error'.tr, 'failed_to_convert_order'.tr);
    } finally {
      isConverting.value = false;
    }
  }

  Future<void> markDelivered(String saleId) async {
    try {
      await _repository.markDelivered(saleId);
      await loadSales();
      Get.snackbar('success'.tr, 'sale_marked_delivered'.tr);
    } catch (e) {
      Get.snackbar('error'.tr, 'failed_to_mark_delivered'.tr);
    }
  }

  Future<void> recordPayment(String saleId, double amount) async {
    try {
      await _repository.recordPayment(saleId, amount);
      await loadSales();
      Get.snackbar('success'.tr, 'payment_recorded'.tr);
    } catch (e) {
      Get.snackbar('error'.tr, 'failed_to_record_payment'.tr);
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  List<Sale> get pendingSales {
    return sales.where((s) => s.status == SaleStatus.pending).toList();
  }

  List<Sale> get deliveredSales {
    return sales.where((s) => s.status == SaleStatus.delivered).toList();
  }
}
