using System.Diagnostics;
using System.IO;
using System.Text.Json;

namespace Backend.Services;

public class ModelProcessor
{
    private readonly ILogger<ModelProcessor> _logger;
    private readonly IConfiguration _config;

    public ModelProcessor(ILogger<ModelProcessor> logger, IConfiguration config)
    {
        _logger = logger;
        _config = config;
    }

    public async Task ProcessAsync(string inputPath, string outputPath)
    {
        var dir = Path.GetDirectoryName(outputPath) ?? throw new InvalidOperationException("Invalid output path");
        Directory.CreateDirectory(dir);

        var scriptPath = Path.Combine(Directory.GetCurrentDirectory(), "scripts", "optimize_model.py");
        var outputDir = Path.GetDirectoryName(outputPath)!;

        _logger.LogInformation($"Running Blender: {inputPath} -> {outputPath}");

        var psi = new ProcessStartInfo
        {
            FileName = _config["Blender:ExePath"] ?? @"C:\Program Files\Blender Foundation\Blender 4.2\blender.exe",
            Arguments = $"--background --python \"{scriptPath}\" -- \"{inputPath}\" \"{outputPath}\"",
            UseShellExecute = false,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            WorkingDirectory = outputDir,
            CreateNoWindow = true
        };

        using var process = new Process { StartInfo = psi };
        process.Start();

        var outputTask = process.StandardOutput.ReadToEndAsync();
        var errorTask = process.StandardError.ReadToEndAsync();

        await process.WaitForExitAsync();

        var output = await outputTask;
        var error = await errorTask;

        if (process.ExitCode != 0)
        {
            _logger.LogError($"Blender failed (code {process.ExitCode}): {error}");
            throw new InvalidOperationException($"Blender processing failed: {error}\nOutput: {output}");
        }

        _logger.LogInformation($"Blender success: {output}");
    }
}
