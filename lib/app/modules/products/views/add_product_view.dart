/// Add Product View — Functional Product Form
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/strings.dart';
import '../../../widgets/layouts/standard_page_layout.dart';
import '../../../widgets/forms/standard_form_fields.dart';
import '../controllers/product_form_controller.dart';

class AddProductView extends GetView<ProductFormController> {
  const AddProductView({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Get.locale?.languageCode ?? 'gu';
    
    return Obx(() => FormPageLayout(
      title: controller.editingProduct != null 
          ? AppStrings.editProduct.tr 
          : AppStrings.addProduct.tr,
      isLoading: controller.isLoading.value,
      onSave: () => controller.saveProduct(),
      form: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Information Section
            SectionHeader(
              title: 'Basic Information',
              subtitle: 'Enter product details',
            ),
            const SizedBox(height: 16),

            // Gujarati Name (Required)
            StandardTextField(
              label: AppStrings.productNameGujarati.tr,
              hint: AppStrings.enterProductName.tr,
              controller: controller.nameGuController,
              validator: controller.validateRequired,
            ),
            const SizedBox(height: 16),

            // English Name (Optional)
            StandardTextField(
              label: AppStrings.productNameEnglish.tr,
              hint: AppStrings.enterProductNameEnglish.tr,
              controller: controller.nameEnController,
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            StandardDropdown<dynamic>(
              label: AppStrings.category.tr,
              hint: AppStrings.selectCategory.tr,
              value: controller.selectedCategory.value,
              items: controller.categories,
              itemLabel: (cat) => cat.getName(lang),
              onChanged: (val) => controller.selectedCategory.value = val,
            ),
            const SizedBox(height: 16),

            // Unit Dropdown
            StandardDropdown<dynamic>(
              label: AppStrings.unit.tr,
              hint: AppStrings.selectUnit.tr,
              value: controller.selectedUnit.value,
              items: controller.units,
              itemLabel: (unit) => unit.getName(lang),
              onChanged: (val) => controller.selectedUnit.value = val,
            ),
            const SizedBox(height: 16),

            // Max Price (Optional)
            StandardTextField(
              label: AppStrings.maxPrice.tr,
              hint: AppStrings.enterMaxPrice.tr,
              controller: controller.maxPriceController,
              keyboardType: TextInputType.number,
              validator: controller.validatePrice,
              prefixIcon: const Icon(Icons.currency_rupee),
            ),
            const SizedBox(height: 24),

            // Image Section
            SectionHeader(
              title: 'Product Image',
              subtitle: 'Optional - Add product photo',
            ),
            const SizedBox(height: 16),

            StandardImagePicker(
              label: AppStrings.productImage.tr,
              imagePath: controller.selectedImagePath.value,
              onTap: () => controller.pickImage(),
              onClear: () => controller.selectedImagePath.value = null,
            ),
            const SizedBox(height: 24),

            // Status Section
            SectionHeader(
              title: 'Status',
              subtitle: 'Enable or disable product',
            ),
            const SizedBox(height: 16),

            StandardSwitch(
              label: AppStrings.active.tr,
              subtitle: AppStrings.productWillBeVisible.tr,
              value: controller.isActive.value,
              onChanged: (val) => controller.isActive.value = val,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ));
  }
}
