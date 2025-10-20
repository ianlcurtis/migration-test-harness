using Microsoft.Extensions.Logging;
using SqlTestRunner.Configuration;
using SqlTestRunner.Models;
using SqlTestRunner.Services;

namespace SqlTestRunner;

public class TestRunner
{
    private readonly TestConfiguration _config;
    private readonly ITestCaseReader _testCaseReader;
    private readonly ISqlTestExecutor _sqlExecutor;
    private readonly ITestResultLogger _resultLogger;
    private readonly ILogger<TestRunner> _logger;

    public TestRunner(
        TestConfiguration config,
        ITestCaseReader testCaseReader,
        ISqlTestExecutor sqlExecutor,
        ITestResultLogger resultLogger,
        ILogger<TestRunner> logger)
    {
        _config = config;
        _testCaseReader = testCaseReader;
        _sqlExecutor = sqlExecutor;
        _resultLogger = resultLogger;
        _logger = logger;
    }

    public async Task RunTestsAsync()
    {
        _logger.LogInformation("Starting test execution");

        // Validate configuration
        ValidateConfiguration();

        // Test database connection
        _logger.LogInformation("Testing database connection...");
        if (!await _sqlExecutor.TestConnectionAsync())
        {
            throw new InvalidOperationException("Failed to connect to database");
        }

        // Load test cases
        _logger.LogInformation("Loading test cases from: {CsvPath}", _config.TestArgumentsCsvPath);
        var allTestCases = await _testCaseReader.ReadTestCasesAsync(_config.TestArgumentsCsvPath);
        
        // Filter test cases based on configuration
        var testCasesToRun = FilterTestCases(allTestCases);
        
        _logger.LogInformation("Loaded {TotalTests} test cases, will run {FilteredTests} tests", 
            allTestCases.Count, testCasesToRun.Count);

        if (testCasesToRun.Count == 0)
        {
            _logger.LogWarning("No tests to run based on current filters");
            return;
        }

        // Execute tests
        var results = new List<TestResult>();
        var stopwatch = System.Diagnostics.Stopwatch.StartNew();

        for (int i = 0; i < testCasesToRun.Count; i++)
        {
            var testCase = testCasesToRun[i];
            _logger.LogInformation("Running test {Current}/{Total}: {TestId} - {TestName}", 
                i + 1, testCasesToRun.Count, testCase.TestId, testCase.TestName);

            try
            {
                // Cleanup database if configured
                if (_config.CleanupBetweenTests)
                {
                    await _sqlExecutor.CleanupDatabaseAsync();
                }

                // Setup test data
                await _sqlExecutor.SetupTestDataAsync(testCase.TestId);

                // Execute test
                var result = await _sqlExecutor.ExecuteTestAsync(testCase);
                results.Add(result);

                _logger.LogInformation("Test {TestId} completed: {Status} in {Duration}ms", 
                    testCase.TestId, result.Status, result.DurationMs);

                // Stop on first failure if configured
                if (_config.StopOnFirstFailure && (result.Status == TestStatus.Fail || result.Status == TestStatus.Error))
                {
                    _logger.LogWarning("Stopping execution due to test failure (StopOnFirstFailure = true)");
                    break;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error running test {TestId}", testCase.TestId);
                
                var errorResult = new TestResult
                {
                    TestId = testCase.TestId,
                    TestName = testCase.TestName,
                    ExecutionDate = DateTime.UtcNow,
                    Status = TestStatus.Error,
                    ErrorMessage = ex.Message,
                    Exception = ex,
                    ActualResult = $"SYSTEM ERROR: {ex.Message}"
                };
                results.Add(errorResult);

                if (_config.StopOnFirstFailure)
                {
                    _logger.LogWarning("Stopping execution due to system error (StopOnFirstFailure = true)");
                    break;
                }
            }
        }

        stopwatch.Stop();

        // Generate summary
        var summary = GenerateSummary(results, stopwatch.ElapsedMilliseconds);
        LogSummary(summary);

        // Save results
        _logger.LogInformation("Saving test results to: {OutputPath}", _config.TestResultsOutputPath);
        await _resultLogger.LogResultsAsync(results, _config.TestResultsOutputPath);

        _logger.LogInformation("Test execution completed");
    }

    private void ValidateConfiguration()
    {
        var errors = new List<string>();

        if (string.IsNullOrEmpty(_config.ConnectionString))
            errors.Add("Connection string is required");

        if (string.IsNullOrEmpty(_config.TestArgumentsCsvPath) || !File.Exists(_config.TestArgumentsCsvPath))
            errors.Add($"Test arguments CSV file not found: {_config.TestArgumentsCsvPath}");

        if (string.IsNullOrEmpty(_config.TestDataSetupSqlPath) || !File.Exists(_config.TestDataSetupSqlPath))
            errors.Add($"Test data setup SQL file not found: {_config.TestDataSetupSqlPath}");

        if (string.IsNullOrEmpty(_config.StoredProcedureName))
            errors.Add("Stored procedure name is required");

        if (errors.Any())
        {
            throw new InvalidOperationException($"Configuration validation failed:\n{string.Join("\n", errors)}");
        }
    }

    private List<TestCase> FilterTestCases(List<TestCase> allTestCases)
    {
        var filtered = allTestCases.AsEnumerable();

        // Filter by test IDs
        if (_config.TestIdsToRun.Any())
        {
            filtered = filtered.Where(tc => _config.TestIdsToRun.Contains(tc.TestId, StringComparer.OrdinalIgnoreCase));
        }

        // Filter by categories
        if (_config.CategoriesToRun.Any())
        {
            filtered = filtered.Where(tc => _config.CategoriesToRun.Contains(tc.TestCategory, StringComparer.OrdinalIgnoreCase));
        }

        return filtered.ToList();
    }

    private static TestSummary GenerateSummary(List<TestResult> results, long totalDurationMs)
    {
        return new TestSummary
        {
            TotalTests = results.Count,
            PassedTests = results.Count(r => r.Status == TestStatus.Pass),
            FailedTests = results.Count(r => r.Status == TestStatus.Fail),
            ErrorTests = results.Count(r => r.Status == TestStatus.Error),
            SkippedTests = results.Count(r => r.Status == TestStatus.Skipped),
            TotalDurationMs = totalDurationMs,
            AverageDurationMs = results.Count > 0 ? results.Average(r => r.DurationMs) : 0,
            SuccessRate = results.Count > 0 ? (double)results.Count(r => r.Status == TestStatus.Pass) / results.Count * 100 : 0
        };
    }

    private void LogSummary(TestSummary summary)
    {
        _logger.LogInformation("=== TEST EXECUTION SUMMARY ===");
        _logger.LogInformation("Total Tests: {Total}", summary.TotalTests);
        _logger.LogInformation("Passed: {Passed}", summary.PassedTests);
        _logger.LogInformation("Failed: {Failed}", summary.FailedTests);
        _logger.LogInformation("Errors: {Errors}", summary.ErrorTests);
        _logger.LogInformation("Skipped: {Skipped}", summary.SkippedTests);
        _logger.LogInformation("Success Rate: {SuccessRate:F1}%", summary.SuccessRate);
        _logger.LogInformation("Total Duration: {TotalDuration:N0}ms", summary.TotalDurationMs);
        _logger.LogInformation("Average Test Duration: {AverageDuration:F1}ms", summary.AverageDurationMs);
        _logger.LogInformation("===============================");
    }
}

public class TestSummary
{
    public int TotalTests { get; set; }
    public int PassedTests { get; set; }
    public int FailedTests { get; set; }
    public int ErrorTests { get; set; }
    public int SkippedTests { get; set; }
    public long TotalDurationMs { get; set; }
    public double AverageDurationMs { get; set; }
    public double SuccessRate { get; set; }
}