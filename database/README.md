# SQL Server Stored Procedure Testing Framework# SQL Server Stored Procedure Testing Framework# SQL Server Stored Procedure Testing Framework# SQL Server Stored Procedure Testing Framework - Project Structure



A comprehensive framework for generating and executing SQL Server stored procedure tests with automatic output capture and verification.



## 🎯 OverviewA comprehensive framework for generating and executing SQL Server stored procedure tests with automatic output capture and verification.



This framework consists of two main components:



1. **LLM Prompts** (Two-phase approach) - Generates comprehensive test cases with human review checkpoint## 🎯 OverviewA comprehensive framework for generating and executing SQL Server stored procedure tests with automatic output capture and verification.## Overview

2. **Test Runner** (`SqlTestRunner/`) - Executes tests and captures all outputs



## 🔄 Two-Phase Workflow

This framework consists of two main components:This project provides a comprehensive framework for testing SQL Server stored procedures with two main components:

### Phase 1: Test Case Design (PROMPT_1_TEST_CASE_DESIGN.md)



**Purpose:** Analyze the stored procedure and design comprehensive test cases for human review.

1. **LLM Prompts** (Two-phase approach) - Generates comprehensive test cases with human review## 🎯 Overview1. **LLM Prompt** (README.md) - Generates test cases and data

**Input:**

- DDL (database schema)2. **Test Runner** (`SqlTestRunner/`) - Executes tests and captures all outputs

- Stored procedure code

- Optional: Business rules/context2. **Test Runner** (SqlTestRunner/) - Executes tests and captures results



**Output:**## 🚀 Quick Start

- `[StoredProcedureName]_TEST_CASES.md` - Complete test case design document

This framework consists of two main components:

**Contains:**

- Procedure analysis summary### Phase 1: Design Test Cases (Human Review)

- Complete dependency map

- Detailed test case inventory (HP001, UP001, EC001, etc.)---

- Verification strategy (tables to verify, queries needed)

- Coverage checklistsProvide these inputs to an LLM (ChatGPT, GitHub Copilot, etc.):

- Review checklist

- **Prompt**: Content from `PROMPT_1_TEST_CASE_DESIGN.md`1. **LLM Prompt** (`TEST_DATA_CREATION_PROMPT.md`) - Generates comprehensive test cases

**👤 Human Review Point:**

- Review test coverage- **DDL**: Your database schema

- Verify all dependencies identified

- Check verification strategy- **Stored Procedure**: The procedure you want to test2. **Test Runner** (`SqlTestRunner/`) - Executes tests and captures all outputs## Root Directory: `/testing`

- Approve or request modifications



---

The LLM will generate:

### Phase 2: Test File Generation (PROMPT_2_TEST_FILE_GENERATION.md)

- `[StoredProcedureName]_TEST_CASES.md` - Comprehensive test case design

**Purpose:** Generate CSV and SQL files from approved test case design.

## 🚀 Quick Start### 📄 README.md

**Input:**

- Approved `[StoredProcedureName]_TEST_CASES.md` (from Phase 1)**👤 Review this file** to ensure test coverage is complete and accurate before proceeding.

- DDL (for reference)

- Stored procedure code (for reference)**Purpose**: Complete LLM prompt for generating SQL Server stored procedure test cases



**Output:**### Phase 2: Generate Test Files

- `test_arguments.csv` - Test case definitions with parameters

- `test_data_setup.sql` - Test data setup with VERIFY sections### 1. Generate Test Files (Using LLM)



**Contains:**After approving the test case design, provide to an LLM:

- CSV: One row per test with all parameters and expected results

- SQL: TEST sections with INSERT statements + VERIFY sections with verification queries- **Prompt**: Content from `PROMPT_2_TEST_FILE_GENERATION.md`**Contains**:

- All dependency data (foreign keys, lookups, reference tables)

- Verification queries based on approved strategy- **Test Case Design**: The approved `[StoredProcedureName]_TEST_CASES.md`



---- **DDL**: Your database schema (for reference)Provide these inputs to an LLM (ChatGPT, GitHub Copilot, etc.):- Input requirements (DDL, stored procedure, context)



## ✨ Benefits of Two-Phase Approach- **Stored Procedure**: The procedure code (for reference)



### 🎯 Better Test Quality- **Prompt**: Content from `TEST_DATA_CREATION_PROMPT.md`- Output requirements (CSV test cases, SQL test data)

- Human expert reviews test design before generation

- Catches missing scenarios earlyThe LLM will generate:

- Ensures appropriate coverage

- Validates verification strategy- `test_arguments.csv` - Test case parameter definitions- **DDL**: Your database schema- VERIFY section guidelines (when to include/omit)



### 📝 Better Documentation- `test_data_setup.sql` - Test data with verification queries

- Test case design document serves as test specification

- Stakeholders can review test approach- **Stored Procedure**: The procedure you want to test- Analysis steps (dependency mapping)

- Design is documented before implementation

- Easier to justify test coverage decisions### Phase 3: Run Tests



### 🔄 Better Iteration- Test case design (HAPPY_PATH, UNHAPPY_PATH, EDGE_CASE)

- Modify test design without regenerating files

- Add/remove test cases at design phase```powershell

- Adjust verification strategy before implementation

- Faster iteration cyclecd SqlTestRunnerThe LLM will generate:- CSV and SQL file specifications



### ✅ Better Alignment# Configure appsettings.json with your connection string

- Files guaranteed to match approved design

- No manual transcription errorsdotnet run- `test_arguments.csv` - Test case definitions- Mandatory coverage requirements

- Consistent test IDs across all artifacts

- Dependency data always complete```



---- `test_data_setup.sql` - Test data with verification queries- Quality checklist



## 🚀 Quick Start### Phase 4: View Results



### 1. Design Phase- Example output formats (data-modifying and read-only procedures)



```bashOpen `test_results.html` for an interactive report, or review:

# Prepare inputs

1. Gather your database DDL- `test_results.csv` - Summary### 2. Run Tests- Common verification patterns (6 practical patterns)

2. Gather your stored procedure code

- `test_results.json` - Detailed data with all captures

# Use LLM (ChatGPT, GitHub Copilot, etc.)

3. Provide PROMPT_1_TEST_CASE_DESIGN.md content- Execution instructions (10-step process)

4. Add DDL and stored procedure

5. Receive [StoredProcedureName]_TEST_CASES.md## ✨ Key Features



# Review```powershell

6. Review the test case design

7. Request modifications if needed### Test Generation (Two-Phase Approach)

8. Approve when ready

```- ✅ **Phase 1: Design** - Comprehensive test case analysis with human review checkpointcd SqlTestRunner**Key Features**:



### 2. Generation Phase- ✅ **Phase 2: Generation** - Automated file creation from approved designs



```bash- ✅ Automatic dependency analysis (foreign keys, lookups, cascades)# Configure appsettings.json with your connection string- ✅ Comprehensive dependency analysis (direct, indirect, system)

# Prepare approved design

1. Open approved [StoredProcedureName]_TEST_CASES.md- ✅ Smart VERIFY sections (included for data-modifying, omitted for read-only)



# Use LLM- ✅ 6 verification query patterns with examplesdotnet run- ✅ Read-only procedure support (omit VERIFY sections)

2. Provide PROMPT_2_TEST_FILE_GENERATION.md content

3. Add the approved TEST_CASES.md- ✅ Quality checklists for completeness

4. Add DDL and stored procedure (for reference)

5. Receive test_arguments.csv and test_data_setup.sql```- ✅ Data-modifying procedure support (require VERIFY sections)



# Save files### Test Execution (C# Application)

6. Save both files to SqlTestRunner/Examples/ or your test directory

```- ✅ Captures return values, output parameters, and all result sets- ✅ Verification query patterns and examples



### 3. Configure and Run Tests- ✅ Database state capture (3 modes: custom queries, specific tables, auto-detect)



```bash- ✅ Multiple report formats (CSV, JSON, HTML)### 3. View Results- ✅ Quality checklist with dependency and verification checks

# Configure connection

cd SqlTestRunner- ✅ Configurable execution (specific tests, categories, stop on failure)

# Edit appsettings.json with your connection string

- ✅ Automatic cleanup between tests

# Run tests

dotnet run -- \

  --csv "Examples/test_arguments.csv" \

  --setup-sql "Examples/test_data_setup.sql" \## 🔄 Why Two-Phase Approach?Open `test_results.html` for an interactive report, or review:**Usage**: Provide this prompt + DDL + stored procedure to an LLM to generate test files

  --stored-procedure "YourStoredProcedure" \

  --cleanup-sql "Examples/test_cleanup.sql"

```

**Phase 1 Benefits:**- `test_results.csv` - Summary

### 4. View Results

- 👤 Human review of test case design before generating files

The test runner generates three report formats:

- 🎯 Ensures test coverage is appropriate- `test_results.json` - Detailed data with all captures---

- **CSV Report** (`test_results_[timestamp].csv`) - Summary with pass/fail status

- **JSON Report** (`test_results_[timestamp].json`) - Detailed with full data capture- 📝 Documents test strategy for stakeholders

- **HTML Report** (`test_results_[timestamp].html`) - Interactive with collapsible sections

- ✅ Catches missing scenarios early

---

- 🔄 Iterate on design without regenerating files

## 📊 Workflow Comparison

## ✨ Key Features## Application Directory: `/testing/SqlTestRunner`

### Old Single-Phase Approach ❌

**Phase 2 Benefits:**

```

Input (DDL + Procedure) - 🤖 Automated file generation from approved design

    ↓

  LLM Analysis + Generation- ✔️ Consistency across CSV and SQL files

    ↓

Output (CSV + SQL files)- 🚫 No manual errors in file creation### Test Generation (LLM Prompt)### 📄 README.md

    ↓

Human discovers issues during execution- 🔄 Easy to regenerate if format changes needed

    ↓

Regenerate everything from scratch- ✅ Comprehensive test coverage (HAPPY_PATH, UNHAPPY_PATH, EDGE_CASE)**Purpose**: Documentation for the C# .NET console application

```

## 📋 What Gets Captured

**Problems:**

- No review before file generation- ✅ Automatic dependency analysis (foreign keys, lookups, cascades)

- Issues discovered late (during test execution)

- Must regenerate both files for any changeFor every test execution:

- No documented test strategy

- **Return Value**: Scalar value returned by stored procedure- ✅ Smart VERIFY sections (included for data-modifying, omitted for read-only)**Contains**:

### New Two-Phase Approach ✅

- **Output Parameters**: All `@output` parameter values

```

Phase 1:- **Result Sets**: All SELECT result sets with all rows/columns- ✅ 6 verification query patterns with examples- Application overview and features

Input (DDL + Procedure)

    ↓- **Database State**: 

  LLM Analysis + Design

    ↓  - Custom VERIFY queries (recommended for data-modifying procedures)- ✅ Quality checklists for completeness- Prerequisites (.NET 8.0, SQL Server)

Output (TEST_CASES.md)

    ↓  - Specific table snapshots

👤 HUMAN REVIEW CHECKPOINT

    ↓  - Auto-detected affected tables- Installation instructions

Approve or Request Changes

    ↓

  

Phase 2:## 🔍 Procedure Type Support### Test Execution (C# Application)- Configuration guide (appsettings.json)

Input (Approved TEST_CASES.md)

    ↓

  LLM File Generation

    ↓### Data-Modifying Procedures (INSERT/UPDATE/DELETE)- ✅ Captures return values, output parameters, and all result sets- Usage examples (command-line options)

Output (CSV + SQL files)

    ↓- **VERIFY Sections**: Required

Ready for execution

```- **What's Verified**: Database tables, foreign keys, constraints, calculations- ✅ Database state capture (3 modes: custom queries, specific tables, auto-detect)- Test file structure explanation



**Benefits:**- **Example**: `CreateTransaction`, `UpdateBalance`, `DeleteOrder`

- Review before generation

- Issues caught early (at design phase)- ✅ Multiple report formats (CSV, JSON, HTML)- Output formats (CSV, JSON, HTML reports)

- Easy to regenerate files from same design

- Documented test strategy### Read-Only Procedures (SELECT only)



---- **VERIFY Sections**: Omitted (redundant)- ✅ Configurable execution (specific tests, categories, stop on failure)- Troubleshooting guide



## 🔍 Key Features- **What's Verified**: Result sets (captured automatically)



### Comprehensive Output Capture- **Example**: `GetUserReport`, `SearchProducts`, `CalculateTotal`- ✅ Automatic cleanup between tests



The test runner captures ALL outputs from stored procedure execution:

- ✅ Return values

- ✅ Output parameters## 📁 Project Structure### 📄 OUTPUT_CAPTURE_GUIDE.md

- ✅ Multiple result sets

- ✅ Database state changes



### Three Database Verification Modes```## 📋 What Gets Captured**Purpose**: Comprehensive guide for output capture features



1. **Custom VERIFY Queries** (Recommended for data-modifying procedures)/testing

   - Uses `-- VERIFY SECTION [TestID]` queries from setup SQL

   - Captures results for each test case├── README.md                            ← You are here

   - Provides precise, targeted verification

├── PROMPT_1_TEST_CASE_DESIGN.md         ← Phase 1: Design test cases

2. **Specific Tables Mode**

   - Configure tables to capture in `appsettings.json`├── PROMPT_2_TEST_FILE_GENERATION.md     ← Phase 2: Generate test filesFor every test execution:**Contains**:

   - Captures state of specified tables after each test

   - Good for known affected tables│



3. **Auto-Detect Mode** (Fallback)└── SqlTestRunner/- **Return Value**: Scalar value returned by stored procedure- Overview of capture capabilities

   - Automatically detects modified tables

   - Uses SQL Server change tracking    ├── README.md                        ← Application usage guide

   - Works without additional configuration

    ├── OUTPUT_CAPTURE_GUIDE.md          ← Output capture documentation- **Output Parameters**: All `@output` parameter values- Return value capture

### Test Categories

    ├── appsettings.json                 ← Configuration

Tests are organized by category:

- **HAPPY_PATH** (HP001, HP002, ...) - Valid inputs, expected success    ├── Program.cs                       ← Entry point- **Result Sets**: All SELECT result sets with all rows/columns- Output parameter capture

- **UNHAPPY_PATH** (UP001, UP002, ...) - Invalid inputs, expected failures

- **EDGE_CASE** (EC001, EC002, ...) - Boundary conditions, special cases    ├── Configuration/                   ← Config classes



### Report Formats    ├── Models/                          ← Data models- **Database State**: - Result set capture (multiple result sets)



**CSV Report** - Quick summary    ├── Services/                        ← Core services

```csv

TestID,Category,Passed,ErrorMessage    │   ├── TestCaseReader.cs            ← CSV reader  - Custom VERIFY queries (recommended for data-modifying procedures)- Database state capture (3 modes)

HP001,HAPPY_PATH,True,

UP001,UNHAPPY_PATH,True,    │   ├── SqlTestExecutor.cs           ← Test executor

```

    │   └── TestResultLogger.cs          ← Report generator  - Specific table snapshots- VERIFY section format and usage

**JSON Report** - Complete data

```json    └── Examples/                        ← Sample test files

{

  "testId": "HP001",```  - Auto-detected affected tables- Configuration examples

  "passed": true,

  "returnValue": 0,

  "outputParameters": [...],

  "resultSets": [...],## 🛠️ Configuration- Report format examples

  "databaseState": [...]

}

```

Edit `SqlTestRunner/appsettings.json`:## 🔍 Procedure Type Support- Best practices

**HTML Report** - Interactive

- Collapsible sections

- Color-coded pass/fail

- Expandable result sets```json

- Formatted database state

{

---

  "TestConfiguration": {### Data-Modifying Procedures (INSERT/UPDATE/DELETE)### 📄 CHANGES.md

## ⚙️ Configuration

    "ConnectionString": "Server=localhost;Database=MyDB;...",

### appsettings.json

    "StoredProcedureName": "YourStoredProcedureName",- **VERIFY Sections**: Required**Purpose**: Summary of output capture feature enhancements

```json

{    "TestArgumentsCsvPath": "./Examples/test_arguments.csv",

  "ConnectionStrings": {

    "TestDatabase": "Server=localhost;Database=TestDB;Integrated Security=true;"    "TestDataSetupSqlPath": "./Examples/test_data_setup.sql",- **What's Verified**: Database tables, foreign keys, constraints, calculations

  },

  "TestSettings": {    "CaptureDatabaseState": true,

    "CaptureDatabaseState": true,

    "CaptureAllAffectedTables": true,    "CaptureAllAffectedTables": true- **Example**: `CreateTransaction`, `UpdateBalance`, `DeleteOrder`**Contains**:

    "TablesToCapture": []

  }  }

}

```}- Feature additions (Oct 20, 2025)



**Configuration Options:**```

- `CaptureDatabaseState`: Enable/disable database state capture

- `CaptureAllAffectedTables`: Auto-detect modified tables### Read-Only Procedures (SELECT only)- Enhanced TestResult model properties

- `TablesToCapture`: Specific tables to capture (overrides auto-detect)

## 📊 Report Formats

**Behavior:**

- If `TablesToCapture` is empty: Uses VERIFY queries (if present) or auto-detect- **VERIFY Sections**: Omitted (redundant)- Database state capture modes

- If `TablesToCapture` has values: Captures only specified tables

- If `CaptureDatabaseState` is false: No database capture### CSV Report



---Quick summary with test results, durations, and pass/fail status.- **What's Verified**: Result sets (captured automatically)- Report format enhancements



## 📦 Command-Line Options**Use for**: Spreadsheet analysis, CI/CD integration



```bash- **Example**: `GetUserReport`, `SearchProducts`, `CalculateTotal`- Documentation additions

dotnet run -- \

  --csv "path/to/test_arguments.csv" \### JSON Report

  --setup-sql "path/to/test_data_setup.sql" \

  --stored-procedure "YourStoredProcedure" \Complete structured data with all captures (return values, parameters, result sets, database state).

  --cleanup-sql "path/to/test_cleanup.sql" \

  --output-format "all"  # Options: csv, json, html, all (default)**Use for**: Programmatic analysis, debugging, automation

```

## 📁 Project Structure### 📄 SqlTestRunner.csproj

**Required Arguments:**

- `--csv` - Path to test arguments CSV file### HTML Report

- `--setup-sql` - Path to test data setup SQL file

- `--stored-procedure` - Name of the stored procedure to testInteractive report with collapsible sections, color-coded status, and formatted tables.**Purpose**: .NET project file with dependencies



**Optional Arguments:****Use for**: Human review, documentation, test reporting

- `--cleanup-sql` - Path to cleanup SQL file (runs after all tests)

- `--output-format` - Report format (default: all)```



---## 🎯 Test Case Categories



## 🎯 Best Practices/testing**Dependencies**:



### For Phase 1 (Design)Tests are organized into three categories:

1. Provide complete DDL with all constraints and relationships

2. Include business rules and edge cases in your prompt├── README.md                         ← You are here- Microsoft.Data.SqlClient 5.1.2 (SQL Server connectivity)

3. Review the dependency map thoroughly

4. Ensure verification strategy covers all data modifications| Category | Purpose | Examples |

5. Check that all test categories are represented

|----------|---------|----------|├── TEST_DATA_CREATION_PROMPT.md      ← LLM prompt for test generation- CsvHelper 30.0.1 (CSV parsing)

### For Phase 2 (Generation)

1. Only proceed after Phase 1 design is approved| **HAPPY_PATH** | Valid scenarios that should succeed | Valid user purchase, successful registration |

2. Provide the complete, unmodified TEST_CASES.md

3. Include DDL and procedure for reference| **UNHAPPY_PATH** | Invalid scenarios that should fail gracefully | Invalid user ID, insufficient balance |├── PROJECT_STRUCTURE.md              ← Detailed project documentation- System.CommandLine (CLI interface)

4. Verify generated files match the approved design

5. Validate CSV and SQL alignment before running tests| **EDGE_CASE** | Boundary and unusual scenarios | NULL values, empty strings, max/min limits |



### For Test Execution│- Microsoft.Extensions.* (DI, Configuration, Logging)

1. Use a dedicated test database

2. Always provide cleanup SQL for proper isolation## 📝 Example Workflow

3. Review all three report formats for comprehensive analysis

4. Use VERIFY sections for data-modifying procedures└── SqlTestRunner/

5. Configure appropriate database capture mode

```

### For Read-Only Procedures

- VERIFY sections are optional (procedure doesn't modify data)Phase 1: Test Case Design    ├── README.md                     ← Application usage guide### 📄 Program.cs

- Focus on validating result sets

- Test runner handles gracefully if VERIFY sections are missing├─ Provide DDL + Stored Procedure to LLM with Prompt 1



---├─ Receive [ProcedureName]_TEST_CASES.md    ├── OUTPUT_CAPTURE_GUIDE.md       ← Output capture documentation**Purpose**: Application entry point and CLI configuration



## 📁 File Structure├─ Review test coverage, dependencies, verification strategy



```└─ Approve or request modifications    ├── appsettings.json              ← Configuration

/testing

├── README.md                            # This file - project overview

├── PROMPT_1_TEST_CASE_DESIGN.md         # Phase 1: Design & analyze test cases

├── PROMPT_2_TEST_FILE_GENERATION.md     # Phase 2: Generate CSV and SQL filesPhase 2: Test File Generation    ├── Program.cs                    ← Entry point**Features**:

│

└── SqlTestRunner/├─ Provide approved test cases to LLM with Prompt 2

    ├── Program.cs                       # Entry point

    ├── TestRunner.cs                    # Test orchestration├─ Receive test_arguments.csv and test_data_setup.sql    ├── Configuration/                ← Config classes- Command-line argument parsing

    ├── SqlTestExecutor.cs               # Test execution & capture

    ├── TestCaseReader.cs                # CSV parsing└─ Files ready for execution

    ├── TestResultLogger.cs              # Report generation

    ├── TestModels.cs                    # Data models    ├── Models/                       ← Data models- Dependency injection setup

    ├── appsettings.json                 # Configuration

    ├── SqlTestRunner.csproj             # Project filePhase 3: Test Execution

    │

    └── Examples/├─ 1. Database Cleanup    ├── Services/                     ← Core services- Configuration loading

        ├── test_arguments.csv           # Sample test cases

        ├── test_data_setup.sql          # Sample setup├─ 2. Setup Test Data (INSERT statements)

        └── test_cleanup.sql             # Sample cleanup

```├─ 3. Execute Stored Procedure    │   ├── TestCaseReader.cs         ← CSV reader- Test runner orchestration



---├─ 4. Capture Outputs (return value, parameters, result sets, database state)



## 🚀 Technology Stack├─ 5. Compare Expected vs Actual    │   ├── SqlTestExecutor.cs        ← Test executor



- **C# .NET 8.0** - Test runner application└─ 6. Generate Reports (CSV, JSON, HTML)

- **Microsoft.Data.SqlClient** - SQL Server connectivity

- **CsvHelper** - CSV parsing```    │   └── TestResultLogger.cs       ← Report generator### 📄 TestRunner.cs

- **System.CommandLine** - CLI argument parsing

- **Microsoft.Extensions.Configuration** - Configuration management



---## 🔧 Command-Line Options    └── Examples/                     ← Sample test files**Purpose**: Main test execution orchestration



## 📚 Additional Documentation



- **SqlTestRunner/README.md** - Detailed application usage guide```powershell```

- **SqlTestRunner/OUTPUT_CAPTURE_GUIDE.md** - Output capture features

- **SqlTestRunner/CHANGES.md** - Feature change log# Run all tests



---dotnet run**Responsibilities**:



## 🎉 Version History



**Version 2.0** (Current) - Two-Phase Approach# Run specific tests## 🛠️ Configuration- Load test cases from CSV

- Split into Phase 1 (Design) and Phase 2 (Generation)

- Added human review checkpointdotnet run -- --test-ids HP001,HP002,UP001

- Created structured test case design document format

- Enhanced documentation- Execute tests in sequence



**Version 1.0** - Single-Phase Approach# Run by category

- Original LLM prompt

- Comprehensive output capturedotnet run -- --categories HAPPY_PATH,EDGE_CASEEdit `SqlTestRunner/appsettings.json`:- Capture results

- VERIFY section support

- Read-only procedure handling


# Stop on first failure- Generate reports

dotnet run -- --stop-on-failure

``````json- Handle failures



## 📚 Documentation{



- **README.md** (this file) - Project overview and quick start  "TestConfiguration": {### 📄 appsettings.json

- **PROMPT_1_TEST_CASE_DESIGN.md** - Phase 1: Test case design prompt

- **PROMPT_2_TEST_FILE_GENERATION.md** - Phase 2: Test file generation prompt    "ConnectionString": "Server=localhost;Database=MyDB;...",**Purpose**: Application configuration file

- **SqlTestRunner/README.md** - Application usage guide

- **SqlTestRunner/OUTPUT_CAPTURE_GUIDE.md** - Output capture features    "StoredProcedureName": "YourStoredProcedureName",



## ✅ Quality Assurance    "TestArgumentsCsvPath": "./Examples/test_arguments.csv",**Configuration Sections**:



The framework ensures comprehensive test coverage through:    "TestDataSetupSqlPath": "./Examples/test_data_setup.sql",- **TestConfiguration**: Test execution settings



- ✅ **Parameter Coverage**: All parameters tested with valid/invalid/NULL/boundary values    "CaptureDatabaseState": true,  - Connection string

- ✅ **Dependency Coverage**: Foreign keys, lookups, cascades, triggers properly tested

- ✅ **Business Logic Coverage**: All conditional branches and validation rules    "CaptureAllAffectedTables": true  - File paths (CSV, SQL, output)

- ✅ **Database State Coverage**: Empty database, existing data, constraint violations

- ✅ **Verification Coverage**: All modified tables, relationships, and constraints  }  - Stored procedure name

- ✅ **Human Review**: Test design approved before file generation

}  - Execution options (stop on failure, cleanup between tests)

## 🎓 Best Practices

```  - Output options (detailed logging, HTML report)

### Test Design (Phase 1)

- Ensure all dependencies are identified in the dependency map  - Database state capture settings (3 modes)

- Cover all conditional branches in business logic

- Include realistic error scenarios## 📊 Report Formats- **DatabaseConfiguration**: SQL Server connection details

- Document verification strategy clearly

- Aim for minimum 10 test cases with balanced coverage- **Logging**: Log level configuration



### Test File Generation (Phase 2)### CSV Report

- Follow approved test case designs exactly

- Include all dependency data from designQuick summary with test results, durations, and pass/fail status.---

- Use consistent naming patterns: `test_user_001`, `test_product_001`

- Maintain referential integrity in INSERT order**Use for**: Spreadsheet analysis, CI/CD integration

- Generate VERIFY sections only for data-modifying procedures

## Subdirectories

### Test Execution

- Review HTML report for visual overview### JSON Report

- Use JSON report for debugging specific failures

- Use CSV report for trend analysisComplete structured data with all captures (return values, parameters, result sets, database state).### `/Configuration`

- Re-run failed tests individually for investigation

**Use for**: Programmatic analysis, debugging, automation- **TestConfiguration.cs**: Configuration classes and models

## 🚦 Requirements



- **.NET 8.0** or higher

- **SQL Server** (any version with stored procedures)### HTML Report### `/Models`

- **NuGet Packages** (automatically restored):

  - Microsoft.Data.SqlClientInteractive report with collapsible sections, color-coded status, and formatted tables.- **TestModels.cs**: Core data models

  - CsvHelper

  - System.CommandLine**Use for**: Human review, documentation, test reporting  - TestCase: Test definition with parameters

  - Microsoft.Extensions.*

  - TestResult: Execution results with output capture

## 🤝 Contributing

## 🎯 Test Case Categories  - TestStatus: Enum (Pass, Fail, Error, Skipped)

This framework is designed to be extensible. Key extension points:

  - TestCategory: Enum (HAPPY_PATH, UNHAPPY_PATH, EDGE_CASE)

- Add new report formats in `TestResultLogger.cs`

- Add new database state capture modes in `SqlTestExecutor.cs`Tests are organized into three categories:

- Customize test case reading in `TestCaseReader.cs`

- Modify prompt templates for specific testing needs### `/Services`



## 📄 License| Category | Purpose | Examples |- **TestCaseReader.cs**: CSV test case loading



[Add your license here]|----------|---------|----------|  - Interface: ITestCaseReader



## 👥 Authors| **HAPPY_PATH** | Valid scenarios that should succeed | Valid user purchase, successful registration |  - Implementation: CsvTestCaseReader (uses CsvHelper)



[Add authors/contributors here]| **UNHAPPY_PATH** | Invalid scenarios that should fail gracefully | Invalid user ID, insufficient balance |  



---| **EDGE_CASE** | Boundary and unusual scenarios | NULL values, empty strings, max/min limits |- **SqlTestExecutor.cs**: SQL test execution



**Last Updated**: October 20, 2025    - Interface: ISqlTestExecutor

**Version**: 2.0 (Two-Phase Approach)  

**Status**: Production Ready ✅## 📝 Example Test Flow  - Methods:


    - TestConnectionAsync(): Verify database connectivity

```    - CleanupDatabaseAsync(): Purge test data

1. Database Cleanup    - SetupTestDataAsync(): Insert test data

   └─ Remove all test data from previous run    - ExecuteTestAsync(): Run stored procedure and capture outputs

    - CaptureDatabaseStateAsync(): Capture database state (3 modes)

2. Setup Test Data    - ExtractVerificationSql(): Parse VERIFY sections

   └─ Execute INSERT statements from test_data_setup.sql    - ExecuteVerificationQueriesAsync(): Run custom verification queries

    - CaptureSpecificTablesAsync(): Capture specified tables

3. Execute Stored Procedure    - CaptureAffectedTablesAsync(): Auto-detect and capture affected tables

   └─ Call procedure with parameters from test_arguments.csv  

- **TestResultLogger.cs**: Report generation

4. Capture Outputs  - Interface: ITestResultLogger

   ├─ Return value (e.g., transaction ID)  - Methods:

   ├─ Output parameters (e.g., @new_balance)    - GenerateCsvReportAsync(): Summary CSV report

   ├─ Result sets (e.g., transaction details)    - GenerateJsonReportAsync(): Detailed JSON report

   └─ Database state (VERIFY queries)    - GenerateHtmlReportAsync(): Interactive HTML report with collapsible sections



5. Compare Results### `/Examples`

   └─ Expected vs Actual- **test_arguments.csv**: Sample test case CSV file

- **test_data_setup.sql**: Sample test data SQL script with VERIFY sections

6. Generate Reports- **cleanup_database.sql**: Sample cleanup script

   └─ CSV, JSON, HTML

```---



## 🔧 Command-Line Options## Test Execution Flow



```powershell```

# Run all tests1. Load Configuration (appsettings.json)

dotnet run   ↓

2. Initialize Services (DI container)

# Run specific tests   ↓

dotnet run -- --test-ids T001,T002,T0053. Read Test Cases (CSV file)

   ↓

# Run by category4. For Each Test:

dotnet run -- --categories HAPPY_PATH,EDGE_CASE   ↓

   a. Cleanup Database (purge previous test data)

# Stop on first failure   ↓

dotnet run -- --stop-on-failure   b. Setup Test Data (run INSERT statements from SQL)

```   ↓

   c. Execute Stored Procedure (with parameters from CSV)

## 📚 Documentation   ↓

   d. Capture Outputs:

- **README.md** (this file) - Project overview and quick start      - Return value

- **TEST_DATA_CREATION_PROMPT.md** - Complete LLM prompt for test generation      - Output parameters

- **PROJECT_STRUCTURE.md** - Detailed project structure and architecture      - Result sets (all)

- **SqlTestRunner/README.md** - Application usage guide      - Database state (VERIFY queries or auto-detect)

- **SqlTestRunner/OUTPUT_CAPTURE_GUIDE.md** - Output capture features   ↓

   e. Compare Expected vs Actual Results

## ✅ Quality Assurance   ↓

   f. Store TestResult

The framework ensures comprehensive test coverage through:   ↓

5. Generate Reports:

- ✅ **Parameter Coverage**: All parameters tested with valid/invalid/NULL/boundary values   - CSV: Summary with pass/fail counts

- ✅ **Dependency Coverage**: Foreign keys, lookups, cascades, triggers properly tested   - JSON: Full structured data with all captures

- ✅ **Business Logic Coverage**: All conditional branches and validation rules   - HTML: Interactive report with expandable sections

- ✅ **Database State Coverage**: Empty database, existing data, constraint violations   ↓

- ✅ **Verification Coverage**: All modified tables, relationships, and constraints6. Display Summary Statistics

```

## 🎓 Best Practices

---

### Test Design

- Use descriptive test names: `Valid_Purchase_Sufficient_Balance`## Database State Capture Modes

- Include all dependencies: parent records, lookup data, reference tables

- Keep test data minimal but complete### Mode 1: Custom VERIFY Queries (Recommended)

- Use consistent naming: `test_user_001`, `test_product_001`- **Configuration**: CaptureDatabaseState = true, VERIFY sections in SQL file

- **Behavior**: Executes named queries from VERIFY sections

### Verification Design- **Use Case**: Data-modifying procedures requiring specific verification

- Include VERIFY sections for data-modifying procedures- **Example**:

- Omit VERIFY sections for read-only procedures  ```sql

- Use descriptive query names: `UserBalanceAfterPurchase`  -- VERIFY: T001

- Filter with WHERE clauses to test-specific data  -- QUERY: UserBalance

- Verify all affected tables  SELECT user_id, balance FROM Users WHERE user_id = 1001;

  ```

### Code Quality

- Self-contained tests (each has all required data)### Mode 2: Specific Tables

- Proper cleanup between tests (database purged)- **Configuration**: CaptureDatabaseState = true, TablesToCapture = ["Users", "Transactions"]

- Realistic but distinguishable test values- **Behavior**: Captures all rows from specified tables

- Maintain referential integrity in test data- **Use Case**: When you know exactly which tables are affected

- **Note**: No WHERE clauses - captures entire tables

## 🚦 Requirements

### Mode 3: Auto-Detect Affected Tables

- **.NET 8.0** or higher- **Configuration**: CaptureDatabaseState = true, CaptureAllAffectedTables = true

- **SQL Server** (any version with stored procedures)- **Behavior**: Queries sys.sql_expression_dependencies to find affected tables

- **NuGet Packages** (automatically restored):- **Use Case**: Quick testing without writing verification queries

  - Microsoft.Data.SqlClient- **Note**: May capture unrelated data if tables are used by multiple procedures

  - CsvHelper

  - System.CommandLine### Mode 4: No Capture (Read-Only Procedures)

  - Microsoft.Extensions.*- **Configuration**: CaptureDatabaseState = false

- **Behavior**: Only captures return values, output parameters, and result sets

## 🤝 Contributing- **Use Case**: Read-only stored procedures (SELECT-only)

- **Note**: Result sets provide sufficient verification

This framework is designed to be extensible. Key extension points:

---

- Add new report formats in `TestResultLogger.cs`

- Add new database state capture modes in `SqlTestExecutor.cs`## Report Formats

- Customize test case reading in `TestCaseReader.cs`

### CSV Report (Summary)

## 📄 License```csv

test_id,test_name,status,duration_ms,expected,actual,error

[Add your license here]T001,Valid Transaction,Pass,145,SUCCESS,SUCCESS,

T002,Invalid User,Fail,98,ERROR,SUCCESS,Expected error but got success

## 👥 Authors```



[Add authors/contributors here]**Use For**: Quick overview, spreadsheet analysis, CI/CD integration



---### JSON Report (Detailed)

```json

**Last Updated**: October 20, 2025  {

**Version**: 1.0    "test_id": "T001",

**Status**: Production Ready ✅  "status": "Pass",

  "return_value": 2001,
  "output_parameters": { "@new_balance": 74.50 },
  "result_sets": [ [{"column": "value"}] ],
  "database_state": {
    "UserBalance": [{"user_id": 1001, "balance": 74.50}]
  }
}
```

**Use For**: Programmatic analysis, debugging, automation

### HTML Report (Interactive)
- Collapsible test sections
- Color-coded status (Pass=green, Fail=red, Error=orange)
- Tables for result sets and database state
- Expandable stored procedure output
- Duration metrics
- Summary statistics

**Use For**: Human review, test reporting, documentation

---

## Key Design Decisions

### 1. Self-Contained Tests
Each test includes ALL required data (foreign keys, lookup tables, dependencies).
**Reason**: Database is purged between tests for isolation.

### 2. Read-Only vs Data-Modifying
Different verification approaches based on procedure type.
**Reason**: Read-only procedures verified through result sets; data-modifying require database state checks.

### 3. Multiple Result Set Capture
`List<List<Dictionary<string, object?>>>` structure.
**Reason**: Stored procedures can return multiple result sets.

### 4. Three Database State Capture Modes
Custom queries, specific tables, auto-detect.
**Reason**: Flexibility for different testing needs and procedure types.

### 5. Dependency Injection
Services injected via Microsoft.Extensions.DependencyInjection.
**Reason**: Testability, maintainability, separation of concerns.

---

## Testing Best Practices

### For Data-Modifying Procedures:
1. ✅ Include VERIFY sections with descriptive query names
2. ✅ Verify all affected tables
3. ✅ Use WHERE clauses to filter test-specific data
4. ✅ Include aggregate checks (COUNT, SUM) where appropriate
5. ✅ Verify foreign key relationships
6. ✅ Check constraint validations

### For Read-Only Procedures:
1. ❌ Omit VERIFY sections (redundant)
2. ✅ Rely on result set capture (automatic)
3. ✅ Specify expected row counts in CSV
4. ✅ Document expected data in descriptions

### For All Procedures:
1. ✅ Cover HAPPY_PATH, UNHAPPY_PATH, EDGE_CASE scenarios
2. ✅ Test all parameters (valid, invalid, NULL, boundaries)
3. ✅ Test all dependency scenarios (missing FK, cascade effects)
4. ✅ Use descriptive test names and IDs
5. ✅ Keep test data minimal but complete
6. ✅ Use consistent naming patterns (test_user_001, test_product_001)

---

## File Naming Conventions

### Test Files:
- **test_arguments.csv**: Test case definitions
- **test_data_setup.sql**: Test data with VERIFY sections
- **cleanup_database.sql**: Database cleanup script

### Output Files:
- **test_results.csv**: Summary report
- **test_results.json**: Detailed report
- **test_results.html**: Interactive report

### Test IDs:
- **T001-T999**: Standard tests (data-modifying)
- **R001-R999**: Read-only tests (optional convention)
- **E001-E999**: Error/exception tests (optional convention)

---

## Troubleshooting

### Common Issues:

**Issue**: "Foreign key constraint violation"
**Solution**: Ensure parent records inserted before child records in SQL file

**Issue**: "Stored procedure not found"
**Solution**: Check StoredProcedureName in appsettings.json matches database

**Issue**: "CSV parameter mismatch"
**Solution**: Ensure CSV columns match stored procedure parameters exactly

**Issue**: "Empty database state capture"
**Solution**: For data-modifying procedures, add VERIFY sections or configure TablesToCapture

**Issue**: "Test fails but should pass"
**Solution**: Check expected_result in CSV matches actual return value/output

---

## Future Enhancements

Potential improvements:
- [ ] Parallel test execution
- [ ] Database snapshot/restore for faster cleanup
- [ ] Test data generation from schema
- [ ] Performance benchmarking mode
- [ ] Integration with CI/CD pipelines
- [ ] Visual test builder UI
- [ ] Code coverage analysis
- [ ] Mutation testing support

---

## Documentation Map

| Document | Purpose | Audience |
|----------|---------|----------|
| `/testing/README.md` | LLM prompt for test generation | LLM, Test Designers |
| `/testing/SqlTestRunner/README.md` | Application usage guide | Developers, QA |
| `/testing/SqlTestRunner/OUTPUT_CAPTURE_GUIDE.md` | Output capture feature details | Developers |
| `/testing/SqlTestRunner/CHANGES.md` | Recent feature additions | Developers |
| `/testing/PROJECT_STRUCTURE.md` | This document - complete overview | All Users |

---

## Quick Start

### Generate Test Files (Using LLM):
1. Provide README.md + DDL + Stored Procedure to LLM
2. Receive test_arguments.csv and test_data_setup.sql
3. Save files to SqlTestRunner/Examples/ folder

### Run Tests:
```powershell
cd SqlTestRunner
dotnet run
```

### View Results:
- Open `test_results.html` in browser for interactive report
- Review `test_results.csv` for summary
- Analyze `test_results.json` for detailed data

---

**Last Updated**: October 20, 2025
**Framework Version**: 1.0
**Author**: SQL Testing Framework Team
