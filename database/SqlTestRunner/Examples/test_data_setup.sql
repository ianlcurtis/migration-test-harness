-- =====================================================
-- Test Data Setup Script for ProcessTransaction
-- =====================================================

-- TEST: T001 - Valid Purchase Transaction
-- Category: HAPPY_PATH
-- Description: User with sufficient balance makes valid purchase
-- Expected: SUCCESS with transaction ID returned
INSERT INTO Users (user_id, username, balance, status) VALUES (1001, 'test_user_001', 100.00, 'ACTIVE');
INSERT INTO Products (product_id, name, price, status) VALUES (501, 'test_product_001', 25.50, 'AVAILABLE');
INSERT INTO PaymentMethods (method_id, method_name, is_active) VALUES (1, 'CREDIT_CARD', 1);

-- VERIFY: T001
-- QUERY: UserBalance
SELECT user_id, username, balance, status FROM Users WHERE user_id = 1001;
-- QUERY: TransactionHistory
SELECT transaction_id, user_id, product_id, amount, transaction_type, status FROM Transactions WHERE user_id = 1001;
-- QUERY: ProductStatus
SELECT product_id, name, price, status FROM Products WHERE product_id = 501;

-- TEST: T002 - Valid Refund Transaction
-- Category: HAPPY_PATH
-- Description: Process a valid refund for existing transaction
-- Expected: SUCCESS with refund transaction ID returned
INSERT INTO Users (user_id, username, balance, status) VALUES (1002, 'test_user_002', 50.00, 'ACTIVE');
INSERT INTO Products (product_id, name, price, status) VALUES (502, 'test_product_002', 15.00, 'AVAILABLE');
INSERT INTO PaymentMethods (method_id, method_name, is_active) VALUES (2, 'DEBIT_CARD', 1);
INSERT INTO Transactions (transaction_id, user_id, product_id, amount, transaction_type, status) VALUES (2001, 1002, 502, 15.00, 'PURCHASE', 'COMPLETED');

-- TEST: T003 - Large Amount Purchase
-- Category: HAPPY_PATH
-- Description: Process purchase at boundary limit
-- Expected: SUCCESS with transaction ID returned
INSERT INTO Users (user_id, username, balance, status) VALUES (1003, 'test_user_003', 1500.00, 'ACTIVE');
INSERT INTO Products (product_id, name, price, status) VALUES (503, 'test_product_003', 999.99, 'AVAILABLE');
INSERT INTO PaymentMethods (method_id, method_name, is_active) VALUES (3, 'BANK_TRANSFER', 1);

-- TEST: T004 - Insufficient Funds
-- Category: UNHAPPY_PATH
-- Description: User attempts purchase with insufficient balance
-- Expected: ERROR with "Insufficient funds" message
INSERT INTO Users (user_id, username, balance, status) VALUES (1004, 'test_user_004', 10.00, 'ACTIVE');
INSERT INTO Products (product_id, name, price, status) VALUES (504, 'test_product_004', 1000.00, 'AVAILABLE');
INSERT INTO PaymentMethods (method_id, method_name, is_active) VALUES (4, 'CREDIT_CARD', 1);

-- TEST: T005 - Invalid User ID
-- Category: UNHAPPY_PATH
-- Description: Attempt transaction with non-existent user
-- Expected: ERROR with "User not found" message
INSERT INTO Products (product_id, name, price, status) VALUES (505, 'test_product_005', 25.50, 'AVAILABLE');
INSERT INTO PaymentMethods (method_id, method_name, is_active) VALUES (5, 'CREDIT_CARD', 1);
-- Note: User 9999 intentionally not inserted

-- TEST: T006 - Invalid Transaction Type
-- Category: UNHAPPY_PATH
-- Description: Use unsupported transaction type
-- Expected: ERROR with "Invalid transaction type" message
INSERT INTO Users (user_id, username, balance, status) VALUES (1005, 'test_user_005', 100.00, 'ACTIVE');
INSERT INTO Products (product_id, name, price, status) VALUES (506, 'test_product_006', 25.50, 'AVAILABLE');
INSERT INTO PaymentMethods (method_id, method_name, is_active) VALUES (6, 'CREDIT_CARD', 1);

-- TEST: T007 - Negative Amount
-- Category: UNHAPPY_PATH
-- Description: Attempt transaction with negative amount
-- Expected: ERROR with "Amount must be positive" message
INSERT INTO Users (user_id, username, balance, status) VALUES (1006, 'test_user_006', 100.00, 'ACTIVE');
INSERT INTO Products (product_id, name, price, status) VALUES (507, 'test_product_007', 25.50, 'AVAILABLE');
INSERT INTO PaymentMethods (method_id, method_name, is_active) VALUES (7, 'CREDIT_CARD', 1);

-- TEST: T008 - Null User ID
-- Category: EDGE_CASE
-- Description: Test with null user ID parameter
-- Expected: ERROR with "User ID cannot be null" message
INSERT INTO PaymentMethods (method_id, method_name, is_active) VALUES (8, 'CREDIT_CARD', 1);
-- Note: No user or product setup required for null parameter test

-- TEST: T009 - Zero Amount
-- Category: EDGE_CASE
-- Description: Test transaction with zero amount
-- Expected: ERROR with "Amount must be greater than zero" message
INSERT INTO Users (user_id, username, balance, status) VALUES (1007, 'test_user_007', 100.00, 'ACTIVE');
INSERT INTO Products (product_id, name, price, status) VALUES (508, 'test_product_008', 25.50, 'AVAILABLE');
INSERT INTO PaymentMethods (method_id, method_name, is_active) VALUES (9, 'CREDIT_CARD', 1);

-- TEST: T010 - Maximum Amount
-- Category: EDGE_CASE
-- Description: Test with maximum allowed amount
-- Expected: SUCCESS with transaction ID returned
INSERT INTO Users (user_id, username, balance, status) VALUES (1008, 'test_user_008', 1500000.00, 'ACTIVE');
INSERT INTO Products (product_id, name, price, status) VALUES (509, 'test_product_009', 999999.99, 'AVAILABLE');
INSERT INTO PaymentMethods (method_id, method_name, is_active) VALUES (10, 'BANK_TRANSFER', 1);

-- TEST: T011 - Inactive User
-- Category: EDGE_CASE
-- Description: Transaction attempt by inactive user
-- Expected: ERROR with "User account is inactive" message
INSERT INTO Users (user_id, username, balance, status) VALUES (1009, 'test_user_009', 100.00, 'INACTIVE');
INSERT INTO Products (product_id, name, price, status) VALUES (510, 'test_product_010', 25.50, 'AVAILABLE');
INSERT INTO PaymentMethods (method_id, method_name, is_active) VALUES (11, 'CREDIT_CARD', 1);

-- TEST: T012 - Concurrent Transaction
-- Category: EDGE_CASE
-- Description: Test handling of concurrent transactions
-- Expected: SUCCESS with transaction ID returned
INSERT INTO Users (user_id, username, balance, status) VALUES (1010, 'test_user_010', 200.00, 'ACTIVE');
INSERT INTO Products (product_id, name, price, status) VALUES (511, 'test_product_011', 50.00, 'AVAILABLE');
INSERT INTO PaymentMethods (method_id, method_name, is_active) VALUES (12, 'CREDIT_CARD', 1);