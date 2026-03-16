-- ==========================================
-- GREEN_VEG COMPLETE DATABASE SCHEMA & SEED
-- Compatible with Supabase & Any PostgreSQL
-- ==========================================

-- 1. EXTENSIONS
-- Required for UUID generation in standard PostgreSQL (Supabase usually has this by default)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ==========================================
-- SECTION 1: CORE TABLES (000_create_base_tables)
-- ==========================================

-- Vendors Table
CREATE TABLE IF NOT EXISTS vendors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    settings JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    pin_hash VARCHAR(255)
);

CREATE INDEX IF NOT EXISTS idx_vendors_email ON vendors(email);
CREATE INDEX IF NOT EXISTS idx_vendors_active ON vendors(is_active);

-- Units Table
CREATE TABLE IF NOT EXISTS units (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_gu VARCHAR(100) NOT NULL,
    name_en VARCHAR(100) NOT NULL,
    symbol VARCHAR(20) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Insert default units
INSERT INTO units (name_gu, name_en, symbol) VALUES ('કિ.ગ્રા.', 'Kilogram', 'kg') ON CONFLICT DO NOTHING;
INSERT INTO units (name_gu, name_en, symbol) VALUES ('પાઉન્ડ', 'Pound', 'lb') ON CONFLICT DO NOTHING;
INSERT INTO units (name_gu, name_en, symbol) VALUES ('ગ્રામ', 'Gram', 'g') ON CONFLICT DO NOTHING;
INSERT INTO units (name_gu, name_en, symbol) VALUES ('પીસ', 'Piece', 'pc') ON CONFLICT DO NOTHING;
INSERT INTO units (name_gu, name_en, symbol) VALUES ('કિટલ', 'Quintal', 'qt') ON CONFLICT DO NOTHING;
INSERT INTO units (name_gu, name_en, symbol) VALUES ('ટન', 'Ton', 'ton') ON CONFLICT DO NOTHING;

-- Categories Table
CREATE TABLE IF NOT EXISTS categories (
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

CREATE INDEX IF NOT EXISTS idx_categories_vendor ON categories(vendor_id);
CREATE INDEX IF NOT EXISTS idx_categories_active ON categories(is_active);

-- Products Table
CREATE TABLE IF NOT EXISTS products (
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

CREATE INDEX IF NOT EXISTS idx_products_vendor ON products(vendor_id);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_active ON products(is_active);

-- ==========================================
-- SECTION 2: CUSTOMERS & ORDERS (001_create_customer_order_tables)
-- ==========================================

-- Customers Table
CREATE TABLE IF NOT EXISTS customers (
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

CREATE INDEX IF NOT EXISTS idx_customers_vendor ON customers(vendor_id);
CREATE INDEX IF NOT EXISTS idx_customers_type ON customers(type);
CREATE INDEX IF NOT EXISTS idx_customers_active ON customers(is_active);

-- Orders Table
CREATE TABLE IF NOT EXISTS orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    vendor_id UUID NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    order_date DATE NOT NULL,
    status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'delivered', 'cancelled')),
    total_amount DECIMAL(10, 2),
    total_cost DECIMAL(10, 2),
    notes TEXT,
    delivery_address TEXT,
    payment_status VARCHAR(20) DEFAULT 'unpaid' CHECK (payment_status IN ('unpaid', 'partial', 'paid')),
    paid_amount DECIMAL(10, 2) DEFAULT 0,
    contact_phone VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_orders_vendor ON orders(vendor_id);
CREATE INDEX IF NOT EXISTS idx_orders_customer ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_date ON orders(order_date);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);

-- Order Items Table
CREATE TABLE IF NOT EXISTS order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE SET NULL,
    quantity DECIMAL(10, 3) NOT NULL CHECK (quantity > 0),
    price_per_unit DECIMAL(10, 2),
    cost_price DECIMAL(10, 2),
    total_price DECIMAL(10, 2),
    notes TEXT,
    is_custom_item BOOLEAN DEFAULT false,
    custom_item_name VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product ON order_items(product_id);

-- ==========================================
-- SECTION 3: PHASE 2 - PURCHASES, STOCK, SALES (002_create_phase2_tables)
-- ==========================================

-- Purchases Table
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

-- Stock Table
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

-- Stock Movement Table
CREATE TABLE IF NOT EXISTS stock_movements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    stock_id UUID NOT NULL REFERENCES stock(id) ON DELETE CASCADE,
    movement_type VARCHAR(50) NOT NULL CHECK (movement_type IN ('purchase', 'sale', 'adjustment', 'waste')),
    quantity DECIMAL(10, 3) NOT NULL,
    reference_type VARCHAR(50), 
    reference_id UUID,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_stock_movements_stock ON stock_movements(stock_id);
CREATE INDEX IF NOT EXISTS idx_stock_movements_type ON stock_movements(movement_type);
CREATE INDEX IF NOT EXISTS idx_stock_movements_date ON stock_movements(created_at);

-- Sales Table
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

-- ==========================================
-- SECTION 4: DAILY PRICES (003_create_daily_prices_table)
-- ==========================================

CREATE TABLE IF NOT EXISTS daily_prices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    price_date DATE NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_product_date UNIQUE (product_id, price_date)
);

CREATE INDEX IF NOT EXISTS idx_daily_prices_product ON daily_prices(product_id);
CREATE INDEX IF NOT EXISTS idx_daily_prices_date ON daily_prices(price_date);
CREATE INDEX IF NOT EXISTS idx_daily_prices_product_date ON daily_prices(product_id, price_date);
CREATE INDEX IF NOT EXISTS idx_daily_prices_date_lookup ON daily_prices(price_date, product_id);

-- ==========================================
-- SECTION 5: TRIGGERS & VIEWS
-- ==========================================

-- Trigger Function for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers to all appropriate tables
DROP TRIGGER IF EXISTS update_vendors_updated_at ON vendors;
CREATE TRIGGER update_vendors_updated_at BEFORE UPDATE ON vendors FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_categories_updated_at ON categories;
CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON categories FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_products_updated_at ON products;
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_customers_updated_at ON customers;
CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON customers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_orders_updated_at ON orders;
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_purchases_updated_at ON purchases;
CREATE TRIGGER update_purchases_updated_at BEFORE UPDATE ON purchases FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_stock_updated_at ON stock;
CREATE TRIGGER update_stock_updated_at BEFORE UPDATE ON stock FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_sales_updated_at ON sales;
CREATE TRIGGER update_sales_updated_at BEFORE UPDATE ON sales FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_delivery_routes_updated_at ON delivery_routes;
CREATE TRIGGER update_delivery_routes_updated_at BEFORE UPDATE ON delivery_routes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_delivery_stops_updated_at ON delivery_stops;
CREATE TRIGGER update_delivery_stops_updated_at BEFORE UPDATE ON delivery_stops FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Views
CREATE OR REPLACE VIEW vw_current_stock AS
SELECT 
    s.id, s.vendor_id, s.product_id,
    p.name_gu as product_name_gu, p.name_en as product_name_en, u.symbol as unit_symbol,
    s.quantity, s.min_stock_level,
    CASE 
        WHEN s.quantity <= 0 THEN 'out_of_stock'
        WHEN s.quantity <= s.min_stock_level THEN 'low_stock'
        ELSE 'in_stock'
    END as stock_status,
    s.last_updated
FROM stock s
JOIN products p ON s.product_id = p.id
JOIN units u ON p.unit_id = u.id;

CREATE OR REPLACE VIEW vw_daily_sales_summary AS
SELECT 
    vendor_id, sale_date,
    COUNT(*) as total_sales, COUNT(DISTINCT customer_id) as total_customers,
    SUM(total_amount) as total_revenue, SUM(paid_amount) as total_paid, SUM(total_amount - paid_amount) as total_pending
FROM sales
GROUP BY vendor_id, sale_date
ORDER BY sale_date DESC;

-- ==========================================
-- SECTION 6: SEED DATA (004_seed_data)
-- ==========================================

-- Insert Main Demo Vendor
INSERT INTO vendors (id, email, password_hash, name, phone, is_active)
VALUES (
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'demo@greenveg.com',
    'd3ad9315b7be5dd53b31a273b3b3aba5defe700808305aa16a3062b76658a791',
    'Demo Vendor',
    '1234567890',
    true
) ON CONFLICT (email) DO NOTHING;

-- Insert Categories
INSERT INTO categories (id, vendor_id, name_gu, name_en, color, sort_order) VALUES
('11111111-1111-1111-1111-111111111111', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'શાકભાજી', 'Vegetables', '#4CAF50', 1),
('22222222-2222-2222-2222-222222222222', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'ફળ', 'Fruits', '#FF9800', 2),
('33333333-3333-3333-3333-333333333333', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'મસાલા', 'Spices', '#E91E63', 3)
ON CONFLICT DO NOTHING;

-- Insert Default kg unit (fallback if not created by above insert)
INSERT INTO units (id, name_gu, name_en, symbol) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'કિ.ગ્રા.', 'Kilogram', 'kg')
ON CONFLICT DO NOTHING;

-- Insert Products
INSERT INTO products (vendor_id, category_id, unit_id, name_gu, name_en, max_price, sort_order) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'ટામેટા કેરેટ', 'Tomatoes', 50, 1),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'બટેકા કેરેટ', 'Potatoes', 22, 2),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'કાંદા બોરી', 'Onions', 36, 3),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'કોબી બોરી', 'Cabbage', 25, 4),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'સિમલા', 'Capsicum', 40, 5),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'આદુ', 'Ginger', 70, 6),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'મર્સી', 'Mirchi', 80, 7),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'મકાઈ', 'Sweet Corn', 60, 8),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'કાકડી', 'Cucumber', 60, 9),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'લાંબા મર્સા', 'Beans', 60, 10),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'ભૉલાર નાના', 'Cluster Beans', 60, 11),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'લીંબુ', 'Lemon', 40, 12),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'રીંગણા', 'Brinjal', 30, 13),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'બટેકા નાના', 'Potatoes Small', 25, 14),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'પરવર', 'Parwal', 40, 15),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'પાપડી', 'Papdi', 100, 16),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'ફણસી', 'Fanasi', 70, 17),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'તુરીયા', 'Turiya', 50, 18),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'કોબી', 'Cabbage', 25, 19),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'ફ્લાવર', 'Cauliflower', 60, 20),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'કોળું', 'Pumpkin', 25, 21),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'ગાજર', 'Carrot', 25, 22),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'બીટ', 'Beetroot', 35, 23),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'રતાળુ ગોળ', 'Radish', 70, 24),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'સાકરીયા', 'Sugarcane', 50, 25),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'ટામેટા', 'Tomatoes', 50, 26),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'પાલક', 'Spinach', 35, 27),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'દેશી ધાણા', 'Coriander', 40, 28),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'ધાણા', 'Coriander', 40, 29),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'લીલાં કાંદા', 'Green Onions', 30, 30),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '33333333-3333-3333-3333-333333333333', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'લીલું લસણ', 'Garlic', 120, 31),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'મેથી', 'Fenugreek', 30, 32),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'નાની મેથી', 'Small Fenugreek', 70, 33),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'ફુદીનો', 'Fudino', 80, 34),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '33333333-3333-3333-3333-333333333333', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'લીમડી', 'Lemon Raw', 30, 35),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'સરગવો', 'Sargavo', 40, 36),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '33333333-3333-3333-3333-333333333333', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'લસણ', 'Garlic', 120, 37),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'વટાણા', 'Peas', 80, 38),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'લાલ સિમલા', 'Red Capsicum', 110, 39),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'પીળાં સિમલા', 'Yellow Capsicum', 110, 40),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'બ્રોકલી', 'Broccoli', 60, 41),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'મશરૂમ', 'Mushroom', 60, 42),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'કાંદા નાના', 'Small Onions', 25, 43),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'દૂધી', 'Doodhi', 30, 44),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'ચોળી', 'Chori', 40, 45),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'ગવાર', 'Gavar', 50, 46),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '22222222-2222-2222-2222-222222222222', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'કેરી', 'Mango', 80, 47),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'મૂળા', 'Mooli', 25, 48),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'ભીંડી', 'Bhindi', 40, 49),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'કારેલા', 'Karela', 50, 50),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '22222222-2222-2222-2222-222222222222', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'સફરજન', 'Orange', 80, 51),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '22222222-2222-2222-2222-222222222222', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'દાડમ', 'Pomegranate', 150, 52),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'તિંદોર', 'Tindora', 60, 53),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '22222222-2222-2222-2222-222222222222', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'દ્રાક્ષ', 'Grapes', 100, 54);
