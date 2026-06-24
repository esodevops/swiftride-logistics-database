-- RBAC Setup for Logistics Company
-- This script creates roles for different departments in the logistics company to manage access control.
CREATE ROLE finance_team;

-- Assign Users to Roles
-- Now each user belongs to only one department.
GRANT finance_team TO finance_user;

-- Connecting each role to the database
GRANT CONNECT ON DATABASE swiftride_logistics TO finance_team;

-- Schema Access Grant 
-- USAGE means the user can enter or reference that schema.
GRANT USAGE ON SCHEMA finance TO finance_team;

-- Grant Table Access
GRANT SELECT ON ALL TABLES IN SCHEMA finance TO finance_team;

-- All the above only grants read/view access 
-- give each department read/write access to its own tables:
GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA finance TO finance_team;

-- Future-Proofing: To ensure that any new tables created in the future are automatically accessible to the respective teams, we can set default privileges.
ALTER DEFAULT PRIVILEGES IN SCHEMA finance GRANT
SELECT, INSERT, UPDATE, DELETE ON TABLES TO finance_team;

-- REVOKE access to other schemas (operations, fleet, warehouse) for finance_team to ensure they only have access to their own schema.
REVOKE ALL ON SCHEMA operations FROM finance_team;
REVOKE ALL ON SCHEMA fleet FROM finance_team;
REVOKE ALL ON SCHEMA warehouse FROM finance_team;

-- Create a test user for the manager role to verify access permissions
-- Manager User Test
-- Host: localhost
-- Database: swiftride_logistics_db
-- Username: finance_user
-- Password: Finance123