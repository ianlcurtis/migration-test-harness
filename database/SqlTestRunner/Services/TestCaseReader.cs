using CsvHelper;
using CsvHelper.Configuration;
using SqlTestRunner.Models;
using System.Globalization;

namespace SqlTestRunner.Services;

public interface ITestCaseReader
{
    Task<List<TestCase>> ReadTestCasesAsync(string csvFilePath);
}

public class CsvTestCaseReader : ITestCaseReader
{
    public async Task<List<TestCase>> ReadTestCasesAsync(string csvFilePath)
    {
        if (!File.Exists(csvFilePath))
        {
            throw new FileNotFoundException($"Test arguments CSV file not found: {csvFilePath}");
        }

        var testCases = new List<TestCase>();

        using var reader = new StreamReader(csvFilePath);
        using var csv = new CsvReader(reader, CultureInfo.InvariantCulture);

        // Read the header row to get column names
        await csv.ReadAsync();
        csv.ReadHeader();
        var headers = csv.HeaderRecord;

        if (headers == null || headers.Length == 0)
        {
            throw new InvalidDataException("CSV file must contain headers");
        }

        // Validate required columns
        var requiredColumns = new[] { "test_id", "test_name", "test_category", "description", "expected_result" };
        var missingColumns = requiredColumns.Where(col => !headers.Contains(col, StringComparer.OrdinalIgnoreCase)).ToList();
        
        if (missingColumns.Any())
        {
            throw new InvalidDataException($"Missing required columns: {string.Join(", ", missingColumns)}");
        }

        // Find parameter columns (anything not in the fixed columns)
        var fixedColumns = new[] { "test_id", "test_name", "test_category", "description", "expected_result", "expected_error_message", "setup_note" };
        var parameterColumns = headers.Where(h => !fixedColumns.Contains(h, StringComparer.OrdinalIgnoreCase)).ToList();

        while (await csv.ReadAsync())
        {
            var testCase = new TestCase
            {
                TestId = GetValue(csv, "test_id"),
                TestName = GetValue(csv, "test_name"),
                TestCategory = GetValue(csv, "test_category"),
                Description = GetValue(csv, "description"),
                ExpectedResult = GetValue(csv, "expected_result"),
                ExpectedErrorMessage = GetValue(csv, "expected_error_message"),
                SetupNote = GetValue(csv, "setup_note")
            };

            // Read parameter values
            foreach (var paramColumn in parameterColumns)
            {
                var value = csv.GetField(paramColumn);
                testCase.Parameters[paramColumn] = ParseParameterValue(value);
            }

            testCases.Add(testCase);
        }

        return testCases;
    }

    private static string GetValue(CsvReader csv, string columnName)
    {
        try
        {
            return csv.GetField(columnName) ?? string.Empty;
        }
        catch (HeaderValidationException)
        {
            return string.Empty;
        }
    }

    private static object? ParseParameterValue(string? value)
    {
        if (string.IsNullOrWhiteSpace(value) || value.Equals("NULL", StringComparison.OrdinalIgnoreCase))
        {
            return null;
        }

        // Try to parse as different types
        if (int.TryParse(value, out var intValue))
        {
            return intValue;
        }

        if (decimal.TryParse(value, out var decimalValue))
        {
            return decimalValue;
        }

        if (bool.TryParse(value, out var boolValue))
        {
            return boolValue;
        }

        if (DateTime.TryParse(value, out var dateValue))
        {
            return dateValue;
        }

        // Return as string if no other type matches
        return value;
    }
}