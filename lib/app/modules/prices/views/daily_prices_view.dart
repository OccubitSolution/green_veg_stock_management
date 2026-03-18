import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../controllers/daily_prices_controller.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';

class DailyPricesView extends GetView<DailyPricesController> {
  const DailyPricesView({super.key});

  String get lang => Get.locale?.languageCode ?? 'gu';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          // Header with Date Selector
          _buildHeader(context),

          // Compact Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacingMD,
              AppTheme.spacingXS,
              AppTheme.spacingMD,
              AppTheme.spacingXS,
            ),
            child: ModernSearchBar(
              controller: controller.searchController,
              hintText: 'search_products'.tr,
              onChanged: controller.searchProducts,
              onClear: controller.clearSearch,
            ),
          ).animate().fadeIn(delay: 200.ms),

          // Products List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const SkeletonList();
              }

              if (controller.filteredProducts.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.price_change_outlined,
                  message: 'no_products'.tr,
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.spacingMD,
                  AppTheme.spacingXS,
                  AppTheme.spacingMD,
                  100, // Space for bottom nav bar
                ),
                physics: const BouncingScrollPhysics(),
                itemCount: controller.filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = controller.filteredProducts[index];
                  final price = controller.getPriceForProduct(product.id);

                  return _buildPriceCard(context, product, price, index);
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppTheme.spacingMD,
        left: AppTheme.spacingMD,
        right: AppTheme.spacingMD,
        bottom: AppTheme.spacingMD,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'daily_prices'.tr,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(
                    () => Text(
                      controller.formattedDate.value,
                      style: TextStyle(
                        color: AppTheme.textSecondaryLight,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              // Copy + Save Buttons
              Row(
                children: [
                  IconButton(
                    onPressed: controller.copyPreviousDayPrices,
                    icon: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                      ),
                      child: const Icon(
                        Icons.content_copy_rounded,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    tooltip: 'copy_yesterday_prices'.tr,
                  ),
                  Obx(() => controller.hasChanges.value
                      ? TextButton.icon(
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.savePrices,
                          icon: controller.isLoading.value
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save_rounded, size: 18, color: Colors.white),
                          label: Text(
                            'save_prices'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                            ),
                          ),
                        )
                      : const SizedBox.shrink()),
                ],
              ),
            ],
          ).animate().fadeIn().slideY(begin: -0.3),

          const SizedBox(height: AppTheme.spacingMD),

          // Date Navigation
          Obx(
            () => ModernDateSelector(
              dateText: controller.formattedDate.value,
              onPrevious: controller.previousDay,
              onNext: controller.nextDay,
              onTap: () => controller.selectDate(context),
            ),
          ).animate().fadeIn(delay: 100.ms),
        ],
      ),
    );
  }

  Widget _buildPriceCard(
    BuildContext context,
    dynamic product,
    double? price,
    int index,
  ) {
    final iconColor = _getCategoryColor(product.categoryId);
    final yesterdayPrice = controller.getYesterdayPrice(product.id);

    // Calculate delay with a max cap
    final delayMs = (index * 50).clamp(0, 500);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingXS),
      child:
          PriceInputCard(
                name: product.getName(lang),
                unit: product.unitSymbol ?? 'kg',
                priceController: controller.priceControllers[product.id],
                onPriceChanged: (value) =>
                    controller.updatePrice(product.id, value),
                icon: Icons.eco,
                iconColor: iconColor,
                yesterdayPrice: yesterdayPrice,
                currentPrice: price,
              )
              .animate()
              .fadeIn(delay: Duration(milliseconds: delayMs))
              .slideX(begin: 0.1),
    );
  }

  Color _getCategoryColor(String? categoryId) {
    return AppTheme.getCategoryColor(categoryId);
  }
}
