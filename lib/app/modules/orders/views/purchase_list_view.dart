import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:green_veg_stock_management/app/controllers/app_controller.dart';
import 'package:green_veg_stock_management/app/data/models/customer_order_models.dart';
import 'package:green_veg_stock_management/app/data/repositories/order_repository.dart';
import 'package:green_veg_stock_management/app/theme/app_theme.dart';

/// Purchase List View
/// Shows aggregated orders - the KEY feature for the vegetable broker
/// Groups all orders by product and sums quantities
class PurchaseListView extends StatefulWidget {
  const PurchaseListView({super.key});

  @override
  State<PurchaseListView> createState() => _PurchaseListViewState();
}

class _PurchaseListViewState extends State<PurchaseListView> {
  final OrderRepository _repository = OrderRepository();
  final AppController _appController = Get.find<AppController>();

  DateTime selectedDate = DateTime.now();
  List<AggregatedOrderItem> aggregatedItems = [];
  bool isLoading = false;
  Map<String, dynamic> stats = {};
  
  // Track purchased items (product ID -> isPurchased)
  final Set<String> _selectedProductIds = {};
  bool isSelectionMode = false;

  // Compact sizing specifications
  static const double _cardBorderRadius = 12.0; // Reduced from 16
  static const double _spacingXS = 3.0; // Reduced from 4
  static const double _spacingSM = 6.0; // Reduced from 8
  static const double _spacingMD = 10.0; // Reduced from 16
  static const double _spacingLG = 16.0; // Reduced from 24
  static const double _spacingXL = 20.0; // Reduced from 32

  @override
  void initState() {
    super.initState();
    _loadAggregatedData();
  }

  Future<void> _loadAggregatedData() async {
    setState(() => isLoading = true);

    try {
      final vendorId = _appController.vendorId.value;
      if (vendorId.isEmpty) {
        setState(() => isLoading = false);
        Get.snackbar(
          'error'.tr,
          'Vendor ID not found. Please log in again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
        );
        return;
      }

      // Check if user is staff - use inviter's orders
      final inviterId = _appController.inviterId.value;
      
      final items = await _repository.getAggregatedOrders(
        vendorId,
        selectedDate,
        inviterVendorId: inviterId.isNotEmpty ? inviterId : null,
      );
      final orderStats = await _repository.getOrderStats(
        vendorId,
        selectedDate,
        inviterVendorId: inviterId.isNotEmpty ? inviterId : null,
      );

      setState(() {
        aggregatedItems = items;
        stats = orderStats;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Purchase list error: $e');
      Get.snackbar(
        'error'.tr,
        'Failed to load: ${e.toString().substring(0, e.toString().length.clamp(0, 100))}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        duration: const Duration(seconds: 5),
      );
    }
  }

  void _setDate(DateTime date) {
    setState(() => selectedDate = date);
    _loadAggregatedData();
  }

  String _generateShareText() {
    final buffer = StringBuffer();
    buffer.writeln(
      '🥬 ${'purchase_list'.tr} - ${DateFormat('dd MMM yyyy').format(selectedDate)}',
    );
    buffer.writeln('═' * 40);
    buffer.writeln();

    for (var i = 0; i < aggregatedItems.length; i++) {
      final item = aggregatedItems[i];
      buffer.writeln(
        '${i + 1}. ${item.getProductName(Get.locale?.languageCode ?? 'en')}',
      );
      buffer.writeln(
        '   📦 ${item.totalQuantity.toStringAsFixed(1)} ${item.unitSymbol}',
      );
      buffer.writeln('   👥 ${item.orderCount} ${'customers'.tr}');
      buffer.writeln();
    }

    buffer.writeln('═' * 40);
    buffer.writeln('${'total_items'.tr}: ${aggregatedItems.length}');
    buffer.writeln('${'total_customers'.tr}: ${stats['totalCustomers'] ?? 0}');

    return buffer.toString();
  }

  String _generateSelectedShareText() {
    final buffer = StringBuffer();
    buffer.writeln(
      '🥬 ${'selected_items'.tr} - ${DateFormat('dd MMM yyyy').format(selectedDate)}',
    );
    buffer.writeln('═' * 40);
    buffer.writeln();

    int count = 1;
    for (final item in aggregatedItems) {
      if (_selectedProductIds.contains(item.productId)) {
        buffer.writeln(
          '${count++}. ${item.getProductName(Get.locale?.languageCode ?? 'en')}',
        );
        buffer.writeln(
          '   📦 ${item.totalQuantity.toStringAsFixed(1)} ${item.unitSymbol}',
        );
        buffer.writeln();
      }
    }

    buffer.writeln('═' * 40);
    buffer.writeln('${'total_selected'.tr}: ${count - 1}');

    return buffer.toString();
  }

  Future<void> _togglePurchased(String productId, bool currentlyPurchased) async {
    try {
      final vendorId = _appController.vendorId.value;
      await _repository.markProductAsPurchased(
        vendorId,
        selectedDate,
        productId,
        !currentlyPurchased,
      );
      // Reload data to reflect change
      _loadAggregatedData();
    } catch (e) {
      Get.snackbar('error'.tr, 'Failed to update: $e');
    }
  }

  Future<void> _markSelectedAsPurchased() async {
    if (_selectedProductIds.isEmpty) return;
    
    setState(() => isLoading = true);
    try {
      final vendorId = _appController.vendorId.value;
      for (final pid in _selectedProductIds) {
        await _repository.markProductAsPurchased(
          vendorId,
          selectedDate,
          pid,
          true,
        );
      }
      _selectedProductIds.clear();
      isSelectionMode = false;
      await _loadAggregatedData();
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar('error'.tr, 'Failed to update items');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Column(
        children: [
          // Compact Header with inline stats
          _buildCompactHeader(context),

          // Purchase List
          Expanded(
            child: isLoading
                ? _buildLoadingState()
                : aggregatedItems.isEmpty
                ? _buildEmptyState()
                : _buildPurchaseList(),
          ),
        ],
      ),
      bottomNavigationBar: aggregatedItems.isNotEmpty
          ? _buildBottomBar(context)
          : null,
    );
  }

  Widget _buildCompactHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Title row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                  Expanded(
                    child: Text(
                      'purchase_list'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    onPressed: _loadAggregatedData,
                    icon: const Icon(Icons.refresh, color: Colors.white, size: 22),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isSelectionMode = !isSelectionMode;
                        if (!isSelectionMode) _selectedProductIds.clear();
                      });
                    },
                    icon: Icon(
                      isSelectionMode ? Icons.close : Icons.playlist_add_check_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            
            // Date selector - inline compact
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _setDate(selectedDate.subtract(const Duration(days: 1))),
                    icon: const Icon(Icons.chevron_left, color: Colors.white, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) _setDate(picked);
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('dd MMM yyyy').format(selectedDate),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _setDate(selectedDate.add(const Duration(days: 1))),
                    icon: const Icon(Icons.chevron_right, color: Colors.white, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
            ),
            
            // Inline stats - single row
            Container(
              margin: const EdgeInsets.fromLTRB(12, 6, 12, 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInlineStat(Icons.inventory_2, aggregatedItems.length.toString(), 'items'.tr),
                  Container(width: 1, height: 24, color: Colors.white.withValues(alpha: 0.3)),
                  _buildInlineStat(Icons.people, (stats['totalCustomers'] ?? 0).toString(), 'customers'.tr),
                  Container(width: 1, height: 24, color: Colors.white.withValues(alpha: 0.3)),
                  _buildInlineStat(Icons.receipt, (stats['totalOrders'] ?? 0).toString(), 'orders'.tr),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInlineStat(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: _spacingMD),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
              margin: const EdgeInsets.only(bottom: _spacingMD),
              padding: const EdgeInsets.all(_spacingMD),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_cardBorderRadius),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: _spacingMD),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: _spacingXS),
                        Container(
                          width: 80,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fade(duration: 800.ms, begin: 0.5, end: 1.0);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryDark.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 56,
              color: AppTheme.primaryDark,
            ),
          ),
          const SizedBox(height: _spacingLG),
          Text(
            'no_orders_yet'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryLight,
            ),
          ),
          const SizedBox(height: _spacingSM),
          Text(
            'add_orders_to_generate'.tr,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: _spacingXL),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed('/orders'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryDark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: _spacingLG,
                vertical: _spacingMD,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add),
            label: Text('add_orders'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 80), // Reduced padding
      itemCount: aggregatedItems.length,
      itemBuilder: (context, index) {
        final item = aggregatedItems[index];
        return _buildPurchaseItemCard(item, index);
      },
    );
  }

  Widget _buildPurchaseItemCard(AggregatedOrderItem item, int index) {
    final isPurchased = item.isPurchased;
    final isSelected = _selectedProductIds.contains(item.productId);
    
    // Generate compact customer breakdown: "User1: 1kg, User2: 32kg, User3: 1.5kg"
    final breakdownText = item.itemDetails.map((d) => 
      '${d.customerName}: ${d.quantity.toStringAsFixed(d.quantity % 1 == 0 ? 0 : 1)}${item.unitSymbol}'
    ).join(', ');

    return GestureDetector(
      onLongPress: () {
        setState(() {
          isSelectionMode = true;
          _selectedProductIds.add(item.productId);
        });
      },
      onTap: isSelectionMode ? () {
        setState(() {
          if (isSelected) {
            _selectedProductIds.remove(item.productId);
            if (_selectedProductIds.isEmpty) isSelectionMode = false;
          } else {
            _selectedProductIds.add(item.productId);
          }
        });
      } : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : isPurchased ? AppTheme.successLight : Colors.white,
          borderRadius: BorderRadius.circular(_cardBorderRadius),
          border: Border.all(
            color: isSelected 
                ? AppTheme.primaryColor 
                : isPurchased ? AppTheme.success.withValues(alpha: 0.5) : AppTheme.borderLight,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // Selection Checkbox (left)
              if (isSelectionMode) ...[
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryColor : Colors.grey[400]!,
                      width: 1.5,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: isSelected 
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : null,
                ),
                const SizedBox(width: 12),
              ],
              
              // Product info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.getProductName(Get.locale?.languageCode ?? 'en'),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isPurchased ? AppTheme.textSecondaryLight : AppTheme.textPrimaryLight,
                              decoration: isPurchased ? TextDecoration.lineThrough : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isPurchased 
                              ? AppTheme.success.withValues(alpha: 0.15)
                              : AppTheme.primaryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${item.totalQuantity.toStringAsFixed(item.totalQuantity % 1 == 0 ? 0 : 1)} ${item.unitSymbol}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isPurchased ? AppTheme.success : AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      breakdownText,
                      style: TextStyle(
                        fontSize: 11,
                        color: isPurchased ? AppTheme.textTertiaryLight : AppTheme.textSecondaryLight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Purchased Toggle (Right)
              if (!isSelectionMode) ...[
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () => _togglePurchased(item.productId, isPurchased),
                  icon: Icon(
                    isPurchased ? Icons.check_circle : Icons.circle_outlined,
                    color: isPurchased ? AppTheme.success : AppTheme.textTertiaryLight,
                    size: 26,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate(delay: (index * 30).ms).fadeIn(duration: 200.ms).slideY(begin: 0.05);
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: isSelectionMode 
          ? Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final text = _generateSelectedShareText();
                      Share.share(text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.share, size: 18),
                    label: Text('share_selected'.tr, style: const TextStyle(fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _markSelectedAsPurchased,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.done_all, size: 18),
                    label: Text('mark_purchased'.tr, style: const TextStyle(fontSize: 14)),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final text = _generateShareText();
                      Clipboard.setData(ClipboardData(text: text));
                      Get.snackbar(
                        'copied'.tr,
                        'purchase_list_copied'.tr,
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 2),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.info,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.copy, size: 18),
                    label: Text('copy'.tr, style: const TextStyle(fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final text = _generateShareText();
                      try {
                        await Share.share(
                          text,
                          subject: 'Purchase List - ${DateFormat('dd MMM yyyy').format(selectedDate)}',
                        );
                      } catch (e) {
                        Get.snackbar(
                          'error'.tr,
                          'Failed to share: $e',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red[100],
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.share, size: 18),
                    label: Text('share_list'.tr, style: const TextStyle(fontSize: 14)),
                  ),
                ),
              ],
            ),
      ),
    );
  }
}
