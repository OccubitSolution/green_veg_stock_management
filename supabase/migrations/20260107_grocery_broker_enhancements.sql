-- Migration: Grocery Broker Workflow Enhancements
-- Date: 2026-01-07
-- Description: Add purchase tracking, order workflow, delivery bundles, and payment tracking

-- ============================================================================
-- 1. PURCHASE TRACKING TABLES
-- ============================================================================

-- Purchases table (records purchases from farms/suppliers)
CREATE TABLE IF NOT EXISTS purchases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vendor_id UUID NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
  purchase_date DATE NOT NULL DEFAULT CURRENT_DATE,
  supplier_name TEXT,
  total_amount DECIMAL(10, 2),
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES vendors(id)
);

-- Purchase items (individual items in a purchase)
CREATE TABLE IF NOT EXISTS purchase_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  purchase_id UUID NOT NULL REFERENCES purchases(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
  quantity DECIMAL(10, 2) NOT NULL CHECK (quantity > 0),
  price_per_unit DECIMAL(10, 2),
  total_price DECIMAL(10, 2),
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Junction table linking purchase items to order items
CREATE TABLE IF NOT EXISTS purchase_order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  purchase_item_id UUID NOT NULL REFERENCES purchase_items(id) ON DELETE CASCADE,
  order_item_id UUID NOT NULL REFERENCES order_items(id) ON DELETE CASCADE,
  quantity DECIMAL(10, 2) NOT NULL CHECK (quantity > 0),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(purchase_item_id, order_item_id)
);

-- ============================================================================
-- 2. ORDER WORKFLOW ENHANCEMENTS
-- ============================================================================

-- Add new columns to orders table
ALTER TABLE orders 
  ADD COLUMN IF NOT EXISTS delivered_at TIMESTAMP WITH TIME ZONE,
  ADD COLUMN IF NOT EXISTS delivered_by UUID REFERENCES vendors(id),
  ADD COLUMN IF NOT EXISTS cancellation_reason TEXT,
  ADD COLUMN IF NOT EXISTS cancelled_at TIMESTAMP WITH TIME ZONE,
  ADD COLUMN IF NOT EXISTS cancelled_by UUID REFERENCES vendors(id);

-- Order status history (audit trail)
CREATE TABLE IF NOT EXISTS order_status_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  from_status TEXT,
  to_status TEXT NOT NULL,
  changed_by UUID NOT NULL REFERENCES vendors(id),
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- 3. DELIVERY BUNDLES
-- ============================================================================

-- Delivery bundles (groups of orders for delivery)
CREATE TABLE IF NOT EXISTS delivery_bundles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vendor_id UUID NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  delivery_date DATE NOT NULL,
  assigned_to UUID REFERENCES vendors(id),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES vendors(id)
);

-- Junction table for bundle orders
CREATE TABLE IF NOT EXISTS delivery_bundle_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bundle_id UUID NOT NULL REFERENCES delivery_bundles(id) ON DELETE CASCADE,
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  sequence_number INTEGER,
  delivered_at TIMESTAMP WITH TIME ZONE,
  delivery_notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(bundle_id, order_id)
);

-- ============================================================================
-- 4. PAYMENT TRACKING
-- ============================================================================

-- Payments table
CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  vendor_id UUID NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
  amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
  payment_date DATE NOT NULL DEFAULT CURRENT_DATE,
  payment_method TEXT,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES vendors(id)
);

-- ============================================================================
-- 5. VENDOR/STAFF ROLE ENHANCEMENTS
-- ============================================================================

-- Add role fields to vendors table (if not exists)
ALTER TABLE vendors
  ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'admin' CHECK (role IN ('admin', 'manager', 'delivery_staff', 'viewer')),
  ADD COLUMN IF NOT EXISTS invited_by UUID REFERENCES vendors(id),
  ADD COLUMN IF NOT EXISTS invite_code TEXT UNIQUE;

-- ============================================================================
-- 6. INDEXES FOR PERFORMANCE
-- ============================================================================

-- Purchase tracking indexes
CREATE INDEX IF NOT EXISTS idx_purchases_vendor_date ON purchases(vendor_id, purchase_date DESC);
CREATE INDEX IF NOT EXISTS idx_purchase_items_purchase ON purchase_items(purchase_id);
CREATE INDEX IF NOT EXISTS idx_purchase_items_product ON purchase_items(product_id);
CREATE INDEX IF NOT EXISTS idx_purchase_order_items_purchase ON purchase_order_items(purchase_item_id);
CREATE INDEX IF NOT EXISTS idx_purchase_order_items_order ON purchase_order_items(order_item_id);

-- Order workflow indexes
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_delivered_by ON orders(delivered_by);
CREATE INDEX IF NOT EXISTS idx_order_status_history_order ON order_status_history(order_id, created_at DESC);

-- Delivery bundle indexes
CREATE INDEX IF NOT EXISTS idx_delivery_bundles_vendor_date ON delivery_bundles(vendor_id, delivery_date DESC);
CREATE INDEX IF NOT EXISTS idx_delivery_bundles_assigned ON delivery_bundles(assigned_to);
CREATE INDEX IF NOT EXISTS idx_delivery_bundle_orders_bundle ON delivery_bundle_orders(bundle_id);
CREATE INDEX IF NOT EXISTS idx_delivery_bundle_orders_order ON delivery_bundle_orders(order_id);

-- Payment indexes
CREATE INDEX IF NOT EXISTS idx_payments_order ON payments(order_id);
CREATE INDEX IF NOT EXISTS idx_payments_vendor_date ON payments(vendor_id, payment_date DESC);

-- Vendor role indexes
CREATE INDEX IF NOT EXISTS idx_vendors_role ON vendors(role);
CREATE INDEX IF NOT EXISTS idx_vendors_invited_by ON vendors(invited_by);
CREATE INDEX IF NOT EXISTS idx_vendors_invite_code ON vendors(invite_code) WHERE invite_code IS NOT NULL;

-- ============================================================================
-- 7. FUNCTIONS AND TRIGGERS
-- ============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
DROP TRIGGER IF EXISTS update_purchases_updated_at ON purchases;
CREATE TRIGGER update_purchases_updated_at
  BEFORE UPDATE ON purchases
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_delivery_bundles_updated_at ON delivery_bundles;
CREATE TRIGGER update_delivery_bundles_updated_at
  BEFORE UPDATE ON delivery_bundles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- 8. ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

-- Enable RLS on new tables
ALTER TABLE purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE delivery_bundles ENABLE ROW LEVEL SECURITY;
ALTER TABLE delivery_bundle_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

-- Purchases policies
CREATE POLICY "Vendors can view their own purchases"
  ON purchases FOR SELECT
  USING (vendor_id = auth.uid() OR vendor_id IN (
    SELECT invited_by FROM vendors WHERE id = auth.uid()
  ));

CREATE POLICY "Vendors can create their own purchases"
  ON purchases FOR INSERT
  WITH CHECK (vendor_id = auth.uid() OR vendor_id IN (
    SELECT invited_by FROM vendors WHERE id = auth.uid()
  ));

CREATE POLICY "Vendors can update their own purchases"
  ON purchases FOR UPDATE
  USING (vendor_id = auth.uid());

-- Purchase items policies
CREATE POLICY "Vendors can view purchase items"
  ON purchase_items FOR SELECT
  USING (purchase_id IN (
    SELECT id FROM purchases WHERE vendor_id = auth.uid() OR vendor_id IN (
      SELECT invited_by FROM vendors WHERE id = auth.uid()
    )
  ));

CREATE POLICY "Vendors can create purchase items"
  ON purchase_items FOR INSERT
  WITH CHECK (purchase_id IN (
    SELECT id FROM purchases WHERE vendor_id = auth.uid() OR vendor_id IN (
      SELECT invited_by FROM vendors WHERE id = auth.uid()
    )
  ));

-- Order status history policies
CREATE POLICY "Vendors can view order status history"
  ON order_status_history FOR SELECT
  USING (order_id IN (
    SELECT id FROM orders WHERE vendor_id = auth.uid() OR vendor_id IN (
      SELECT invited_by FROM vendors WHERE id = auth.uid()
    )
  ));

CREATE POLICY "Vendors can create order status history"
  ON order_status_history FOR INSERT
  WITH CHECK (order_id IN (
    SELECT id FROM orders WHERE vendor_id = auth.uid() OR vendor_id IN (
      SELECT invited_by FROM vendors WHERE id = auth.uid()
    )
  ));

-- Delivery bundles policies
CREATE POLICY "Vendors can view their delivery bundles"
  ON delivery_bundles FOR SELECT
  USING (vendor_id = auth.uid() OR assigned_to = auth.uid() OR vendor_id IN (
    SELECT invited_by FROM vendors WHERE id = auth.uid()
  ));

CREATE POLICY "Vendors can create delivery bundles"
  ON delivery_bundles FOR INSERT
  WITH CHECK (vendor_id = auth.uid());

CREATE POLICY "Vendors can update their delivery bundles"
  ON delivery_bundles FOR UPDATE
  USING (vendor_id = auth.uid() OR assigned_to = auth.uid());

-- Payments policies
CREATE POLICY "Vendors can view their payments"
  ON payments FOR SELECT
  USING (vendor_id = auth.uid() OR vendor_id IN (
    SELECT invited_by FROM vendors WHERE id = auth.uid()
  ));

CREATE POLICY "Vendors can create payments"
  ON payments FOR INSERT
  WITH CHECK (vendor_id = auth.uid());

-- ============================================================================
-- 9. COMMENTS FOR DOCUMENTATION
-- ============================================================================

COMMENT ON TABLE purchases IS 'Records purchases made from farms/suppliers';
COMMENT ON TABLE purchase_items IS 'Individual items within a purchase';
COMMENT ON TABLE purchase_order_items IS 'Links purchase items to order items for tracking';
COMMENT ON TABLE order_status_history IS 'Audit trail of order status changes';
COMMENT ON TABLE delivery_bundles IS 'Groups of orders for delivery routing';
COMMENT ON TABLE delivery_bundle_orders IS 'Orders within a delivery bundle';
COMMENT ON TABLE payments IS 'Payment records for orders';

COMMENT ON COLUMN orders.delivered_at IS 'Timestamp when order was delivered';
COMMENT ON COLUMN orders.delivered_by IS 'Staff member who delivered the order';
COMMENT ON COLUMN orders.cancellation_reason IS 'Reason for order cancellation';
COMMENT ON COLUMN orders.cancelled_at IS 'Timestamp when order was cancelled';
COMMENT ON COLUMN orders.cancelled_by IS 'User who cancelled the order';

COMMENT ON COLUMN vendors.role IS 'User role: admin, manager, delivery_staff, or viewer';
COMMENT ON COLUMN vendors.invited_by IS 'Admin who invited this staff member';
COMMENT ON COLUMN vendors.invite_code IS 'Unique code for staff registration';
