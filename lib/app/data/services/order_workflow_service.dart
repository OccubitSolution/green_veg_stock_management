/// Order Workflow Service
/// Manages order status transitions and workflow validation
library;

import '../models/customer_order_models.dart';

class OrderWorkflowService {
  /// Validate if order can transition to new status
  bool canTransitionTo(Order order, OrderStatus newStatus) {
    switch (newStatus) {
      case OrderStatus.confirmed:
        return order.status == OrderStatus.pending;
      
      case OrderStatus.delivered:
        return order.status == OrderStatus.confirmed;
      
      case OrderStatus.cancelled:
        return order.status != OrderStatus.delivered && 
               order.status != OrderStatus.cancelled;
      
      case OrderStatus.pending:
        // Cannot transition back to pending
        return false;
    }
  }

  /// Get available status transitions for an order
  List<OrderStatus> getAvailableTransitions(Order order) {
    final transitions = <OrderStatus>[];
    
    for (final status in OrderStatus.values) {
      if (status != order.status && canTransitionTo(order, status)) {
        transitions.add(status);
      }
    }
    
    return transitions;
  }

  /// Validate order can be confirmed
  /// Returns error message if invalid, null if valid
  String? validateConfirmation(Order order) {
    if (order.status != OrderStatus.pending) {
      return 'Only pending orders can be confirmed';
    }
    
    if (order.totalAmount == null || order.totalAmount! <= 0) {
      return 'Order must have a valid total amount';
    }
    
    return null;
  }

  /// Validate order can be marked as purchased
  /// Returns error message if invalid, null if valid
  String? validatePurchased(Order order) {
    if (order.status != OrderStatus.confirmed) {
      return 'Only confirmed orders can be marked as purchased';
    }
    
    return null;
  }

  /// Validate order can be delivered
  /// Returns error message if invalid, null if valid
  String? validateDelivery(Order order, String deliveredBy) {
    if (order.status != OrderStatus.confirmed) {
      return 'Only confirmed orders can be delivered';
    }
    
    if (deliveredBy.isEmpty) {
      return 'Delivery person must be specified';
    }
    
    if (order.totalAmount == null || order.totalAmount! <= 0) {
      return 'Order must have a valid total amount';
    }
    
    return null;
  }

  /// Validate order can be cancelled
  /// Returns error message if invalid, null if valid
  String? validateCancellation(Order order, String reason) {
    if (order.status == OrderStatus.delivered) {
      return 'Delivered orders cannot be cancelled';
    }
    
    if (order.status == OrderStatus.cancelled) {
      return 'Order is already cancelled';
    }
    
    if (reason.trim().isEmpty) {
      return 'Cancellation reason is required';
    }
    
    return null;
  }

  /// Create updated order for confirmation
  Order confirmOrder(Order order) {
    return order.copyWith(
      status: OrderStatus.confirmed,
    );
  }

  /// Create updated order for delivery
  Order markAsDelivered(Order order, String deliveredBy) {
    return order.copyWith(
      status: OrderStatus.delivered,
      deliveredAt: DateTime.now(),
      deliveredBy: deliveredBy,
    );
  }

  /// Create updated order for cancellation
  Order cancelOrder(Order order, String reason, String cancelledBy) {
    return order.copyWith(
      status: OrderStatus.cancelled,
      cancellationReason: reason,
      cancelledAt: DateTime.now(),
      cancelledBy: cancelledBy,
    );
  }

  /// Check if order is editable
  bool isEditable(Order order) {
    return order.status == OrderStatus.pending;
  }

  /// Check if order is deletable
  bool isDeletable(Order order) {
    return order.status == OrderStatus.pending || 
           order.status == OrderStatus.cancelled;
  }

  /// Get workflow status description
  String getStatusDescription(Order order, String lang) {
    switch (order.status) {
      case OrderStatus.pending:
        return lang == 'en' 
            ? 'Waiting for confirmation' 
            : 'પુષ્ટિની રાહ જોઈ રહ્યું છે';
      
      case OrderStatus.confirmed:
        return lang == 'en'
            ? 'Confirmed, ready for purchase'
            : 'પુષ્ટિ થઈ, ખરીદી માટે તૈયાર';
      
      case OrderStatus.delivered:
        final deliveredAt = order.deliveredAt;
        if (deliveredAt != null) {
          final dateStr = '${deliveredAt.day}/${deliveredAt.month}/${deliveredAt.year}';
          return lang == 'en'
              ? 'Delivered on $dateStr'
              : '$dateStr ના રોજ ડિલિવર થયું';
        }
        return lang == 'en' ? 'Delivered' : 'ડિલિવર થયું';
      
      case OrderStatus.cancelled:
        return lang == 'en' ? 'Cancelled' : 'રદ કર્યું';
    }
  }
}
