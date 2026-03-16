/// Profit Calculation Service
/// Calculates costs, revenue, and profits for orders and items
library;

import '../models/customer_order_models.dart';

/// Profit Summary
class ProfitSummary {
  final double totalRevenue;
  final double totalCost;
  final double totalProfit;
  final double profitMargin;
  final int orderCount;
  final int itemCount;

  ProfitSummary({
    required this.totalRevenue,
    required this.totalCost,
    required this.totalProfit,
    required this.profitMargin,
    required this.orderCount,
    required this.itemCount,
  });

  factory ProfitSummary.empty() {
    return ProfitSummary(
      totalRevenue: 0,
      totalCost: 0,
      totalProfit: 0,
      profitMargin: 0,
      orderCount: 0,
      itemCount: 0,
    );
  }
}

class ProfitCalculationService {
  /// Calculate profit for a single order item
  double calculateItemProfit(OrderItem item) {
    final revenue = item.totalPrice ?? 0;
    final cost = (item.costPrice ?? 0) * item.quantity;
    return revenue - cost;
  }

  /// Calculate profit margin for a single order item (as percentage)
  double calculateItemProfitMargin(OrderItem item) {
    final revenue = item.totalPrice ?? 0;
    if (revenue <= 0) return 0;

    final profit = calculateItemProfit(item);
    return (profit / revenue) * 100;
  }

  /// Calculate total cost for an order
  double calculateOrderCost(List<OrderItem> items) {
    return items.fold(0.0, (sum, item) {
      return sum + ((item.costPrice ?? 0) * item.quantity);
    });
  }

  /// Calculate total revenue for an order
  double calculateOrderRevenue(List<OrderItem> items) {
    return items.fold(0.0, (sum, item) {
      return sum + (item.totalPrice ?? 0);
    });
  }

  /// Calculate total profit for an order
  double calculateOrderProfit(List<OrderItem> items) {
    final revenue = calculateOrderRevenue(items);
    final cost = calculateOrderCost(items);
    return revenue - cost;
  }

  /// Calculate profit margin for an order (as percentage)
  double calculateOrderProfitMargin(List<OrderItem> items) {
    final revenue = calculateOrderRevenue(items);
    if (revenue <= 0) return 0;

    final profit = calculateOrderProfit(items);
    return (profit / revenue) * 100;
  }

  /// Calculate daily profit summary
  ProfitSummary calculateDailySummary(List<Order> orders) {
    if (orders.isEmpty) {
      return ProfitSummary.empty();
    }

    double totalRevenue = 0;
    double totalCost = 0;
    int itemCount = 0;

    for (final order in orders) {
      totalRevenue += order.totalAmount ?? 0;
      totalCost += order.totalCost ?? 0;
    }

    final totalProfit = totalRevenue - totalCost;
    final profitMargin = totalRevenue > 0
        ? (totalProfit / totalRevenue) * 100
        : 0;

    return ProfitSummary(
      totalRevenue: totalRevenue,
      totalCost: totalCost,
      totalProfit: totalProfit,
      profitMargin: double.parse(profitMargin.toStringAsFixed(2)),
      orderCount: orders.length,
      itemCount: itemCount,
    );
  }

  /// Calculate profit summary for a date range
  ProfitSummary calculatePeriodSummary(
    List<Order> orders,
    DateTime startDate,
    DateTime endDate,
  ) {
    final filteredOrders = orders.where((order) {
      return order.orderDate.isAfter(
            startDate.subtract(const Duration(days: 1)),
          ) &&
          order.orderDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();

    return calculateDailySummary(filteredOrders);
  }

  /// Calculate average cost per unit for a product
  double calculateAverageCost(List<OrderItem> items) {
    if (items.isEmpty) return 0;

    double totalCost = 0;
    double totalQuantity = 0;

    for (final item in items) {
      if (item.costPrice != null) {
        totalCost += item.costPrice! * item.quantity;
        totalQuantity += item.quantity;
      }
    }

    return totalQuantity > 0 ? totalCost / totalQuantity : 0;
  }

  /// Calculate average selling price per unit for a product
  double calculateAverageSellingPrice(List<OrderItem> items) {
    if (items.isEmpty) return 0;

    double totalRevenue = 0;
    double totalQuantity = 0;

    for (final item in items) {
      if (item.pricePerUnit != null) {
        totalRevenue += item.pricePerUnit! * item.quantity;
        totalQuantity += item.quantity;
      }
    }

    return totalQuantity > 0 ? totalRevenue / totalQuantity : 0;
  }

  /// Get profit breakdown by customer
  Map<String, ProfitSummary> getProfitByCustomer(
    List<Order> orders,
    Map<String, List<OrderItem>> orderItems,
  ) {
    final Map<String, ProfitSummary> breakdown = {};

    for (final order in orders) {
      final customerId = order.customerId;
      final items = orderItems[order.id] ?? [];

      final revenue = calculateOrderRevenue(items);
      final cost = calculateOrderCost(items);
      final profit = revenue - cost;
      final margin = revenue > 0 ? (profit / revenue) * 100 : 0;

      if (breakdown.containsKey(customerId)) {
        final existing = breakdown[customerId]!;
        breakdown[customerId] = ProfitSummary(
          totalRevenue: existing.totalRevenue + revenue,
          totalCost: existing.totalCost + cost,
          totalProfit: existing.totalProfit + profit,
          profitMargin: existing.totalRevenue + revenue > 0
              ? ((existing.totalProfit + profit) /
                        (existing.totalRevenue + revenue)) *
                    100
              : 0,
          orderCount: existing.orderCount + 1,
          itemCount: existing.itemCount + items.length,
        );
      } else {
        breakdown[customerId] = ProfitSummary(
          totalRevenue: revenue,
          totalCost: cost,
          totalProfit: profit,
          profitMargin: double.parse(margin.toStringAsFixed(2)),
          orderCount: 1,
          itemCount: items.length,
        );
      }
    }

    return breakdown;
  }

  /// Get profit breakdown by product
  Map<String, ProfitSummary> getProfitByProduct(List<OrderItem> items) {
    final Map<String, ProfitSummary> breakdown = {};

    for (final item in items) {
      final productId = item.productId ?? 'custom';

      final revenue = item.totalPrice ?? 0;
      final cost = (item.costPrice ?? 0) * item.quantity;
      final profit = revenue - cost;
      final margin = revenue > 0 ? (profit / revenue) * 100 : 0;

      if (breakdown.containsKey(productId)) {
        final existing = breakdown[productId]!;
        breakdown[productId] = ProfitSummary(
          totalRevenue: existing.totalRevenue + revenue,
          totalCost: existing.totalCost + cost,
          totalProfit: existing.totalProfit + profit,
          profitMargin: existing.totalRevenue + revenue > 0
              ? ((existing.totalProfit + profit) /
                        (existing.totalRevenue + revenue)) *
                    100
              : 0,
          orderCount: existing.orderCount,
          itemCount: existing.itemCount + 1,
        );
      } else {
        breakdown[productId] = ProfitSummary(
          totalRevenue: revenue,
          totalCost: cost,
          totalProfit: profit,
          profitMargin: double.parse(margin.toStringAsFixed(2)),
          orderCount: 0,
          itemCount: 1,
        );
      }
    }

    return breakdown;
  }

  /// Format currency for display
  String formatCurrency(double amount, {String symbol = '₹'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  /// Format percentage for display
  String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }
}
