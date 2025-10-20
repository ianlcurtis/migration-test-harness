namespace SqlTestRunner.Configuration;

public class TestConfiguration
{
    public string ConnectionString { get; set; } = string.Empty;
    public string TestArgumentsCsvPath { get; set; } = string.Empty;
    public string TestDataSetupSqlPath { get; set; } = string.Empty;
    public string CleanupSqlPath { get; set; } = string.Empty;
    public string StoredProcedureName { get; set; } = string.Empty;
    public string TestResultsOutputPath { get; set; } = string.Empty;
    public bool StopOnFirstFailure { get; set; } = false;
    public int CommandTimeoutSeconds { get; set; } = 30;
    public bool LogDetailedResults { get; set; } = true;
    public bool GenerateHtmlReport { get; set; } = true;
    public List<string> TestIdsToRun { get; set; } = new();
    public List<string> CategoriesToRun { get; set; } = new();
    public bool CleanupBetweenTests { get; set; } = true;
    public bool CaptureDatabaseState { get; set; } = true;
    public List<string> TablesToCapture { get; set; } = new();
    public bool CaptureAllAffectedTables { get; set; } = true;
}

public class DatabaseConfiguration
{
    public string Server { get; set; } = string.Empty;
    public string Database { get; set; } = string.Empty;
    public string UserId { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
    public bool TrustedConnection { get; set; } = false;
    public int ConnectionTimeout { get; set; } = 30;
    public bool Encrypt { get; set; } = true;
    public bool TrustServerCertificate { get; set; } = false;

    public string GetConnectionString()
    {
        var builder = new List<string>();
        
        builder.Add($"Server={Server}");
        builder.Add($"Database={Database}");
        builder.Add($"Connection Timeout={ConnectionTimeout}");
        builder.Add($"Encrypt={Encrypt}");
        builder.Add($"TrustServerCertificate={TrustServerCertificate}");

        if (TrustedConnection)
        {
            builder.Add("Trusted_Connection=true");
        }
        else
        {
            builder.Add($"User Id={UserId}");
            builder.Add($"Password={Password}");
        }

        return string.Join(";", builder);
    }
}