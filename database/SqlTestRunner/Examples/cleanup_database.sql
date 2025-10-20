-- ===========================================
-- Database Cleanup Script
-- Run between each test to ensure clean state
-- ===========================================

-- Disable foreign key constraints temporarily
EXEC sp_MSforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT all"

-- Delete data from all tables (order matters for FK relationships)
DELETE FROM TransactionDetails;
DELETE FROM Transactions;
DELETE FROM PaymentMethods;
DELETE FROM Products;
DELETE FROM Users;

-- Re-enable foreign key constraints
EXEC sp_MSforeachtable "ALTER TABLE ? WITH CHECK CHECK CONSTRAINT all"

-- Reset identity columns if applicable
IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('Users'))
    DBCC CHECKIDENT ('Users', RESEED, 1000);

IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('Products'))
    DBCC CHECKIDENT ('Products', RESEED, 500);

IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('Transactions'))
    DBCC CHECKIDENT ('Transactions', RESEED, 2000);

IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('PaymentMethods'))
    DBCC CHECKIDENT ('PaymentMethods', RESEED, 0);