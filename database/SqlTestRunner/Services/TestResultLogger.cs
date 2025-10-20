using SqlTestRunner.Models;
using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Logging;

namespace SqlTestRunner.Services;

public interface ITestResultLogger
{
    Task LogResultsAsync(List<TestResult> results, string outputPath);
    Task GenerateHtmlReportAsync(List<TestResult> results, string outputPath);
    Task GenerateCsvReportAsync(List<TestResult> results, string outputPath);
    Task GenerateJsonReportAsync(List<TestResult> results, string outputPath);
}

public class TestResultLogger : ITestResultLogger
{
    private readonly ILogger<TestResultLogger> _logger;

    public TestResultLogger(ILogger<TestResultLogger> logger)
    {
        _logger = logger;
    }

    public async Task LogResultsAsync(List<TestResult> results, string outputPath)
    {
        var directory = Path.GetDirectoryName(outputPath);
        if (!string.IsNullOrEmpty(directory) && !Directory.Exists(directory))
        {
            Directory.CreateDirectory(directory);
        }

        // Generate all report formats
        var baseFileName = Path.GetFileNameWithoutExtension(outputPath);
        var baseDirectory = Path.GetDirectoryName(outputPath) ?? ".";

        await GenerateCsvReportAsync(results, Path.Combine(baseDirectory, $"{baseFileName}.csv"));
        await GenerateJsonReportAsync(results, Path.Combine(baseDirectory, $"{baseFileName}.json"));
        await GenerateHtmlReportAsync(results, Path.Combine(baseDirectory, $"{baseFileName}.html"));

        _logger.LogInformation("Test results saved to: {OutputPath}", baseDirectory);
    }

    public async Task GenerateCsvReportAsync(List<TestResult> results, string outputPath)
    {
        var csv = new StringBuilder();
        csv.AppendLine("test_id,test_name,execution_date,status,actual_result,error_message,notes,duration_ms,return_value,output_params_count,result_sets_count,database_tables_captured");

        foreach (var result in results)
        {
            csv.AppendLine($"{EscapeCsvValue(result.TestId)}," +
                          $"{EscapeCsvValue(result.TestName)}," +
                          $"{result.ExecutionDate:yyyy-MM-dd HH:mm:ss}," +
                          $"{result.Status}," +
                          $"{EscapeCsvValue(result.ActualResult)}," +
                          $"{EscapeCsvValue(result.ErrorMessage)}," +
                          $"{EscapeCsvValue(result.Notes)}," +
                          $"{result.DurationMs}," +
                          $"{EscapeCsvValue(result.ReturnValue?.ToString() ?? "")}," +
                          $"{result.OutputParameters.Count}," +
                          $"{result.ResultSets.Count}," +
                          $"{result.DatabaseState.Count}");
        }

        await File.WriteAllTextAsync(outputPath, csv.ToString());
        _logger.LogDebug("CSV report generated: {Path}", outputPath);
    }

    public async Task GenerateJsonReportAsync(List<TestResult> results, string outputPath)
    {
        var summary = new
        {
            ExecutionDate = DateTime.UtcNow,
            TotalTests = results.Count,
            Passed = results.Count(r => r.Status == TestStatus.Pass),
            Failed = results.Count(r => r.Status == TestStatus.Fail),
            Errors = results.Count(r => r.Status == TestStatus.Error),
            Skipped = results.Count(r => r.Status == TestStatus.Skipped),
            TotalDurationMs = results.Sum(r => r.DurationMs),
            Results = results.Select(r => new
            {
                r.TestId,
                r.TestName,
                r.ExecutionDate,
                Status = r.Status.ToString(),
                r.ActualResult,
                r.ErrorMessage,
                r.Notes,
                r.DurationMs,
                ExceptionType = r.Exception?.GetType().Name,
                ExceptionMessage = r.Exception?.Message,
                StoredProcedureOutput = new
                {
                    r.ReturnValue,
                    r.OutputParameters,
                    ResultSets = r.ResultSets.Select((rs, index) => new
                    {
                        ResultSetIndex = index,
                        RowCount = rs.Count,
                        Rows = rs
                    }).ToList()
                },
                DatabaseState = new
                {
                    Tables = r.DatabaseState.Select(kvp => new
                    {
                        TableName = kvp.Key,
                        RowCount = kvp.Value.Count,
                        Rows = kvp.Value
                    }).ToList(),
                    StateJson = r.DatabaseStateJson
                }
            })
        };

        var options = new JsonSerializerOptions
        {
            WriteIndented = true,
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase
        };

        var json = JsonSerializer.Serialize(summary, options);
        await File.WriteAllTextAsync(outputPath, json);
        _logger.LogDebug("JSON report generated: {Path}", outputPath);
    }

    public async Task GenerateHtmlReportAsync(List<TestResult> results, string outputPath)
    {
        var totalTests = results.Count;
        var passed = results.Count(r => r.Status == TestStatus.Pass);
        var failed = results.Count(r => r.Status == TestStatus.Fail);
        var errors = results.Count(r => r.Status == TestStatus.Error);
        var skipped = results.Count(r => r.Status == TestStatus.Skipped);
        var totalDuration = results.Sum(r => r.DurationMs);

        var html = new StringBuilder();
        html.AppendLine("<!DOCTYPE html>");
        html.AppendLine("<html>");
        html.AppendLine("<head>");
        html.AppendLine("    <title>SQL Test Results</title>");
        html.AppendLine("    <style>");
        html.AppendLine("        body { font-family: Arial, sans-serif; margin: 20px; }");
        html.AppendLine("        .summary { background-color: #f5f5f5; padding: 15px; border-radius: 5px; margin-bottom: 20px; }");
        html.AppendLine("        .passed { color: green; font-weight: bold; }");
        html.AppendLine("        .failed { color: red; font-weight: bold; }");
        html.AppendLine("        .error { color: orange; font-weight: bold; }");
        html.AppendLine("        .skipped { color: gray; font-weight: bold; }");
        html.AppendLine("        table { border-collapse: collapse; width: 100%; }");
        html.AppendLine("        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }");
        html.AppendLine("        th { background-color: #f2f2f2; }");
        html.AppendLine("        .status-pass { background-color: #d4edda; }");
        html.AppendLine("        .status-fail { background-color: #f8d7da; }");
        html.AppendLine("        .status-error { background-color: #fff3cd; }");
        html.AppendLine("        .status-skipped { background-color: #e2e3e5; }");
        html.AppendLine("        .details { max-width: 300px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }");
        html.AppendLine("        .collapsible { cursor: pointer; background-color: #f2f2f2; padding: 10px; margin: 5px 0; border: 1px solid #ddd; border-radius: 3px; }");
        html.AppendLine("        .collapsible:hover { background-color: #e0e0e0; }");
        html.AppendLine("        .content { display: none; padding: 10px; border: 1px solid #ddd; margin-bottom: 10px; background-color: #fafafa; }");
        html.AppendLine("        .content pre { margin: 0; white-space: pre-wrap; word-wrap: break-word; font-size: 12px; }");
        html.AppendLine("        .output-section { margin: 20px 0; }");
        html.AppendLine("    </style>");
        html.AppendLine("    <script>");
        html.AppendLine("        function toggleContent(id) {");
        html.AppendLine("            var content = document.getElementById(id);");
        html.AppendLine("            if (content.style.display === 'block') {");
        html.AppendLine("                content.style.display = 'none';");
        html.AppendLine("            } else {");
        html.AppendLine("                content.style.display = 'block';");
        html.AppendLine("            }");
        html.AppendLine("        }");
        html.AppendLine("    </script>");
        html.AppendLine("</head>");
        html.AppendLine("<body>");
        
        html.AppendLine("    <h1>SQL Test Results</h1>");
        html.AppendLine($"    <p>Generated on: {DateTime.UtcNow:yyyy-MM-dd HH:mm:ss} UTC</p>");
        
        html.AppendLine("    <div class=\"summary\">");
        html.AppendLine("        <h2>Summary</h2>");
        html.AppendLine($"        <p>Total Tests: {totalTests}</p>");
        html.AppendLine($"        <p><span class=\"passed\">Passed: {passed}</span></p>");
        html.AppendLine($"        <p><span class=\"failed\">Failed: {failed}</span></p>");
        html.AppendLine($"        <p><span class=\"error\">Errors: {errors}</span></p>");
        html.AppendLine($"        <p><span class=\"skipped\">Skipped: {skipped}</span></p>");
        html.AppendLine($"        <p>Total Duration: {totalDuration:N0} ms</p>");
        html.AppendLine($"        <p>Success Rate: {(totalTests > 0 ? (double)passed / totalTests * 100 : 0):F1}%</p>");
        html.AppendLine("    </div>");

        html.AppendLine("    <table>");
        html.AppendLine("        <tr>");
        html.AppendLine("            <th>Test ID</th>");
        html.AppendLine("            <th>Test Name</th>");
        html.AppendLine("            <th>Status</th>");
        html.AppendLine("            <th>Actual Result</th>");
        html.AppendLine("            <th>Error Message</th>");
        html.AppendLine("            <th>Duration (ms)</th>");
        html.AppendLine("            <th>Notes</th>");
        html.AppendLine("        </tr>");

        foreach (var result in results.OrderBy(r => r.TestId))
        {
            var statusClass = result.Status.ToString().ToLowerInvariant();
            html.AppendLine("        <tr>");
            html.AppendLine($"            <td>{EscapeHtml(result.TestId)}</td>");
            html.AppendLine($"            <td>{EscapeHtml(result.TestName)}</td>");
            html.AppendLine($"            <td class=\"status-{statusClass}\">{result.Status}</td>");
            html.AppendLine($"            <td class=\"details\" title=\"{EscapeHtml(result.ActualResult)}\">{EscapeHtml(result.ActualResult)}</td>");
            html.AppendLine($"            <td class=\"details\" title=\"{EscapeHtml(result.ErrorMessage)}\">{EscapeHtml(result.ErrorMessage)}</td>");
            html.AppendLine($"            <td>{result.DurationMs:N0}</td>");
            html.AppendLine($"            <td class=\"details\" title=\"{EscapeHtml(result.Notes)}\">{EscapeHtml(result.Notes)}</td>");
            html.AppendLine("        </tr>");
        }

        html.AppendLine("    </table>");
        
        // Add detailed output sections for each test
        html.AppendLine("    <div class=\"output-section\">");
        html.AppendLine("        <h2>Detailed Test Output</h2>");
        
        foreach (var result in results.OrderBy(r => r.TestId))
        {
            html.AppendLine($"        <div class=\"collapsible\" onclick=\"toggleContent('{result.TestId}_details')\">");
            html.AppendLine($"            ▶ {EscapeHtml(result.TestId)} - {EscapeHtml(result.TestName)} (Click to expand)");
            html.AppendLine("        </div>");
            html.AppendLine($"        <div id=\"{result.TestId}_details\" class=\"content\">");
            
            // Stored Procedure Output
            html.AppendLine("            <h3>Stored Procedure Output</h3>");
            html.AppendLine($"            <p><strong>Return Value:</strong> {EscapeHtml(result.ReturnValue?.ToString() ?? "NULL")}</p>");
            
            if (result.OutputParameters.Any())
            {
                html.AppendLine("            <h4>Output Parameters:</h4>");
                html.AppendLine("            <pre>");
                foreach (var param in result.OutputParameters)
                {
                    html.AppendLine($"{EscapeHtml(param.Key)}: {EscapeHtml(param.Value?.ToString() ?? "NULL")}");
                }
                html.AppendLine("            </pre>");
            }
            
            if (result.ResultSets.Any())
            {
                html.AppendLine($"            <h4>Result Sets ({result.ResultSets.Count}):</h4>");
                for (int i = 0; i < result.ResultSets.Count; i++)
                {
                    var resultSet = result.ResultSets[i];
                    html.AppendLine($"            <h5>Result Set {i + 1} ({resultSet.Count} rows):</h5>");
                    
                    if (resultSet.Count > 0)
                    {
                        html.AppendLine("            <table style=\"font-size: 12px;\">");
                        
                        // Headers
                        html.AppendLine("                <tr>");
                        foreach (var column in resultSet[0].Keys)
                        {
                            html.AppendLine($"                    <th>{EscapeHtml(column)}</th>");
                        }
                        html.AppendLine("                </tr>");
                        
                        // Data rows
                        foreach (var row in resultSet)
                        {
                            html.AppendLine("                <tr>");
                            foreach (var value in row.Values)
                            {
                                html.AppendLine($"                    <td>{EscapeHtml(value?.ToString() ?? "NULL")}</td>");
                            }
                            html.AppendLine("                </tr>");
                        }
                        
                        html.AppendLine("            </table>");
                    }
                }
            }
            
            // Database State
            if (result.DatabaseState.Any())
            {
                html.AppendLine("            <h3>Database State After Test</h3>");
                foreach (var table in result.DatabaseState)
                {
                    html.AppendLine($"            <h4>{EscapeHtml(table.Key)} ({table.Value.Count} rows):</h4>");
                    
                    if (table.Value.Count > 0)
                    {
                        html.AppendLine("            <table style=\"font-size: 12px;\">");
                        
                        // Headers
                        html.AppendLine("                <tr>");
                        foreach (var column in table.Value[0].Keys)
                        {
                            html.AppendLine($"                    <th>{EscapeHtml(column)}</th>");
                        }
                        html.AppendLine("                </tr>");
                        
                        // Data rows (limit to first 10 for readability)
                        var displayRows = table.Value.Take(10);
                        foreach (var row in displayRows)
                        {
                            html.AppendLine("                <tr>");
                            foreach (var value in row.Values)
                            {
                                html.AppendLine($"                    <td>{EscapeHtml(value?.ToString() ?? "NULL")}</td>");
                            }
                            html.AppendLine("                </tr>");
                        }
                        
                        if (table.Value.Count > 10)
                        {
                            html.AppendLine($"                <tr><td colspan=\"{table.Value[0].Keys.Count}\">... and {table.Value.Count - 10} more rows</td></tr>");
                        }
                        
                        html.AppendLine("            </table>");
                    }
                    else
                    {
                        html.AppendLine("            <p><em>No rows</em></p>");
                    }
                }
            }
            
            html.AppendLine("        </div>");
        }
        
        html.AppendLine("    </div>");
        
        html.AppendLine("</body>");
        html.AppendLine("</html>");

        await File.WriteAllTextAsync(outputPath, html.ToString());
        _logger.LogDebug("HTML report generated: {Path}", outputPath);
    }

    private static string EscapeCsvValue(string value)
    {
        if (string.IsNullOrEmpty(value))
            return string.Empty;

        if (value.Contains(',') || value.Contains('"') || value.Contains('\n') || value.Contains('\r'))
        {
            return $"\"{value.Replace("\"", "\"\"")}\"";
        }

        return value;
    }

    private static string EscapeHtml(string value)
    {
        if (string.IsNullOrEmpty(value))
            return string.Empty;

        return value
            .Replace("&", "&amp;")
            .Replace("<", "&lt;")
            .Replace(">", "&gt;")
            .Replace("\"", "&quot;")
            .Replace("'", "&#39;");
    }
}