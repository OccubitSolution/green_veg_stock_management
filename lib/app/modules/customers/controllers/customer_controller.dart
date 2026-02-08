import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:green_veg_stock_management/app/controllers/app_controller.dart';
import 'package:green_veg_stock_management/app/data/models/customer_order_models.dart';
import 'package:green_veg_stock_management/app/data/repositories/customer_repository.dart';

/// Customer Controller
/// Manages customer list, creation, and editing
class CustomerController extends GetxController {
  final CustomerRepository _repository = CustomerRepository();
  final AppController _appController = Get.find<AppController>();

  // Observables
  final RxList<Customer> customers = <Customer>[].obs;
  final RxList<Customer> filteredCustomers = <Customer>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final Rx<CustomerType?> filterType = Rx<CustomerType?>(null);

  // Form controllers
  final nameController = TextEditingController();
  final contactPersonController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final notesController = TextEditingController();
  final Rx<CustomerType> selectedType = CustomerType.other.obs;

  @override
  void onInit() {
    super.onInit();
    loadCustomers();

    // Debounce search
    debounce(searchQuery, (_) => filterCustomers(), time: 300.milliseconds);
  }

  @override
  void onClose() {
    nameController.dispose();
    contactPersonController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    notesController.dispose();
    super.onClose();
  }

  /// Load all customers
  Future<void> loadCustomers() async {
    isLoading.value = true;
    try {
      final vendorId = _appController.vendorId.value;
      if (vendorId.isEmpty) return;

      final data = await _repository.getCustomers(vendorId);
      customers.value = data;
      filterCustomers();
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_load_customers'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter customers based on search and type
  void filterCustomers() {
    var result = customers.toList();

    // Filter by type
    if (filterType.value != null) {
      result = result.where((c) => c.type == filterType.value).toList();
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result
          .where(
            (c) =>
                c.name.toLowerCase().contains(query) ||
                (c.phone?.toLowerCase().contains(query) ?? false) ||
                (c.contactPerson?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    }

    filteredCustomers.value = result;
  }

  /// Set filter type
  void setFilterType(CustomerType? type) {
    filterType.value = type;
    filterCustomers();
  }

  /// Clear all filters
  void clearFilters() {
    searchQuery.value = '';
    filterType.value = null;
    filterCustomers();
  }

  /// Initialize form for editing
  void initEditForm(Customer customer) {
    nameController.text = customer.name;
    contactPersonController.text = customer.contactPerson ?? '';
    phoneController.text = customer.phone ?? '';
    emailController.text = customer.email ?? '';
    addressController.text = customer.address ?? '';
    notesController.text = customer.notes ?? '';
    selectedType.value = customer.type;
  }

  /// Clear form
  void clearForm() {
    nameController.clear();
    contactPersonController.clear();
    phoneController.clear();
    emailController.clear();
    addressController.clear();
    notesController.clear();
    selectedType.value = CustomerType.other;
  }

  /// Save customer (create or update)
  Future<bool> saveCustomer({String? customerId}) async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'error'.tr,
        'name_required'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    isLoading.value = true;
    try {
      final vendorId = _appController.vendorId.value;
      if (vendorId.isEmpty) return false;

      final customer = Customer(
        id: customerId ?? '',
        vendorId: vendorId,
        name: nameController.text.trim(),
        contactPerson: contactPersonController.text.trim().isEmpty
            ? null
            : contactPersonController.text.trim(),
        phone: phoneController.text.trim().isEmpty
            ? null
            : phoneController.text.trim(),
        email: emailController.text.trim().isEmpty
            ? null
            : emailController.text.trim(),
        address: addressController.text.trim().isEmpty
            ? null
            : addressController.text.trim(),
        type: selectedType.value,
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (customerId != null) {
        await _repository.updateCustomer(customer);
        Get.snackbar(
          'success'.tr,
          'customer_updated'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        await _repository.createCustomer(customer);
        Get.snackbar(
          'success'.tr,
          'customer_created'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      await loadCustomers();
      clearForm();
      return true;
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_save_customer'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete customer
  Future<void> deleteCustomer(String customerId) async {
    try {
      await _repository.deleteCustomer(customerId);
      await loadCustomers();
      Get.snackbar(
        'success'.tr,
        'customer_deleted'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_delete_customer'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Get customer count
  int get customerCount => customers.length;

  /// Get customer count by type
  Map<CustomerType, int> get customerCountByType {
    final counts = <CustomerType, int>{};
    for (final customer in customers) {
      counts[customer.type] = (counts[customer.type] ?? 0) + 1;
    }
    return counts;
  }
}
