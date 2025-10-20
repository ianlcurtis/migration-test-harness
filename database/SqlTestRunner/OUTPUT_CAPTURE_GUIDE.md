# Database State and Output Capture Guide

This document explains how the SQL Test Runner captures and logs stored procedure outputs and database state.

## Overview

The test runner captures comprehensive information about each test execution:

1. **Stored Procedure Outputs**: Return values, output parameters, and result sets
2. **Database State**: Table contents after test execution
3. **Test Metadata**: Execution time, status, and error messages

All captured data is included in CSV, JSON, and HTML reports.

## Stored Procedure Output Capture

### Return Value

The stored procedure's return value (integer) is automatically captured:

```sql
CREATE PROCEDURE ProcessTransaction
    @user_id INT,
    @amount DECIMAL(10,2)
AS
BEGIN
    -- Process logic here
    RETURN 0;  -- This value is captured
END
```

**In Reports:**
- CSV: `return_value` column
- JSON: `storedProcedureOutput.returnValue` field
- HTML: "Return Value" in detailed output section

### Output Parameters

Output parameters are automatically detected and captured:

```sql
CREATE PROCEDURE ProcessTransaction
    @user_id INT,
    @amount DECIMAL(10,2),
    @transaction_id INT OUTPUT,
    @new_balance DECIMAL(10,2) OUTPUT
AS
BEGIN
    -- Process logic here
    SET @transaction_id = 12345;
    SET @new_balance = 75.50;
END
```

**In Reports:**
- JSON: `storedProcedureOutput.outputParameters` object with parameter names and values
- HTML: "Output Parameters" section with all parameters listed

### Result Sets

All SELECT statements in the stored procedure are captured as result sets:

```sql
CREATE PROCEDURE GetTransactionDetails
    @user_id INT
AS
BEGIN
    -- Result Set 1: User information
    SELECT user_id, username, balance FROM Users WHERE user_id = @user_id;
    
    -- Result Set 2: Transaction history
    SELECT transaction_id, amount, transaction_date FROM Transactions WHERE user_id = @user_id;
END
```

**In Reports:**
- JSON: `storedProcedureOutput.resultSets` array with all rows and columns
- HTML: Expandable tables for each result set with full column data

## Database State Capture

The test runner captures the state of database tables after each test execution. This is critical for verifying that the stored procedure made the correct changes to the database.

### Capture Modes

#### 1. Custom Verification Queries (Recommended)

Define specific queries to capture exactly what you need:

```sql
-- TEST: T001 - Valid Purchase Transaction
-- Category: HAPPY_PATH
INSERT INTO Users (user_id, username, balance) VALUES (1001, 'test_user', 100.00);
INSERT INTO Products (product_id, name, price) VALUES (501, 'test_product', 25.50);

-- VERIFY: T001
-- QUERY: UserBalance
SELECT user_id, username, balance, last_transaction_date FROM Users WHERE user_id = 1001;

-- QUERY: RecentTransactions
SELECT transaction_id, user_id, amount, status, created_date 
FROM Transactions 
WHERE user_id = 1001 
ORDER BY created_date DESC;

-- QUERY: ProductInventory
SELECT product_id, name, quantity_available, reserved_quantity 
FROM Products 
WHERE product_id = 501;
```

**Benefits:**
- Capture only relevant data
- Use WHERE clauses to filter rows
- Include computed columns or joins
- Give meaningful names to verification queries
- Multiple queries per test

**In Reports:**
- Each query appears as a separate table section
- Query names used as table names in reports
- Full row and column data captured

#### 2. Specific Tables Configuration

Configure specific tables to capture in `appsettings.json`:

```json
{
  "TestConfiguration": {
    "CaptureDatabaseState": true,
    "TablesToCapture": ["Users", "Transactions", "Products"],
    "CaptureAllAffectedTables": false
  }
}
```

**Behavior:**
- Executes `SELECT * FROM [TableName]` for each configured table
- Captures all rows and columns
- Same tables captured for all tests

#### 3. Auto-Detect Mode (Default)

Automatically detects tables used by the stored procedure:

```json
{
  "TestConfiguration": {
    "CaptureDatabaseState": true,
    "CaptureAllAffectedTables": true
  }
}
```

**Behavior:**
- Queries system catalog to find tables referenced by stored procedure
- Captures all rows from affected tables
- No configuration needed
- May capture unnecessary data

### Disabling Database State Capture

To disable database state capture entirely:

```json
{
  "TestConfiguration": {
    "CaptureDatabaseState": false
  }
}
```

## Report Output Examples

### JSON Output Structure

```json
{
  "executionDate": "2025-10-20T10:30:00Z",
  "totalTests": 1,
  "passed": 1,
  "results": [
    {
      "testId": "T001",
      "testName": "Valid Purchase Transaction",
      "status": "Pass",
      "durationMs": 45,
      "storedProcedureOutput": {
        "returnValue": 0,
        "outputParameters": {
          "@transaction_id": 12345,
          "@new_balance": 74.50
        },
        "resultSets": [
          {
            "resultSetIndex": 0,
            "rowCount": 1,
            "rows": [
              {
                "transaction_id": 12345,
                "status": "COMPLETED",
                "message": "Transaction successful"
              }
            ]
          }
        ]
      },
      "databaseState": {
        "tables": [
          {
            "tableName": "UserBalance",
            "rowCount": 1,
            "rows": [
              {
                "user_id": 1001,
                "username": "test_user",
                "balance": 74.50,
                "last_transaction_date": "2025-10-20T10:30:00Z"
              }
            ]
          },
          {
            "tableName": "RecentTransactions",
            "rowCount": 1,
            "rows": [
              {
                "transaction_id": 12345,
                "user_id": 1001,
                "amount": 25.50,
                "status": "COMPLETED",
                "created_date": "2025-10-20T10:30:00Z"
              }
            ]
          }
        ]
      }
    }
  ]
}
```

### HTML Output Features

The HTML report includes:

1. **Summary Table**: Quick overview of all test results
2. **Detailed Output Sections**: Expandable sections for each test with:
   - Stored Procedure Output
     - Return value displayed prominently
     - Output parameters in formatted list
     - Result sets in HTML tables
   - Database State After Test
     - Each captured table in separate section
     - Full column data in HTML tables
     - Limited to first 10 rows (with row count indicator)

### CSV Output Columns

Basic columns:
- `test_id`: Test identifier
- `test_name`: Test name
- `status`: Pass/Fail/Error
- `duration_ms`: Execution time

Output summary columns:
- `return_value`: Stored procedure return value
- `output_params_count`: Number of output parameters
- `result_sets_count`: Number of result sets returned
- `database_tables_captured`: Number of tables captured

## Best Practices

### 1. Use Custom Verification Queries

Define specific queries that verify your test expectations:

```sql
-- VERIFY: T001
-- QUERY: VerifyUserBalance
SELECT user_id, balance FROM Users WHERE user_id = 1001;

-- QUERY: VerifyTransactionCreated
SELECT COUNT(*) as transaction_count FROM Transactions WHERE user_id = 1001;

-- QUERY: VerifyProductReservation
SELECT product_id, quantity_available, reserved_quantity FROM Products WHERE product_id = 501;
```

### 2. Name Queries Descriptively

Use meaningful names that describe what is being verified:
- `UserBalance` instead of `Query1`
- `TransactionHistory` instead of `Query2`
- `ProductInventoryAfterPurchase` instead of `Query3`

### 3. Filter Data in Queries

Only capture relevant rows to keep reports concise:

```sql
-- QUERY: RecentUserTransactions
SELECT TOP 5 transaction_id, amount, status 
FROM Transactions 
WHERE user_id = @user_id 
ORDER BY created_date DESC;
```

### 4. Verify Calculated Values

Capture computed columns or aggregated data:

```sql
-- QUERY: AccountSummary
SELECT 
    user_id,
    balance,
    (SELECT COUNT(*) FROM Transactions WHERE user_id = Users.user_id) as total_transactions,
    (SELECT SUM(amount) FROM Transactions WHERE user_id = Users.user_id) as total_spent
FROM Users 
WHERE user_id = 1001;
```

### 5. Check Foreign Key Relationships

Verify that relationships are maintained:

```sql
-- QUERY: TransactionWithDetails
SELECT 
    t.transaction_id,
    t.user_id,
    u.username,
    t.product_id,
    p.name as product_name,
    t.amount
FROM Transactions t
INNER JOIN Users u ON t.user_id = u.user_id
INNER JOIN Products p ON t.product_id = p.product_id
WHERE t.transaction_id = 12345;
```

## Troubleshooting

### Database State Not Captured

**Problem**: Database state section is empty in reports

**Solutions:**
1. Verify `CaptureDatabaseState` is set to `true` in configuration
2. Check that verification queries are correctly formatted
3. Ensure stored procedure actually modifies tables
4. Review logs for capture errors

### Verification Queries Not Found

**Problem**: Auto-detect captures wrong tables

**Solution:** Use custom verification queries:
```sql
-- VERIFY: T001
-- QUERY: CustomQuery
SELECT * FROM YourTable WHERE condition = 'value';
```

### Too Much Data in Reports

**Problem**: HTML report is too large or slow to load

**Solutions:**
1. Use custom verification queries with WHERE clauses
2. Use `TOP N` or `LIMIT` in verification queries
3. Configure specific tables instead of auto-detect
4. Filter columns to only what's needed

### Output Parameters Not Captured

**Problem**: Output parameters show as empty

**Solutions:**
1. Verify stored procedure declares parameters with `OUTPUT` keyword
2. Check that stored procedure assigns values to output parameters
3. Review SQL error logs for parameter-related errors

## Console Logging

During test execution, the console shows:

```
[10:30:15 INF] Running test 1/12: T001 - Valid Purchase Transaction
[10:30:15 DBG] Added parameter @user_id = 1001
[10:30:15 DBG] Added parameter @amount = 25.50
[10:30:15 DBG] Captured 1 rows for verification query: UserBalance
[10:30:15 DBG] Captured 1 rows for verification query: RecentTransactions
[10:30:15 INF] Test T001 completed: Pass in 45ms
```

Use `--verbose` flag for detailed logging including:
- SQL statements being executed
- Parameter values
- Row counts for each verification query
- Database state capture details