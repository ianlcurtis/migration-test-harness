# LLM PROMPT 2: SQL Server Stored Procedure Test File Generator

## OVERVIEW

You are a SQL testing expert. Your task is to generate test files (CSV and SQL) based on approved test case designs. This is **Phase 2** - test file generation only.

**Prerequisites**: You must have the output from PROMPT 1 (`[StoredProcedureName]_TEST_CASES.md`) which contains the approved test case designs.

## INPUT REQUIREMENTS

You will be provided with:
1. **Test Case Design File**: `[StoredProcedureName]_TEST_CASES.md` (from Phase 1) - Contains approved test case designs with test ID ranges
2. **DDL File** (e.g., `create_database.sql`): Database schema definition including table structures, foreign key relationships, and identity columns
3. **Stored Procedure**: The complete stored procedure code (for reference)
4. **database_setup.sql** (if exists): Pre-populated lookup/reference data that already exists in the database before tests run (seed data)

## OUTPUT REQUIREMENTS

Generate exactly THREE files:

### File 1: `test_arguments.csv`
CSV file containing test case parameters and expected results.

**Format**:
```csv
test_id,test_name,test_category,description,[param1],[param2],...,[paramN],expected_result,expected_error_message,setup_note
```

**Requirements**:
- One row per test case from the design document
- Column headers must match stored procedure parameter names
- Use test IDs from design (HP001, UP001, EC001, etc.)
- Translate test case designs into specific parameter values

### File 2: `test_data_setup.sql`
SQL script containing test data setup with INSERT statements and VERIFY sections.

**Format**:
```sql
-- =====================================================
-- Test Data Setup Script for [Stored Procedure Name]
-- =====================================================

-- TEST: HP001 - [Test Name]
-- Category: HAPPY_PATH
-- Description: [From design doc]
-- Expected: [Expected result from design]
[INSERT statements]

-- VERIFY: HP001
[Verification queries based on verification strategy]

-- TEST: UP001 - [Test Name]
...
```

**Requirements**:
- One TEST section per test case from design
- Include all dependency data (FKs, lookups, parent records)
- VERIFY sections for data-modifying procedures (based on verification strategy)
- No VERIFY sections for read-only procedures
- Maintain referential integrity in INSERT order

### File 3: `cleanup_database.sql`
SQL script for selective database cleanup that preserves seed data while removing test-specific data.

**Format**:
```sql
-- =====================================================
-- Selective Database Cleanup Script for [Stored Procedure Name]
-- Preserves seed data from database_setup.sql
-- Removes only test-specific data
-- =====================================================

-- Disable foreign key constraints
EXEC sp_MSforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT all"

-- Remove test data (preserve seed data)
[DELETE statements for test data only]

-- Reset identity columns to test ranges
[DBCC CHECKIDENT statements]

-- Re-enable constraints
EXEC sp_MSforeachtable "ALTER TABLE ? WITH CHECK CHECK CONSTRAINT all"

-- Verification queries
[Validation statements]
```

**Requirements**:
- Analyze database_setup.sql to identify seed data ID ranges
- Generate DELETE statements that preserve seed data
- Reset identity columns to appropriate test ranges
- Include verification to ensure cleanup worked correctly
- Maintain referential integrity during cleanup

## FILE GENERATION GUIDELINES

### CSV File Generation

Use the test case inventory from the design document to populate CSV rows:

**Column Mapping**:
1. **test_id**: Use exact ID from design (HP001, UP001, EC001)
2. **test_name**: Use test name from design
3. **test_category**: Map to standard categories:
   - HP### → HAPPY_PATH
   - UP### → UNHAPPY_PATH
   - EC### → EDGE_CASE
4. **description**: Copy from design document
5. **[param1-N]**: Use parameter values from design
6. **expected_result**: From "Expected Result" in design (SUCCESS/ERROR/specific value)
7. **expected_error_message**: From "Expected Error" in design (if ERROR expected)
8. **setup_note**: From "Setup Requirements" in design (brief summary)

**CSV Rules**:
- Use quotes for text containing commas
- Use NULL (unquoted) for null parameter values
- Use empty cell for optional parameters not being tested
- Maintain order: HAPPY_PATH tests first, then UNHAPPY_PATH, then EDGE_CASE

### SQL File Generation

For each test case in the design document, generate a TEST section:

**TEST Section Structure**:
```sql
-- TEST: [test_id] - [test_name]
-- Category: [test_category]
-- Description: [description from design]
-- Expected: [expected result from design]
-- Dependencies: [list from design]
[INSERT statements for setup requirements]
```

**INSERT Statement Rules**:
1. **Analyze Setup Requirements**: From "Setup Requirements" in test design
2. **Check Pre-Configured Data**: If database_setup.sql exists, identify which data is already present
   - **DO NOT** re-insert rows that exist in database_setup.sql
   - **DO** use existing IDs/values from pre-configured data (e.g., use manager_id = 101 if Managers table is pre-populated)
   - **DO** insert only test-specific data that doesn't exist in database_setup.sql
3. **Generate INSERT statements** for required data NOT in database_setup.sql:
   - Parent records (for FKs) - only if not pre-configured
   - Lookup table entries - only if not pre-configured
   - Reference data - only if not pre-configured
   - Primary test data
4. **Maintain referential integrity**: Insert parent tables before child tables
5. **Use consistent test values**: test_user_001, test_product_501, etc.
6. **Use pre-configured values**: When fields reference pre-populated tables (e.g., manager_id), use values from database_setup.sql
7. **Include all columns needed**: Don't rely on defaults if they affect test outcome

**VERIFY Section Rules** (Use Verification Strategy from design):

**For Data-Modifying Procedures**:
```sql
-- VERIFY: [test_id]
-- QUERY: [QueryName1]
[SELECT statement based on verification strategy]
-- QUERY: [QueryName2]
[SELECT statement based on verification strategy]
```

Generate queries based on the "Verification Strategy" section:
- One query per table listed in "Tables to Verify"
- Include queries for "Aggregates to Check"
- Use WHERE clauses to filter to test-specific data
- Use descriptive query names

**For Read-Only Procedures**:
- Omit VERIFY section entirely
- Add comment: `-- NO VERIFY SECTION - Read-only procedure`

## COMMON VERIFICATION PATTERNS

Use these patterns when creating VERIFY queries:

### Pattern 1: Single Record Check
```sql
-- QUERY: RecordDetails
SELECT column1, column2, column3 
FROM TableName 
WHERE id = [test_specific_id];
```

### Pattern 2: Row Count Verification
```sql
-- QUERY: RecordCount
SELECT COUNT(*) as total_records 
FROM TableName 
WHERE condition = 'test_value';
```

### Pattern 3: Aggregate Calculations
```sql
-- QUERY: TotalAmount
SELECT entity_id, 
       SUM(amount) as total, 
       AVG(amount) as average,
       COUNT(*) as count
FROM TableName 
WHERE entity_id = [test_specific_id]
GROUP BY entity_id;
```

### Pattern 4: Multi-Table Join
```sql
-- QUERY: RelatedData
SELECT t1.id, t1.value, t2.name, t3.status
FROM Table1 t1
INNER JOIN Table2 t2 ON t1.fk_id = t2.id
LEFT JOIN Table3 t3 ON t1.id = t3.table1_id
WHERE t1.id = [test_specific_id];
```

### Pattern 5: Constraint/Business Rule Check
```sql
-- QUERY: RuleValidation
SELECT id, value, 
       CASE WHEN value >= 0 THEN 'VALID' ELSE 'INVALID' END as status
FROM TableName 
WHERE id = [test_specific_id];
```

### Pattern 6: Before/After State Comparison
```sql
-- QUERY: StateChange
SELECT id, 
       [initial_value] as initial_value,
       current_value as final_value,
       (current_value - [initial_value]) as change
FROM TableName 
WHERE id = [test_specific_id];
```

## EXECUTION INSTRUCTIONS

1. **Read the test case design document** (`[StoredProcedureName]_TEST_CASES.md`) thoroughly
2. **Extract procedure information**:
   - Procedure name
   - Procedure type (data-modifying or read-only)
   - Parameters
3. **Extract test data ID ranges** from the test case design document:
   - Use the "Test Data ID Ranges" section from the Dependency Map
   - Ensure all generated test data uses these exact ID ranges
   - Verify consistency across all test cases
4. **Analyze seed data** (if database_setup.sql and DDL file exist):
   - Identify tables with pre-populated data from database_setup.sql
   - Determine ID ranges used by seed data in each table
   - Note which tables are lookup/reference vs transactional
   - Extract table structure and dependencies from the DDL file (create_database.sql)
5. **Generate CSV file**:
   - Create header row with parameter names
   - Generate one row per test case
   - Use exact values from test designs
   - Use exact parameter values from test case designs (including specific IDs from test data ranges)
   - Maintain test category order
6. **Generate test data SQL file**:
   - Add file header with procedure name
   - For each test case:
     - Generate TEST section with comments
     - Analyze setup requirements
     - Generate INSERT statements for all dependencies using exact IDs from test data ranges
     - Generate VERIFY section (if data-modifying procedure)
7. **Generate cleanup SQL file**:
   - Analyze table dependencies from DDL file (create_database.sql)
   - Create selective DELETE statements that preserve seed data
   - Use test data ID ranges from test case design document
   - Include identity column resets to test ranges (from test case design)
   - Add verification queries to ensure cleanup worked
8. **Cross-reference**: Ensure every CSV row has a matching SQL TEST section
9. **Validate**:
   - All test IDs match between CSV and SQL
   - All dependencies included in SQL
   - VERIFY sections match procedure type
   - INSERT statements maintain referential integrity
   - Cleanup script preserves all seed data from database_setup.sql

## CSV FILE SPECIFICATION

### Header Row Construction

Based on stored procedure parameters from test design:

```csv
test_id,test_name,test_category,description,[actual_param_names],expected_result,expected_error_message,setup_note
```

Replace `[actual_param_names]` with comma-separated parameter names (without @ symbol) **in the same order as they appear in the stored procedure definition**.

### Data Row Construction

For each test case in design:

```csv
[test_id],[test_name],[category],[description],[param_values],[expected_result],[error_msg],[setup_note]
```

**Example**:
```csv
HP001,Valid Purchase,HAPPY_PATH,"User with sufficient balance purchases product",1001,501,25.50,SUCCESS,,"User 1001 exists with $100 balance"
UP001,Invalid User,UNHAPPY_PATH,"Purchase with non-existent user",9999,501,25.50,ERROR,"User not found","No user with ID 9999"
```

## SQL FILE SPECIFICATION

### File Header
```sql
-- =====================================================
-- Test Data Setup Script for [Stored Procedure Name]
-- Generated from Test Case Design
-- Total Tests: [X]
-- =====================================================
```

### TEST Section Template
```sql
-- TEST: [test_id] - [test_name]
-- Category: [HAPPY_PATH/UNHAPPY_PATH/EDGE_CASE]
-- Description: [description from design]
-- Expected: [expected result from design]
-- Dependencies: [list from design doc "Setup Requirements"]

-- Insert dependency data (foreign keys, lookups, references)
INSERT INTO [ParentTable] ([columns]) VALUES ([values]);
INSERT INTO [LookupTable] ([columns]) VALUES ([values]);

-- Insert primary test data
INSERT INTO [PrimaryTable] ([columns]) VALUES ([test_values]);
```

### VERIFY Section Template (Data-Modifying Only)
```sql
-- VERIFY: [test_id]
-- QUERY: [DescriptiveName1]
SELECT [columns_to_verify]
FROM [TableName]
WHERE [filter_to_test_data];

-- QUERY: [DescriptiveName2]
SELECT [aggregate_columns]
FROM [TableName]
WHERE [filter_to_test_data]
GROUP BY [grouping_columns];
```

## DEPENDENCY DATA GENERATION

Use the Dependency Map from the test case design to generate INSERT statements:

### For Each Test:

1. **Identify Required Dependencies** from "Setup Requirements"
2. **Check database_setup.sql** (if provided):
   - Identify which tables/rows are already pre-populated
   - Note the specific IDs/values available for use
   - **SKIP INSERT statements** for data that already exists
3. **Generate Parent Records** (only if NOT in database_setup.sql):
   ```sql
   -- Parent table for FK: Users.user_id (NOT pre-configured)
   INSERT INTO Users (user_id, username, balance, status) 
   VALUES (1001, 'test_user_001', 100.00, 'ACTIVE');
   ```

4. **Use Pre-Configured Values** (when referencing pre-populated tables):
   ```sql
   -- Use existing manager_id from database_setup.sql (Managers table pre-populated with IDs 101-105)
   INSERT INTO Employees (employee_id, name, manager_id, department) 
   VALUES (2001, 'test_employee_001', 101, 'Sales');  -- manager_id = 101 exists in database_setup.sql
   ```

5. **Generate Lookup/Reference Data** (only if NOT in database_setup.sql):
   ```sql
   -- Lookup table: PaymentMethods (only if not pre-configured)
   INSERT INTO PaymentMethods (method_id, method_name) 
   VALUES (1, 'CREDIT_CARD');
   ```

6. **Generate Child/Dependent Records**:
   ```sql
   -- Related data: UserPreferences
   INSERT INTO UserPreferences (user_id, notification_enabled) 
   VALUES (1001, 1);
   ```

7. **Use Test-Specific IDs**: Consistent patterns within designated ranges
   - User IDs: 1001, 1002, 1003, etc. (each test case should use unique, non-overlapping IDs)
   - Product IDs: 501, 502, 503, etc. (each test case should use unique, non-overlapping IDs)
   - Transaction IDs: 2001, 2002, 2003, etc. (or let identity column handle)
   - **Reference pre-configured IDs**: manager_id from 101-105, status_code from database_setup.sql values
   - **Maintain uniqueness**: Each test should use different IDs to prevent conflicts if tests run in sequence

## VERIFICATION QUERY GENERATION

Use the "Verification Strategy" section from test design:

### For Each Table Listed in "Tables to Verify":

Generate a query that captures the relevant state:

**Example from Verification Strategy**:
```
Tables to Verify:
1. Users - Check balance changes
2. Transactions - Verify new records inserted
```

**Generated VERIFY Queries**:
```sql
-- VERIFY: HP001
-- QUERY: UserBalanceAfter
SELECT user_id, username, balance, status 
FROM Users 
WHERE user_id = 1001;

-- QUERY: TransactionInserted
SELECT transaction_id, user_id, product_id, amount, status, created_date
FROM Transactions 
WHERE user_id = 1001
ORDER BY created_date DESC;
```

### For Aggregates Listed in "Aggregates to Check":

Generate aggregate queries:

**Example from Verification Strategy**:
```
Aggregates to Check:
- Total transaction count for user
- Sum of transaction amounts
```

**Generated VERIFY Query**:
```sql
-- QUERY: TransactionSummary
SELECT user_id,
       COUNT(*) as total_transactions,
       SUM(amount) as total_spent
FROM Transactions
WHERE user_id = 1001
GROUP BY user_id;
```

## CLEANUP DATABASE GENERATION

### Analysis Requirements

Before generating the cleanup script, analyze the provided files:

#### From Test Case Design Document (`[StoredProcedureName]_TEST_CASES.md`):
1. **Test Data ID Ranges**: Extract the defined ID ranges for test data from the "Test Data ID Ranges" section
2. **Pre-Configured Data Ranges**: Note the seed data ID ranges that must be preserved

#### From DDL File (`create_database.sql`):
1. **Table Structure**: Extract all table names and their dependencies
2. **Foreign Key Relationships**: Identify parent-child relationships for proper deletion order
3. **Identity Columns**: Identify which tables have IDENTITY columns and their current seed values
4. **Primary Keys**: Understand the primary key structure for each table

#### From `database_setup.sql` (if provided):
1. **Seed Data Analysis**: 
   - Identify which tables contain pre-populated data
   - Determine the ID ranges used by seed data (e.g., VehicleMakes 1-8, VehicleModels 1-15)
   - Note any specific values that tests might reference
2. **Lookup vs Transactional Tables**:
   - **Lookup Tables**: Usually have seed data that should NEVER be deleted (Status codes, Categories, Makes/Models)
   - **Transactional Tables**: Usually empty after setup, all data is test-generated

### Cleanup Script Generation Rules

#### Step 1: Use Test Data ID Ranges from Design Document
**CRITICAL**: Do NOT recalculate test ID ranges. Use the exact ranges specified in the test case design document's "Test Data ID Ranges" section.

**If test case design lacks ID ranges** (fallback only):
- If seed data uses IDs 1-100, start test data at 1000+
- If seed data uses IDs 1-500, start test data at 1000+
- Always leave a gap of at least 500 between seed data and test data

**Example Analysis**:
```sql
-- From database_setup.sql analysis:
-- VehicleMakes: IDs 1-8 (seed data)
-- VehicleModels: IDs 1-15 (seed data)  
-- Users: No seed data (empty table)
-- Products: No seed data (empty table)

-- Therefore:
-- Test Users: Start at 1000
-- Test Products: Start at 500  
-- Test Vehicles: Start at 100 (referencing seed makes/models)
-- Test Transactions: Start at 2000
```

#### Step 2: Generate Deletion Statements

**Preserve Seed Data Pattern**:
```sql
-- Remove test data only (preserve seed data with ID < [threshold])
DELETE FROM [ChildTable] WHERE [parent_id_column] >= [test_range_start];
DELETE FROM [ParentTable] WHERE [id_column] >= [test_range_start];

-- Alternative: Remove all data from purely transactional tables
DELETE FROM [TransactionTable]; -- No seed data exists
```

**Example Generation**:
```sql
-- Child tables first (maintain referential integrity)
DELETE FROM TransactionDetails WHERE transaction_id IN 
    (SELECT transaction_id FROM Transactions WHERE transaction_id >= 2000);
DELETE FROM Transactions WHERE transaction_id >= 2000;

-- Remove test vehicles (preserve seed data references)
DELETE FROM Vehicles WHERE vehicle_id >= 100;

-- Remove test products (no seed data in this table)
DELETE FROM Products WHERE product_id >= 500;

-- Remove test users (no seed data in this table)  
DELETE FROM Users WHERE user_id >= 1000;

-- DO NOT delete from VehicleMakes, VehicleModels (seed data)
-- DO NOT delete from StatusCodes, Categories (lookup tables)
```

#### Step 3: Reset Identity Columns

**Identity Column Reset Pattern**:
```sql
-- Reset to just before test range (next insert will be first test ID)
IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('[TableName]'))
    DBCC CHECKIDENT ('[TableName]', RESEED, [test_range_start - 1]);
```

**Example Generation**:
```sql
-- Reset identity columns to test ranges
IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('Users'))
    DBCC CHECKIDENT ('Users', RESEED, 999);      -- Next insert: 1000

IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('Products'))
    DBCC CHECKIDENT ('Products', RESEED, 499);   -- Next insert: 500

IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('Vehicles'))  
    DBCC CHECKIDENT ('Vehicles', RESEED, 99);    -- Next insert: 100

IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('Transactions'))
    DBCC CHECKIDENT ('Transactions', RESEED, 1999); -- Next insert: 2000
```

#### Step 4: Generate Verification Queries

**Seed Data Verification**:
```sql
-- Verify seed data still exists (critical lookup data)
IF NOT EXISTS (SELECT 1 FROM VehicleMakes WHERE MakeID BETWEEN 1 AND 8)
    RAISERROR ('CLEANUP ERROR: Seed data missing from VehicleMakes', 16, 1);

IF NOT EXISTS (SELECT 1 FROM VehicleModels WHERE ModelID BETWEEN 1 AND 15)
    RAISERROR ('CLEANUP ERROR: Seed data missing from VehicleModels', 16, 1);
```

**Test Data Removal Verification**:
```sql  
-- Verify test data removed
IF EXISTS (SELECT 1 FROM Users WHERE user_id >= 1000)
    RAISERROR ('CLEANUP ERROR: Test users still exist', 16, 1);

IF EXISTS (SELECT 1 FROM Products WHERE product_id >= 500)  
    RAISERROR ('CLEANUP ERROR: Test products still exist', 16, 1);

IF EXISTS (SELECT 1 FROM Vehicles WHERE vehicle_id >= 100)
    RAISERROR ('CLEANUP ERROR: Test vehicles still exist', 16, 1);

IF EXISTS (SELECT 1 FROM Transactions WHERE transaction_id >= 2000)
    RAISERROR ('CLEANUP ERROR: Test transactions still exist', 16, 1);
```

### Complete Cleanup Script Template

```sql
-- =====================================================  
-- Selective Database Cleanup Script for [Stored Procedure Name]
-- Preserves seed data from database_setup.sql
-- Removes only test-specific data
-- Generated: [Current Date]
-- =====================================================

-- Disable foreign key constraints temporarily
EXEC sp_MSforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT all"

-- =====================================================
-- REMOVE TEST DATA ONLY (preserve seed data)  
-- Seed Data Analysis:
-- [List tables and ID ranges that contain seed data]
-- Test Data Ranges:
-- [List tables and ID ranges used for test data]
-- =====================================================

[Generated DELETE statements in proper order]

-- =====================================================
-- RESET IDENTITY COLUMNS TO TEST RANGES
-- =====================================================

[Generated DBCC CHECKIDENT statements]

-- =====================================================
-- RE-ENABLE CONSTRAINTS
-- =====================================================
EXEC sp_MSforeachtable "ALTER TABLE ? WITH CHECK CHECK CONSTRAINT all"

-- =====================================================
-- VERIFICATION  
-- =====================================================

[Generated verification queries]

PRINT 'Database cleanup completed successfully - seed data preserved, test data removed';
```

### Special Considerations

#### When No `database_setup.sql` Exists:
- Generate a full cleanup script (remove all data)
- Reset all identity columns to 0 or starting values
- No seed data preservation needed

#### When Tables Have No Identity Columns:
- Omit DBCC CHECKIDENT statements for those tables
- Use EXISTS check before running DBCC CHECKIDENT

#### When Circular Dependencies Exist:
- Use temporary disabling of specific constraints
- Document the circular dependency in comments
- Provide alternative cleanup approach if needed

## QUALITY CHECKLIST

Before generating output files, verify:

### CSV File:
- [ ] Header row contains all stored procedure parameters
- [ ] One row per test case from design document
- [ ] Test IDs match design document exactly
- [ ] All parameter values specified
- [ ] Expected results clearly defined (SUCCESS/ERROR/value)
- [ ] Expected error messages filled for ERROR cases
- [ ] Setup notes provide context

### SQL File:
- [ ] File header includes procedure name and test count
- [ ] One TEST section per test case from design
- [ ] Test IDs match CSV and design document
- [ ] All dependencies included (from Dependency Map)
- [ ] Pre-configured data from database_setup.sql is NOT re-inserted
- [ ] Pre-configured IDs/values are used correctly in test data
- [ ] INSERT statements in correct order (parents before children)
- [ ] Referential integrity maintained
- [ ] Test values are distinguishable and consistent
- [ ] VERIFY sections included for data-modifying procedures only
- [ ] VERIFY sections omitted for read-only procedures
- [ ] VERIFY queries match verification strategy from design
- [ ] All queries have descriptive names
- [ ] WHERE clauses filter to test-specific data

### Cleanup SQL File:
- [ ] Analyzes database_setup.sql (if provided) to identify seed data
- [ ] DELETE statements preserve all seed data from database_setup.sql
- [ ] DELETE statements are in correct order (child tables before parent tables)
- [ ] Test data ID ranges are properly identified and used
- [ ] DBCC CHECKIDENT statements reset to appropriate test ranges
- [ ] Identity column checks use EXISTS to avoid errors
- [ ] Verification queries confirm seed data preservation
- [ ] Verification queries confirm test data removal
- [ ] Foreign key constraints are properly disabled/enabled
- [ ] Script includes comments explaining seed vs test data ranges

### Cross-Reference:
- [ ] Every CSV test_id has matching SQL TEST section
- [ ] Every SQL TEST section has matching CSV row
- [ ] Test categories consistent between files
- [ ] Test data ID ranges match exactly between test case design and all generated files
- [ ] Cleanup script ID ranges align with test data INSERT statements
- [ ] Test data uses IDs within the ranges specified in test case design
- [ ] Parameter values in CSV match data setup in SQL
- [ ] All test cases use consistent, non-overlapping IDs within their designated ranges

## EXAMPLE WORKFLOW

### Input (from test case design):
```markdown
#### HP001: Valid User Purchase
- Description: User with sufficient balance purchases available product
- Parameters: @user_id = 1001, @product_id = 501, @quantity = 1
- Setup Requirements: User 1001 with $100 balance, Product 501 priced at $25
- Expected Result: SUCCESS
- Expected Return: Transaction ID
- Verification Needed: Yes (check balance deduction, transaction insert)
- Uses Pre-Configured: status_code = 'ACTIVE' (from database_setup.sql)
```

### Output CSV Row:
```csv
HP001,Valid User Purchase,HAPPY_PATH,"User with sufficient balance purchases available product",1001,501,1,SUCCESS,,"User $100 balance, Product $25 price"
```

### Output SQL Section:
```sql
-- TEST: HP001 - Valid User Purchase
-- Category: HAPPY_PATH
-- Description: User with sufficient balance purchases available product
-- Expected: SUCCESS with transaction ID returned
-- Pre-Configured Data: Uses status_code 'ACTIVE' from database_setup.sql

-- Setup: User with sufficient balance
-- Note: Using status_code 'ACTIVE' which is pre-populated in database_setup.sql
INSERT INTO Users (user_id, username, balance, status) 
VALUES (1001, 'test_user_001', 100.00, 'ACTIVE');

-- Setup: Available product
INSERT INTO Products (product_id, name, price, stock, status) 
VALUES (501, 'test_product_001', 25.00, 100, 'AVAILABLE');

-- VERIFY: HP001
-- QUERY: UserBalanceAfterPurchase
SELECT user_id, balance 
FROM Users 
WHERE user_id = 1001;

-- QUERY: TransactionCreated
SELECT transaction_id, user_id, product_id, quantity, total_amount, status
FROM Transactions
WHERE user_id = 1001;

-- QUERY: ProductStockReduced
SELECT product_id, stock
FROM Products
WHERE product_id = 501;
```

## IMPORTANT NOTES

1. **Follow the design exactly** - Don't add or remove test cases
2. **Use approved test IDs** - Match the design document precisely
3. **Use approved test data ID ranges** - Extract from test case design document, do NOT recalculate
4. **Include all dependencies** - Reference the Dependency Map
5. **Respect database_setup.sql** - Do NOT re-insert pre-configured data; use existing IDs/values
6. **Match verification strategy** - Use the specific queries outlined in design
7. **Maintain data integrity** - Parent records before child records
8. **Be consistent** - Use same naming patterns and ID ranges throughout all files
9. **Filter VERIFY queries** - Always use WHERE clauses with test-specific IDs

---

**This prompt generates test files from approved test case designs.**
**Use this only after PROMPT 1 output has been reviewed and approved.**
