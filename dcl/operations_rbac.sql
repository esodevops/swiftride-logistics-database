-- RBAC Setup for Logistics Company
-- This script creates roles for different departments in the logistics company to manage access control.
CREATE ROLE operations_team;

-- Assign Users to Roles
-- Now each user belongs to only one department.
GRANT operations_team TO operations_user;

-- Connecting each role to the database
GRANT CONNECT ON DATABASE swiftride_logistics TO operations_team;

-- Schema Access Grant 
-- USAGE means the user can enter or reference that schema.
GRANT USAGE ON SCHEMA operations TO operations_team;

-- Grant Table Access
GRANT SELECT ON ALL TABLES IN SCHEMA operations TO operations_team;

-- All the above only grants read/view access 
-- give each department read/write access to its own tables:
GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA operations TO operations_team;

-- Future-Proofing: To ensure that any new tables created in the future are automatically accessible to the respective teams, we can set default privileges.
ALTER DEFAULT PRIVILEGES IN SCHEMA operations GRANT
SELECT, INSERT, UPDATE, DELETE ON TABLES TO operations_team;

-- REVOKE access to other schemas (fleet, finance, warehouse) for operations_team to ensure they only have access to their own schema.
REVOKE ALL ON SCHEMA fleet FROM operations_team;
REVOKE ALL ON SCHEMA finance FROM operations_team;
REVOKE ALL ON SCHEMA warehouse FROM operations_team;

-- Create a test user for the operations role to verify access permissions
-- Operations User Test
-- Host: localhost
-- Database: swiftride_logistics_db
-- Username: operations_user
-- Password: Operations123