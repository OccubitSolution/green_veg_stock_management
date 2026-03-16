/// Access Control Service
/// Manages role-based permissions and data filtering
library;

import '../models/workflow_models.dart';
import '../models/customer_order_models.dart';

class AccessControlService {
  /// Get permissions for a role
  StaffPermissions getPermissions(String? role) {
    if (role == null || role.isEmpty) {
      return StaffPermissions.forRole(StaffRole.admin);
    }
    
    final staffRole = StaffRole.fromString(role);
    return StaffPermissions.forRole(staffRole);
  }

  /// Check if user can view costs and profits
  bool canViewCosts(String? role) {
    return getPermissions(role).canViewCosts;
  }

  /// Check if user can confirm orders
  bool canConfirmOrders(String? role) {
    return getPermissions(role).canConfirmOrders;
  }

  /// Check if user can cancel orders
  bool canCancelOrders(String? role) {
    return getPermissions(role).canCancelOrders;
  }

  /// Check if user can mark orders as delivered
  bool canMarkDelivered(String? role) {
    return getPermissions(role).canMarkDelivered;
  }

  /// Check if user can manage products
  bool canManageProducts(String? role) {
    return getPermissions(role).canManageProducts;
  }

  /// Check if user can manage customers
  bool canManageCustomers(String? role) {
    return getPermissions(role).canManageCustomers;
  }

  /// Check if user can view reports
  bool canViewReports(String? role) {
    return getPermissions(role).canViewReports;
  }

  /// Check if user can manage staff
  bool canManageStaff(String? role) {
    return getPermissions(role).canManageStaff;
  }

  /// Check if user can view all orders
  bool canViewAllOrders(String? role) {
    return getPermissions(role).canViewAllOrders;
  }

  /// Filter orders based on user role and permissions
  /// Staff users only see confirmed orders from their inviter
  List<Order> filterOrdersForUser({
    required List<Order> orders,
    required String? role,
    required String? inviterId,
  }) {
    // Admin and managers see all orders
    if (canViewAllOrders(role)) {
      return orders;
    }

    // Staff users only see confirmed orders
    return orders.where((order) {
      // Must be confirmed or delivered
      return order.status == OrderStatus.confirmed || 
             order.status == OrderStatus.delivered;
    }).toList();
  }

  /// Filter purchase list items based on user role
  /// Staff users only see items from confirmed orders
  List<T> filterPurchaseListForUser<T>({
    required List<T> items,
    required String? role,
    required bool Function(T) isFromConfirmedOrder,
  }) {
    // Admin and managers see all items
    if (canViewAllOrders(role)) {
      return items;
    }

    // Staff users only see items from confirmed orders
    return items.where(isFromConfirmedOrder).toList();
  }

  /// Check if user can perform action on order
  bool canPerformAction({
    required String action,
    required Order order,
    required String? role,
  }) {
    switch (action) {
      case 'confirm':
        return canConfirmOrders(role) && order.status == OrderStatus.pending;
      
      case 'deliver':
        return canMarkDelivered(role) && order.status == OrderStatus.confirmed;
      
      case 'cancel':
        return canCancelOrders(role) && 
               order.status != OrderStatus.delivered &&
               order.status != OrderStatus.cancelled;
      
      case 'edit':
        return canConfirmOrders(role) && order.status == OrderStatus.pending;
      
      case 'delete':
        return canCancelOrders(role) && 
               (order.status == OrderStatus.pending || 
                order.status == OrderStatus.cancelled);
      
      case 'view_costs':
        return canViewCosts(role);
      
      default:
        return false;
    }
  }

  /// Get error message for unauthorized action
  String getUnauthorizedMessage(String action, String lang) {
    final messages = {
      'confirm': {
        'en': 'You do not have permission to confirm orders',
        'gu': 'તમને ઓર્ડર પુષ્ટિ કરવાની પરવાનગી નથી',
      },
      'deliver': {
        'en': 'You do not have permission to mark orders as delivered',
        'gu': 'તમને ઓર્ડર ડિલિવર તરીકે ચિહ્નિત કરવાની પરવાનગી નથી',
      },
      'cancel': {
        'en': 'You do not have permission to cancel orders',
        'gu': 'તમને ઓર્ડર રદ કરવાની પરવાનગી નથી',
      },
      'edit': {
        'en': 'You do not have permission to edit orders',
        'gu': 'તમને ઓર્ડર સંપાદિત કરવાની પરવાનગી નથી',
      },
      'delete': {
        'en': 'You do not have permission to delete orders',
        'gu': 'તમને ઓર્ડર કાઢી નાખવાની પરવાનગી નથી',
      },
      'view_costs': {
        'en': 'You do not have permission to view costs and profits',
        'gu': 'તમને ખર્ચ અને નફો જોવાની પરવાનગી નથી',
      },
      'manage_products': {
        'en': 'You do not have permission to manage products',
        'gu': 'તમને ઉત્પાદનો સંચાલિત કરવાની પરવાનગી નથી',
      },
      'manage_customers': {
        'en': 'You do not have permission to manage customers',
        'gu': 'તમને ગ્રાહકોને સંચાલિત કરવાની પરવાનગી નથી',
      },
      'view_reports': {
        'en': 'You do not have permission to view reports',
        'gu': 'તમને રિપોર્ટ જોવાની પરવાનગી નથી',
      },
      'manage_staff': {
        'en': 'You do not have permission to manage staff',
        'gu': 'તમને સ્ટાફને સંચાલિત કરવાની પરવાનગી નથી',
      },
    };

    final message = messages[action];
    if (message == null) {
      return lang == 'en' 
          ? 'You do not have permission to perform this action'
          : 'તમને આ ક્રિયા કરવાની પરવાનગી નથી';
    }

    return message[lang] ?? message['en']!;
  }

  /// Check if user is admin
  bool isAdmin(String? role) {
    return role == null || role.isEmpty || role == 'admin';
  }

  /// Check if user is staff (not admin)
  bool isStaff(String? role) {
    return role != null && role.isNotEmpty && role != 'admin';
  }

  /// Get role display name
  String getRoleName(String? role, String lang) {
    if (role == null || role.isEmpty) {
      return lang == 'en' ? 'Admin' : 'એડમિન';
    }

    final staffRole = StaffRole.fromString(role);
    return staffRole.getName(lang);
  }
}
