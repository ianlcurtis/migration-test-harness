# LLM PROMPT 1: SQL Server Stored Procedure Test Case Designer

## OVERVIEW

You are a SQL testing expert. Your task is to analyze a SQL Server stored procedure and design comprehensive test cases covering happy path, unhappy path, and edge cases. This is **Phase 1** - test case design only.

## INPUT REQUIREMENTS

You will be provided with:
1. **DDL File**: Database schema definition (tables, constraints, relationships)
2. **Stored Procedure**: The complete stored procedure code to test
3. **Additional Context**: Any business rules or requirements (optional)

## OUTPUT REQUIREMENTS

Generate exactly ONE file: `[StoredProcedureName]_TEST_CASES.md`

This markdown file will contain:
1. **Analysis Summary** - Your findings about the procedure
2. **Dependency Map** - All dependencies identified
3. **Test Case Inventory** - Complete list of planned test cases
4. **Verification Strategy** - What will be verified for data-modifying procedures

**Important**: This output will be reviewed by a human before proceeding to file generation in Phase 2.

## ANALYSIS STEPS

### Step 1: Analyze Stored Procedure

Extract and document:

**Procedure Characteristics:**
- **Name**: The stored procedure name
- **Type**: Data-Modifying (INSERT/UPDATE/DELETE/MERGE) OR Read-Only (SELECT only)
- **Purpose**: What the procedure does in 1-2 sentences

**Parameters:**
- List each parameter with:
  - Name
  - Data type
  - Nullability (NULL/NOT NULL)
  - Default value (if any)
  - Valid range/values (if determinable)

**Return Information:**
- Return value type (if any)
- Output parameters (if any)
- Result sets returned (if any)

**Business Logic:**
- Validation rules enforced
- Calculations performed
- Conditional branches
- Error conditions that can occur

### Step 2: Identify Database Dependencies

Map ALL dependencies that affect the stored procedure:

#### Direct Dependencies:
- **Tables Accessed**: List tables with operation type (SELECT/INSERT/UPDATE/DELETE)
- **Foreign Key Relationships**: Parent → Child relationships
- **Check Constraints**: Business rules that must be satisfied
- **Unique Constraints**: Uniqueness requirements

#### Indirect Dependencies:
- **Triggers**: Any triggers on affected tables
- **Views**: Views used by the procedure (list underlying tables)
- **User-Defined Functions**: Functions called by the procedure
- **Nested Procedures**: Other stored procedures called
- **Computed Columns**: Calculated columns that may be affected

#### System Dependencies:
- **Identity Columns**: Auto-incrementing PKs
- **Default Constraints**: Auto-populated values
- **Cascade Actions**: ON DELETE CASCADE, ON UPDATE CASCADE
- **Indexed Views**: Materialized views affected

### Step 3: Design Test Cases

Plan comprehensive test coverage across three categories:

## TEST CASE CATEGORIES

### 1. HAPPY_PATH Tests
Valid scenarios that should succeed:
- Typical use cases with valid data
- Boundary values within acceptable ranges
- Common business scenarios
- All major code paths with valid inputs

**Minimum Required**: 3-5 tests (more for complex procedures)

### 2. UNHAPPY_PATH Tests
Invalid scenarios that should fail gracefully:
- Invalid parameter values (wrong type, out of range)
- Constraint violations (FK, CHECK, UNIQUE)
- Business rule violations
- Missing required data
- Dependency failures (missing reference data, broken relationships)

**Minimum Required**: 3-5 tests (more for complex procedures)

### 3. EDGE_CASE Tests
Boundary and unusual scenarios:
- NULL values where allowed/disallowed
- Empty strings, zero values
- Maximum/minimum data type limits
- Missing optional data
- Dependency edge cases (circular references, cascade effects, orphaned records)

**Minimum Required**: 2-4 tests

## OUTPUT FORMAT

Generate a markdown file named `[StoredProcedureName]_TEST_CASES.md` with the following structure:

```markdown
# Test Case Design: [StoredProcedureName]

## Procedure Analysis

### Procedure Information
- **Name**: [procedure name]
- **Type**: Data-Modifying | Read-Only
- **Purpose**: [Brief description]

### Parameters
| Parameter | Type | Nullable | Default | Valid Range/Values |
|-----------|------|----------|---------|-------------------|
| @param1   | int  | No       | None    | > 0              |
| @param2   | varchar(50) | Yes | NULL | Max 50 chars |

### Return Information
- **Return Value**: [description]
- **Output Parameters**: [list]
- **Result Sets**: [description]

### Business Logic
- [Validation rule 1]
- [Validation rule 2]
- [Calculation 1]
- [Error condition 1]

## Dependency Map

### Direct Dependencies
**Tables Accessed:**
- Users (SELECT, UPDATE)
- Transactions (INSERT)
- Products (SELECT)

**Foreign Keys:**
- Transactions.user_id → Users.user_id
- Transactions.product_id → Products.product_id

**Constraints:**
- CHECK: Users.balance >= 0
- UNIQUE: Users.username

### Indirect Dependencies
**Triggers:**
- TR_Users_Audit (ON UPDATE) - Logs balance changes

**Functions:**
- dbo.CalculateDiscount(@amount, @user_level) - Calculates price

### System Dependencies
**Identity Columns:**
- Transactions.transaction_id (auto-increment)

**Cascade Actions:**
- None

## Test Case Inventory

### HAPPY_PATH Tests (Total: X)

#### HP001: [Test Name]
- **Description**: [Detailed scenario description]
- **Parameters**: 
  - @param1 = [value]
  - @param2 = [value]
- **Setup Requirements**: [What data must exist]
  - User with ID 1001, balance $100
  - Product with ID 501, price $25
- **Expected Result**: SUCCESS
- **Expected Return**: [value or description]
- **Dependencies Tested**: Valid FK references, sufficient balance
- **Verification Needed**: Yes (check balance update, transaction insert)

#### HP002: [Test Name]
[Same structure...]

### UNHAPPY_PATH Tests (Total: X)

#### UP001: [Test Name]
- **Description**: [Detailed scenario description]
- **Parameters**: 
  - @param1 = [value]
  - @param2 = [value]
- **Setup Requirements**: [What data must exist]
- **Expected Result**: ERROR
- **Expected Error**: [Error message or code]
- **Dependencies Tested**: Invalid FK reference
- **Verification Needed**: No (procedure should reject before any changes)

#### UP002: [Test Name]
[Same structure...]

### EDGE_CASE Tests (Total: X)

#### EC001: [Test Name]
- **Description**: [Detailed scenario description]
- **Parameters**: 
  - @param1 = NULL
  - @param2 = [value]
- **Setup Requirements**: [What data must exist]
- **Expected Result**: SUCCESS | ERROR
- **Expected Return/Error**: [value or error description]
- **Dependencies Tested**: NULL handling
- **Verification Needed**: [Yes/No and what to check]

#### EC002: [Test Name]
[Same structure...]

## Verification Strategy

### For Data-Modifying Procedures:

**Tables to Verify:**
1. **Users** - Check balance changes
2. **Transactions** - Verify new records inserted
3. **AuditLog** - Confirm audit trail (if trigger exists)

**Verification Queries Needed:**
- Query 1: User balance after transaction
- Query 2: Transaction record details
- Query 3: Related records affected by cascades

**Aggregates to Check:**
- Total transaction count for user
- Sum of transaction amounts

### For Read-Only Procedures:

**Verification**: Result sets captured automatically by test runner. No additional queries needed.

## Coverage Summary

### Parameter Coverage
- [ ] All parameters tested with valid values
- [ ] All parameters tested with invalid values
- [ ] All nullable parameters tested with NULL
- [ ] All parameters tested at boundaries
- [ ] Required parameters tested as missing

### Dependency Coverage
- [ ] All FK dependencies tested (valid and invalid)
- [ ] All lookup table dependencies covered
- [ ] Constraint violations tested
- [ ] Cascade effects tested (if applicable)
- [ ] Trigger behavior tested (if applicable)

### Business Logic Coverage
- [ ] All conditional branches covered
- [ ] All validation rules tested
- [ ] All error conditions triggered
- [ ] All calculation paths verified

## Test Case Statistics
- **Total Test Cases**: [X]
- **HAPPY_PATH**: [X]
- **UNHAPPY_PATH**: [X]
- **EDGE_CASE**: [X]

## Review Checklist

Before proceeding to Phase 2 (file generation), verify:
- [ ] All stored procedure parameters are covered
- [ ] All dependencies are identified and tested
- [ ] Each test category has adequate coverage
- [ ] Test cases are specific and unambiguous
- [ ] Expected results are clearly defined
- [ ] Verification strategy is appropriate for procedure type
- [ ] Edge cases cover boundary conditions
- [ ] Error scenarios are realistic and testable

## Next Steps

After human review and approval:
1. Provide this file to **LLM PROMPT 2: Test File Generator**
2. LLM will generate `test_arguments.csv` and `test_data_setup.sql`
3. Files will be ready for test execution

---

**Generated**: [Date]
**Procedure**: [StoredProcedureName]
**Total Tests Designed**: [X]
```

## EXECUTION INSTRUCTIONS

1. **Read and analyze** the provided DDL and stored procedure thoroughly
2. **Determine procedure type**: Data-Modifying (INSERT/UPDATE/DELETE/MERGE) or Read-Only (SELECT only)
3. **Map ALL dependencies** using the dependency mapping steps above
4. **Extract parameters** and their characteristics
5. **Identify business logic** including validations, calculations, and error conditions
6. **Design test cases** ensuring comprehensive coverage:
   - Minimum 10 total test cases
   - Balance across categories (HAPPY_PATH, UNHAPPY_PATH, EDGE_CASE)
   - Cover all parameters, dependencies, and business logic
7. **Define verification strategy** based on procedure type
8. **Complete coverage checklists** to ensure nothing is missed
9. **Format output** as specified in the OUTPUT FORMAT section above
10. **Generate the markdown file** for human review

## QUALITY CHECKLIST

Before generating the output, ensure:
- [ ] Procedure analysis is complete and accurate
- [ ] All dependencies are identified (direct, indirect, system)
- [ ] At least 10 test cases designed
- [ ] Each test case has clear description, parameters, setup, expected result
- [ ] HAPPY_PATH covers typical scenarios
- [ ] UNHAPPY_PATH covers realistic error conditions
- [ ] EDGE_CASE covers boundary conditions
- [ ] Verification strategy matches procedure type (VERIFY queries for data-modifying, none for read-only)
- [ ] Coverage summary shows comprehensive coverage
- [ ] Test case descriptions are specific enough to implement
- [ ] Dependencies tested include FK, constraints, triggers, cascades

## IMPORTANT NOTES

1. **This is Phase 1 only** - Do NOT generate CSV or SQL files yet
2. **Be thorough** - The test case design will be reviewed by humans
3. **Be specific** - Each test case should have enough detail to implement
4. **Think about dependencies** - Most bugs occur at dependency boundaries
5. **Consider the procedure type** - Read-only and data-modifying procedures need different verification approaches
6. **Coverage matters** - Aim for comprehensive coverage, not just basic happy path

---

**This prompt generates test case designs for human review.**
**Use LLM PROMPT 2 after approval to generate actual test files.**
