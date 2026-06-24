-- RBAC Setup for Logistics Company
-- This script creates roles for different departments in the logistics company to manage access control.
CREATE ROLE warehouse_team;

-- Assign Users to Roles
-- Now each user belongs to only one department.
GRANT warehouse_team TO warehouse_user;

-- Connecting each role to the database
GRANT CONNECT ON DATABASE swiftride_logistics TO warehouse_team;

-- Schema Access Grant 
-- USAGE means the user can enter or reference that schema.
GRANT USAGE ON SCHEMA warehouse TO warehouse_team;

-- Grant Table Access
GRANT SELECT ON ALL TABLES IN SCHEMA warehouse TO warehouse_team;

-- All the above only grants read/view access 
-- give each department read/write access to its own tables:
GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA warehouse TO warehouse_team;

-- Future-Proofing: To ensure that any new tables created in the future are automatically accessible to the respective teams, we can set default privileges.
ALTER DEFAULT PRIVILEGES IN SCHEMA warehouse GRANT
SELECT, INSERT, UPDATE, DELETE ON TABLES TO warehouse_team;

-- REVOKE access to other schemas (operations, finance, fleet) for warehouse_team to ensure they only have access to their own schema.
REVOKE ALL ON SCHEMA operations FROM warehouse_team;
REVOKE ALL ON SCHEMA finance FROM warehouse_team;
REVOKE ALL ON SCHEMA fleet FROM warehouse_team;

-- Create a test user for the warehouse role to verify access permissions
-- Warehouse User Test
-- Host: localhost
-- Database: swiftride_logistics_db
-- Username: warehouse_user
-- Password: Warehouse123