-- DCL (Data Control Language) for Finance Schema Access
-- This script creates a role with access ONLY to the finance schema
-- Run this as a superuser or admin in Supabase

-- ============================================================
-- STEP 1: Create a role for finance users
-- ============================================================
-- Replace 'finance_user' with your desired username
-- Replace the placeholder below with a strong password before running this file.
\set finance_user_password 'change_me_before_running'

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_roles
        WHERE rolname = 'finance_user'
    ) THEN
        CREATE ROLE finance_user WITH LOGIN;
    END IF;
END
$$;

ALTER ROLE finance_user WITH LOGIN PASSWORD :'finance_user_password';

-- ============================================================
-- STEP 2: Grant schema usage permissions
-- ============================================================
-- Allow the role to access objects in the finance schema
GRANT USAGE ON SCHEMA finance TO finance_user;

-- ============================================================
-- STEP 3: Grant table permissions
-- ============================================================
-- Grant SELECT, INSERT, UPDATE, DELETE on all tables in finance schema
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA finance TO finance_user;

-- Grant usage on all sequences in finance schema (for SERIAL columns)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA finance TO finance_user;

-- ============================================================
-- STEP 4: Set default permissions for future tables
-- ============================================================
-- Ensure new tables created in finance schema are automatically accessible
ALTER DEFAULT PRIVILEGES IN SCHEMA finance 
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO finance_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA finance 
GRANT USAGE, SELECT ON SEQUENCES TO finance_user;

-- ============================================================
-- STEP 5: Explicitly REVOKE access to other schemas
-- ============================================================
-- Ensure the role cannot access other schemas (operations, fleet, warehouse)
REVOKE ALL ON SCHEMA operations FROM finance_user;
REVOKE ALL ON SCHEMA fleet FROM finance_user;
REVOKE ALL ON SCHEMA warehouse FROM finance_user;

-- Revoke access to public schema (optional, but recommended for security)
REVOKE ALL ON SCHEMA public FROM finance_user;

-- ============================================================
-- STEP 6: Verify the setup (optional)
-- ============================================================
-- To test, connect as finance_user and try:
-- SELECT * FROM finance.payments;  -- Should work
-- SELECT * FROM operations.orders; -- Should fail with permission denied

-- ============================================================
-- ALTERNATIVE: Grant read-only access only
-- ============================================================
-- If you want a read-only finance user, use this instead:
-- 
-- CREATE ROLE finance_reader WITH LOGIN PASSWORD 'change_me_before_running';
-- GRANT USAGE ON SCHEMA finance TO finance_reader;
-- GRANT SELECT ON ALL TABLES IN SCHEMA finance TO finance_reader;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA finance TO finance_reader;
-- ALTER DEFAULT PRIVILEGES IN SCHEMA finance GRANT SELECT ON TABLES TO finance_reader;
-- ALTER DEFAULT PRIVILEGES IN SCHEMA finance GRANT USAGE, SELECT ON SEQUENCES TO finance_reader;

-- ============================================================
-- SUPABASE-SPECIFIC NOTES
-- ============================================================
-- 1. In Supabase, you may need to run this from the SQL Editor
-- 2. Supabase uses role-based security, so ensure you have admin privileges
-- 3. You can manage users/roles from Supabase Dashboard > Authentication
-- 4. For production, use environment variables for passwords
-- 5. Consider using Supabase Row Level Security (RLS) for additional security
