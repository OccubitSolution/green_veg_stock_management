# Requirements Document

## Introduction

This document specifies requirements for enhancing a grocery brokerage management application. The system serves a vegetable broker who receives daily orders from restaurants, cafes, hotels, and catering businesses, aggregates these orders to determine total quantities needed from farms, purchases items from farms, and delivers individual orders to each customer. The broker employs sub-workers (staff) who assist with viewing purchase lists and managing deliveries.

The current application has basic order management functionality but lacks critical workflow features for purchase tracking, order status management, delivery coordination, cost tracking, and staff access control. This specification addresses these gaps to create a complete broker workflow system.

## Glossary

- **System**: The grocery brokerage management application
- **Admin**: The broker (business owner) who manages all operations
- **Staff**: Sub-workers employed by the broker who assist with operations
- **Customer**: Restaurants, cafes, hotels, catering businesses, supermarkets, or messes that place orders
- **Order**: A request from a customer for specific products on a specific date
- **Purchase_List**: An aggregated view of all order items grouped by product, showing total quantities needed from farms
- **Purchase**: A transaction where the broker buys products from farms/suppliers
- **Delivery**: The act of delivering ordered products to a customer
- **Delivery_Bundle**: A group of orders organized by delivery route or area
- **Farm**: A supplier from whom the broker purchases products
- **Order_Status**: The current state of an order (pending, confirmed, purchased, delivered, cancelled)
- **Purchase_Status**: Whether a product has been purchased from the farm
- **Payment_Status**: The payment state of an order (unpaid, partial, paid)
- **Cost_Price**: The price the broker pays to purchase a product from the farm
- **Selling_Price**: The price the broker charges customers for a product
- **Profit**: The difference between selling price and cost price
- **Confirmed_Order**: An order that the admin has approved for purchase and delivery

## Requirements

### Requirement 1: Purchase Confirmation and Tracking

**User Story:** As an admin, I want to mark products as purchased from farms with cost details, so that I can track what has been bought and calculate profits accurately.

#### Acceptance Criteria

1. WHEN viewing the purchase list, THE System SHALL display a checkbox for each product to mark it as purchased
2. WHEN the admin marks a product as purchased, THE System SHALL prompt for purchase cost per unit and optional supplier name
3. WHEN the admin confirms the purchase, THE System SHALL persist the purchase status, cost, supplier, and timestamp to the database
4. WHEN a product is marked as purchased, THE System SHALL create a Purchase record and associated Purchase_Item records
5. WHEN viewing the purchase list, THE System SHALL visually distinguish purchased items from unpurchased items
6. WHEN the admin views purchase history, THE System SHALL display all past purchases with dates, products, quantities, costs, and suppliers
7. WHEN calculating order totals, THE System SHALL use the recorded cost prices to compute profit margins
8. THE System SHALL allow the admin to edit or delete purchase records within 24 hours of creation

### Requirement 2: Order Status Workflow Management

**User Story:** As an admin, I want to manage orders through a defined workflow from pending to delivered, so that I can track order progress and control what staff can see.

#### Acceptance Criteria

1. WHEN a new order is created, THE System SHALL set its status to pending
2. WHEN the admin confirms an order, THE System SHALL change its status from pending to confirmed
3. WHEN all items in an order are marked as purchased, THE System SHALL automatically change the order status from confirmed to purchased
4. WHEN the admin or staff marks an order as delivered, THE System SHALL change its status from purchased to delivered and record the delivery timestamp
5. WHEN the admin cancels an order, THE System SHALL change its status to cancelled and record the cancellation reason
6. THE System SHALL prevent status transitions that violate the workflow (e.g., pending directly to delivered)
7. WHEN viewing orders, THE System SHALL display the current status with appropriate visual indicators (icons and colors)
8. THE System SHALL maintain an audit log of all status changes with timestamps and user information

### Requirement 3: Staff Access Control for Confirmed Orders

**User Story:** As an admin, I want staff to only see confirmed and purchased orders in the purchase list, so that they don't see tentative orders that haven't been approved yet.

#### Acceptance Criteria

1. WHEN a staff user views the purchase list, THE System SHALL only include items from orders with status confirmed, purchased, or delivered
2. WHEN a staff user views the purchase list, THE System SHALL exclude items from orders with status pending or cancelled
3. WHEN an admin user views the purchase list, THE System SHALL include items from all orders regardless of status
4. WHEN displaying order details to staff, THE System SHALL hide cost prices and profit information
5. WHEN displaying order details to admin, THE System SHALL show all cost prices and profit calculations
6. THE System SHALL prevent staff users from modifying order status except marking orders as delivered
7. THE System SHALL prevent staff users from accessing purchase cost entry or editing features
8. WHEN a staff user attempts unauthorized actions, THE System SHALL display an appropriate error message

### Requirement 4: Delivery Bundle Management

**User Story:** As an admin, I want to group orders by delivery route or area and assign them to staff, so that deliveries can be organized efficiently.

#### Acceptance Criteria

1. WHEN the admin creates a delivery bundle, THE System SHALL allow selection of multiple orders with status purchased
2. WHEN creating a delivery bundle, THE System SHALL allow the admin to specify a bundle name, delivery date, and assigned staff member
3. WHEN a delivery bundle is created, THE System SHALL group the selected orders and display them together
4. WHEN viewing a delivery bundle, THE System SHALL display all orders in the bundle with customer names, addresses, and contact information
5. WHEN viewing a delivery bundle, THE System SHALL provide a printable or shareable format optimized for delivery routing
6. WHEN a staff member views their assigned bundles, THE System SHALL display only bundles assigned to them
7. WHEN a staff member marks an order in a bundle as delivered, THE System SHALL update the order status and record the delivery timestamp
8. WHEN all orders in a bundle are delivered, THE System SHALL mark the bundle as complete
9. THE System SHALL allow the admin to reassign bundles to different staff members
10. THE System SHALL allow the admin to add or remove orders from a bundle before any deliveries are marked

### Requirement 5: Cost and Profit Tracking

**User Story:** As an admin, I want to track purchase costs and calculate profits for each order and item, so that I can understand my business profitability.

#### Acceptance Criteria

1. WHEN recording a purchase, THE System SHALL store the cost price per unit for each product
2. WHEN creating order items, THE System SHALL record both the selling price and the cost price
3. WHEN displaying order items to admin, THE System SHALL calculate and display profit per item as selling price minus cost price
4. WHEN displaying order totals to admin, THE System SHALL calculate and display total cost, total revenue, and total profit
5. WHEN viewing daily summaries, THE System SHALL aggregate all orders for the day and display total revenue, total costs, and total profit
6. WHEN viewing profit reports, THE System SHALL allow filtering by date range, customer, or product
7. WHEN a product's cost price changes, THE System SHALL use the cost price from the purchase date for historical orders
8. THE System SHALL display profit margins as both absolute amounts and percentages

### Requirement 6: Enhanced Purchase List with Persistence

**User Story:** As an admin, I want the purchase list to remember which items I've marked as purchased, so that I don't lose track when I close and reopen the app.

#### Acceptance Criteria

1. WHEN the admin marks an item as purchased in the purchase list, THE System SHALL persist this status to the database immediately
2. WHEN the admin reopens the purchase list, THE System SHALL display the previously marked purchase statuses
3. WHEN viewing the purchase list, THE System SHALL provide a filter to show only unpurchased items
4. WHEN viewing the purchase list, THE System SHALL provide a filter to show only purchased items
5. WHEN viewing the purchase list, THE System SHALL provide a filter to show all items regardless of purchase status
6. WHEN the admin shares or copies the purchase list, THE System SHALL include purchase status indicators for each item
7. WHEN a new order is added for a date, THE System SHALL update the purchase list aggregation in real-time
8. WHEN an order is cancelled, THE System SHALL remove its items from the purchase list aggregation

### Requirement 7: Delivery Status Tracking

**User Story:** As an admin or staff member, I want to track which orders have been delivered with timestamps and notes, so that I can confirm completion and handle any delivery issues.

#### Acceptance Criteria

1. WHEN marking an order as delivered, THE System SHALL record the delivery timestamp automatically
2. WHEN marking an order as delivered, THE System SHALL allow entry of optional delivery notes
3. WHEN marking an order as delivered, THE System SHALL record which user (admin or staff) completed the delivery
4. WHEN viewing delivered orders, THE System SHALL display the delivery timestamp, delivery notes, and delivery person
5. WHEN an order is marked as delivered, THE System SHALL send a notification to the admin if completed by staff
6. THE System SHALL allow the admin to view a daily delivery report showing all completed deliveries
7. THE System SHALL allow filtering orders by delivery status (not delivered, delivered today, delivered in date range)
8. WHEN a delivery issue occurs, THE System SHALL allow marking the order as "delivery failed" with a reason and allow rescheduling

### Requirement 8: Payment Collection Tracking

**User Story:** As an admin, I want to track payment collection from customers, so that I can manage accounts receivable and identify outstanding payments.

#### Acceptance Criteria

1. WHEN creating an order, THE System SHALL set the payment status to unpaid by default
2. WHEN the admin records a payment, THE System SHALL allow entry of the payment amount and payment date
3. WHEN a partial payment is recorded, THE System SHALL update the payment status to partial and display the remaining balance
4. WHEN the full payment is recorded, THE System SHALL update the payment status to paid
5. WHEN viewing orders, THE System SHALL display payment status with visual indicators (unpaid in red, partial in orange, paid in green)
6. WHEN viewing customer details, THE System SHALL display total outstanding balance across all unpaid and partially paid orders
7. THE System SHALL allow the admin to view a payment collection report filtered by date range or customer
8. THE System SHALL allow the admin to record multiple partial payments for a single order with timestamps
9. WHEN an order is cancelled, THE System SHALL handle any recorded payments and allow refund tracking

### Requirement 9: Staff Assignment and Permissions

**User Story:** As an admin, I want to assign specific permissions to staff members, so that I can control what each staff member can view and modify.

#### Acceptance Criteria

1. WHEN creating a staff account, THE System SHALL allow the admin to assign a role (viewer, delivery_staff, or manager)
2. WHEN a staff member has the viewer role, THE System SHALL allow them to view confirmed orders but not modify anything
3. WHEN a staff member has the delivery_staff role, THE System SHALL allow them to view confirmed orders and mark deliveries as complete
4. WHEN a staff member has the manager role, THE System SHALL allow them to view confirmed orders, manage deliveries, and record payments
5. THE System SHALL prevent all staff members from viewing cost prices, purchase costs, or profit information
6. THE System SHALL prevent all staff members from confirming or cancelling orders
7. THE System SHALL prevent all staff members from creating or editing products, categories, or customers
8. WHEN a staff member attempts an unauthorized action, THE System SHALL display a clear error message explaining the permission requirement

### Requirement 10: Daily Operations Dashboard

**User Story:** As an admin, I want a dashboard showing today's key metrics and pending tasks, so that I can quickly understand the day's operations at a glance.

#### Acceptance Criteria

1. WHEN the admin opens the dashboard, THE System SHALL display the count of pending orders for today
2. WHEN the admin opens the dashboard, THE System SHALL display the count of confirmed orders awaiting purchase
3. WHEN the admin opens the dashboard, THE System SHALL display the count of purchased orders awaiting delivery
4. WHEN the admin opens the dashboard, THE System SHALL display today's total revenue, costs, and profit
5. WHEN the admin opens the dashboard, THE System SHALL display the count of unpurchased items in today's purchase list
6. WHEN the admin opens the dashboard, THE System SHALL display outstanding payment amounts by customer
7. WHEN the admin opens the dashboard, THE System SHALL display active delivery bundles and their completion status
8. THE System SHALL allow the admin to tap on any dashboard metric to navigate to the detailed view
9. THE System SHALL refresh dashboard metrics automatically when underlying data changes

### Requirement 11: Purchase History and Supplier Management

**User Story:** As an admin, I want to view purchase history by product and supplier, so that I can track purchasing patterns and supplier reliability.

#### Acceptance Criteria

1. WHEN viewing purchase history, THE System SHALL display all purchases grouped by date
2. WHEN viewing purchase history, THE System SHALL allow filtering by date range, product, or supplier
3. WHEN viewing a specific product's purchase history, THE System SHALL display all past purchases with dates, quantities, costs, and suppliers
4. WHEN viewing purchase history, THE System SHALL calculate and display average cost per unit over time
5. THE System SHALL allow the admin to add supplier contact information (name, phone, address)
6. WHEN recording a purchase, THE System SHALL allow selection from saved suppliers or entry of a new supplier
7. WHEN viewing supplier details, THE System SHALL display all products purchased from that supplier with total quantities and amounts
8. THE System SHALL allow the admin to mark preferred suppliers for specific products

### Requirement 12: Order Modification and Cancellation

**User Story:** As an admin, I want to modify or cancel orders with proper tracking, so that I can handle changes in customer requirements while maintaining data integrity.

#### Acceptance Criteria

1. WHEN an order has status pending, THE System SHALL allow the admin to modify order items, quantities, and prices
2. WHEN an order has status confirmed, THE System SHALL allow the admin to modify order items but require a confirmation prompt
3. WHEN an order has status purchased or delivered, THE System SHALL prevent modification of order items
4. WHEN the admin cancels an order, THE System SHALL require entry of a cancellation reason
5. WHEN an order is cancelled, THE System SHALL remove its items from the purchase list aggregation
6. WHEN an order is cancelled after purchase, THE System SHALL flag the cancellation for inventory adjustment
7. THE System SHALL maintain a history of all modifications to orders with timestamps and user information
8. WHEN viewing a cancelled order, THE System SHALL display the cancellation reason and timestamp

### Requirement 13: Mobile-Optimized Purchase List Sharing

**User Story:** As an admin, I want to share the purchase list via WhatsApp or other messaging apps in a readable format, so that I can communicate with farm suppliers easily.

#### Acceptance Criteria

1. WHEN the admin shares the purchase list, THE System SHALL format it as plain text optimized for mobile messaging apps
2. WHEN formatting the purchase list, THE System SHALL group items by category for better readability
3. WHEN formatting the purchase list, THE System SHALL include product names in both Gujarati and English
4. WHEN formatting the purchase list, THE System SHALL include quantities with appropriate unit symbols
5. WHEN sharing the purchase list, THE System SHALL include only unpurchased items by default
6. THE System SHALL allow the admin to toggle inclusion of purchased items before sharing
7. WHEN sharing the purchase list, THE System SHALL include the date and total item count in the header
8. THE System SHALL provide a "Copy to Clipboard" option for easy pasting into messaging apps

### Requirement 14: Delivery Route Optimization Suggestions

**User Story:** As an admin, I want the system to suggest optimal delivery groupings based on customer addresses, so that I can create efficient delivery routes.

#### Acceptance Criteria

1. WHEN creating a delivery bundle, THE System SHALL analyze customer addresses from selected orders
2. WHEN customer addresses contain area or locality information, THE System SHALL suggest grouping orders by geographic proximity
3. WHEN displaying delivery bundle suggestions, THE System SHALL show the suggested groups with customer names and addresses
4. THE System SHALL allow the admin to accept, modify, or reject the suggested groupings
5. WHEN displaying a delivery bundle, THE System SHALL show customers in a suggested delivery sequence
6. THE System SHALL allow the admin to manually reorder customers within a delivery bundle
7. WHEN customer addresses are incomplete, THE System SHALL flag them and allow the admin to update addresses before creating bundles
8. THE System SHALL remember frequently used delivery routes and suggest them for future bundles

### Requirement 15: Bilingual Support for All New Features

**User Story:** As an admin who primarily uses Gujarati, I want all new features to support both Gujarati and English, so that I can use the app in my preferred language.

#### Acceptance Criteria

1. WHEN displaying order statuses, THE System SHALL show status names in the selected language (Gujarati or English)
2. WHEN displaying delivery bundle information, THE System SHALL show all labels and instructions in the selected language
3. WHEN displaying profit reports, THE System SHALL show all column headers and labels in the selected language
4. WHEN displaying error messages for staff permissions, THE System SHALL show messages in the selected language
5. WHEN sharing the purchase list, THE System SHALL include product names in both languages regardless of the selected UI language
6. THE System SHALL allow the admin to switch between Gujarati and English at any time
7. WHEN displaying dates and times, THE System SHALL use the appropriate format for the selected language
8. THE System SHALL maintain consistent terminology across all new features in both languages
