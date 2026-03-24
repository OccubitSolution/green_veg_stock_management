-- ============================================================
-- GREEN VEG STOCK MANAGEMENT - COMPLETE FRESH MIGRATION
-- ============================================================
-- WARNING: This DROPS all existing tables and recreates them.
-- Run this in Supabase SQL Editor for a clean slate.
-- ============================================================

-- ============================================================
-- STEP 1: DROP ALL TABLES (reverse dependency order)
-- ============================================================

DROP TABLE IF EXISTS daily_prices CASCADE;
DROP TABLE IF EXISTS delivery_stops CASCADE;
DROP TABLE IF EXISTS delivery_routes CASCADE;
DROP TABLE IF EXISTS delivery_bundle_orders CASCADE;
DROP TABLE IF EXISTS delivery_bundles CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS stock_movements CASCADE;
DROP TABLE IF EXISTS stock CASCADE;
DROP TABLE IF EXISTS sale_items CASCADE;
DROP TABLE IF EXISTS sales CASCADE;
DROP TABLE IF EXISTS purchase_order_items CASCADE;
DROP TABLE IF EXISTS purchase_items CASCADE;
DROP TABLE IF EXISTS purchases CASCADE;
DROP TABLE IF EXISTS order_status_history CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS units CASCADE;
DROP TABLE IF EXISTS vendors CASCADE;

DROP VIEW IF EXISTS vw_current_stock CASCADE;
DROP VIEW IF EXISTS vw_daily_sales_summary CASCADE;
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;

-- ============================================================
-- STEP 2: CREATE TABLES
-- ============================================================

-- Vendors
CREATE TABLE vendors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    settings JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    pin_hash VARCHAR(255),
    role TEXT DEFAULT 'admin' CHECK (role IN ('admin', 'manager', 'delivery_staff', 'viewer')),
    invited_by UUID REFERENCES vendors(id),
    invite_code TEXT UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_vendors_email ON vendors(email);
CREATE INDEX idx_vendors_active ON vendors(is_active);
CREATE INDEX idx_vendors_role ON vendors(role);
CREATE INDEX idx_vendors_invited_by ON vendors(invited_by);
CREATE INDEX idx_vendors_invite_code ON vendors(invite_code) WHERE invite_code IS NOT NULL;

-- Units
CREATE TABLE units (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_gu VARCHAR(100) NOT NULL,
    name_en VARCHAR(100) NOT NULL,
    symbol VARCHAR(20) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Categories
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id UUID REFERENCES vendors(id) ON DELETE CASCADE,
    name_gu VARCHAR(100) NOT NULL,
    name_en VARCHAR(100),
    color VARCHAR(20) DEFAULT '#00897B',
    icon VARCHAR(50) DEFAULT 'category',
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_categories_vendor ON categories(vendor_id);
CREATE INDEX idx_categories_active ON categories(is_active);

-- Products
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id UUID NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    unit_id UUID REFERENCES units(id) ON DELETE SET NULL,
    name_gu VARCHAR(255) NOT NULL,
    name_en VARCHAR(255),
    max_price DECIMAL(10, 2),
    image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_products_vendor ON products(vendor_id);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_active ON products(is_active);

-- Customers
CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id UUID NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    contact_person VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(255),
    address TEXT,
    type VARCHAR(50) DEFAULT 'other' CHECK (type IN ('hotel', 'cafe', 'restaurant', 'supermarket', 'mess', 'catering', 'other')),
    notes TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_customers_vendor ON customers(vendor_id);
CREATE INDEX idx_customers_type ON customers(type);
CREATE INDEX idx_customers_active ON customers(is_active);

-- Orders
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    vendor_id UUID NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    order_date DATE NOT NULL,
    status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'delivered', 'cancelled')),
    delivery_slot VARCHAR(20) DEFAULT 'morning' CHECK (delivery_slot IN ('morning', 'evening', 'night')),
    total_amount DECIMAL(10, 2),
    total_cost DECIMAL(10, 2),
    notes TEXT,
    delivery_address TEXT,
    payment_status VARCHAR(20) DEFAULT 'unpaid' CHECK (payment_status IN ('unpaid', 'partial', 'paid')),
    paid_amount DECIMAL(10, 2) DEFAULT 0,
    contact_phone VARCHAR(20),
    delivered_at TIMESTAMP WITH TIME ZONE,
    delivered_by UUID REFERENCES vendors(id),
    cancellation_reason TEXT,
    cancelled_at TIMESTAMP WITH TIME ZONE,
    cancelled_by UUID REFERENCES vendors(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_orders_vendor ON orders(vendor_id);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_delivered_by ON orders(delivered_by);

-- Order Items
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE SET NULL,
    quantity DECIMAL(10, 3) NOT NULL CHECK (quantity > 0),
    price_per_unit DECIMAL(10, 2),
    cost_price DECIMAL(10, 2),
    total_price DECIMAL(10, 2),
    notes TEXT,
    is_purchased BOOLEAN DEFAULT false,
    is_custom_item BOOLEAN DEFAULT false,
    custom_item_name VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);

-- Order Status History
CREATE TABLE order_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    from_status TEXT,
    to_status TEXT NOT NULL,
    changed_by UUID NOT NULL REFERENCES vendors(id),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_order_status_history_order ON order_status_history(order_id, created_at DESC);

-- Purchases
CREATE TABLE purchases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id UUID NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    supplier_name TEXT,
    purchase_date DATE NOT NULL DEFAULT CURRENT_DATE,
    total_amount DECIMAL(10, 2),
    notes TEXT,
    created_by UUID REFERENCES vendors(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_purchases_vendor ON purchases(vendor_id);
CREATE INDEX idx_purchases_date ON purchases(purchase_date);
CREATE INDEX idx_purchases_vendor_date ON purchases(vendor_id, purchase_date DESC);

-- Purchase Items
CREATE TABLE purchase_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    purchase_id UUID NOT NULL REFERENCES purchases(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    quantity DECIMAL(10, 3) NOT NULL CHECK (quantity > 0),
    price_per_unit DECIMAL(10, 2),
    total_price DECIMAL(10, 2),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_purchase_items_purchase ON purchase_items(purchase_id);
CREATE INDEX idx_purchase_items_product ON purchase_items(product_id);

-- Purchase Order Items (junction)
CREATE TABLE purchase_order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    purchase_item_id UUID NOT NULL REFERENCES purchase_items(id) ON DELETE CASCADE,
    order_item_id UUID NOT NULL REFERENCES order_items(id) ON DELETE CASCADE,
    quantity DECIMAL(10, 2) NOT NULL CHECK (quantity > 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(purchase_item_id, order_item_id)
);

CREATE INDEX idx_purchase_order_items_purchase ON purchase_order_items(purchase_item_id);
CREATE INDEX idx_purchase_order_items_order ON purchase_order_items(order_item_id);

-- Stock
CREATE TABLE stock (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id UUID NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    quantity DECIMAL(10, 3) NOT NULL DEFAULT 0,
    min_stock_level DECIMAL(10, 3) DEFAULT 0,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(vendor_id, product_id)
);

CREATE INDEX idx_stock_vendor ON stock(vendor_id);
CREATE INDEX idx_stock_product ON stock(product_id);
CREATE INDEX idx_stock_low ON stock(quantity) WHERE quantity <= min_stock_level;

-- Stock Movements
CREATE TABLE stock_movements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    stock_id UUID NOT NULL REFERENCES stock(id) ON DELETE CASCADE,
    movement_type VARCHAR(50) NOT NULL CHECK (movement_type IN ('purchase', 'sale', 'adjustment', 'waste')),
    quantity DECIMAL(10, 3) NOT NULL,
    reference_type VARCHAR(50),
    reference_id UUID,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_stock_movements_stock ON stock_movements(stock_id);
CREATE INDEX idx_stock_movements_type ON stock_movements(movement_type);
CREATE INDEX idx_stock_movements_date ON stock_movements(created_at);

-- Sales
CREATE TABLE sales (
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

CREATE INDEX idx_sales_vendor ON sales(vendor_id);
CREATE INDEX idx_sales_customer ON sales(customer_id);
CREATE INDEX idx_sales_order ON sales(order_id);
CREATE INDEX idx_sales_date ON sales(sale_date);
CREATE INDEX idx_sales_status ON sales(status);

-- Sale Items
CREATE TABLE sale_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sale_id UUID NOT NULL REFERENCES sales(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    quantity DECIMAL(10, 3) NOT NULL CHECK (quantity > 0),
    price_per_unit DECIMAL(10, 2),
    total_price DECIMAL(10, 2),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_sale_items_sale ON sale_items(sale_id);
CREATE INDEX idx_sale_items_product ON sale_items(product_id);

-- Delivery Bundles
CREATE TABLE delivery_bundles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id UUID NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    delivery_date DATE NOT NULL,
    assigned_to UUID REFERENCES vendors(id),
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
    notes TEXT,
    created_by UUID REFERENCES vendors(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_delivery_bundles_vendor_date ON delivery_bundles(vendor_id, delivery_date DESC);
CREATE INDEX idx_delivery_bundles_assigned ON delivery_bundles(assigned_to);

-- Delivery Bundle Orders
CREATE TABLE delivery_bundle_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bundle_id UUID NOT NULL REFERENCES delivery_bundles(id) ON DELETE CASCADE,
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    sequence_number INTEGER,
    delivered_at TIMESTAMP WITH TIME ZONE,
    delivery_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(bundle_id, order_id)
);

CREATE INDEX idx_delivery_bundle_orders_bundle ON delivery_bundle_orders(bundle_id);
CREATE INDEX idx_delivery_bundle_orders_order ON delivery_bundle_orders(order_id);

-- Delivery Routes
CREATE TABLE delivery_routes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id UUID NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    route_date DATE NOT NULL DEFAULT CURRENT_DATE,
    status VARCHAR(50) DEFAULT 'planned' CHECK (status IN ('planned', 'in_progress', 'completed')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_delivery_routes_vendor ON delivery_routes(vendor_id);
CREATE INDEX idx_delivery_routes_date ON delivery_routes(route_date);

-- Delivery Stops
CREATE TABLE delivery_stops (
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

CREATE INDEX idx_delivery_stops_route ON delivery_stops(route_id);
CREATE INDEX idx_delivery_stops_customer ON delivery_stops(customer_id);
CREATE INDEX idx_delivery_stops_status ON delivery_stops(status);

-- Payments
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    vendor_id UUID NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
    payment_date DATE NOT NULL DEFAULT CURRENT_DATE,
    payment_method TEXT,
    notes TEXT,
    created_by UUID REFERENCES vendors(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_payments_order ON payments(order_id);
CREATE INDEX idx_payments_vendor_date ON payments(vendor_id, payment_date DESC);

-- Daily Prices
CREATE TABLE daily_prices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    price_date DATE NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_product_date UNIQUE (product_id, price_date)
);

CREATE INDEX idx_daily_prices_product ON daily_prices(product_id);
CREATE INDEX idx_daily_prices_date ON daily_prices(price_date);
CREATE INDEX idx_daily_prices_product_date ON daily_prices(product_id, price_date);
CREATE INDEX idx_daily_prices_date_lookup ON daily_prices(price_date, product_id);

-- ============================================================
-- STEP 3: TRIGGERS
-- ============================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_vendors_updated_at
    BEFORE UPDATE ON vendors FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_categories_updated_at
    BEFORE UPDATE ON categories FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_products_updated_at
    BEFORE UPDATE ON products FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_customers_updated_at
    BEFORE UPDATE ON customers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_orders_updated_at
    BEFORE UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_purchases_updated_at
    BEFORE UPDATE ON purchases FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_stock_updated_at
    BEFORE UPDATE ON stock FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_sales_updated_at
    BEFORE UPDATE ON sales FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_delivery_routes_updated_at
    BEFORE UPDATE ON delivery_routes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_delivery_stops_updated_at
    BEFORE UPDATE ON delivery_stops FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_delivery_bundles_updated_at
    BEFORE UPDATE ON delivery_bundles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- STEP 4: VIEWS
-- ============================================================

CREATE VIEW vw_current_stock AS
SELECT
    s.id, s.vendor_id, s.product_id,
    p.name_gu AS product_name_gu, p.name_en AS product_name_en,
    u.symbol AS unit_symbol,
    s.quantity, s.min_stock_level,
    CASE
        WHEN s.quantity <= 0 THEN 'out_of_stock'
        WHEN s.quantity <= s.min_stock_level THEN 'low_stock'
        ELSE 'in_stock'
    END AS stock_status,
    s.last_updated
FROM stock s
JOIN products p ON s.product_id = p.id
JOIN units u ON p.unit_id = u.id;

CREATE VIEW vw_daily_sales_summary AS
SELECT
    vendor_id, sale_date,
    COUNT(*) AS total_sales,
    COUNT(DISTINCT customer_id) AS total_customers,
    SUM(total_amount) AS total_revenue,
    SUM(paid_amount) AS total_paid,
    SUM(total_amount - paid_amount) AS total_pending
FROM sales
GROUP BY vendor_id, sale_date
ORDER BY sale_date DESC;

-- ============================================================
-- STEP 5: ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE delivery_bundles ENABLE ROW LEVEL SECURITY;
ALTER TABLE delivery_bundle_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Vendors can view their own purchases"
    ON purchases FOR SELECT USING (vendor_id = auth.uid() OR vendor_id IN (SELECT invited_by FROM vendors WHERE id = auth.uid()));
CREATE POLICY "Vendors can create their own purchases"
    ON purchases FOR INSERT WITH CHECK (vendor_id = auth.uid() OR vendor_id IN (SELECT invited_by FROM vendors WHERE id = auth.uid()));
CREATE POLICY "Vendors can update their own purchases"
    ON purchases FOR UPDATE USING (vendor_id = auth.uid());

CREATE POLICY "Vendors can view purchase items"
    ON purchase_items FOR SELECT USING (purchase_id IN (SELECT id FROM purchases WHERE vendor_id = auth.uid() OR vendor_id IN (SELECT invited_by FROM vendors WHERE id = auth.uid())));
CREATE POLICY "Vendors can create purchase items"
    ON purchase_items FOR INSERT WITH CHECK (purchase_id IN (SELECT id FROM purchases WHERE vendor_id = auth.uid() OR vendor_id IN (SELECT invited_by FROM vendors WHERE id = auth.uid())));

CREATE POLICY "Vendors can view order status history"
    ON order_status_history FOR SELECT USING (order_id IN (SELECT id FROM orders WHERE vendor_id = auth.uid() OR vendor_id IN (SELECT invited_by FROM vendors WHERE id = auth.uid())));
CREATE POLICY "Vendors can create order status history"
    ON order_status_history FOR INSERT WITH CHECK (order_id IN (SELECT id FROM orders WHERE vendor_id = auth.uid() OR vendor_id IN (SELECT invited_by FROM vendors WHERE id = auth.uid())));

CREATE POLICY "Vendors can view their delivery bundles"
    ON delivery_bundles FOR SELECT USING (vendor_id = auth.uid() OR assigned_to = auth.uid() OR vendor_id IN (SELECT invited_by FROM vendors WHERE id = auth.uid()));
CREATE POLICY "Vendors can create delivery bundles"
    ON delivery_bundles FOR INSERT WITH CHECK (vendor_id = auth.uid());
CREATE POLICY "Vendors can update their delivery bundles"
    ON delivery_bundles FOR UPDATE USING (vendor_id = auth.uid() OR assigned_to = auth.uid());

CREATE POLICY "Vendors can view their payments"
    ON payments FOR SELECT USING (vendor_id = auth.uid() OR vendor_id IN (SELECT invited_by FROM vendors WHERE id = auth.uid()));
CREATE POLICY "Vendors can create payments"
    ON payments FOR INSERT WITH CHECK (vendor_id = auth.uid());

-- ============================================================
-- STEP 6: SEED DATA
-- ============================================================

-- Units
INSERT INTO units (id, name_gu, name_en, symbol) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'કિ.ગ્રા.', 'Kilogram', 'kg'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'પાઉન્ડ',   'Pound',    'lb'),
('cccccccc-cccc-cccc-cccc-cccccccccccc', 'ગ્રામ',     'Gram',     'g'),
('dddddddd-dddd-dddd-dddd-dddddddddddd', 'પીસ',       'Piece',    'pc'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'કિટલ',     'Quintal',  'qt'),
('ffffffff-ffff-ffff-ffff-ffffffffffff', 'ટન',        'Ton',      'ton');

-- Demo vendor  (email: demo@gmail.com  password: demo123)
INSERT INTO vendors (id, email, password_hash, name, phone, is_active) VALUES (
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'demo@gmail.com',
    'd3ad9315b7be5dd53b31a273b3b3aba5defe700808305aa16a3062b76658a791',
    'Demo Vendor', '1234567890', true
);

-- Categories
INSERT INTO categories (id, vendor_id, name_gu, name_en, color, sort_order) VALUES
('11111111-1111-1111-1111-111111111111', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'શાકભાજી', 'Vegetables', '#4CAF50', 1),
('22222222-2222-2222-2222-222222222222', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'ફળ',       'Fruits',     '#FF9800', 2),
('33333333-3333-3333-3333-333333333333', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'મસાલા',    'Spices',     '#E91E63', 3);

-- Products (54 items)
INSERT INTO products (vendor_id, category_id, unit_id, name_gu, name_en, max_price, sort_order) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'ટામેટા કેરેટ', 'Tomatoes', 50, 1),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'બટેકા કેરેટ', 'Potatoes', 22, 2),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'કાંદા બોરી', 'Onions', 36, 3),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'કોબી બોરી', 'Cabbage', 25, 4),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'સિમલા', 'Capsicum', 40, 5),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'આદુ', 'Ginger', 70, 6),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'મર્સી', 'Mirchi', 80, 7),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'મકાઈ', 'Sweet Corn', 60, 8),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'કાકડી', 'Cucumber', 60, 9),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'લાંબા મર્સા', 'Beans', 60, 10),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'ભૉલાર નાના', 'Cluster Beans', 60, 11),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'લીંબુ', 'Lemon', 40, 12),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'રીંગણા', 'Brinjal', 30, 13),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'બટેકા નાના', 'Potatoes Small', 25, 14),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'પરવર', 'Parwal', 40, 15),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'પાપડી', 'Papdi', 100, 16),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'ફણસી', 'Fanasi', 70, 17),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'તુરીયા', 'Turiya', 50, 18),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'કોબી', 'Cabbage', 25, 19),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'ફ્લાવર', 'Cauliflower', 60, 20),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'કોળું', 'Pumpkin', 25, 21),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'ગાજર', 'Carrot', 25, 22),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'બીટ', 'Beetroot', 35, 23),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'રતાળુ ગોળ', 'Radish', 70, 24),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'સાકરીયા', 'Sugarcane', 50, 25),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'ટામેટા', 'Tomatoes', 50, 26),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'પાલક', 'Spinach', 35, 27),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'દેશી ધાણા', 'Coriander', 40, 28),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'ધાણા', 'Coriander', 40, 29),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'લીલાં કાંદા', 'Green Onions', 30, 30),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '33333333-3333-3333-3333-333333333333'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'લીલું લસણ', 'Garlic Green', 120, 31),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'મેથી', 'Fenugreek', 30, 32),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'નાની મેથી', 'Small Fenugreek', 70, 33),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'ફુદીનો', 'Mint', 80, 34),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '33333333-3333-3333-3333-333333333333'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'લીમડી', 'Curry Leaves', 30, 35),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'સરગવો', 'Drumstick', 40, 36),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '33333333-3333-3333-3333-333333333333'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'લસણ', 'Garlic', 120, 37),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'વટાણા', 'Peas', 80, 38),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'લાલ સિમલા', 'Red Capsicum', 110, 39),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'પીળાં સિમલા', 'Yellow Capsicum', 110, 40),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'બ્રોકલી', 'Broccoli', 60, 41),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'મશરૂમ', 'Mushroom', 60, 42),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'કાંદા નાના', 'Small Onions', 25, 43),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'દૂધી', 'Bottle Gourd', 30, 44),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'ચોળી', 'Black Eyed Beans', 40, 45),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'ગવાર', 'Cluster Beans', 50, 46),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '22222222-2222-2222-2222-222222222222'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'કેરી', 'Mango', 80, 47),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'મૂળા', 'Radish White', 25, 48),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'ભીંડી', 'Okra', 40, 49),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'કારેલા', 'Bitter Gourd', 50, 50),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '22222222-2222-2222-2222-222222222222'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'સફરજન', 'Apple', 80, 51),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '22222222-2222-2222-2222-222222222222'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'દાડમ', 'Pomegranate', 150, 52),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'તિંદોર', 'Ivy Gourd', 60, 53),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, '22222222-2222-2222-2222-222222222222'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'દ્રાક્ષ', 'Grapes', 100, 54);

-- ============================================================
-- VERIFY
-- ============================================================
SELECT 'units' AS tbl, COUNT(*) AS rows FROM units
UNION ALL SELECT 'vendors',    COUNT(*) FROM vendors
UNION ALL SELECT 'categories', COUNT(*) FROM categories
UNION ALL SELECT 'products',   COUNT(*) FROM products;
