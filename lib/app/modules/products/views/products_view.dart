/// Products View - Redesigned with modern UI and Animations
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/products_controller.dart';
import '../../../theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/common_widgets.dart';

class ProductsView extends GetView<ProductsController> {
  const ProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar with Gradient
            _buildAppBar(context),

            // Search Bar
            _buildSearchBar(context).animate().fadeIn(delay: 200.ms),

            // Category Filter Chips
            _buildCategoryFilter(context),

            const SizedBox(height: 8),

            // Products Grid/List
            Expanded(child: _buildProductsList(context)),
          ],
        ),
      ),
      floatingActionButton: _buildAddFAB(
        context,
      ).animate().scale(delay: 500.ms),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMD,
        vertical: AppTheme.spacingSM,
      ),
      decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
      child: Row(
        children: [
          // Back Button
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          // Title
          Expanded(
            child: Text(
              'products'.tr,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Product Count Badge
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppTheme.radiusXL),
              ),
              child: Text(
                '${controller.filteredProducts.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // View Toggle
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            ),
            child: IconButton(
              icon: const Icon(Icons.grid_view, color: Colors.white),
              onPressed: () {
                // TODO: Toggle grid/list view
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.5, end: 0);
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          boxShadow: AppTheme.softShadow,
        ),
        child: TextField(
          controller: controller.searchController,
          onChanged: controller.searchProducts,
          decoration: InputDecoration(
            hintText: 'search_products'.tr,
            hintStyle: const TextStyle(color: AppTheme.textSecondaryLight),
            prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
            suffixIcon: Obx(
              () => controller.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: AppTheme.textSecondaryLight,
                      ),
                      onPressed: controller.clearSearch,
                    )
                  : const SizedBox.shrink(),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMD,
              vertical: AppTheme.spacingMD,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Obx(() {
        final categories = controller.categories;
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: categories.length + 1,
          itemBuilder: (context, index) {
            Widget chip;
            if (index == 0) {
              chip = Obx(
                () => ModernFilterChip(
                  label: 'all'.tr,
                  isSelected: controller.selectedCategory.value.isEmpty,
                  color: AppTheme.primaryColor,
                  onSelected: () => controller.filterByCategory(''),
                ),
              );
            } else {
              final category = categories[index - 1];
              final categoryColors = {
                'leafy_vegetables': AppTheme.vegLeafy,
                'root_vegetables': AppTheme.vegRoot,
                'gourds': AppTheme.vegGourd,
                'exotic': AppTheme.vegExotic,
                'fruits': AppTheme.vegFruit,
              };

              chip = Obx(
                () => ModernFilterChip(
                  label: category.getName(Get.locale?.languageCode ?? 'gu'),
                  isSelected: controller.selectedCategory.value == category.id,
                  color: categoryColors[category.id] ?? AppTheme.accentColor,
                  onSelected: () => controller.filterByCategory(category.id),
                ),
              );
            }

            return chip
                .animate()
                .fadeIn(delay: (300 + (index * 50)).ms)
                .slideX(begin: 0.2, end: 0);
          },
        );
      }),
    );
  }

  Widget _buildProductsList(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SkeletonList();
      }

      if (controller.filteredProducts.isEmpty) {
        return EmptyStateWidget(
          icon: Icons.inventory_2_outlined,
          message: 'no_products_found'.tr,
          actionLabel: 'add_product'.tr,
          onAction: () => Get.toNamed(AppRoutes.addProduct),
        ).animate().fadeIn(duration: 300.ms);
      }

      return ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spacingMD),
        itemCount: controller.filteredProducts.length,
        itemBuilder: (context, index) {
          final product = controller.filteredProducts[index];
          return _buildProductCard(context, product)
              .animate()
              .fadeIn(delay: (50 * index).ms)
              .scale(begin: const Offset(0.9, 0.9), delay: (50 * index).ms);
        },
      );
    });
  }

  Widget _buildProductCard(BuildContext context, dynamic product) {
    final lang = Get.locale?.languageCode ?? 'gu';

    // Get category color based on product category
    Color iconColor = AppTheme.primaryColor;
    if (product.categoryId != null) {
      final categoryColors = {
        'leafy_vegetables': AppTheme.vegLeafy,
        'root_vegetables': AppTheme.vegRoot,
        'gourds': AppTheme.vegGourd,
        'exotic': AppTheme.vegExotic,
        'fruits': AppTheme.vegFruit,
      };
      iconColor = categoryColors[product.categoryId] ?? AppTheme.primaryColor;
    }

    return ModernProductCard(
      name: product.getName(lang),
      subtitle:
          '${product.unitSymbol ?? 'kg'} • ${product.categoryId ?? 'vegetables'.tr}',
      price: product.defaultPrice != null ? '₹${product.defaultPrice}' : null,
      icon: Icons.eco,
      iconColor: iconColor,
      onTap: () {
        // TODO: Navigate to product details
      },
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (product.defaultPrice != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              ),
              child: Text(
                '₹${product.defaultPrice}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: iconColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: AppTheme.textSecondaryLight),
        ],
      ),
    );
  }

  Widget _buildAddFAB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        boxShadow: AppTheme.coloredShadow(AppTheme.primaryColor),
      ),
      child: FloatingActionButton.extended(
        backgroundColor: Colors.transparent,
        elevation: 0,
        onPressed: () => Get.toNamed(AppRoutes.addProduct),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'add_product'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
