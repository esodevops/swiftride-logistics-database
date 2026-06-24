-- MANAGER RBAC SETUP
-- Create a manager role that can access all schemas but only with read permissions.

-- Create a manager role
CREATE ROLE manager;

-- Create a user for the manager role and grant the manager role to that user
CREATE USER manager_user WITH PASSWORD 'Manager123';

-- Grant the manager role to the manager user and give read-only access to all schemas
GRANT manager TO manager_user;

-- Grant the manager role read-only access to all schemas
GRANT USAGE ON SCHEMA operations TO manager;
GRANT USAGE ON SCHEMA fleet TO manager;
GRANT USAGE ON SCHEMA finance TO manager;
GRANT USAGE ON SCHEMA warehouse TO manager;

-- Grant SELECT permissions to the manager role for all tables in each schema
GRANT SELECT ON ALL TABLES IN SCHEMA operations TO manager;
GRANT SELECT ON ALL TABLES IN SCHEMA fleet TO manager;
GRANT SELECT ON ALL TABLES IN SCHEMA finance TO manager;
GRANT SELECT ON ALL TABLES IN SCHEMA warehouse TO manager;

-- Create a test user for the manager role to verify access permissions
-- Manager User Test
-- Host: localhost
-- Database: swiftride_logistics_db
-- Username: manager_user
-- Password: Manager123

-- Test Queries for Manager User
SELECT CURRENT_USER;
SELECT * FROM operations.customers;
SELECT * FROM fleet.drivers;
SELECT * FROM finance.payments;
SELECT * FROM warehouse.inventory;