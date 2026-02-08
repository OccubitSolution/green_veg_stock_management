import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:green_veg_stock_management/app/data/models/customer_order_models.dart';
import 'package:green_veg_stock_management/app/modules/customers/controllers/customer_controller.dart';
import 'package:green_veg_stock_management/app/theme/app_theme.dart';
import 'package:green_veg_stock_management/app/widgets/common_widgets.dart';

class CustomersView extends GetView<CustomerController> {
  const CustomersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // App Bar with Search
          SliverAppBar(
            expandedHeight: 180,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: AppTheme.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'customers'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => Text(
                            '${controller.customerCount} ${'customers_registered'.tr}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLight,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      onChanged: (value) =>
                          controller.searchQuery.value = value,
                      decoration: InputDecoration(
                        hintText: 'search_customers'.tr,
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppTheme.primaryColor,
                        ),
                        suffixIcon: Obx(
                          () => controller.searchQuery.value.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    controller.searchQuery.value = '';
                                  },
                                )
                              : const SizedBox.shrink(),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppTheme.primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Obx(
                        () => Row(
                          children: [
                            _buildFilterChip(
                              null,
                              'all'.tr,
                              controller.filterType.value == null,
                            ),
                            ...CustomerType.values.map(
                              (type) => _buildFilterChip(
                                type,
                                type.getName(Get.locale?.languageCode ?? 'en'),
                                controller.filterType.value == type,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Customer List
          Obx(() {
            if (controller.isLoading.value) {
              return const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (controller.filteredCustomers.isEmpty) {
              return SliverFillRemaining(
                child: EmptyStateWidget(
                  icon: Icons.people_outline,
                  message: 'no_customers'.tr,
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final customer = controller.filteredCustomers[index];
                  return _buildCustomerCard(customer, index);
                }, childCount: controller.filteredCustomers.length),
              ),
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'customers_fab',
        onPressed: () => _showAddCustomerDialog(context),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add),
        label: Text('add_customer'.tr),
      ).animate().scale(delay: 300.ms, duration: 300.ms),
    );
  }

  Widget _buildFilterChip(CustomerType? type, String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        onSelected: (_) => controller.setFilterType(type),
        label: Text(label),
        backgroundColor: Colors.white,
        selectedColor: AppTheme.primaryColor.withOpacity(0.15),
        checkmarkColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
        ),
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer, int index) {
    return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () => _showEditCustomerDialog(Get.context!, customer),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Customer Icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          customer.type.color.withOpacity(0.8),
                          customer.type.color,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: customer.type.color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      customer.type.icon,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Customer Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.business,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              customer.type.getName(
                                Get.locale?.languageCode ?? 'en',
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        if (customer.phone != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.phone,
                                size: 14,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                customer.phone!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Actions
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey[400]),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditCustomerDialog(Get.context!, customer);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(customer);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text('edit'.tr),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              size: 20,
                              color: Colors.red[400],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'delete'.tr,
                              style: TextStyle(color: Colors.red[400]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
        .animate(delay: (index * 50).ms)
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.2);
  }

  void _showAddCustomerDialog(BuildContext context) {
    controller.clearForm();
    _showCustomerFormDialog(context, null);
  }

  void _showEditCustomerDialog(BuildContext context, Customer customer) {
    controller.initEditForm(customer);
    _showCustomerFormDialog(context, customer);
  }

  void _showCustomerFormDialog(BuildContext context, Customer? customer) {
    final isEditing = customer != null;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isEditing ? Icons.edit : Icons.person_add,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditing ? 'edit_customer'.tr : 'add_customer'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            isEditing
                                ? 'update_customer_info'.tr
                                : 'enter_customer_details'.tr,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Form
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer Type
                      Text(
                        'customer_type'.tr,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Obx(
                        () => Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: CustomerType.values.map((type) {
                            final isSelected =
                                controller.selectedType.value == type;
                            return ChoiceChip(
                              selected: isSelected,
                              onSelected: (_) =>
                                  controller.selectedType.value = type,
                              avatar: Icon(
                                type.icon,
                                size: 18,
                                color: isSelected ? Colors.white : type.color,
                              ),
                              label: Text(
                                type.getName(Get.locale?.languageCode ?? 'en'),
                              ),
                              selectedColor: type.color,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[700],
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                              backgroundColor: Colors.grey[100],
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Name
                      _buildTextField(
                        controller: controller.nameController,
                        label: 'customer_name'.tr,
                        hint: 'enter_customer_name'.tr,
                        icon: Icons.business,
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),

                      // Contact Person
                      _buildTextField(
                        controller: controller.contactPersonController,
                        label: 'contact_person'.tr,
                        hint: 'enter_contact_person'.tr,
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),

                      // Phone
                      _buildTextField(
                        controller: controller.phoneController,
                        label: 'phone'.tr,
                        hint: 'enter_phone'.tr,
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      // Email
                      _buildTextField(
                        controller: controller.emailController,
                        label: 'email'.tr,
                        hint: 'enter_email'.tr,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // Address
                      _buildTextField(
                        controller: controller.addressController,
                        label: 'address'.tr,
                        hint: 'enter_address'.tr,
                        icon: Icons.location_on_outlined,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),

                      // Notes
                      _buildTextField(
                        controller: controller.notesController,
                        label: 'notes'.tr,
                        hint: 'enter_notes'.tr,
                        icon: Icons.notes,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              // Actions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('cancel'.tr),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {
                          final success = await controller.saveCustomer(
                            customerId: customer?.id,
                          );
                          if (success) Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Obx(
                          () => controller.isLoading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(isEditing ? 'update'.tr : 'save'.tr),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryLight,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: Colors.red[400],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryColor,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(Customer customer) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange[600]),
            const SizedBox(width: 8),
            Text('delete_customer'.tr),
          ],
        ),
        content: Text(
          'delete_customer_confirmation'.trParams({'name': customer.name}),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteCustomer(customer.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
            ),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
  }
}

// Extension to add color property to CustomerType
extension CustomerTypeExtension on CustomerType {
  Color get color {
    switch (this) {
      case CustomerType.hotel:
        return const Color(0xFF5C6BC0); // Indigo
      case CustomerType.cafe:
        return const Color(0xFF8D6E63); // Brown
      case CustomerType.restaurant:
        return const Color(0xFFEF5350); // Red
      case CustomerType.supermarket:
        return const Color(0xFF42A5F5); // Blue
      case CustomerType.mess:
        return const Color(0xFF66BB6A); // Green
      case CustomerType.catering:
        return const Color(0xFFAB47BC); // Purple
      case CustomerType.other:
        return const Color(0xFF78909C); // Blue Grey
    }
  }
}
