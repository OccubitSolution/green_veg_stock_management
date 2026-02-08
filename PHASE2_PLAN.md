# Phase 2 Implementation Plan

## Goal
Implement Purchase Management, Inventory Tracking, and Sales Recording to complete the vegetable brokering workflow.

## Business Workflow
1. **Purchase** - Buy vegetables from farms based on Purchase List
2. **Inventory** - Track what you have in stock
3. **Sales** - Record what you deliver to customers (converting orders to sales)
4. **Delivery** - Manage delivery routes and confirmations

## Phase 2 Features

### 1. Purchase Management
**Purpose**: Record purchases from farms
**Data Model**:
- Purchase (id, vendor_id, purchase_date, supplier_name, total_amount, notes)
- PurchaseItem (id, purchase_id, product_id, quantity, price_per_unit, total_price)

**UI**:
- Purchase list view
- Add purchase screen
- View purchase details

### 2. Inventory/Stock Management
**Purpose**: Track available stock after purchases
**Data Model**:
- Stock (id, vendor_id, product_id, quantity, last_updated)
- StockMovement (id, stock_id, movement_type, quantity, reference_type, reference_id, notes)

**UI**:
- Current stock view
- Stock movement history
- Low stock alerts

### 3. Sales Management
**Purpose**: Record actual deliveries to customers
**Data Model**:
- Sale (id, order_id, customer_id, vendor_id, sale_date, total_amount, status)
- SaleItem (id, sale_id, product_id, quantity, price_per_unit, total_price)

**UI**:
- Sales list
- Convert order to sale
- Record delivery

### 4. Delivery Management
**Purpose**: Track deliveries and routes
**Data Model**:
- DeliveryRoute (id, vendor_id, route_date, status)
- DeliveryStop (id, route_id, customer_id, order_id, status, sequence)

**UI**:
- Today's deliveries
- Route planning
- Delivery confirmation

## Implementation Order

1. Database migrations (purchases, stock, sales tables)
2. Purchase Management module
3. Inventory module
4. Sales module
5. Delivery module
6. Update dashboard with new stats
7. Add translations

## Files to Create

### Data Layer
- `purchases_model.dart` - Purchase and PurchaseItem models
- `inventory_model.dart` - Stock and StockMovement models
- `sales_model.dart` - Sale and SaleItem models
- `purchase_repository.dart` - Purchase operations
- `inventory_repository.dart` - Stock operations
- `sales_repository.dart` - Sales operations

### UI Layer
- `purchases/views/purchases_view.dart`
- `purchases/views/add_purchase_view.dart`
- `inventory/views/inventory_view.dart`
- `sales/views/sales_view.dart`
- `sales/views/convert_order_view.dart`
- `delivery/views/delivery_view.dart`

### Controllers
- `purchases/controllers/purchase_controller.dart`
- `inventory/controllers/inventory_controller.dart`
- `sales/controllers/sales_controller.dart`
- `delivery/controllers/delivery_controller.dart`

## Success Criteria
- User can record purchases from farms
- Stock updates automatically after purchases
- User can convert orders to sales
- User can track what's been delivered
- Dashboard shows purchase, inventory, and sales stats

## Estimated Time
- Database migrations: 30 minutes
- Purchase module: 1 hour
- Inventory module: 1 hour
- Sales module: 1 hour
- Delivery module: 45 minutes
- Integration & testing: 45 minutes
- **Total: ~5 hours**
