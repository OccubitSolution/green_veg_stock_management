/// Payment Tracking Service
/// Manages payment calculations and status tracking
library;

import '../models/workflow_models.dart';
import '../models/customer_order_models.dart';

/// Outstanding Balance
class OutstandingBalance {
  final String customerId;
  final String customerName;
  final double totalAmount;
  final double paidAmount;
  final double outstandingAmount;
  final int orderCount;

  OutstandingBalance({
    required this.customerId,
    required this.customerName,
    required this.totalAmount,
    required this.paidAmount,
    required this.outstandingAmount,
    required this.orderCount,
  });
}

class PaymentTrackingService {
  /// Calculate total paid amount for an order from payment list
  double calculateTotalPaid(List<Payment> payments) {
    return payments.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  /// Calculate outstanding balance for an order
  double calculateOutstanding(double totalAmount, List<Payment> payments) {
    final paid = calculateTotalPaid(payments);
    return totalAmount - paid;
  }

  /// Determine payment status based on amounts
  PaymentStatus determinePaymentStatus(
    double totalAmount,
    List<Payment> payments,
  ) {
    if (totalAmount <= 0) {
      return PaymentStatus.unpaid;
    }

    final paid = calculateTotalPaid(payments);
    
    if (paid <= 0) {
      return PaymentStatus.unpaid;
    } else if (paid >= totalAmount) {
      return PaymentStatus.paid;
    } else {
      return PaymentStatus.partial;
    }
  }

  /// Validate payment amount
  String? validatePayment({
    required double amount,
    required double totalAmount,
    required double alreadyPaid,
  }) {
    if (amount <= 0) {
      return 'Payment amount must be greater than zero';
    }

    final outstanding = totalAmount - alreadyPaid;
    if (amount > outstanding) {
      return 'Payment amount cannot exceed outstanding balance';
    }

    return null;
  }

  /// Calculate outstanding balances by customer
  List<OutstandingBalance> calculateOutstandingByCustomer(
    List<Order> orders,
    Map<String, List<Payment>> paymentsByOrder,
  ) {
    final Map<String, OutstandingBalance> balances = {};

    for (final order in orders) {
      // Skip cancelled orders
      if (order.status == OrderStatus.cancelled) continue;

      final customerId = order.customerId;
      final customerName = order.customerName ?? 'Unknown';
      final totalAmount = order.totalAmount ?? 0;
      
      final payments = paymentsByOrder[order.id] ?? [];
      final paidAmount = calculateTotalPaid(payments);
      final outstanding = totalAmount - paidAmount;

      if (balances.containsKey(customerId)) {
        final existing = balances[customerId]!;
        balances[customerId] = OutstandingBalance(
          customerId: customerId,
          customerName: customerName,
          totalAmount: existing.totalAmount + totalAmount,
          paidAmount: existing.paidAmount + paidAmount,
          outstandingAmount: existing.outstandingAmount + outstanding,
          orderCount: existing.orderCount + 1,
        );
      } else {
        balances[customerId] = OutstandingBalance(
          customerId: customerId,
          customerName: customerName,
          totalAmount: totalAmount,
          paidAmount: paidAmount,
          outstandingAmount: outstanding,
          orderCount: 1,
        );
      }
    }

    // Filter out customers with no outstanding balance
    return balances.values
        .where((balance) => balance.outstandingAmount > 0)
        .toList()
      ..sort((a, b) => b.outstandingAmount.compareTo(a.outstandingAmount));
  }

  /// Get unpaid orders (orders with outstanding balance)
  List<Order> getUnpaidOrders(
    List<Order> orders,
    Map<String, List<Payment>> paymentsByOrder,
  ) {
    return orders.where((order) {
      // Skip cancelled orders
      if (order.status == OrderStatus.cancelled) return false;

      final totalAmount = order.totalAmount ?? 0;
      if (totalAmount <= 0) return false;

      final payments = paymentsByOrder[order.id] ?? [];
      final outstanding = calculateOutstanding(totalAmount, payments);
      
      return outstanding > 0;
    }).toList();
  }

  /// Get partially paid orders
  List<Order> getPartiallyPaidOrders(
    List<Order> orders,
    Map<String, List<Payment>> paymentsByOrder,
  ) {
    return orders.where((order) {
      // Skip cancelled orders
      if (order.status == OrderStatus.cancelled) return false;

      final totalAmount = order.totalAmount ?? 0;
      if (totalAmount <= 0) return false;

      final payments = paymentsByOrder[order.id] ?? [];
      final paid = calculateTotalPaid(payments);
      
      return paid > 0 && paid < totalAmount;
    }).toList();
  }

  /// Get fully paid orders
  List<Order> getFullyPaidOrders(
    List<Order> orders,
    Map<String, List<Payment>> paymentsByOrder,
  ) {
    return orders.where((order) {
      // Skip cancelled orders
      if (order.status == OrderStatus.cancelled) return false;

      final totalAmount = order.totalAmount ?? 0;
      if (totalAmount <= 0) return false;

      final payments = paymentsByOrder[order.id] ?? [];
      final paid = calculateTotalPaid(payments);
      
      return paid >= totalAmount;
    }).toList();
  }

  /// Calculate total outstanding for all orders
  double calculateTotalOutstanding(
    List<Order> orders,
    Map<String, List<Payment>> paymentsByOrder,
  ) {
    double total = 0;

    for (final order in orders) {
      // Skip cancelled orders
      if (order.status == OrderStatus.cancelled) continue;

      final totalAmount = order.totalAmount ?? 0;
      final payments = paymentsByOrder[order.id] ?? [];
      final outstanding = calculateOutstanding(totalAmount, payments);
      
      total += outstanding;
    }

    return total;
  }

  /// Format payment method for display
  String formatPaymentMethod(String? method, String lang) {
    if (method == null || method.isEmpty) {
      return lang == 'en' ? 'Not specified' : 'ઉલ્લેખિત નથી';
    }

    final methods = {
      'cash': {'en': 'Cash', 'gu': 'રોકડ'},
      'upi': {'en': 'UPI', 'gu': 'UPI'},
      'card': {'en': 'Card', 'gu': 'કાર્ડ'},
      'bank_transfer': {'en': 'Bank Transfer', 'gu': 'બેંક ટ્રાન્સફર'},
      'cheque': {'en': 'Cheque', 'gu': 'ચેક'},
    };

    final methodMap = methods[method.toLowerCase()];
    if (methodMap != null) {
      return methodMap[lang] ?? method;
    }

    return method;
  }

  /// Get payment status color
  int getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return 0xFF4CAF50; // Green
      case PaymentStatus.partial:
        return 0xFFFF9800; // Orange
      case PaymentStatus.unpaid:
        return 0xFFE53935; // Red
    }
  }

  /// Get payment summary text
  String getPaymentSummary(
    double totalAmount,
    double paidAmount,
    String lang,
  ) {
    final outstanding = totalAmount - paidAmount;
    
    if (outstanding <= 0) {
      return lang == 'en' ? 'Fully Paid' : 'સંપૂર્ણ ચૂકવેલ';
    } else if (paidAmount > 0) {
      return lang == 'en'
          ? 'Paid ₹${paidAmount.toStringAsFixed(0)} of ₹${totalAmount.toStringAsFixed(0)}'
          : '₹${totalAmount.toStringAsFixed(0)} માંથી ₹${paidAmount.toStringAsFixed(0)} ચૂકવેલ';
    } else {
      return lang == 'en' ? 'Unpaid' : 'અચૂકવેલ';
    }
  }
}
