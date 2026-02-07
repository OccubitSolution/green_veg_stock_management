/// Daily Prices View - Redesigned with modern UI and Animations
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/daily_prices_controller.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';

class DailyPricesView extends GetView<DailyPricesController> {
  const DailyPricesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar with Gradient
            _buildAppBar(context),

            // Date Selector
            _buildDateSelector(context).animate().fadeIn(delay: 100.ms),

            // Search Bar
            _buildSearchBar(context).animate().fadeIn(delay: 200.ms),

            // Products List with Prices
            Expanded(child: _buildProductsList(context)),
          ],
        ),
      ),
      floatingActionButton: _buildSaveFAB(
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
              'daily_prices'.tr,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Copy Previous Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            ),
            child: IconButton(
              icon: const Icon(Icons.copy_all, color: Colors.white),
              tooltip: 'copy_previous'.tr,
              onPressed: controller.copyPreviousDayPrices,
            ),
          ),
          const SizedBox(width: 8),
          // Language Toggle
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            ),
            child: IconButton(
              icon: const Icon(Icons.translate, color: Colors.white),
              onPressed: () {
                final newLocale = Get.locale?.languageCode == 'gu'
                    ? const Locale('en')
                    : const Locale('gu');
                Get.updateLocale(newLocale);
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.5, end: 0);
  }

  Widget _buildDateSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      child: Center(
        child: Obx(
          () => ModernDateSelector(
            dateText: controller.formattedDate.value,
            onPrevious: controller.previousDay,
            onNext: controller.nextDay,
            onTap: () => controller.selectDate(context),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMD),
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

  Widget _buildProductsList(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SkeletonList();
      }

      if (controller.filteredProducts.isEmpty) {
        return EmptyStateWidget(
          icon: Icons.inventory_2_outlined,
          message: 'no_products_found'.tr,
        ).animate().fadeIn(duration: 300.ms);
      }

      return ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spacingMD),
        itemCount: controller.filteredProducts.length,
        itemBuilder: (context, index) {
          final product = controller.filteredProducts[index];
          final price = controller.getPriceForProduct(product.id);
          return _buildPriceCard(context, product, price, index)
              .animate()
              .fadeIn(delay: (50 * index).ms)
              .slideY(begin: 0.1, end: 0, delay: (50 * index).ms);
        },
      );
    });
  }

  Widget _buildPriceCard(
    BuildContext context,
    dynamic product,
    double? price,
    int index,
  ) {
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

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSM),
      child: PriceInputCard(
        name: product.getName(lang),
        unit: product.unitSymbol ?? 'kg',
        priceController: controller.priceControllers[product.id],
        onPriceChanged: (value) => controller.updatePrice(product.id, value),
        icon: Icons.eco,
        iconColor: iconColor,
      ),
    );
  }

  Widget _buildSaveFAB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        boxShadow: AppTheme.coloredShadow(AppTheme.primaryColor),
      ),
      child: FloatingActionButton.extended(
        backgroundColor: Colors.transparent,
        elevation: 0,
        onPressed: controller.savePrices,
        icon: const Icon(Icons.save, color: Colors.white),
        label: Text(
          'save'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
