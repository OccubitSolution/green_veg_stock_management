import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:green_veg_stock_management/app/controllers/app_controller.dart';
import 'package:green_veg_stock_management/app/data/models/customer_order_models.dart';
import 'package:green_veg_stock_management/app/data/repositories/order_repository.dart';

/// Purchase List View
/// Shows aggregated orders - the KEY feature for the vegetable broker
/// Groups all orders by product and sums quantities
class PurchaseListView extends StatefulWidget {
  const PurchaseListView({Key? key}) : super(key: key);

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

  // Exact sizing specifications
  static const double _headerHeight = 180.0;
  static const double _cardBorderRadius = 16.0;
  static const double _iconSize = 24.0;
  static const double _spacingXS = 4.0;
  static const double _spacingSM = 8.0;
  static const double _spacingMD = 16.0;
  static const double _spacingLG = 24.0;
  static const double _spacingXL = 32.0;

  @override
  void initState() {
    super.initState();
    _loadAggregatedData();
  }

  Future<void> _loadAggregatedData() async {
    setState(() => isLoading = true);

    try {
      final vendorId = _appController.vendorId.value;
      if (vendorId.isEmpty) return;

      final items = await _repository.getAggregatedOrders(
        vendorId,
        selectedDate,
      );
      final orderStats = await _repository.getOrderStats(
        vendorId,
        selectedDate,
      );

      setState(() {
        aggregatedItems = items;
        stats = orderStats;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar(
        'error'.tr,
        'failed_to_load_purchase_list'.tr,
        snackPosition: SnackPosition.BOTTOM,
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
    buffer.writeln('${'total_customers'.tr}: ${stats['totalCustomers']}');

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      body: Column(
        children: [
          // Header
          _buildHeader(context),

          // Date Selector
          _buildDateSelector(context),

          // Stats Cards
          _buildStatsRow(context),

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

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: _headerHeight,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00897B), Color(0xFF004D40)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(_cardBorderRadius),
          bottomRight: Radius.circular(_cardBorderRadius),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(_spacingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),

                  const Text(
                    'Purchase List',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),

                  // Refresh Button
                  IconButton(
                    onPressed: _loadAggregatedData,
                    icon: Container(
                      padding: const EdgeInsets.all(_spacingSM),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: _spacingLG),

              // Subtitle
              Text(
                'Aggregated quantities from all customer orders',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(_spacingMD),
      padding: const EdgeInsets.symmetric(
        horizontal: _spacingSM,
        vertical: _spacingXS,
      ),
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () =>
                _setDate(selectedDate.subtract(const Duration(days: 1))),
            icon: const Icon(Icons.chevron_left, color: Color(0xFF00695C)),
            padding: EdgeInsets.zero,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF00695C),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) _setDate(picked);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: Color(0xFF00695C),
                  ),
                  const SizedBox(width: _spacingSM),
                  Text(
                    DateFormat('EEE, dd MMM yyyy').format(selectedDate),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () =>
                _setDate(selectedDate.add(const Duration(days: 1))),
            icon: const Icon(Icons.chevron_right, color: Color(0xFF00695C)),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _spacingMD),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              Icons.inventory,
              aggregatedItems.length.toString(),
              'Products',
              const Color(0xFF00897B),
            ),
          ),
          const SizedBox(width: _spacingMD),
          Expanded(
            child: _buildStatCard(
              Icons.people,
              (stats['totalCustomers'] ?? 0).toString(),
              'Customers',
              const Color(0xFF5C6BC0),
            ),
          ),
          const SizedBox(width: _spacingMD),
          Expanded(
            child: _buildStatCard(
              Icons.receipt,
              (stats['totalOrders'] ?? 0).toString(),
              'Orders',
              const Color(0xFFFF7043),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(_spacingMD),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: _iconSize),
          const SizedBox(height: _spacingXS),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
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
              color: const Color(0xFF00695C).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 56,
              color: Color(0xFF00695C),
            ),
          ),
          const SizedBox(height: _spacingLG),
          Text(
            'No Orders Yet',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: _spacingSM),
          Text(
            'Add customer orders to generate purchase list',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: _spacingXL),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed('/orders'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00695C),
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
            label: const Text('Add Orders'),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseList() {
    return ListView.builder(
      padding: const EdgeInsets.all(_spacingMD),
      itemCount: aggregatedItems.length,
      itemBuilder: (context, index) {
        final item = aggregatedItems[index];
        return _buildPurchaseItemCard(item, index);
      },
    );
  }

  Widget _buildPurchaseItemCard(AggregatedOrderItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: _spacingMD),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: _spacingMD),
          childrenPadding: const EdgeInsets.all(_spacingMD),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00897B), Color(0xFF00695C)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.eco, color: Colors.white, size: 24),
          ),
          title: Text(
            item.getProductName(Get.locale?.languageCode ?? 'en'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          subtitle: Text(
            '${item.orderCount} customers ordered this',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: _spacingMD,
              vertical: _spacingSM,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF00897B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${item.totalQuantity.toStringAsFixed(1)} ${item.unitSymbol}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00897B),
              ),
            ),
          ),
          children: [
            const Divider(height: 1),
            const SizedBox(height: _spacingMD),
            Text(
              'Customer Breakdown:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: _spacingSM),
            ...item.itemDetails
                .map(
                  (detail) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: _spacingXS),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: _spacingSM),
                        Expanded(
                          child: Text(
                            detail.customerName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        Text(
                          '${detail.quantity.toStringAsFixed(1)} ${item.unitSymbol}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    ).animate(delay: (index * 50).ms).fadeIn().slideY(begin: 0.1);
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_spacingMD),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  final text = _generateShareText();
                  Clipboard.setData(ClipboardData(text: text));
                  Get.snackbar(
                    'Copied!',
                    'Purchase list copied to clipboard',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C6BC0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: _spacingMD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.copy),
                label: const Text('Copy'),
              ),
            ),
            const SizedBox(width: _spacingMD),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () {
                  final text = _generateShareText();
                  // Use share plugin here
                  Get.snackbar(
                    'Share',
                    'Sharing functionality will be implemented',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00695C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: _spacingMD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.share),
                label: const Text('Share List'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
