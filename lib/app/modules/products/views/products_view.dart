import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../controllers/products_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';

class ProductsView extends GetView<ProductsController> {
  const ProductsView({super.key});

  String get lang => Get.locale?.languageCode ?? 'en';

  @override
  Widget build(BuildContext context) {
    // Refresh products every time the view is built/opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchData();
    });
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context),

            // Category Filters
            _buildCategoryFilters(context),

            // Product List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const SkeletonList(count: 8);
                }

                if (controller.filteredProducts.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.eco_outlined,
                    message: 'no_products_found'.tr,
                    actionLabel: 'add_product'.tr,
                    onAction: () async {
                      final result = await Get.toNamed(AppRoutes.addProduct);
                      if (result == true) {
                        controller.fetchData();
                      }
                    },
                  );
                }

                return _buildProductList(context);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingMD,
        AppTheme.spacingMD,
        AppTheme.spacingMD,
        AppTheme.spacingSM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row with Add Button
          Row(
            children: [
              Expanded(
                child: Text(
                  'products'.tr,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // Add Product Button
              Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                  boxShadow: AppTheme.coloredShadow(AppTheme.primaryColor),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Get.toNamed(AppRoutes.addProduct),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'add'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Stats Badge
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.eco_rounded,
                        size: 14,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${controller.products.length}',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ).animate().fadeIn().slideX(begin: -0.1),
          const SizedBox(height: AppTheme.spacingMD),

          // Search Bar
          ModernSearchBar(
            controller: controller.searchController,
            hintText: 'search_products'.tr,
            onChanged: (value) => controller.searchProducts(value),
            onClear: () => controller.searchProducts(''),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters(BuildContext context) {
    return Obx(() {
      final selectedCat = controller.selectedCategory.value;
      final cats = controller.categories;
      return SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMD),
          itemCount: cats.length + 1, // +1 for "All"
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ModernFilterChip(
                  label: 'all'.tr,
                  isSelected: selectedCat.isEmpty,
                  icon: Icons.grid_view_rounded,
                  onSelected: () => controller.filterByCategory(''),
                ),
              );
            }

            final category = cats[index - 1];
            final isSelected = selectedCat == category.id;
            final color = AppTheme.getCategoryColor(category.id);

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ModernFilterChip(
                label: category.getName(lang),
                isSelected: isSelected,
                color: color,
                icon: _getCategoryIcon(category.id),
                onSelected: () => controller.filterByCategory(category.id),
              ),
            );
          },
        ),
      );
    });
  }

  IconData _getCategoryIcon(String? categoryId) {
    const categoryIcons = {
      'leafy_vegetables': Icons.eco,
      'root_vegetables': Icons.spa,
      'gourds': Icons.grass,
      'exotic': Icons.local_florist,
      'fruits': Icons.apple,
    };
    return categoryIcons[categoryId] ?? Icons.category;
  }

  Widget _buildProductList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingMD,
        AppTheme.spacingMD,
        AppTheme.spacingMD,
        100, // Space for bottom nav bar
      ),
      itemCount: controller.filteredProducts.length,
      itemBuilder: (context, index) {
        final product = controller.filteredProducts[index];
        return _buildProductCard(context, product, index);
      },
    );
  }

  Widget _buildProductCard(BuildContext context, dynamic product, int index) {
    final iconColor = AppTheme.getCategoryColor(product.categoryId);
    
    // Get category name from the categories list
    String categoryName = 'vegetables'.tr;
    if (product.categoryId != null) {
      final category = controller.categories.firstWhereOrNull(
        (cat) => cat.id == product.categoryId,
      );
      if (category != null) {
        categoryName = category.getName(lang);
      }
    }

    return ModernProductCard(
          name: product.getName(lang),
          subtitle: '${product.unitSymbol ?? 'kg'} • $categoryName',
          price: product.currentPrice != null
              ? '₹${product.currentPrice}'
              : null,
          icon: Icons.eco,
          iconColor: iconColor,
          onTap: () {
            Get.toNamed(AppRoutes.productDetail, arguments: product.id);
          },
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (product.currentPrice != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  ),
                  child: Text(
                    '₹${product.currentPrice}',
                    style: TextStyle(
                      color: iconColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  ),
                  child: Text(
                    'no_price'.tr,
                    style: const TextStyle(
                      color: AppTheme.warning,
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textTertiaryLight,
                size: 20,
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: (50 * index).clamp(0, 300)))
        .slideX(begin: 0.05);
  }
}
