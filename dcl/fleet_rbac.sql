-- RBAC Setup for Logistics Company
-- This script creates roles for different departments in the logistics company to manage access control.
CREATE ROLE fleet_team;

-- Assign Users to Roles
-- Now each user belongs to only one department.
GRANT fleet_team TO fleet_user;

-- Connecting each role to the database
GRANT CONNECT ON DATABASE swiftride_logistics TO fleet_team;

-- Schema Access Grant 
-- USAGE means the user can enter or reference that schema.
GRANT USAGE ON SCHEMA fleet TO fleet_team;

-- Grant Table Access
GRANT SELECT ON ALL TABLES IN SCHEMA fleet TO fleet_team;

-- All the above only grants read/view access 
-- give each department read/write access to its own tables:
GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA fleet TO fleet_team;

-- Future-Proofing: To ensure that any new tables created in the future are automatically accessible to the respective teams, we can set default privileges.
ALTER DEFAULT PRIVILEGES IN SCHEMA fleet GRANT
SELECT, INSERT, UPDATE, DELETE ON TABLES TO fleet_team;

-- REVOKE access to other schemas (operations, finance, warehouse) for fleet_team to ensure they only have access to their own schema.
REVOKE ALL ON SCHEMA operations FROM fleet_team;
REVOKE ALL ON SCHEMA finance FROM fleet_team;
REVOKE ALL ON SCHEMA warehouse FROM fleet_team;

-- Create a test user for the fleet role to verify access permissions
-- Fleet User Test
-- Host: localhost
-- Database: swiftride_logistics_db
-- Username: fleet_user
-- Password: Fleet123
