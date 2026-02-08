-- Migration: Create Daily Prices Table
-- This table stores daily prices for products

-- Daily Prices Table
CREATE TABLE IF NOT EXISTS daily_prices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    price_date DATE NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Ensure only one price per product per date
    CONSTRAINT unique_product_date UNIQUE (product_id, price_date)
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_daily_prices_product ON daily_prices(product_id);
CREATE INDEX IF NOT EXISTS idx_daily_prices_date ON daily_prices(price_date);
CREATE INDEX IF NOT EXISTS idx_daily_prices_product_date ON daily_prices(product_id, price_date);

-- Create index for finding prices by date range
CREATE INDEX IF NOT EXISTS idx_daily_prices_date_lookup ON daily_prices(price_date, product_id);
