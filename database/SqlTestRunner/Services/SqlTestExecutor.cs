using Microsoft.Data.SqlClient;
using SqlTestRunner.Models;
using SqlTestRunner.Configuration;
using System.Data;
using System.Text.RegularExpressions;
using Microsoft.Extensions.Logging;

namespace SqlTestRunner.Services;

public interface ISqlTestExecutor
{
    Task<bool> TestConnectionAsync();
    Task CleanupDatabaseAsync();
    Task SetupTestDataAsync(string testId);
    Task<TestResult> ExecuteTestAsync(TestCase testCase);
}

public class SqlTestExecutor : ISqlTestExecutor
{
    private readonly TestConfiguration _config;
    private readonly ILogger<SqlTestExecutor> _logger;
    private readonly string _setupSqlContent;

    public SqlTestExecutor(TestConfiguration config, ILogger<SqlTestExecutor> logger)
    {
        _config = config;
        _logger = logger;
        
        if (File.Exists(_config.TestDataSetupSqlPath))
        {
            _setupSqlContent = File.ReadAllText(_config.TestDataSetupSqlPath);
        }
        else
        {
            _setupSqlContent = string.Empty;
            _logger.LogWarning("Test data setup SQL file not found: {Path}", _config.TestDataSetupSqlPath);
        }
    }

    public async Task<bool> TestConnectionAsync()
    {
        try
        {
            using var connection = new SqlConnection(_config.ConnectionString);
            await connection.OpenAsync();
            _logger.LogInformation("Database connection successful");
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to connect to database");
            return false;
        }
    }

    public async Task CleanupDatabaseAsync()
    {
        if (!File.Exists(_config.CleanupSqlPath))
        {
            _logger.LogWarning("Cleanup SQL file not found: {Path}", _config.CleanupSqlPath);
            return;
        }

        var cleanupSql = await File.ReadAllTextAsync(_config.CleanupSqlPath);
        
        using var connection = new SqlConnection(_config.ConnectionString);
        await connection.OpenAsync();

        var batches = SplitSqlIntoBatches(cleanupSql);
        
        foreach (var batch in batches)
        {
            if (string.IsNullOrWhiteSpace(batch)) continue;

            using var command = new SqlCommand(batch, connection)
            {
                CommandTimeout = _config.CommandTimeoutSeconds
            };
            
            await command.ExecuteNonQueryAsync();
        }

        _logger.LogDebug("Database cleanup completed");
    }

    public async Task SetupTestDataAsync(string testId)
    {
        if (string.IsNullOrEmpty(_setupSqlContent))
        {
            _logger.LogWarning("No setup SQL content available for test {TestId}", testId);
            return;
        }

        var testDataSql = ExtractTestDataSql(testId);
        if (string.IsNullOrEmpty(testDataSql))
        {
            _logger.LogWarning("No setup data found for test {TestId}", testId);
            return;
        }

        using var connection = new SqlConnection(_config.ConnectionString);
        await connection.OpenAsync();

        var batches = SplitSqlIntoBatches(testDataSql);
        
        foreach (var batch in batches)
        {
            if (string.IsNullOrWhiteSpace(batch)) continue;

            using var command = new SqlCommand(batch, connection)
            {
                CommandTimeout = _config.CommandTimeoutSeconds
            };
            
            await command.ExecuteNonQueryAsync();
        }

        _logger.LogDebug("Test data setup completed for test {TestId}", testId);
    }

    public async Task<TestResult> ExecuteTestAsync(TestCase testCase)
    {
        var result = new TestResult
        {
            TestId = testCase.TestId,
            TestName = testCase.TestName,
            ExecutionDate = DateTime.UtcNow
        };

        var stopwatch = System.Diagnostics.Stopwatch.StartNew();

        try
        {
            using var connection = new SqlConnection(_config.ConnectionString);
            await connection.OpenAsync();

            using var command = new SqlCommand(_config.StoredProcedureName, connection)
            {
                CommandType = CommandType.StoredProcedure,
                CommandTimeout = _config.CommandTimeoutSeconds
            };

            // Discover stored procedure parameters dynamically
            SqlCommandBuilder.DeriveParameters(command);
            
            _logger.LogInformation("=== Discovered {Count} parameters for {ProcName} ===", command.Parameters.Count, _config.StoredProcedureName);
            foreach (SqlParameter p in command.Parameters)
            {
                _logger.LogInformation("  {Name}: Direction={Direction}, SqlDbType={Type}, Size={Size}, HasDefault={HasDefault}", 
                    p.ParameterName, p.Direction, p.SqlDbType, p.Size, p.Value != DBNull.Value);
            }

            // Track which INPUT parameters to remove (those with defaults that aren't provided)
            var parametersToRemove = new List<SqlParameter>();

            // Map test case parameters to stored procedure parameters
            foreach (SqlParameter sqlParam in command.Parameters)
            {
                var paramNameWithoutAt = sqlParam.ParameterName.TrimStart('@');
                
                // Only process INPUT parameters - skip OUTPUT and RETURN VALUE
                if (sqlParam.Direction == ParameterDirection.Input)
                {
                    // Check if test case provides a value for this parameter
                    if (testCase.Parameters.ContainsKey(paramNameWithoutAt))
                    {
                        var testValue = testCase.Parameters[paramNameWithoutAt];
                        
                        if (testValue != null)
                        {
                            sqlParam.Value = testValue;
                            _logger.LogDebug("Set INPUT parameter {ParamName} = {ParamValue}", sqlParam.ParameterName, testValue);
                        }
                        else
                        {
                            // NULL value explicitly provided by test case
                            // For UNHAPPY_PATH/ERROR tests, this tests NULL validation
                            // For other tests, remove parameter to allow default value
                            if (testCase.TestCategory == "UNHAPPY_PATH" || testCase.ExpectedResult == "ERROR")
                            {
                                sqlParam.Value = DBNull.Value;
                                _logger.LogDebug("Set INPUT parameter {ParamName} = DBNull (testing NULL validation in UNHAPPY_PATH)", sqlParam.ParameterName);
                            }
                            else
                            {
                                // HAPPY_PATH with NULL - remove to use stored procedure default
                                parametersToRemove.Add(sqlParam);
                                _logger.LogDebug("Will remove INPUT parameter {ParamName} (NULL in HAPPY_PATH, use default)", sqlParam.ParameterName);
                            }
                        }
                    }
                    else
                    {
                        // Parameter not provided in test case - assume it has a default, remove it
                        parametersToRemove.Add(sqlParam);
                        _logger.LogDebug("INPUT parameter {ParamName} not in test case, will remove to use default", sqlParam.ParameterName);
                    }
                }
                else if (sqlParam.Direction == ParameterDirection.Output)
                {
                    // Keep OUTPUT parameters - they are required by the stored procedure
                    _logger.LogDebug("Keeping OUTPUT parameter: {ParamName} ({SqlDbType})", sqlParam.ParameterName, sqlParam.SqlDbType);
                }
                else if (sqlParam.Direction == ParameterDirection.InputOutput)
                {
                    // InputOutput parameters in SQL Server OUTPUT parameters
                    // They must have a value - set to DBNull if not provided
                    if (sqlParam.Value == null)
                    {
                        sqlParam.Value = DBNull.Value;
                        _logger.LogDebug("Set INPUTOUTPUT parameter (OUTPUT) {ParamName} to DBNull", sqlParam.ParameterName);
                    }
                    else
                    {
                        _logger.LogDebug("Keeping INPUTOUTPUT parameter (OUTPUT): {ParamName} with existing value", sqlParam.ParameterName);
                    }
                }
                else if (sqlParam.Direction == ParameterDirection.ReturnValue)
                {
                    _logger.LogDebug("Keeping RETURN VALUE parameter");
                }
            }

            // Remove only INPUT parameters that should use defaults (keep OUTPUT parameters!)
            foreach (var param in parametersToRemove)
            {
                command.Parameters.Remove(param);
                _logger.LogDebug("Removed INPUT parameter {ParamName}", param.ParameterName);
            }
            
            _logger.LogInformation("=== Final parameter list ({Count} total) ===", command.Parameters.Count);
            foreach (SqlParameter p in command.Parameters)
            {
                _logger.LogInformation("  {Name}: Direction={Direction}, Value={Value}", 
                    p.ParameterName, p.Direction, p.Value == null ? "null" : (p.Value == DBNull.Value ? "DBNull" : p.Value.ToString()));
            }

            // Execute stored procedure and capture result sets
            using var reader = await command.ExecuteReaderAsync();
            
            // Capture all result sets
            do
            {
                var resultSet = new List<Dictionary<string, object?>>();
                while (await reader.ReadAsync())
                {
                    var row = new Dictionary<string, object?>();
                    for (int i = 0; i < reader.FieldCount; i++)
                    {
                        var fieldName = reader.GetName(i);
                        var value = reader.IsDBNull(i) ? null : reader.GetValue(i);
                        row[fieldName] = value;
                    }
                    resultSet.Add(row);
                }
                if (resultSet.Count > 0)
                {
                    result.ResultSets.Add(resultSet);
                }
            } while (await reader.NextResultAsync());

            await reader.CloseAsync();

            // Capture return value and output parameters
            foreach (SqlParameter param in command.Parameters)
            {
                if (param.Direction == ParameterDirection.ReturnValue)
                {
                    result.ReturnValue = param.Value != DBNull.Value ? param.Value : null;
                }
                else if (param.Direction == ParameterDirection.Output || param.Direction == ParameterDirection.InputOutput)
                {
                    result.OutputParameters[param.ParameterName] = param.Value != DBNull.Value ? param.Value : null;
                    _logger.LogDebug("Captured OUTPUT parameter @{ParamName} = {ParamValue}", param.ParameterName, param.Value);
                }
            }

            // Capture database state after execution
            if (_config.CaptureDatabaseState)
            {
                await CaptureDatabaseStateAsync(connection, result, testCase.TestId);
            }

            stopwatch.Stop();
            result.DurationMs = stopwatch.ElapsedMilliseconds;

            // Determine test result
            var primaryResult = result.ReturnValue?.ToString() ?? 
                               (result.ResultSets.Count > 0 ? "RESULT_SET" : "NULL");
            result.ActualResult = primaryResult;
            result.Status = DetermineTestStatus(testCase, result.ActualResult, null);
            result.Notes = $"Executed in {result.DurationMs}ms. " +
                          $"Return Value: {result.ReturnValue}, " +
                          $"Result Sets: {result.ResultSets.Count}, " +
                          $"Output Params: {result.OutputParameters.Count}";

            _logger.LogDebug("Test {TestId} completed with result: {ActualResult}", testCase.TestId, result.ActualResult);
        }
        catch (SqlException sqlEx)
        {
            stopwatch.Stop();
            result.DurationMs = stopwatch.ElapsedMilliseconds;
            result.ErrorMessage = sqlEx.Message;
            result.Exception = sqlEx;
            result.ActualResult = $"SQL ERROR: {sqlEx.Message}";
            
            // Check if this was an expected error
            result.Status = DetermineTestStatus(testCase, result.ActualResult, sqlEx);
            
            _logger.LogDebug("Test {TestId} completed with SQL error: {ErrorMessage}", testCase.TestId, sqlEx.Message);
        }
        catch (Exception ex)
        {
            stopwatch.Stop();
            result.DurationMs = stopwatch.ElapsedMilliseconds;
            result.ErrorMessage = ex.Message;
            result.Exception = ex;
            result.ActualResult = $"ERROR: {ex.Message}";
            result.Status = TestStatus.Error;
            
            _logger.LogError(ex, "Unexpected error executing test {TestId}", testCase.TestId);
        }

        return result;
    }

    private TestStatus DetermineTestStatus(TestCase testCase, string actualResult, Exception? exception)
    {
        var expectedResult = testCase.ExpectedResult.Trim();
        var expectedError = testCase.ExpectedErrorMessage.Trim();

        // If we expect an error
        if (!string.IsNullOrEmpty(expectedError))
        {
            if (exception is SqlException && actualResult.Contains(expectedError, StringComparison.OrdinalIgnoreCase))
            {
                return TestStatus.Pass;
            }
            if (exception != null)
            {
                return TestStatus.Fail; // Wrong error
            }
            return TestStatus.Fail; // Expected error but got success
        }

        // If we expect success
        if (expectedResult.Equals("SUCCESS", StringComparison.OrdinalIgnoreCase))
        {
            if (exception == null)
            {
                return TestStatus.Pass;
            }
            return TestStatus.Fail; // Expected success but got error
        }

        // If we expect a specific value
        if (exception == null && actualResult.Equals(expectedResult, StringComparison.OrdinalIgnoreCase))
        {
            return TestStatus.Pass;
        }

        return TestStatus.Fail;
    }

    private string ExtractTestDataSql(string testId)
    {
        // Pattern to match: -- TEST: T001 (case insensitive) up to the next -- TEST: or end of file
        var pattern = $@"--\s*TEST:\s*{Regex.Escape(testId)}\b.*?(?=--\s*TEST:\s*\w+|$)";
        var match = Regex.Match(_setupSqlContent, pattern, RegexOptions.IgnoreCase | RegexOptions.Singleline);
        
        if (!match.Success)
        {
            return string.Empty;
        }

        var testSection = match.Value;
        
        // Remove comment lines and extract just the SQL statements
        var lines = testSection.Split('\n')
            .Where(line => !line.Trim().StartsWith("--") && !string.IsNullOrWhiteSpace(line))
            .ToList();

        return string.Join('\n', lines);
    }

    private async Task CaptureDatabaseStateAsync(SqlConnection connection, TestResult result, string testId)
    {
        try
        {
            // First, try to extract verification queries from the setup SQL
            var verificationSql = ExtractVerificationSql(testId);
            
            if (!string.IsNullOrEmpty(verificationSql))
            {
                // Execute custom verification queries
                await ExecuteVerificationQueriesAsync(connection, result, verificationSql);
            }
            else if (_config.TablesToCapture.Any())
            {
                // Capture specific tables
                await CaptureSpecificTablesAsync(connection, result, _config.TablesToCapture);
            }
            else if (_config.CaptureAllAffectedTables)
            {
                // Auto-detect and capture affected tables from stored procedure
                await CaptureAffectedTablesAsync(connection, result);
            }

            // Serialize database state to JSON for easy logging
            result.DatabaseStateJson = System.Text.Json.JsonSerializer.Serialize(
                result.DatabaseState, 
                new System.Text.Json.JsonSerializerOptions { WriteIndented = true });
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Failed to capture database state for test {TestId}", testId);
            result.DatabaseStateJson = $"Error capturing state: {ex.Message}";
        }
    }

    private string ExtractVerificationSql(string testId)
    {
        // Pattern to match: -- VERIFY: T001 up to the next -- TEST: or -- VERIFY: or end of section
        var pattern = $@"--\s*VERIFY:\s*{Regex.Escape(testId)}\b.*?(?=--\s*(?:TEST|VERIFY):\s*\w+|$)";
        var match = Regex.Match(_setupSqlContent, pattern, RegexOptions.IgnoreCase | RegexOptions.Singleline);
        
        if (!match.Success)
        {
            return string.Empty;
        }

        var verifySection = match.Value;
        
        // Remove comment lines except those that define query names
        var lines = verifySection.Split('\n')
            .Where(line => !line.Trim().StartsWith("-- ") || line.Trim().StartsWith("-- QUERY:"))
            .Where(line => !string.IsNullOrWhiteSpace(line))
            .ToList();

        return string.Join('\n', lines);
    }

    private async Task ExecuteVerificationQueriesAsync(SqlConnection connection, TestResult result, string verificationSql)
    {
        var queries = SplitVerificationQueries(verificationSql);
        
        foreach (var (queryName, querySql) in queries)
        {
            var tableData = new List<Dictionary<string, object?>>();
            
            using var command = new SqlCommand(querySql, connection)
            {
                CommandTimeout = _config.CommandTimeoutSeconds
            };

            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                var row = new Dictionary<string, object?>();
                for (int i = 0; i < reader.FieldCount; i++)
                {
                    var fieldName = reader.GetName(i);
                    var value = reader.IsDBNull(i) ? null : reader.GetValue(i);
                    row[fieldName] = value;
                }
                tableData.Add(row);
            }

            result.DatabaseState[queryName] = tableData;
            _logger.LogDebug("Captured {RowCount} rows for verification query: {QueryName}", tableData.Count, queryName);
        }
    }

    private List<(string QueryName, string QuerySql)> SplitVerificationQueries(string verificationSql)
    {
        var queries = new List<(string, string)>();
        var lines = verificationSql.Split('\n');
        string? currentQueryName = null;
        var currentQueryLines = new List<string>();

        foreach (var line in lines)
        {
            if (line.Trim().StartsWith("-- QUERY:", StringComparison.OrdinalIgnoreCase))
            {
                // Save previous query if exists
                if (currentQueryName != null && currentQueryLines.Count > 0)
                {
                    queries.Add((currentQueryName, string.Join('\n', currentQueryLines)));
                }

                // Start new query
                currentQueryName = line.Substring(line.IndexOf("-- QUERY:", StringComparison.OrdinalIgnoreCase) + 9).Trim();
                currentQueryLines = new List<string>();
            }
            else if (!string.IsNullOrWhiteSpace(line) && !line.Trim().StartsWith("--"))
            {
                currentQueryLines.Add(line);
            }
        }

        // Add last query
        if (currentQueryName != null && currentQueryLines.Count > 0)
        {
            queries.Add((currentQueryName, string.Join('\n', currentQueryLines)));
        }

        // If no named queries found, treat entire content as one query
        if (queries.Count == 0 && !string.IsNullOrWhiteSpace(verificationSql))
        {
            var cleanSql = string.Join('\n', verificationSql.Split('\n')
                .Where(line => !line.Trim().StartsWith("--") && !string.IsNullOrWhiteSpace(line)));
            
            if (!string.IsNullOrWhiteSpace(cleanSql))
            {
                queries.Add(("DefaultVerification", cleanSql));
            }
        }

        return queries;
    }

    private async Task CaptureSpecificTablesAsync(SqlConnection connection, TestResult result, List<string> tableNames)
    {
        foreach (var tableName in tableNames)
        {
            var tableData = new List<Dictionary<string, object?>>();
            var sanitizedTableName = SanitizeTableName(tableName);
            
            var querySql = $"SELECT * FROM {sanitizedTableName}";
            
            using var command = new SqlCommand(querySql, connection)
            {
                CommandTimeout = _config.CommandTimeoutSeconds
            };

            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                var row = new Dictionary<string, object?>();
                for (int i = 0; i < reader.FieldCount; i++)
                {
                    var fieldName = reader.GetName(i);
                    var value = reader.IsDBNull(i) ? null : reader.GetValue(i);
                    row[fieldName] = value;
                }
                tableData.Add(row);
            }

            result.DatabaseState[tableName] = tableData;
            _logger.LogDebug("Captured {RowCount} rows from table: {TableName}", tableData.Count, tableName);
        }
    }

    private async Task CaptureAffectedTablesAsync(SqlConnection connection, TestResult result)
    {
        // Get tables referenced by the stored procedure
        var affectedTables = await GetStoredProcedureTablesAsync(connection, _config.StoredProcedureName);
        
        if (affectedTables.Any())
        {
            await CaptureSpecificTablesAsync(connection, result, affectedTables);
        }
    }

    private async Task<List<string>> GetStoredProcedureTablesAsync(SqlConnection connection, string procedureName)
    {
        var tables = new List<string>();
        
        var query = @"
            SELECT DISTINCT 
                OBJECT_SCHEMA_NAME(d.referenced_id) + '.' + OBJECT_NAME(d.referenced_id) AS TableName
            FROM sys.sql_expression_dependencies d
            WHERE d.referencing_id = OBJECT_ID(@ProcedureName)
              AND d.referenced_id IS NOT NULL
              AND OBJECTPROPERTY(d.referenced_id, 'IsTable') = 1
            ORDER BY TableName";

        using var command = new SqlCommand(query, connection);
        command.Parameters.AddWithValue("@ProcedureName", procedureName);

        using var reader = await command.ExecuteReaderAsync();
        while (await reader.ReadAsync())
        {
            tables.Add(reader.GetString(0));
        }

        return tables;
    }

    private static string SanitizeTableName(string tableName)
    {
        // Basic sanitization - in production, use proper SQL injection prevention
        if (tableName.Contains('[') && tableName.Contains(']'))
        {
            return tableName; // Already bracketed
        }

        // Check if it has schema
        if (tableName.Contains('.'))
        {
            var parts = tableName.Split('.');
            return $"[{parts[0]}].[{parts[1]}]";
        }

        return $"[{tableName}]";
    }

    private static List<string> SplitSqlIntoBatches(string sql)
    {
        // Split on GO statements (case insensitive, whole word)
        var batches = Regex.Split(sql, @"^\s*GO\s*$", RegexOptions.IgnoreCase | RegexOptions.Multiline)
            .Where(batch => !string.IsNullOrWhiteSpace(batch))
            .Select(batch => batch.Trim())
            .ToList();

        return batches;
    }
}