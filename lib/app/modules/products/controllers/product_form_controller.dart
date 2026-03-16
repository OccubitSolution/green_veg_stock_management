/// Product Form Controller
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/values/strings.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/product_repository.dart';

class ProductFormController extends GetxController {
  final ProductRepository _productRepository;
  final _storage = GetStorage();

  // Form controllers
  final nameGuController = TextEditingController();
  final nameEnController = TextEditingController();
  final maxPriceController = TextEditingController();

  // Observable states
  final isLoading = false.obs;
  final selectedCategory = Rxn<Category>();
  final selectedUnit = Rxn<ProductUnit>();
  final categories = <Category>[].obs;
  final units = <ProductUnit>[].obs;
  final selectedImagePath = Rxn<String>();
  final isActive = true.obs;

  // Form key
  final formKey = GlobalKey<FormState>();

  // Edit mode
  Product? editingProduct;

  ProductFormController(this._productRepository);

  @override
  void onInit() {
    super.onInit();
    _loadFormData();
  }

  @override
  void onClose() {
    nameGuController.dispose();
    nameEnController.dispose();
    maxPriceController.dispose();
    super.onClose();
  }

  Future<void> _loadFormData() async {
    isLoading.value = true;
    try {
      final vendorId = _storage.read('vendor_id');
      
      // Load categories and units
      final categoryList = await _productRepository.getCategories(vendorId);
      final unitList = await _productRepository.getUnits();
      
      categories.value = categoryList;
      units.value = unitList;

      // If editing, populate form
      if (editingProduct != null) {
        _populateForm(editingProduct!);
      }
    } catch (e) {
      debugPrint('❌ Load form data failed: $e');
      Get.snackbar(AppStrings.error.tr, AppStrings.failedToLoadData.tr);
    } finally {
      isLoading.value = false;
    }
  }

  void _populateForm(Product product) {
    nameGuController.text = product.nameGu;
    nameEnController.text = product.nameEn ?? '';
    maxPriceController.text = product.maxPrice?.toString() ?? '';
    isActive.value = product.isActive;
    
    // Set selected category
    if (product.categoryId != null) {
      selectedCategory.value = categories.firstWhereOrNull(
        (c) => c.id == product.categoryId,
      );
    }
    
    // Set selected unit
    if (product.unitId != null) {
      selectedUnit.value = units.firstWhereOrNull(
        (u) => u.id == product.unitId,
      );
    }
  }

  Future<void> pickImage() async {
    // TODO: Implement in Task 2.3 - Image upload
    Get.snackbar('info'.tr, 'Image upload will be implemented soon');
  }

  Future<void> saveProduct() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;
    try {
      final vendorId = _storage.read('vendor_id');
      final productNameGu = nameGuController.text.trim();
      
      // Check for duplicate product
      if (editingProduct == null) {
        final existingProducts = await _productRepository.getProducts(vendorId);
        final duplicate = existingProducts.any(
          (p) => p.nameGu.toLowerCase() == productNameGu.toLowerCase(),
        );
        if (duplicate) {
          Get.snackbar(
            'Warning'.tr,
            'This product already exists!'.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange[100],
          );
          isLoading.value = false;
          return;
        }
      }
      
      final productData = {
        'vendor_id': vendorId,
        'name_gu': productNameGu,
        'name_en': nameEnController.text.trim().isEmpty 
            ? null 
            : nameEnController.text.trim(),
        'category_id': selectedCategory.value?.id,
        'unit_id': selectedUnit.value?.id,
        'max_price': maxPriceController.text.isEmpty 
            ? null 
            : double.tryParse(maxPriceController.text),
        'is_active': isActive.value,
        'image_url': null,
      };

      if (editingProduct != null) {
        // Update existing product
        await _productRepository.updateProduct(
          editingProduct!.id,
          productData,
        );
        Get.snackbar(AppStrings.success.tr, AppStrings.productUpdatedSuccessfully.tr);
      } else {
        // Create new product
        final product = Product(
          id: '',
          vendorId: vendorId,
          nameGu: productData['name_gu'] as String,
          nameEn: productData['name_en'] as String?,
          categoryId: productData['category_id'] as String?,
          unitId: productData['unit_id'] as String?,
          maxPrice: productData['max_price'] as double?,
          isActive: productData['is_active'] as bool,
          createdAt: DateTime.now(),
        );
        
        final createdProduct = await _productRepository.createProduct(product);
        if (createdProduct == null) {
          throw Exception('Failed to create product: database returned null');
        }
        Get.snackbar(AppStrings.success.tr, AppStrings.productAddedSuccessfully.tr);
      }

      Get.back(result: true);
    } catch (e) {
      debugPrint('❌ Save product failed: $e');
      Get.snackbar(AppStrings.error.tr, AppStrings.failedToSaveProduct.tr);
    } finally {
      isLoading.value = false;
    }
  }

  String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired.tr;
    }
    return null;
  }

  String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    
    final price = double.tryParse(value);
    if (price == null) {
      return AppStrings.invalidNumber.tr;
    }
    
    if (price < 0) {
      return AppStrings.mustBePositive.tr;
    }
    
    return null;
  }
}
