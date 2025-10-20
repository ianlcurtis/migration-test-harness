# SQL Test Runner - Output Capture Feature Summary

## Overview

The SQL Test Runner has been enhanced to comprehensively log and report all outputs from stored procedure test executions, including procedure outputs and database state verification.

## What's Been Added

### 1. Stored Procedure Output Capture

The application now captures ALL output from stored procedures:

- **Return Values**: Integer return values from stored procedures
- **Output Parameters**: All parameters marked with OUTPUT or INOUT direction
- **Result Sets**: Complete capture of all SELECT statement results
  - Multiple result sets supported
  - All rows and columns captured
  - Data preserved in structured format

### 2. Database State Verification

Three powerful modes for capturing database state after test execution:

#### Mode 1: Custom Verification Queries (Recommended)
Add `-- VERIFY:` sections to your test data setup SQL:

```sql
-- TEST: T001 - Test Name
INSERT INTO Users (user_id, username) VALUES (1001, 'test_user');

-- VERIFY: T001
-- QUERY: UserData
SELECT user_id, username, balance FROM Users WHERE user_id = 1001;
-- QUERY: TransactionHistory  
SELECT * FROM Transactions WHERE user_id = 1001;
```

Benefits:
- Capture only relevant data
- Filter with WHERE clauses
- Name queries for clarity
- Multiple queries per test

#### Mode 2: Specific Tables Configuration
Configure in `appsettings.json`:
```json
{
  "TablesToCapture": ["Users", "Transactions", "Products"]
}
```

#### Mode 3: Auto-Detect (Default)
Automatically detects and captures tables referenced by the stored procedure.

### 3. Enhanced Reporting

All three report formats now include comprehensive output data:

#### CSV Report
- Added columns: `return_value`, `output_params_count`, `result_sets_count`, `database_tables_captured`
- Summary data for quick analysis

#### JSON Report
- Full structured output data
- `storedProcedureOutput` section with return value, output parameters, and all result sets
- `databaseState` section with all captured table data
- Complete rows and columns for all data
- Ideal for automated analysis

#### HTML Report
- Interactive expandable sections for each test
- **Stored Procedure Output** section showing:
  - Return value
  - Output parameters list
  - Result sets in formatted tables
- **Database State After Test** section showing:
  - Each captured table/query
  - Full data in HTML tables
  - First 10 rows displayed (with row count)
- Click to expand/collapse sections

## Configuration Options

New settings in `appsettings.json`:

```json
{
  "TestConfiguration": {
    "CaptureDatabaseState": true,          // Enable/disable database state capture
    "TablesToCapture": [],                 // Specific tables to capture
    "CaptureAllAffectedTables": true       // Auto-detect affected tables
  }
}
```

## Files Modified

1. **Models/TestModels.cs**
   - Added `ReturnValue`, `OutputParameters`, `ResultSets` properties
   - Added `DatabaseState`, `DatabaseStateJson` properties

2. **Configuration/TestConfiguration.cs**
   - Added `CaptureDatabaseState` setting
   - Added `TablesToCapture` list
   - Added `CaptureAllAffectedTables` flag

3. **Services/SqlTestExecutor.cs**
   - Enhanced `ExecuteTestAsync` to capture return values, output parameters, and result sets
   - Added `CaptureDatabaseStateAsync` method
   - Added `ExtractVerificationSql` method for parsing VERIFY sections
   - Added `ExecuteVerificationQueriesAsync` method
   - Added `CaptureSpecificTablesAsync` method
   - Added `CaptureAffectedTablesAsync` method
   - Added `GetStoredProcedureTablesAsync` method for auto-detection

4. **Services/TestResultLogger.cs**
   - Updated `GenerateCsvReportAsync` with new columns
   - Enhanced `GenerateJsonReportAsync` with full output structure
   - Completely redesigned `GenerateHtmlReportAsync` with:
     - Collapsible sections
     - JavaScript for expand/collapse
     - Formatted output tables
     - Database state tables

5. **appsettings.json**
   - Added new configuration options

6. **Examples/test_data_setup.sql**
   - Added example VERIFY section for T001

## New Files Created

1. **OUTPUT_CAPTURE_GUIDE.md**
   - Comprehensive guide to output capture features
   - Examples for all capture modes
   - Report format documentation
   - Best practices
   - Troubleshooting guide

## Usage Examples

### Basic Usage (Auto-Detect)
```bash
dotnet run
# Automatically captures all affected tables
```

### With Custom Verification Queries
```sql
-- TEST: T001 - Purchase Test
INSERT INTO Users VALUES (1001, 'user', 100.00);

-- VERIFY: T001
-- QUERY: FinalBalance
SELECT user_id, balance FROM Users WHERE user_id = 1001;
```

### With Specific Tables
```bash
# In appsettings.json:
"TablesToCapture": ["Users", "Transactions"]
```

## Benefits

1. **Complete Visibility**: See everything that happened during the test
2. **Debugging**: Identify why tests fail by examining actual database state
3. **Verification**: Confirm stored procedure made correct changes
4. **Documentation**: Reports serve as test execution documentation
5. **Audit Trail**: JSON reports provide complete audit trail of test execution

## Console Output

When running with `--verbose`:
```
[10:30:15 DBG] Added parameter @user_id = 1001
[10:30:15 DBG] Captured 1 rows for verification query: UserBalance
[10:30:15 DBG] Captured 2 rows for verification query: TransactionHistory
[10:30:15 INF] Test T001 completed: Pass in 45ms
```

## Report Examples

### JSON Structure
```json
{
  "storedProcedureOutput": {
    "returnValue": 0,
    "outputParameters": {
      "@transaction_id": 12345
    },
    "resultSets": [
      {
        "resultSetIndex": 0,
        "rowCount": 1,
        "rows": [...]
      }
    ]
  },
  "databaseState": {
    "tables": [
      {
        "tableName": "UserBalance",
        "rowCount": 1,
        "rows": [...]
      }
    ]
  }
}
```

### HTML Features
- Summary table with all tests
- Expandable detail sections per test
- Color-coded status (green=pass, red=fail, orange=error)
- Formatted data tables
- Click to expand/collapse

## Backward Compatibility

✅ Fully backward compatible
- Existing tests work without modification
- New features are opt-in via configuration
- Default behavior includes auto-detect mode
- No breaking changes to existing APIs

## Next Steps

1. Update your test data SQL files to include VERIFY sections
2. Configure specific tables to capture if needed
3. Run tests and review enhanced HTML reports
4. Use JSON reports for automated analysis
5. Refer to OUTPUT_CAPTURE_GUIDE.md for detailed documentation