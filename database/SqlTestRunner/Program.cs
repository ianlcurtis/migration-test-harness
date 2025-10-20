using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using SqlTestRunner.Configuration;
using SqlTestRunner.Models;
using SqlTestRunner.Services;
using System.CommandLine;

namespace SqlTestRunner;

class Program
{
    static async Task<int> Main(string[] args)
    {
        var rootCommand = CreateRootCommand();
        return await rootCommand.InvokeAsync(args);
    }

    private static RootCommand CreateRootCommand()
    {
        var rootCommand = new RootCommand("SQL Test Runner - Execute comprehensive stored procedure tests");

        var configFileOption = new Option<FileInfo?>(
            "--config",
            "Path to configuration file (appsettings.json)")
        {
            IsRequired = false
        };

        var connectionStringOption = new Option<string?>(
            "--connection-string",
            "Database connection string (overrides config file)")
        {
            IsRequired = false
        };

        var csvFileOption = new Option<FileInfo?>(
            "--csv-file",
            "Path to test arguments CSV file")
        {
            IsRequired = false
        };

        var sqlFileOption = new Option<FileInfo?>(
            "--sql-file",
            "Path to test data setup SQL file")
        {
            IsRequired = false
        };

        var cleanupFileOption = new Option<FileInfo?>(
            "--cleanup-file",
            "Path to database cleanup SQL file")
        {
            IsRequired = false
        };

        var storedProcOption = new Option<string?>(
            "--stored-procedure",
            "Name of the stored procedure to test")
        {
            IsRequired = false
        };

        var outputOption = new Option<DirectoryInfo?>(
            "--output",
            "Output directory for test results")
        {
            IsRequired = false
        };

        var testIdsOption = new Option<string[]?>(
            "--test-ids",
            "Specific test IDs to run (comma-separated)")
        {
            IsRequired = false,
            AllowMultipleArgumentsPerToken = true
        };

        var categoriesOption = new Option<string[]?>(
            "--categories",
            "Test categories to run: HAPPY_PATH, UNHAPPY_PATH, EDGE_CASE")
        {
            IsRequired = false,
            AllowMultipleArgumentsPerToken = true
        };

        var stopOnFailureOption = new Option<bool>(
            "--stop-on-failure",
            "Stop execution on first test failure")
        {
            IsRequired = false
        };

        var verboseOption = new Option<bool>(
            "--verbose",
            "Enable verbose logging")
        {
            IsRequired = false
        };

        rootCommand.AddOption(configFileOption);
        rootCommand.AddOption(connectionStringOption);
        rootCommand.AddOption(csvFileOption);
        rootCommand.AddOption(sqlFileOption);
        rootCommand.AddOption(cleanupFileOption);
        rootCommand.AddOption(storedProcOption);
        rootCommand.AddOption(outputOption);
        rootCommand.AddOption(testIdsOption);
        rootCommand.AddOption(categoriesOption);
        rootCommand.AddOption(stopOnFailureOption);
        rootCommand.AddOption(verboseOption);

        rootCommand.SetHandler(async (context) =>
        {
            var configFile = context.ParseResult.GetValueForOption(configFileOption);
            var connectionString = context.ParseResult.GetValueForOption(connectionStringOption);
            var csvFile = context.ParseResult.GetValueForOption(csvFileOption);
            var sqlFile = context.ParseResult.GetValueForOption(sqlFileOption);
            var cleanupFile = context.ParseResult.GetValueForOption(cleanupFileOption);
            var storedProc = context.ParseResult.GetValueForOption(storedProcOption);
            var output = context.ParseResult.GetValueForOption(outputOption);
            var testIds = context.ParseResult.GetValueForOption(testIdsOption);
            var categories = context.ParseResult.GetValueForOption(categoriesOption);
            var stopOnFailure = context.ParseResult.GetValueForOption(stopOnFailureOption);
            var verbose = context.ParseResult.GetValueForOption(verboseOption);

            try
            {
                await RunTestsAsync(configFile, connectionString, csvFile, sqlFile, cleanupFile, 
                    storedProc, output, testIds, categories, stopOnFailure, verbose);
                context.ExitCode = 0;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
                if (verbose)
                {
                    Console.WriteLine($"Stack trace: {ex.StackTrace}");
                }
                context.ExitCode = 1;
            }
        });

        return rootCommand;
    }

    private static async Task RunTestsAsync(
        FileInfo? configFile,
        string? connectionString,
        FileInfo? csvFile,
        FileInfo? sqlFile,
        FileInfo? cleanupFile,
        string? storedProc,
        DirectoryInfo? output,
        string[]? testIds,
        string[]? categories,
        bool stopOnFailure,
        bool verbose)
    {
        // Setup logging
        var services = new ServiceCollection();
        services.AddLogging(builder =>
        {
            builder.AddConsole();
            if (verbose)
            {
                builder.SetMinimumLevel(LogLevel.Debug);
            }
            else
            {
                builder.SetMinimumLevel(LogLevel.Information);
            }
        });

        // Load configuration
        var config = LoadConfiguration(configFile, connectionString, csvFile, sqlFile, 
            cleanupFile, storedProc, output, testIds, categories, stopOnFailure);

        // Register services
        services.AddSingleton(config);
        services.AddTransient<ITestCaseReader, CsvTestCaseReader>();
        services.AddTransient<ISqlTestExecutor, SqlTestExecutor>();
        services.AddTransient<ITestResultLogger, TestResultLogger>();
        services.AddTransient<TestRunner>();

        var serviceProvider = services.BuildServiceProvider();
        var logger = serviceProvider.GetRequiredService<ILogger<Program>>();

        logger.LogInformation("Starting SQL Test Runner");
        logger.LogInformation("Configuration loaded: {Config}", 
            System.Text.Json.JsonSerializer.Serialize(config, new System.Text.Json.JsonSerializerOptions { WriteIndented = true }));

        var testRunner = serviceProvider.GetRequiredService<TestRunner>();
        await testRunner.RunTestsAsync();

        logger.LogInformation("SQL Test Runner completed");
    }

    private static TestConfiguration LoadConfiguration(
        FileInfo? configFile,
        string? connectionString,
        FileInfo? csvFile,
        FileInfo? sqlFile,
        FileInfo? cleanupFile,
        string? storedProc,
        DirectoryInfo? output,
        string[]? testIds,
        string[]? categories,
        bool stopOnFailure)
    {
        var builder = new ConfigurationBuilder();

        // Load from appsettings.json if it exists
        var defaultConfigPath = "appsettings.json";
        if (File.Exists(defaultConfigPath))
        {
            builder.AddJsonFile(defaultConfigPath, optional: true);
        }

        // Load from specified config file
        if (configFile?.Exists == true)
        {
            builder.AddJsonFile(configFile.FullName, optional: false);
        }

        var configuration = builder.Build();
        
        // Load base configuration
        var config = new TestConfiguration();
        configuration.GetSection("TestConfiguration").Bind(config);

        // Override with command line arguments
        if (!string.IsNullOrEmpty(connectionString))
            config.ConnectionString = connectionString;
        
        if (csvFile?.Exists == true)
            config.TestArgumentsCsvPath = csvFile.FullName;
        
        if (sqlFile?.Exists == true)
            config.TestDataSetupSqlPath = sqlFile.FullName;
        
        if (cleanupFile?.Exists == true)
            config.CleanupSqlPath = cleanupFile.FullName;
        
        if (!string.IsNullOrEmpty(storedProc))
            config.StoredProcedureName = storedProc;
        
        if (output?.Exists == true)
            config.TestResultsOutputPath = Path.Combine(output.FullName, "test_results");
        
        if (testIds?.Length > 0)
            config.TestIdsToRun = testIds.ToList();
        
        if (categories?.Length > 0)
            config.CategoriesToRun = categories.ToList();
        
        config.StopOnFirstFailure = stopOnFailure;

        // Set defaults if not specified
        if (string.IsNullOrEmpty(config.TestResultsOutputPath))
            config.TestResultsOutputPath = Path.Combine(".", "test_results");

        return config;
    }
}