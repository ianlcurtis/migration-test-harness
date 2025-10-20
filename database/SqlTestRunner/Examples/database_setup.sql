-- =====================================================
-- Database Setup Script (Pre-Configured Data)
-- =====================================================
-- This script contains lookup/reference data that must exist
-- for stored procedures to function correctly.
-- 
-- These rows are inserted ONCE before any tests run.
-- Test data setup scripts should NOT re-insert these rows.
-- Tests should reference existing IDs/values from this script.
-- =====================================================

-- =====================================================
-- LOOKUP TABLES
-- =====================================================

-- Status Codes Lookup Table
-- Tests should use these status_code values: ACTIVE, PENDING, CLOSED, CANCELLED, ON_HOLD
INSERT INTO StatusCodes (status_code, description, is_active) VALUES
('ACTIVE', 'Record is active and in use', 1),
('PENDING', 'Record is pending approval', 1),
('CLOSED', 'Record is closed and no longer active', 1),
('CANCELLED', 'Record has been cancelled', 1),
('ON_HOLD', 'Record is temporarily on hold', 1);

-- Priority Levels Lookup Table
-- Tests should use these priority_id values: 1-5
INSERT INTO PriorityLevels (priority_id, priority_name, sort_order) VALUES
(1, 'Critical', 1),
(2, 'High', 2),
(3, 'Medium', 3),
(4, 'Low', 4),
(5, 'Info', 5);

-- =====================================================
-- REFERENCE DATA
-- =====================================================

-- Department Lookup Table
-- Tests should use these department_id values: 101-105
INSERT INTO Departments (department_id, department_name, budget_code, is_active) VALUES
(101, 'Sales', 'SALES-001', 1),
(102, 'Engineering', 'ENG-001', 1),
(103, 'Marketing', 'MKT-001', 1),
(104, 'Human Resources', 'HR-001', 1),
(105, 'Finance', 'FIN-001', 1);

-- Manager Lookup Table
-- Tests should use these manager_id values: 201-205
INSERT INTO Managers (manager_id, first_name, last_name, email, department_id) VALUES
(201, 'John', 'Smith', 'john.smith@company.com', 101),
(202, 'Sarah', 'Johnson', 'sarah.johnson@company.com', 102),
(203, 'Michael', 'Williams', 'michael.williams@company.com', 103),
(204, 'Emily', 'Brown', 'emily.brown@company.com', 104),
(205, 'David', 'Davis', 'david.davis@company.com', 105);

-- Product Categories Lookup Table
-- Tests should use these category_id values: 301-304
INSERT INTO ProductCategories (category_id, category_name, parent_category_id) VALUES
(301, 'Electronics', NULL),
(302, 'Clothing', NULL),
(303, 'Books', NULL),
(304, 'Home & Garden', NULL);

-- Payment Methods Lookup Table
-- Tests should use these payment_method_id values: 401-404
INSERT INTO PaymentMethods (payment_method_id, method_name, is_active, requires_verification) VALUES
(401, 'Credit Card', 1, 1),
(402, 'Debit Card', 1, 1),
(403, 'PayPal', 1, 0),
(404, 'Bank Transfer', 1, 1);

-- =====================================================
-- CONFIGURATION DATA
-- =====================================================

-- System Configuration
-- Tests may reference these config values
INSERT INTO SystemConfig (config_key, config_value, data_type, description) VALUES
('MAX_TRANSACTION_AMOUNT', '10000.00', 'decimal', 'Maximum allowed transaction amount'),
('MIN_ORDER_QUANTITY', '1', 'int', 'Minimum order quantity allowed'),
('TAX_RATE', '0.08', 'decimal', 'Default tax rate percentage'),
('SHIPPING_THRESHOLD', '50.00', 'decimal', 'Free shipping threshold amount'),
('DEFAULT_CURRENCY', 'USD', 'string', 'Default currency code');

-- =====================================================
-- NOTES FOR TEST DEVELOPERS
-- =====================================================
-- 
-- IMPORTANT: When creating test data setup scripts:
--
-- 1. DO NOT re-insert any of the above data
-- 2. DO use the IDs/values listed above in your tests
-- 3. DO create only test-specific data (users, orders, transactions, etc.)
-- 4. DO reference these pre-configured IDs in foreign key relationships
--
-- Examples:
-- - When inserting an Employee, use manager_id from 201-205
-- - When inserting an Order, use status_code from the StatusCodes list
-- - When inserting a Product, use category_id from 301-304
-- - When inserting a Payment, use payment_method_id from 401-404
--
-- =====================================================
