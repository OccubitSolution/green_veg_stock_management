# Implementation Plan: Grocery Broker Workflow Enhancement

## Overview

This implementation plan breaks down the grocery broker workflow enhancement into discrete, incremental coding tasks. The plan follows a logical progression: database schema updates, data models, services, controllers, and finally UI components. Each task builds on previous work and includes testing sub-tasks to validate functionality early.

The implementation will extend the existing Flutter/GetX application with Supabase PostgreSQL backend, maintaining consistency with the current architecture while adding purchase tracking, order workflow management, delivery bundles, cost/profit tracking, and role-based access control.

## Tasks

- [x] 1. Database schema updates and migrations
  - Create SQL migration files for all new tables and columns
  - Add purchase_order_items junction table
  - Add order_status_history audit table
  - Add delivery_bundles and delivery_bundle_orders tables
  - Add payments table
  - Extend vendors table with role and invite fields
  - Extend orders table with delivery and cancellation fields
  - Run migrations on development database
  - _Requirements: 1.3, 1.4, 2.8, 4.2, 4.3, 8.2, 9.1_

- [x] 2. Extend data models for new features
  - [x] 2.1 Update Order model with new fields
    - Add deliveredAt, deliveredBy, cancellationReason, cancelledAt fields
    - Add computed properties: totalProfit, profitMargin, canBeConfirmed, canBeDelivered, canBeCancelled
    - Update fromJson and toJson methods
    - _Requirements: 2.4, 2.5, 5.3, 12.1, 12.3_
  
  - [ ]* 2.2 Write property test for Order model
    - **Property 3: Profit calculation correctness**
    - **Validates: Requirements 1.7, 5.3**
  
  - [x] 2.3 Create PurchaseStatus and PurchaseDetails models
    - Define PurchaseStatus class with purchase tracking fields
    - Define PurchaseDetails class for purchase entry
    - _Requirements: 1.2, 1.3_
  
  - [x] 2.4 Create DeliveryBundle and BundleOrder models
    - Define DeliveryBundle class with computed properties
    - Define BundleOrder class for bundle order details
    - Define DeliveryBundleStatus enum
    - _Requirements: 4.2, 4.3, 4.8_
  
  - [ ]* 2.5 Write property test for DeliveryBundle model
    - **Property 23: Bundle completion status**
    - **Validates: Requirements 4.8**
  
  - [x] 2.6 Create Payment model
    - Define Payment class with payment tracking fields
    - _Requirements: 8.2_
  
  - [x] 2.7 Extend Vendor model with role fields
    - Add role, invitedBy, inviteCode fields
    - Define StaffRole enum
    - Define StaffPermissions class with forRole factory
    - _Requirements: 9.1, 9.2, 9.3, 9.4_
  
  - [x] 2.8 Create DashboardMetrics model
    - Define DashboardMetrics class with all dashboard fields
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5, 10.6, 10.7_

- [x] 3. Implement core services
  - [x] 3.1 Create OrderWorkflowService
    - Implement confirmOrder method
    - Implement markAsPurchased method
    - Implement markAsDelivered method with timestamp and user tracking
    - Implement cancelOrder method with reason
    - Implement canTransitionTo validation method
    - Implement getAvailableTransitions method
    - _Requirements: 2.2, 2.3, 2.4, 2.5, 2.6_
  
  - [ ]* 3.2 Write property tests for OrderWorkflowService
    - **Property 6: Order confirmation transition**
    - **Property 8: Delivery status transition with timestamp**
    - **Property 9: Cancellation with reason**
    - **Property 10: Invalid state transition rejection**
    - **Validates: Requirements 2.2, 2.4, 2.5, 2.6**
  
  - [x] 3.3 Create AccessControlService
    - Implement canViewCosts method
    - Implement canConfirmOrders method
    - Implement canCancelOrders method
    - Implement canMarkDelivered method
    - Implement canManageProducts method
    - Implement canManageCustomers method
    - Implement canViewReports method
    - Implement filterOrdersForUser method
    - Implement filterPurchaseListForUser method
    - _Requirements: 3.1, 3.4, 3.6, 3.7, 9.2, 9.3, 9.4, 9.5, 9.6, 9.7_
  
  - [ ]* 3.4 Write property tests for AccessControlService
    - **Property 12: Staff purchase list filtering**
    - **Property 14: Role-based cost visibility**
    - **Property 15: Staff delivery permission**
    - **Property 17: Staff role permissions enforcement**
    - **Validates: Requirements 3.1, 3.4, 3.6, 9.2, 9.3, 9.4, 9.5, 9.6, 9.7**
  
  - [x] 3.5 Create ProfitCalculationService
    - Implement calculateItemProfit method
    - Implement calculateItemProfitMargin method
    - Implement calculateOrderCost method
    - Implement calculateOrderRevenue method
    - Implement calculateOrderProfit method
    - Implement calculateOrderProfitMargin method
    - Implement calculateDailySummary method
    - Implement calculatePeriodSummary method
    - _Requirements: 5.3, 5.4, 5.5_
  
  - [ ]* 3.6 Write property tests for ProfitCalculationService
    - **Property 28: Order total aggregation**
    - **Property 29: Daily profit aggregation**
    - **Property 57: Average cost calculation**
    - **Validates: Requirements 5.4, 5.5, 11.4**
  
  - [x] 3.7 Create PaymentTrackingService
    - Implement recordPayment method
    - Implement getPaymentsForOrder method
    - Implement getOutstandingBalance method
    - Implement getAllOutstandingBalances method
    - Implement getUnpaidOrders method
    - _Requirements: 8.2, 8.3, 8.4, 8.6_
  
  - [ ]* 3.8 Write property tests for PaymentTrackingService
    - **Property 43: Partial payment status calculation**
    - **Property 44: Full payment status calculation**
    - **Property 45: Customer outstanding balance aggregation**
    - **Property 47: Multiple payments tracking**
    - **Validates: Requirements 8.3, 8.4, 8.6, 8.8**

- [ ] 4. Checkpoint - Ensure all service tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 5. Implement data repositories
  - [ ] 5.1 Create PurchaseTrackingRepository
    - Implement createPurchase method
    - Implement createPurchaseItems method
    - Implement linkPurchaseToOrderItems method
    - Implement getPurchaseHistory method with filtering
    - Implement updatePurchase method with time validation
    - Implement deletePurchase method with time validation
    - _Requirements: 1.3, 1.4, 1.6, 1.8_
  
  - [ ]* 5.2 Write property tests for PurchaseTrackingRepository
    - **Property 1: Purchase persistence**
    - **Property 2: Purchase history completeness**
    - **Property 4: Time-based purchase edit permissions**
    - **Validates: Requirements 1.3, 1.4, 1.6, 1.8**
  
  - [ ] 5.3 Create OrderStatusRepository
    - Implement updateOrderStatus method
    - Implement createStatusHistoryEntry method
    - Implement getStatusHistory method
    - _Requirements: 2.2, 2.4, 2.5, 2.8_
  
  - [ ]* 5.4 Write property test for OrderStatusRepository
    - **Property 11: Status change audit trail**
    - **Validates: Requirements 2.8**
  
  - [ ] 5.5 Create DeliveryBundleRepository
    - Implement createBundle method
    - Implement addOrdersToBundle method
    - Implement removeOrdersFromBundle method
    - Implement assignToStaff method
    - Implement getBundlesForStaff method
    - Implement updateBundleStatus method
    - _Requirements: 4.2, 4.3, 4.6, 4.9, 4.10_
  
  - [ ]* 5.6 Write property tests for DeliveryBundleRepository
    - **Property 19: Bundle order association**
    - **Property 21: Staff bundle filtering**
    - **Property 24: Bundle reassignment**
    - **Property 25: Bundle modification before delivery**
    - **Validates: Requirements 4.3, 4.6, 4.9, 4.10**
  
  - [ ] 5.7 Create PaymentRepository
    - Implement createPayment method
    - Implement getPaymentsForOrder method
    - Implement updateOrderPaymentStatus method
    - _Requirements: 8.2, 8.8_
  
  - [ ]* 5.8 Write property test for PaymentRepository
    - **Property 47: Multiple payments tracking**
    - **Validates: Requirements 8.8**

- [ ] 6. Implement GetX controllers
  - [ ] 6.1 Create PurchaseTrackingController
    - Implement loadPurchaseList method with role-based filtering
    - Implement markAsPurchased method with dialog
    - Implement loadPurchaseHistory method
    - Implement updatePurchaseStatus method
    - Add reactive state management with Rx variables
    - _Requirements: 1.2, 1.3, 1.6, 3.1, 3.3_
  
  - [ ] 6.2 Extend OrderController with workflow methods
    - Add confirmOrder method
    - Add markAsDelivered method
    - Add cancelOrder method
    - Add status transition validation
    - Update order list filtering for staff users
    - _Requirements: 2.2, 2.4, 2.5, 3.1_
  
  - [ ] 6.3 Create DeliveryBundleController
    - Implement createBundle method with order selection
    - Implement assignToStaff method
    - Implement addOrders method
    - Implement removeOrders method
    - Implement markOrderDelivered method
    - Implement getBundlesForStaff method
    - Implement generateDeliverySheet method
    - Add reactive state management
    - _Requirements: 4.2, 4.3, 4.6, 4.7, 4.9, 4.10_
  
  - [ ] 6.4 Create ProfitReportController
    - Implement loadTodaySummary method
    - Implement loadPeriodSummary method
    - Implement exportReport method
    - Add reactive state management
    - _Requirements: 5.5, 5.6_
  
  - [ ] 6.5 Create PaymentTrackingController
    - Implement recordPayment method
    - Implement loadOutstandingBalances method
    - Implement loadPaymentHistory method
    - Add reactive state management
    - _Requirements: 8.2, 8.6, 8.7_
  
  - [ ] 6.6 Create DashboardController
    - Implement loadMetrics method
    - Implement refresh method
    - Add auto-refresh with timer
    - Add reactive state management
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5, 10.6, 10.7_
  
  - [ ]* 6.7 Write property tests for DashboardController
    - **Property 49: Dashboard order counts**
    - **Property 50: Dashboard profit aggregation**
    - **Property 51: Dashboard unpurchased items count**
    - **Property 52: Dashboard outstanding payments**
    - **Property 53: Dashboard bundle completion status**
    - **Validates: Requirements 10.1, 10.2, 10.3, 10.4, 10.5, 10.6, 10.7**

- [ ] 7. Checkpoint - Ensure all controller tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 8. Implement UI components for purchase tracking
  - [ ] 8.1 Create PurchaseListView with checkboxes
    - Display aggregated items with purchase checkboxes
    - Implement role-based filtering (staff vs admin)
    - Add visual distinction for purchased vs unpurchased items
    - Add filter buttons (all, purchased, unpurchased)
    - _Requirements: 1.1, 1.5, 3.1, 3.3, 6.3_
  
  - [ ] 8.2 Create PurchaseDetailsDialog
    - Create modal dialog for cost and supplier entry
    - Add form validation
    - Implement save functionality
    - _Requirements: 1.2, 1.3_
  
  - [ ] 8.3 Create PurchaseHistoryView
    - Display past purchases grouped by date
    - Add filtering by date range, product, supplier
    - Show all purchase details
    - _Requirements: 1.6, 11.1, 11.2, 11.3_
  
  - [ ] 8.4 Add purchase list sharing functionality
    - Implement formatPurchaseListForSharing method
    - Group items by category
    - Include bilingual product names
    - Include quantities with units
    - Add date and count in header
    - Add copy to clipboard button
    - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.7, 13.8_
  
  - [ ]* 8.5 Write property tests for purchase list formatting
    - **Property 63: Purchase list category grouping**
    - **Property 64: Purchase list bilingual names**
    - **Property 65: Purchase list quantity formatting**
    - **Property 67: Purchase list header information**
    - **Validates: Requirements 13.2, 13.3, 13.4, 13.7**

- [ ] 9. Implement UI components for order workflow
  - [ ] 9.1 Add order status badges to OrderListView
    - Display status with icons and colors
    - Implement bilingual status names
    - _Requirements: 2.7, 15.1_
  
  - [ ] 9.2 Create order action buttons based on status
    - Add "Confirm Order" button for pending orders (admin only)
    - Add "Mark as Delivered" button for purchased orders (admin and staff)
    - Add "Cancel Order" button for non-delivered orders (admin only)
    - Implement permission checks
    - _Requirements: 2.2, 2.4, 2.5, 3.6_
  
  - [ ] 9.3 Create OrderStatusHistoryView
    - Display audit log of status changes
    - Show timestamps, users, and notes
    - _Requirements: 2.8_
  
  - [ ] 9.4 Create CancelOrderDialog
    - Create modal for cancellation reason entry
    - Add form validation
    - Implement cancel functionality
    - _Requirements: 2.5, 12.4_
  
  - [ ] 9.5 Update OrderDetailView with role-based visibility
    - Hide cost prices and profit for staff users
    - Show all details for admin users
    - Display delivery information for delivered orders
    - Display cancellation information for cancelled orders
    - _Requirements: 3.4, 7.4, 12.8_

- [ ] 10. Implement UI components for delivery bundles
  - [ ] 10.1 Create DeliveryBundleListView
    - Display all bundles with status and completion percentage
    - Filter bundles by assigned staff for staff users
    - Add create bundle button (admin only)
    - _Requirements: 4.6_
  
  - [ ] 10.2 Create CreateDeliveryBundleView
    - Display orders with status "purchased"
    - Allow multi-select of orders
    - Add bundle name, date, and staff assignment fields
    - Implement validation
    - Implement create functionality
    - _Requirements: 4.1, 4.2, 4.3_
  
  - [ ] 10.3 Create DeliveryBundleDetailView
    - Display all orders in bundle with customer information
    - Show delivery sequence
    - Add "Mark as Delivered" button for each order
    - Show completion status
    - Add reassign and modify buttons (admin only)
    - _Requirements: 4.4, 4.7, 4.8, 4.9, 4.10_
  
  - [ ] 10.4 Create DeliverySheetView
    - Generate printable/shareable delivery sheet
    - Include customer names, addresses, phones
    - Include order items
    - Optimize layout for mobile viewing
    - Add share functionality
    - _Requirements: 4.5_
  
  - [ ]* 10.5 Write widget tests for delivery bundle UI
    - Test bundle creation flow
    - Test order marking as delivered
    - Test staff filtering

- [ ] 11. Implement UI components for profit tracking
  - [ ] 11.1 Create ProfitDashboardView
    - Display today's revenue, cost, and profit
    - Show profit margin percentage
    - Add navigation to detailed reports
    - Restrict access to admin only
    - _Requirements: 5.4, 5.5, 9.5_
  
  - [ ] 11.2 Create ProfitReportView
    - Display profit breakdown by order, customer, product
    - Add date range, customer, and product filters
    - Show profit margins as amounts and percentages
    - Add export functionality
    - _Requirements: 5.6, 5.8_
  
  - [ ] 11.3 Update OrderDetailView with profit display
    - Show item-level profit for admin
    - Show order-level profit for admin
    - Hide from staff users
    - _Requirements: 5.3, 5.4, 9.5_

- [ ] 12. Implement UI components for payment tracking
  - [ ] 12.1 Create RecordPaymentDialog
    - Add payment amount and date fields
    - Add optional payment method and notes
    - Implement validation
    - Implement save functionality
    - _Requirements: 8.2_
  
  - [ ] 12.2 Update OrderListView with payment status badges
    - Display payment status with colors (red/orange/green)
    - Show pending amount
    - _Requirements: 8.5_
  
  - [ ] 12.3 Create PaymentHistoryView
    - Display all payments for an order
    - Show payment dates, amounts, methods
    - Show total paid and pending amounts
    - _Requirements: 8.8_
  
  - [ ] 12.4 Create OutstandingPaymentsView
    - Display customers with outstanding balances
    - Group by customer
    - Add filtering by customer
    - Add navigation to customer orders
    - _Requirements: 8.6, 8.7_

- [ ] 13. Implement dashboard UI
  - [ ] 13.1 Create DashboardView with metrics cards
    - Display order status counts with tap navigation
    - Display unpurchased items count with tap navigation
    - Display today's profit summary with tap navigation
    - Display outstanding payments with tap navigation
    - Display active delivery bundles with tap navigation
    - Add refresh button
    - Implement auto-refresh
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5, 10.6, 10.7, 10.8_
  
  - [ ]* 13.2 Write widget tests for dashboard
    - Test metric display
    - Test navigation on tap
    - Test refresh functionality

- [ ] 14. Implement staff management UI
  - [ ] 14.1 Create StaffManagementView
    - Display list of staff members with roles
    - Add create staff button (admin only)
    - Add edit and deactivate buttons (admin only)
    - _Requirements: 9.1_
  
  - [ ] 14.2 Create CreateStaffDialog
    - Add name, email, phone, and role fields
    - Generate invite code
    - Implement validation
    - Implement save functionality
    - _Requirements: 9.1_
  
  - [ ] 14.3 Implement permission error handling
    - Display clear error messages for unauthorized actions
    - Use bilingual error messages
    - _Requirements: 3.8, 9.8, 15.4_

- [ ] 15. Implement localization for new features
  - [ ] 15.1 Add Gujarati translations
    - Add translations for all new UI labels
    - Add translations for order statuses
    - Add translations for delivery bundle terms
    - Add translations for profit report terms
    - Add translations for payment terms
    - Add translations for error messages
    - _Requirements: 15.1, 15.2, 15.3, 15.4_
  
  - [ ] 15.2 Add English translations
    - Add translations for all new UI labels
    - Add translations for order statuses
    - Add translations for delivery bundle terms
    - Add translations for profit report terms
    - Add translations for payment terms
    - Add translations for error messages
    - _Requirements: 15.1, 15.2, 15.3, 15.4_
  
  - [ ] 15.3 Implement date/time formatting
    - Add locale-aware date formatting
    - Add locale-aware time formatting
    - _Requirements: 15.7_
  
  - [ ]* 15.4 Write property tests for localization
    - **Property 70: Status name localization**
    - **Property 71: UI label localization**
    - **Property 72: Error message localization**
    - **Property 73: Date format localization**
    - **Validates: Requirements 15.1, 15.2, 15.3, 15.4, 15.7**

- [ ] 16. Implement additional features
  - [ ] 16.1 Add supplier management
    - Create Supplier model
    - Create SupplierRepository
    - Create SupplierManagementView
    - Add supplier selection in purchase entry
    - _Requirements: 11.5, 11.6_
  
  - [ ] 16.2 Implement order modification tracking
    - Create order modification history table
    - Implement modification logging
    - Create OrderModificationHistoryView
    - _Requirements: 12.7_
  
  - [ ] 16.3 Add incomplete address flagging
    - Implement address validation
    - Add visual flags for incomplete addresses
    - Add address update prompt in bundle creation
    - _Requirements: 14.7_
  
  - [ ]* 16.4 Write property test for address validation
    - **Property 69: Incomplete address flagging**
    - **Validates: Requirements 14.7**

- [ ] 17. Integration and testing
  - [ ]* 17.1 Write integration tests for complete workflows
    - Test complete purchase workflow (create order → confirm → purchase → deliver)
    - Test delivery bundle workflow (create bundle → assign → deliver)
    - Test payment workflow (create order → record payments → mark paid)
    - Test staff access control across all features
  
  - [ ]* 17.2 Write widget tests for all new views
    - Test PurchaseListView
    - Test DeliveryBundleViews
    - Test ProfitReportView
    - Test PaymentViews
    - Test DashboardView
  
  - [ ] 17.3 Perform manual testing
    - Test all workflows as admin user
    - Test all workflows as staff users with different roles
    - Test bilingual support (switch between Gujarati and English)
    - Test on different screen sizes
    - Test error handling and edge cases

- [ ] 18. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional testing tasks and can be skipped for faster MVP delivery
- Each task references specific requirements for traceability
- Property tests validate universal correctness properties across all inputs
- Unit tests validate specific examples and edge cases
- Integration tests validate end-to-end workflows
- The implementation follows the existing Flutter/GetX architecture
- All new features support bilingual display (Gujarati and English)
- Role-based access control is enforced at service and UI levels
- Database migrations should be tested on development environment before production
