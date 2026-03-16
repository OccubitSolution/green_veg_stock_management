# Implementation Plan: Production Readiness Complete

## Overview

This implementation plan transforms the Grocery Broker Flutter application from a prototype with 80+ identified issues into a production-ready application. The plan is organized into four phases over 8 weeks, with each phase building upon the previous one. Tasks are designed to be executed incrementally by a code-generation LLM, with each task building on previous work and ending with fully integrated, tested code.

The implementation follows the existing Flutter + GetX + Supabase architecture and focuses on completing incomplete features, adding missing functionality, improving quality, and ensuring comprehensive testing.

## Tasks

### PHASE 1: CRITICAL FIXES (Weeks 1-2)

- [x] 1. Complete truncated view files
  - [x] 1.1 Complete orders_view.dart customer selection UI
    - Implement complete customer search bar with filtering
    - Implement customer list with all customer details
    - Add customer selection handling
    - _Requirements: 1.1_

  - [x] 1.2 Complete orders_view.dart order entry form
    - Implement product search and selection
    - Implement selected products list with quantity controls
    - Implement custom items section
    - Implement order summary with total calculation
    - Add action buttons (save, cancel, clear)
    - _Requirements: 1.2_

  - [x] 1.3 Complete orders_view.dart order list display
    - Implement order list with all columns (customer, date, total, status)
    - Add order actions (view, edit, delete)
    - Add order filtering and sorting
    - _Requirements: 1.3_

  - [x] 1.4 Complete customers_view.dart customer orders sheet
    - Implement draggable scrollable sheet
    - Add order filters (date range, status)
    - Display order list with summaries
    - Add order statistics section
    - _Requirements: 1.4_

  - [x] 1.5 Complete customers_view.dart customer detail view
    - Implement customer info section
    - Add contact info section
    - Add payment summary section
    - Add recent orders section
    - Add action buttons (edit, delete, view orders)
    - _Requirements: 1.5_


- [-] 2. Implement functional product management
  - [x] 2.1 Create product form view and controller
    - Create ProductFormView widget with form fields
    - Create ProductFormController with form state management
    - Implement image picker integration
    - Add category and unit dropdowns
    - _Requirements: 2.1, 2.4, 2.5_

  - [ ]* 2.2 Write property test for product submission
    - **Property 1: Product submission persistence**
    - **Validates: Requirements 2.2**

  - [ ] 2.3 Implement product image upload
    - Add image upload to Supabase Storage
    - Associate image URL with product
    - Handle upload errors
    - _Requirements: 2.3_

  - [ ]* 2.4 Write property test for image upload
    - **Property 2: Image upload association**
    - **Validates: Requirements 2.3**

  - [ ] 2.5 Implement product edit functionality
    - Load existing product data into form
    - Allow modifications to all fields
    - Update product in database
    - _Requirements: 2.6, 2.7_

  - [ ]* 2.6 Write property test for product edit round-trip
    - **Property 3: Product edit round-trip**
    - **Validates: Requirements 2.6, 2.7**

- [ ] 3. Fix order editing and custom items
  - [ ] 3.1 Implement order loading for editing
    - Create loadOrderForEditing method in OrderWorkflowService
    - Load order with all items and custom items
    - Populate form fields with current values
    - _Requirements: 3.1, 3.2_

  - [ ]* 3.2 Write property tests for order editing
    - **Property 4: Order edit field population**
    - **Property 5: Order items completeness**
    - **Validates: Requirements 3.1, 3.2**

  - [ ] 3.3 Implement real-time order total calculation
    - Add reactive total calculation in controller
    - Update total when items change
    - Include custom items in calculation
    - _Requirements: 3.3_

  - [ ]* 3.4 Write property test for order total invariant
    - **Property 6: Order total invariant**
    - **Validates: Requirements 3.3, 4.5**


  - [ ] 3.5 Implement order modification saving
    - Save modified order to database
    - Update order items and custom items
    - Create audit trail entry
    - _Requirements: 3.4_

  - [ ]* 3.6 Write property test for order modification round-trip
    - **Property 7: Order modification round-trip**
    - **Validates: Requirements 3.4**

  - [ ] 3.7 Implement order deletion with confirmation
    - Add confirmation dialog for deletion
    - Implement soft delete (set deleted flag)
    - Maintain audit history
    - _Requirements: 3.5, 3.6_

  - [ ]* 3.8 Write property test for soft delete
    - **Property 8: Soft delete preservation**
    - **Validates: Requirements 3.6, 11.3**

- [ ] 4. Implement custom items persistence
  - [ ] 4.1 Create custom_items table and model
    - Add custom_items table to database (if not exists)
    - Create CustomItem model class
    - Create CustomItemRepository
    - _Requirements: 4.1_

  - [ ] 4.2 Implement custom item CRUD operations
    - Add methods to create custom items
    - Add methods to load custom items for order
    - Add methods to update custom items
    - Add methods to delete custom items
    - _Requirements: 4.1, 4.2, 4.3, 4.4_

  - [ ]* 4.3 Write property tests for custom items
    - **Property 9: Custom item persistence**
    - **Property 10: Custom item modification**
    - **Property 11: Custom item deletion**
    - **Validates: Requirements 4.1, 4.2, 4.3, 4.4**

  - [ ] 4.4 Integrate custom items into order total calculation
    - Update order total calculation to include custom items
    - Ensure custom items appear in order summaries
    - _Requirements: 4.5_

- [ ] 5. Implement comprehensive input validation
  - [ ] 5.1 Create ValidationService class
    - Implement email validation method
    - Implement phone validation method
    - Implement positive number validation method
    - Implement required field validation method
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.7_

  - [ ]* 5.2 Write property tests for validators
    - **Property 12: Email validation correctness**
    - **Property 13: Phone validation correctness**
    - **Property 14: Positive number validation**
    - **Property 16: Required field validation**
    - **Validates: Requirements 5.1, 5.2, 5.3, 5.4, 5.7**


  - [ ] 5.3 Integrate validation into all forms
    - Add validation to customer form
    - Add validation to product form
    - Add validation to order form
    - Add validation to payment form
    - Prevent submission with errors
    - _Requirements: 5.6_

  - [ ]* 5.4 Write property test for form validation
    - **Property 15: Form validation prevents submission**
    - **Validates: Requirements 5.6**

  - [ ] 5.5 Implement translated validation error messages
    - Add error message translation keys
    - Update validators to use translation system
    - _Requirements: 5.8_

  - [ ]* 5.6 Write property test for validation error translation
    - **Property 17: Validation error translation**
    - **Validates: Requirements 5.8**

- [ ] 6. Add missing translations
  - [ ] 6.1 Audit codebase for hardcoded strings
    - Search for hardcoded English strings in all views
    - Create list of missing translation keys
    - _Requirements: 6.1_

  - [ ] 6.2 Add translation keys to app_translations.dart
    - Add English translations for all missing keys
    - Add Gujarati translations for all missing keys
    - Add error message translations
    - Add success message translations
    - Add form label translations
    - Add button text translations
    - Add placeholder text translations
    - _Requirements: 6.2, 6.3, 6.4, 6.5, 6.6_

  - [ ] 6.3 Replace hardcoded strings with translation keys
    - Replace all hardcoded strings in views with .tr calls
    - Replace all hardcoded strings in controllers with .tr calls
    - Replace all hardcoded strings in services with .tr calls
    - _Requirements: 6.1_

  - [ ]* 6.4 Write property test for UI text translation
    - **Property 18: UI text translation completeness**
    - **Validates: Requirements 6.2, 6.3, 6.4, 6.5, 6.6**

  - [ ] 6.5 Implement translation fallback mechanism
    - Update translation system to return key if translation missing
    - _Requirements: 6.7_

  - [ ]* 6.6 Write property test for translation fallback
    - **Property 19: Translation fallback**
    - **Validates: Requirements 6.7**


- [ ] 7. Apply database migration
  - [ ] 7.1 Review and test migration script
    - Review 20260107_grocery_broker_enhancements.sql
    - Test migration on local development database
    - Verify all tables, columns, indexes created
    - _Requirements: 7.1, 7.2, 7.3_

  - [ ] 7.2 Apply migration to staging environment
    - Backup staging database
    - Apply migration script
    - Verify RLS policies applied
    - Verify constraints enforced
    - Test with sample data
    - _Requirements: 7.4, 7.5_

  - [ ]* 7.3 Write property test for migration data preservation
    - **Property 20: Migration data preservation**
    - **Validates: Requirements 7.6**

- [ ] 8. Checkpoint - Phase 1 Complete
  - Ensure all tests pass, ask the user if questions arise.

### PHASE 2: HIGH PRIORITY (Weeks 3-4)

- [ ] 9. Implement payment tracking system
  - [ ] 9.1 Create payment tracking UI
    - Create PaymentFormView for recording payments
    - Create PaymentHistoryView for viewing payment history
    - Add payment status display to order views
    - Add outstanding balance display to customer views
    - _Requirements: 8.1, 8.2, 8.3, 8.5_

  - [ ] 9.2 Create PaymentTrackingService
    - Implement recordPayment method
    - Implement getOutstandingBalance method
    - Implement getPaymentHistory method
    - Implement getPaymentStatus method
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

  - [ ]* 9.3 Write property tests for payment tracking
    - **Property 21: Payment persistence**
    - **Property 22: Outstanding balance invariant**
    - **Property 23: Payment history completeness**
    - **Property 24: Payment status correctness**
    - **Validates: Requirements 8.1, 8.2, 8.3, 8.4, 8.5**

  - [ ] 9.4 Implement payment filtering
    - Add date range filter to payment history
    - Add payment method filter
    - _Requirements: 8.6_

  - [ ]* 9.5 Write property test for payment filtering
    - **Property 25: Payment filtering**
    - **Validates: Requirements 8.6**

  - [ ] 9.6 Add overpayment warning
    - Display warning when payment exceeds outstanding balance
    - _Requirements: 8.7 (edge case)_


- [ ] 10. Complete settings features
  - [ ] 10.1 Implement Change PIN feature
    - Create ChangePINView with current and new PIN fields
    - Validate current PIN before allowing change
    - Update PIN in database
    - _Requirements: 9.1, 9.2_

  - [ ]* 10.2 Write property test for PIN validation
    - **Property 26: PIN validation before change**
    - **Validates: Requirements 9.2**

  - [ ] 10.3 Implement Help section
    - Create HelpView with FAQs and documentation
    - Add help content in both languages
    - _Requirements: 9.3_

  - [ ] 10.4 Implement Privacy Policy section
    - Create PrivacyPolicyView with policy text
    - Add privacy policy content in both languages
    - _Requirements: 9.4_

  - [ ] 10.5 Add app version display
    - Display app version in settings view
    - Get version from package info
    - _Requirements: 9.5_

  - [ ] 10.6 Implement settings persistence
    - Save settings changes to local storage
    - Load settings on app start
    - _Requirements: 9.6_

  - [ ]* 10.7 Write property test for settings persistence
    - **Property 27: Settings persistence round-trip**
    - **Validates: Requirements 9.6**

- [ ] 11. Add comprehensive error handling
  - [ ] 11.1 Create ErrorHandlingService
    - Implement handleNetworkOperation method with timeout
    - Implement isOnline method for offline detection
    - Implement retryOperation method with exponential backoff
    - _Requirements: 10.1, 10.2, 10.4_

  - [ ] 11.2 Implement error message display
    - Create error dialog component
    - Display user-friendly error messages
    - Log technical error details
    - _Requirements: 10.3, 10.5_

  - [ ]* 11.3 Write property tests for error handling
    - **Property 28: Database error handling**
    - **Property 29: Retry mechanism availability**
    - **Property 30: Error logging completeness**
    - **Validates: Requirements 10.3, 10.4, 10.5**

  - [ ] 11.4 Implement translated error messages
    - Add error message translation keys
    - Use translation system for all error messages
    - _Requirements: 10.7_

  - [ ]* 11.5 Write property test for error message translation
    - **Property 31: Error message translation**
    - **Validates: Requirements 10.7**


- [ ] 12. Fix data consistency issues
  - [ ] 12.1 Fix order aggregation to include custom items
    - Update getAggregatedOrders method
    - Include custom items in all calculations
    - _Requirements: 11.1_

  - [ ]* 12.2 Write property test for order aggregation
    - **Property 32: Order aggregation includes custom items**
    - **Validates: Requirements 11.1**

  - [ ] 12.3 Implement order total persistence
    - Save calculated total to database when order is saved
    - Ensure persisted total matches calculated total
    - _Requirements: 11.2_

  - [ ]* 12.4 Write property test for order total persistence
    - **Property 33: Order total persistence invariant**
    - **Validates: Requirements 11.2**

  - [ ] 12.5 Implement audit trail for order modifications
    - Create audit trail entry on order modification
    - Record timestamp, user, and change details
    - _Requirements: 11.4_

  - [ ]* 12.6 Write property test for audit trail
    - **Property 34: Audit trail creation**
    - **Validates: Requirements 11.4**

- [ ] 13. Implement complete order workflow
  - [ ] 13.1 Add order confirmation step
    - Display confirmation dialog before saving order
    - Show order summary in confirmation
    - _Requirements: 12.1_

  - [ ] 13.2 Implement order status management
    - Add status transition validation
    - Update status on confirmation
    - Record delivery timestamp when marked delivered
    - _Requirements: 12.2, 12.3, 12.4_

  - [ ]* 13.3 Write property tests for order workflow
    - **Property 35: Order confirmation status**
    - **Property 36: Status transition validation**
    - **Property 37: Delivery timestamp recording**
    - **Validates: Requirements 12.2, 12.3, 12.4**

  - [ ] 13.4 Implement order status history
    - Create order_status_history table entries
    - Display status history in order detail view
    - _Requirements: 12.5_

  - [ ]* 13.5 Write property test for status history
    - **Property 38: Status history completeness**
    - **Validates: Requirements 12.5**

  - [ ] 13.6 Add delivery tracking UI
    - Add delivery tracking fields to order form
    - Allow updating tracking info for in-transit orders
    - _Requirements: 12.6_

- [ ] 14. Checkpoint - Phase 2 Complete
  - Ensure all tests pass, ask the user if questions arise.


### PHASE 3: MEDIUM PRIORITY (Weeks 5-6)

- [ ] 15. Implement reports and analytics
  - [ ] 15.1 Create ReportGeneratorService
    - Implement generateSalesReport method
    - Implement generateProductPerformance method
    - Implement generateCustomerAnalysis method
    - Implement generatePriceTrends method
    - _Requirements: 13.1, 13.2, 13.3, 13.4_

  - [ ]* 15.2 Write property tests for report generation
    - **Property 39: Sales report accuracy**
    - **Property 40: Product performance calculation**
    - **Property 41: Customer analysis completeness**
    - **Property 42: Price trend accuracy**
    - **Validates: Requirements 13.1, 13.2, 13.3, 13.4**

  - [ ] 15.3 Implement report export functionality
    - Implement exportToPDF method
    - Implement exportToCSV method
    - Implement exportToExcel method
    - _Requirements: 13.5_

  - [ ]* 15.4 Write property tests for report export
    - **Property 43: Report export format validity**
    - **Validates: Requirements 13.5**

  - [ ] 15.5 Create report UI views
    - Create SalesReportView with charts
    - Create ProductPerformanceView with charts
    - Create CustomerAnalysisView
    - Add report filtering controls
    - _Requirements: 13.6_

  - [ ]* 15.6 Write property test for report filtering
    - **Property 44: Report filtering correctness**
    - **Validates: Requirements 13.6**

- [ ] 16. Add inventory management
  - [ ] 16.1 Create InventoryTrackerService
    - Implement stock decrease on sale
    - Implement stock increase on purchase
    - Implement low stock alert detection
    - Implement stock level calculation
    - _Requirements: 14.1, 14.2, 14.3, 14.4_

  - [ ]* 16.2 Write property tests for inventory tracking
    - **Property 45: Stock decrease on sale**
    - **Property 46: Stock increase on purchase**
    - **Property 47: Low stock alert triggering**
    - **Property 48: Inventory display accuracy**
    - **Validates: Requirements 14.1, 14.2, 14.3, 14.4**

  - [ ] 16.3 Implement inventory reconciliation
    - Create inventory adjustment UI
    - Record adjustment reason and timestamp
    - _Requirements: 14.5, 14.6_

  - [ ]* 16.4 Write property test for stock adjustment
    - **Property 49: Stock adjustment recording**
    - **Validates: Requirements 14.6**

  - [ ] 16.5 Create stock movement history view
    - Display all stock movements
    - Show sales, purchases, and adjustments
    - _Requirements: 14.7_

  - [ ]* 16.6 Write property test for stock movement history
    - **Property 50: Stock movement history completeness**
    - **Validates: Requirements 14.7**


- [ ] 17. Create financial features
  - [ ] 17.1 Create FinancialCalculatorService
    - Implement profit calculation method
    - Implement profit aggregation by product/customer/period
    - Implement invoice generation
    - Implement financial dashboard metrics
    - _Requirements: 15.1, 15.2, 15.3, 15.5_

  - [ ]* 17.2 Write property tests for financial calculations
    - **Property 51: Profit calculation invariant**
    - **Property 52: Profit aggregation accuracy**
    - **Property 53: Invoice completeness**
    - **Property 54: Financial dashboard accuracy**
    - **Validates: Requirements 15.1, 15.2, 15.3, 15.5**

  - [ ] 17.3 Implement invoice PDF export
    - Create invoice PDF template
    - Generate PDF with all order details
    - _Requirements: 15.6_

  - [ ]* 17.4 Write property test for invoice PDF
    - **Property 55: Invoice PDF validity**
    - **Validates: Requirements 15.6**

  - [ ] 17.5 Create financial dashboard UI
    - Display revenue, costs, profit metrics
    - Add charts for trends
    - _Requirements: 15.5_

  - [ ] 17.6 Implement payment reminders
    - Display customers with outstanding balances
    - _Requirements: 15.7_

  - [ ]* 17.7 Write property test for payment reminders
    - **Property 56: Payment reminder inclusion**
    - **Validates: Requirements 15.7**

- [ ] 18. Optimize performance
  - [ ] 18.1 Implement pagination for lists
    - Add pagination to order list
    - Add pagination to customer list
    - Add pagination to product list
    - Limit page size to 20-50 items
    - _Requirements: 16.2_

  - [ ]* 18.2 Write property test for pagination
    - **Property 57: Pagination limits data transfer**
    - **Validates: Requirements 16.2**

  - [ ] 18.3 Implement caching strategy
    - Create CacheService
    - Cache frequently accessed data
    - Implement cache invalidation on data changes
    - _Requirements: 16.3, 16.7_

  - [ ]* 18.4 Write property tests for caching
    - **Property 58: Cache reduces database queries**
    - **Property 60: Cache invalidation on data change**
    - **Validates: Requirements 16.3, 16.7**

  - [ ] 18.5 Add loading indicators
    - Add loading indicators to all async operations
    - Use consistent loading UI pattern
    - _Requirements: 16.6_

  - [ ]* 18.6 Write property test for loading indicators
    - **Property 59: Loading indicator display**
    - **Validates: Requirements 16.6, 20.3**


- [ ] 19. Implement role-based access control
  - [ ] 19.1 Create AccessControlService
    - Implement getCurrentUserPermissions method
    - Implement hasPermission method
    - Implement requirePermission method
    - Implement filterMenuItems method
    - _Requirements: 17.1, 17.2, 17.3, 17.4_

  - [ ]* 19.2 Write property tests for access control
    - **Property 61: User role and permissions loading**
    - **Property 62: Permission verification before access**
    - **Property 63: Access denial for unauthorized users**
    - **Property 64: UI feature visibility based on permissions**
    - **Validates: Requirements 17.1, 17.2, 17.3, 17.4**

  - [ ] 19.3 Implement sensitive data access restriction
    - Hide financial data from non-admin users
    - Restrict access to cost prices
    - _Requirements: 17.5_

  - [ ]* 19.4 Write property test for sensitive data restriction
    - **Property 65: Sensitive data access restriction**
    - **Validates: Requirements 17.5**

  - [ ] 19.5 Create user role management UI
    - Add admin interface for managing user roles
    - Allow assigning roles to staff
    - _Requirements: 17.6_

  - [ ] 19.6 Implement role-based permission matrix
    - Define permissions for each role
    - Enforce permissions throughout app
    - _Requirements: 17.7_

  - [ ]* 19.7 Write property test for role permissions
    - **Property 66: Role-based permission assignment**
    - **Validates: Requirements 17.7**

- [ ] 20. Checkpoint - Phase 3 Complete
  - Ensure all tests pass, ask the user if questions arise.

### PHASE 4: TESTING & POLISH (Weeks 7-8)

- [ ] 21. Write comprehensive test suite
  - [ ] 21.1 Set up property-based testing framework
    - Add check package dependency
    - Create test utilities and arbitraries
    - Configure test runner
    - _Requirements: 18.1-18.8_

  - [ ] 21.2 Write unit tests for repositories
    - Test all CRUD operations with mock data
    - Test error handling
    - Test edge cases
    - _Requirements: 18.1_

  - [ ] 21.3 Write unit tests for controllers
    - Test state management logic
    - Test user interaction handling
    - Test validation logic
    - _Requirements: 18.2_

  - [ ] 21.4 Write unit tests for services
    - Test business logic
    - Test calculations
    - Test data transformations
    - _Requirements: 18.2_


  - [ ] 21.5 Write integration tests for critical workflows
    - Test order creation workflow
    - Test payment recording workflow
    - Test order status transitions
    - Test inventory updates
    - _Requirements: 18.3_

  - [ ] 21.6 Write UI tests for main user journeys
    - Test login flow
    - Test order creation flow
    - Test customer management flow
    - Test product management flow
    - _Requirements: 18.4_

  - [ ] 21.7 Verify test coverage
    - Run coverage analysis
    - Ensure 80% coverage for critical business logic
    - Add tests for uncovered areas
    - _Requirements: 18.8_

- [ ] 22. Add security hardening
  - [ ] 22.1 Implement session timeout
    - Track user activity
    - Auto-logout after inactivity period
    - _Requirements: 19.1_

  - [ ]* 22.2 Write property test for session timeout
    - **Property 67: Session timeout enforcement**
    - **Validates: Requirements 19.1**

  - [ ] 22.3 Implement PIN strength requirements
    - Enforce minimum PIN length
    - Enforce PIN complexity rules
    - _Requirements: 19.2_

  - [ ]* 22.4 Write property test for PIN strength
    - **Property 68: PIN strength enforcement**
    - **Validates: Requirements 19.2**

  - [ ] 22.5 Implement rate limiting on login
    - Track failed login attempts
    - Apply rate limiting after threshold
    - _Requirements: 19.3_

  - [ ]* 22.6 Write property test for rate limiting
    - **Property 69: Rate limiting on failed logins**
    - **Validates: Requirements 19.3**

  - [ ] 22.7 Implement audit logging
    - Log all sensitive operations
    - Record user, timestamp, action details
    - _Requirements: 19.4_

  - [ ]* 22.8 Write property test for audit logging
    - **Property 70: Audit logging for sensitive operations**
    - **Validates: Requirements 19.4**

  - [ ] 22.9 Implement data encryption
    - Encrypt sensitive data at rest
    - Use Supabase encryption features
    - _Requirements: 19.5_

  - [ ]* 22.10 Write property test for data encryption
    - **Property 71: Sensitive data encryption**
    - **Validates: Requirements 19.5**

  - [ ] 22.11 Create audit log viewer
    - Display all audit log entries
    - Add filtering and search
    - _Requirements: 19.6_

  - [ ]* 22.12 Write property test for audit log completeness
    - **Property 72: Audit log completeness**
    - **Validates: Requirements 19.6**


- [ ] 23. UI polish and user experience improvements
  - [ ] 23.1 Add confirmation dialogs for destructive actions
    - Add confirmation for order deletion
    - Add confirmation for customer deletion
    - Add confirmation for order cancellation
    - _Requirements: 20.1_

  - [ ]* 23.2 Write property test for destructive action confirmation
    - **Property 73: Destructive action confirmation**
    - **Validates: Requirements 20.1**

  - [ ] 23.3 Implement pull-to-refresh on lists
    - Add pull-to-refresh to order list
    - Add pull-to-refresh to customer list
    - Add pull-to-refresh to product list
    - _Requirements: 20.4_

  - [ ] 23.4 Add empty state illustrations
    - Create empty state widgets
    - Add helpful messages for empty lists
    - Add illustrations or icons
    - _Requirements: 20.5_

  - [ ]* 23.5 Write property test for empty state display
    - **Property 74: Empty state display**
    - **Validates: Requirements 20.5**

  - [ ] 23.6 Improve form error highlighting
    - Highlight error fields in red
    - Display descriptive error messages
    - Show error icon next to field
    - _Requirements: 20.6_

  - [ ]* 23.7 Write property test for form error highlighting
    - **Property 75: Form error highlighting**
    - **Validates: Requirements 20.6**

  - [ ] 23.8 Add success message feedback
    - Display success snackbar for operations
    - Use consistent success message pattern
    - Auto-dismiss after 3 seconds
    - _Requirements: 20.7_

  - [ ]* 23.9 Write property test for success messages
    - **Property 76: Success message display**
    - **Validates: Requirements 20.7**

  - [ ] 23.10 Polish overall UI consistency
    - Ensure consistent spacing and padding
    - Ensure consistent colors and typography
    - Ensure consistent button styles
    - Ensure consistent card styles

- [ ] 24. Performance optimization and final testing
  - [ ] 24.1 Run performance profiling
    - Profile app startup time
    - Profile list scrolling performance
    - Profile database query performance
    - Identify and fix bottlenecks

  - [ ] 24.2 Optimize database queries
    - Ensure all indexes are used
    - Optimize complex queries
    - Add query result caching where appropriate

  - [ ] 24.3 Run full test suite
    - Run all unit tests
    - Run all property tests
    - Run all integration tests
    - Run all UI tests
    - Fix any failing tests

  - [ ] 24.4 Perform manual testing
    - Test all critical user workflows
    - Test on different devices and screen sizes
    - Test with poor network conditions
    - Test offline functionality

- [ ] 25. Final checkpoint - Production Ready
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional property-based tests that can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation at the end of each phase
- Property tests validate universal correctness properties (minimum 100 iterations each)
- Unit tests validate specific examples and edge cases
- All tasks build incrementally on previous work
- No orphaned or unintegrated code should remain

## Implementation Guidelines

1. **Incremental Development**: Each task should be completed fully before moving to the next
2. **Testing**: Write tests alongside implementation, not after
3. **Code Quality**: Follow Flutter and Dart best practices
4. **Documentation**: Add code comments for complex logic
5. **Error Handling**: Handle all error cases gracefully
6. **Translations**: Use translation keys for all user-facing text
7. **Validation**: Validate all user inputs
8. **Security**: Follow security best practices for sensitive data
9. **Performance**: Consider performance implications of all changes
10. **User Experience**: Prioritize clear, intuitive UI/UX

## Success Criteria

### Phase 1 Success Criteria
- All view files render completely without truncation
- Products can be added, edited, and deleted
- Orders can be edited with custom items persisting correctly
- All forms validate inputs with translated error messages
- No hardcoded English strings remain in the codebase
- Database migration applied successfully

### Phase 2 Success Criteria
- Payments can be recorded and tracked accurately
- Outstanding balances calculated correctly
- Settings features (Change PIN, Help, Privacy) functional
- Errors handled gracefully with user-friendly messages and retry options
- Order workflow enforces valid status transitions
- Audit trail created for all order modifications

### Phase 3 Success Criteria
- Reports generate accurately and export to PDF/CSV/Excel
- Inventory tracks stock levels with alerts for low stock
- Profit calculations accurate across all groupings
- Database queries optimized with caching
- Access control enforces role-based permissions
- UI responsive with pagination and loading indicators

### Phase 4 Success Criteria
- 80% code coverage achieved for critical business logic
- All 76 correctness properties tested with property-based tests
- Security features implemented (session timeout, rate limiting, encryption, audit logging)
- Performance meets targets (fast startup, smooth scrolling, quick queries)
- UI polished with confirmations, empty states, error highlighting, success messages
- Application ready for production deployment

## Timeline

- **Phase 1 (Critical Fixes)**: Weeks 1-2
- **Phase 2 (High Priority)**: Weeks 3-4
- **Phase 3 (Medium Priority)**: Weeks 5-6
- **Phase 4 (Testing & Polish)**: Weeks 7-8

**Total Duration**: 8 weeks to full production readiness

**Minimum Viable Product (MVP)**: 4 weeks (Phases 1 & 2 only)
