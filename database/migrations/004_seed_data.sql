-- Seed Data for GreenVeg App
-- Run this after running all migration files

-- 1. Insert Demo Vendor (demo@gmail.com / demo123)
-- Note: Password is hashed using SHA256
INSERT INTO vendors (id, email, password_hash, name, phone, is_active)
VALUES (
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'demo@gmail.com',
    'd3ad9315b7be5dd53b31a273b3b3aba5defe700808305aa16a3062b76658a791',
    'Demo Vendor',
    '1234567890',
    true
) ON CONFLICT (email) DO NOTHING;

-- Get the vendor ID
-- We'll use: a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11

-- 2. Insert Categories
INSERT INTO categories (id, vendor_id, name_gu, name_en, color, sort_order) VALUES
('11111111-1111-1111-1111-111111111111', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'શાકભાજી', 'Vegetables', '#4CAF50', 1),
('22222222-2222-2222-2222-222222222222', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'ફળ', 'Fruits', '#FF9800', 2),
('33333333-3333-3333-3333-333333333333', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'મસાલા', 'Spices', '#E91E63', 3)
ON CONFLICT DO NOTHING;

-- 3. Get unit ID for kg (assuming it's already in units table)
-- If not, insert it first
INSERT INTO units (id, name_gu, name_en, symbol) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'કિ.ગ્રા.', 'Kilogram', 'kg')
ON CONFLICT DO NOTHING;

-- 4. Insert Products (from Excel file)
INSERT INTO products (vendor_id, category_id, unit_id, name_gu, name_en, max_price, sort_order) VALUES

-- Vegetables (use category_id: 11111111-1111-1111-1111-111111111111)
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

-- 5. Verify data
SELECT 'Vendors:' as info, COUNT(*) as count FROM vendors;
SELECT 'Categories:' as info, COUNT(*) as count FROM categories;
SELECT 'Products:' as info, COUNT(*) as count FROM products;
SELECT 'Units:' as info, COUNT(*) as count FROM units;
