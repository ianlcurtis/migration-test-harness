namespace SqlTestRunner.Models;

public class TestCase
{
    public string TestId { get; set; } = string.Empty;
    public string TestName { get; set; } = string.Empty;
    public string TestCategory { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public Dictionary<string, object?> Parameters { get; set; } = new();
    public string ExpectedResult { get; set; } = string.Empty;
    public string ExpectedErrorMessage { get; set; } = string.Empty;
    public string SetupNote { get; set; } = string.Empty;
}

public class TestResult
{
    public string TestId { get; set; } = string.Empty;
    public string TestName { get; set; } = string.Empty;
    public DateTime ExecutionDate { get; set; }
    public TestStatus Status { get; set; }
    public string ActualResult { get; set; } = string.Empty;
    public string ErrorMessage { get; set; } = string.Empty;
    public string Notes { get; set; } = string.Empty;
    public long DurationMs { get; set; }
    public Exception? Exception { get; set; }
    
    // Stored Procedure Output
    public object? ReturnValue { get; set; }
    public Dictionary<string, object?> OutputParameters { get; set; } = new();
    public List<List<Dictionary<string, object?>>> ResultSets { get; set; } = new();
    
    // Database State After Test
    public Dictionary<string, List<Dictionary<string, object?>>> DatabaseState { get; set; } = new();
    public string DatabaseStateJson { get; set; } = string.Empty;
}

public enum TestStatus
{
    NotRun,
    Pass,
    Fail,
    Error,
    Skipped
}

public enum TestCategory
{
    HappyPath,
    UnhappyPath,
    EdgeCase
}