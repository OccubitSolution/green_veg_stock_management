-- Migration: Create Purchase, Inventory, and Sales Tables
-- Phase 2: Purchase Management, Stock Tracking, Sales Recording

-- ============================================
-- PURCHASES
-- ============================================

-- Purchases Table (Buying from farms)
CREATE TABLE IF NOT EXISTS purchases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id UUID NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    supplier_name VARCHAR(255),
    purchase_date DATE NOT NULL DEFAULT CURRENT_DATE,
    total_amount DECIMAL(10, 2),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_purchases_vendor ON purchases(vendor_id);
CREATE INDEX IF NOT EXISTS idx_purchases_date ON purchases(purchase_date);

-- Purchase Items Table
CREATE TABLE IF NOT EXISTS purchase_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    purchase_id UUID NOT NULL REFERENCES purchases(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    quantity DECIMAL(10, 3) NOT NULL CHECK (quantity > 0),
    price_per_unit DECIMAL(10, 2),
    total_price DECIMAL(10, 2),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_purchase_items_purchase ON purchase_items(purchase_id);
CREATE INDEX IF NOT EXISTS idx_purchase_items_product ON purchase_items(product_id);

-- ============================================
-- INVENTORY/STOCK
-- ============================================

-- Stock Table (Current inventory)
CREATE TABLE IF NOT EXISTS stock (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id UUID NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    quantity DECIMAL(10, 3) NOT NULL DEFAULT 0,
    min_stock_level DECIMAL(10, 3) DEFAULT 0,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(vendor_id, product_id)
);

CREATE INDEX IF NOT EXISTS idx_stock_vendor ON stock(vendor_id);
CREATE INDEX IF NOT EXISTS idx_stock_product ON stock(product_id);
CREATE INDEX IF NOT EXISTS idx_stock_low ON stock(quantity) WHERE quantity <= min_stock_level;

-- Stock Movement Table (Track all stock changes)
CREATE TABLE IF NOT EXISTS stock_movements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    stock_id UUID NOT NULL REFERENCES stock(id) ON DELETE CASCADE,
    movement_type VARCHAR(50) NOT NULL CHECK (movement_type IN ('purchase', 'sale', 'adjustment', 'waste')),
    quantity DECIMAL(10, 3) NOT NULL,
    reference_type VARCHAR(50), -- 'purchase', 'sale', 'order'
    reference_id UUID,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_stock_movements_stock ON stock_movements(stock_id);
CREATE INDEX IF NOT EXISTS idx_stock_movements_type ON stock_movements(movement_type);
CREATE INDEX IF NOT EXISTS idx_stock_movements_date ON stock_movements(created_at);

-- ============================================
-- SALES
-- ============================================

-- Sales Table (Actual deliveries to customers)
CREATE TABLE IF NOT EXISTS sales (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES orders(id) ON DELETE SET NULL,
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    vendor_id UUID NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    sale_date DATE NOT NULL DEFAULT CURRENT_DATE,
    total_amount DECIMAL(10, 2),
    paid_amount DECIMAL(10, 2) DEFAULT 0,
    status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'delivered', 'cancelled')),
    delivery_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_sales_vendor ON sales(vendor_id);
CREATE INDEX IF NOT EXISTS idx_sales_customer ON sales(customer_id);
CREATE INDEX IF NOT EXISTS idx_sales_order ON sales(order_id);
CREATE INDEX IF NOT EXISTS idx_sales_date ON sales(sale_date);
CREATE INDEX IF NOT EXISTS idx_sales_status ON sales(status);

-- Sale Items Table
CREATE TABLE IF NOT EXISTS sale_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sale_id UUID NOT NULL REFERENCES sales(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    quantity DECIMAL(10, 3) NOT NULL CHECK (quantity > 0),
    price_per_unit DECIMAL(10, 2),
    total_price DECIMAL(10, 2),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_sale_items_sale ON sale_items(sale_id);
CREATE INDEX IF NOT EXISTS idx_sale_items_product ON sale_items(product_id);

-- ============================================
-- DELIVERY ROUTES
-- ============================================

-- Delivery Routes Table
CREATE TABLE IF NOT EXISTS delivery_routes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id UUID NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    route_date DATE NOT NULL DEFAULT CURRENT_DATE,
    status VARCHAR(50) DEFAULT 'planned' CHECK (status IN ('planned', 'in_progress', 'completed')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_delivery_routes_vendor ON delivery_routes(vendor_id);
CREATE INDEX IF NOT EXISTS idx_delivery_routes_date ON delivery_routes(route_date);

-- Delivery Stops Table
CREATE TABLE IF NOT EXISTS delivery_stops (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    route_id UUID NOT NULL REFERENCES delivery_routes(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    order_id UUID REFERENCES orders(id) ON DELETE SET NULL,
    sale_id UUID REFERENCES sales(id) ON DELETE SET NULL,
    sequence INTEGER NOT NULL DEFAULT 0,
    status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'delivered', 'failed')),
    delivered_at TIMESTAMP WITH TIME ZONE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_delivery_stops_route ON delivery_stops(route_id);
CREATE INDEX IF NOT EXISTS idx_delivery_stops_customer ON delivery_stops(customer_id);
CREATE INDEX IF NOT EXISTS idx_delivery_stops_status ON delivery_stops(status);

-- ============================================
-- TRIGGERS
-- ============================================

-- Trigger to update updated_at timestamp for all tables
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers
DROP TRIGGER IF EXISTS update_purchases_updated_at ON purchases;
CREATE TRIGGER update_purchases_updated_at
    BEFORE UPDATE ON purchases
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_stock_updated_at ON stock;
CREATE TRIGGER update_stock_updated_at
    BEFORE UPDATE ON stock
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_sales_updated_at ON sales;
CREATE TRIGGER update_sales_updated_at
    BEFORE UPDATE ON sales
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_delivery_routes_updated_at ON delivery_routes;
CREATE TRIGGER update_delivery_routes_updated_at
    BEFORE UPDATE ON delivery_routes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_delivery_stops_updated_at ON delivery_stops;
CREATE TRIGGER update_delivery_stops_updated_at
    BEFORE UPDATE ON delivery_stops
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- VIEWS FOR REPORTING
-- ============================================

-- View: Current Stock Levels
CREATE OR REPLACE VIEW vw_current_stock AS
SELECT 
    s.id,
    s.vendor_id,
    s.product_id,
    p.name_gu as product_name_gu,
    p.name_en as product_name_en,
    u.symbol as unit_symbol,
    s.quantity,
    s.min_stock_level,
    CASE 
        WHEN s.quantity <= 0 THEN 'out_of_stock'
        WHEN s.quantity <= s.min_stock_level THEN 'low_stock'
        ELSE 'in_stock'
    END as stock_status,
    s.last_updated
FROM stock s
JOIN products p ON s.product_id = p.id
JOIN units u ON p.unit_id = u.id;

-- View: Daily Sales Summary
CREATE OR REPLACE VIEW vw_daily_sales_summary AS
SELECT 
    vendor_id,
    sale_date,
    COUNT(*) as total_sales,
    COUNT(DISTINCT customer_id) as total_customers,
    SUM(total_amount) as total_revenue,
    SUM(paid_amount) as total_paid,
    SUM(total_amount - paid_amount) as total_pending
FROM sales
GROUP BY vendor_id, sale_date
ORDER BY sale_date DESC;
