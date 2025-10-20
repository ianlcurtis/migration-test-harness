# LLM PROMPT 2: SQL Server Stored Procedure Test File Generator

## OVERVIEW

You are a SQL testing expert. Your task is to generate test files (CSV and SQL) based on approved test case designs. This is **Phase 2** - test file generation only.

**Prerequisites**: You must have the output from PROMPT 1 (`[StoredProcedureName]_TEST_CASES.md`) which contains the approved test case designs.

## INPUT REQUIREMENTS

You will be provided with:
1. **Test Case Design File**: `[StoredProcedureName]_TEST_CASES.md` (from Phase 1)
2. **DDL File**: Database schema definition (for reference)
3. **Stored Procedure**: The complete stored procedure code (for reference)

## OUTPUT REQUIREMENTS

Generate exactly TWO files:

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
2. **Generate INSERT statements** for all required data:
   - Parent records (for FKs)
   - Lookup table entries
   - Reference data
   - Primary test data
3. **Maintain referential integrity**: Insert parent tables before child tables
4. **Use consistent test values**: test_user_001, test_product_501, etc.
5. **Include all columns needed**: Don't rely on defaults if they affect test outcome

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

1. **Read the test case design document** thoroughly
2. **Extract procedure information**:
   - Procedure name
   - Procedure type (data-modifying or read-only)
   - Parameters
3. **Generate CSV file**:
   - Create header row with parameter names
   - Generate one row per test case
   - Use exact values from test designs
   - Maintain test category order
4. **Generate SQL file**:
   - Add file header with procedure name
   - For each test case:
     - Generate TEST section with comments
     - Analyze setup requirements
     - Generate INSERT statements for all dependencies
     - Generate VERIFY section (if data-modifying procedure)
5. **Cross-reference**: Ensure every CSV row has a matching SQL TEST section
6. **Validate**:
   - All test IDs match between CSV and SQL
   - All dependencies included in SQL
   - VERIFY sections match procedure type
   - INSERT statements maintain referential integrity

## CSV FILE SPECIFICATION

### Header Row Construction

Based on stored procedure parameters from test design:

```csv
test_id,test_name,test_category,description,[actual_param_names],expected_result,expected_error_message,setup_note
```

Replace `[actual_param_names]` with comma-separated parameter names (without @ symbol).

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
2. **Generate Parent Records First**:
   ```sql
   -- Parent table for FK: Users.user_id
   INSERT INTO Users (user_id, username, balance, status) 
   VALUES (1001, 'test_user_001', 100.00, 'ACTIVE');
   ```

3. **Generate Lookup/Reference Data**:
   ```sql
   -- Lookup table: PaymentMethods
   INSERT INTO PaymentMethods (method_id, method_name) 
   VALUES (1, 'CREDIT_CARD');
   ```

4. **Generate Child/Dependent Records**:
   ```sql
   -- Related data: UserPreferences
   INSERT INTO UserPreferences (user_id, notification_enabled) 
   VALUES (1001, 1);
   ```

5. **Use Test-Specific IDs**: Consistent patterns
   - User IDs: 1001, 1002, 1003, etc.
   - Product IDs: 501, 502, 503, etc.
   - Transaction IDs: 2001, 2002, 2003, etc. (or let identity column handle)

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
- [ ] INSERT statements in correct order (parents before children)
- [ ] Referential integrity maintained
- [ ] Test values are distinguishable and consistent
- [ ] VERIFY sections included for data-modifying procedures only
- [ ] VERIFY sections omitted for read-only procedures
- [ ] VERIFY queries match verification strategy from design
- [ ] All queries have descriptive names
- [ ] WHERE clauses filter to test-specific data

### Cross-Reference:
- [ ] Every CSV test_id has matching SQL TEST section
- [ ] Every SQL TEST section has matching CSV row
- [ ] Test categories consistent between files
- [ ] Parameter values in CSV match data setup in SQL

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

-- Setup: User with sufficient balance
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
3. **Include all dependencies** - Reference the Dependency Map
4. **Match verification strategy** - Use the specific queries outlined in design
5. **Maintain data integrity** - Parent records before child records
6. **Be consistent** - Use same naming patterns throughout
7. **Filter VERIFY queries** - Always use WHERE clauses with test-specific IDs

---

**This prompt generates test files from approved test case designs.**
**Use this only after PROMPT 1 output has been reviewed and approved.**
