# How to Apply Database Migration

The migration file `20260107_grocery_broker_enhancements.sql` adds new features to your database but hasn't been applied yet.

## Option 1: Using Supabase Dashboard (Recommended)

1. Go to your Supabase/Neon database dashboard
2. Navigate to the SQL Editor
3. Open the file `supabase/migrations/20260107_grocery_broker_enhancements.sql`
4. Copy the entire SQL content
5. Paste it into the SQL Editor
6. Click "Run" to execute the migration

## Option 2: Using psql Command Line

If you have PostgreSQL client installed:

```bash
psql "postgresql://[username]:[password]@[host]/[database]?sslmode=require" -f supabase/migrations/20260107_grocery_broker_enhancements.sql
```

Replace the connection string with your actual database credentials from `lib/core/constants/app_constants.dart`.

## What This Migration Adds

- **Purchase tracking tables**: `purchases`, `purchase_items`, `purchase_order_items`
- **Order workflow**: `order_status_history` table and extended `orders` table
- **Delivery bundles**: `delivery_bundles`, `delivery_bundle_orders` tables
- **Payments**: `payments` table
- **Staff/Role system**: `role`, `invited_by`, `invite_code` columns in `vendors` table
- **Indexes and RLS policies** for better performance and security

## Current Status

The app will work without this migration, but the following features will not be available:
- Staff invite system (Settings > Generate Invite Code)
- Purchase tracking persistence
- Order status workflow
- Delivery bundle management
- Payment tracking

## After Migration

Once the migration is applied, restart your Flutter app to use the new features.
