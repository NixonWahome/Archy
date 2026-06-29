using Microsoft.AspNetCore.Mvc;
using Backend.Services;
using Backend.Models;
using System.IO;
using System.Linq;
using System.Text.Json;

namespace Backend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ModelController : ControllerBase
{
    private readonly ModelProcessor _processor;
    private readonly ILogger<ModelController> _logger;

    public ModelController(ModelProcessor processor, ILogger<ModelController> logger)
    {
        _processor = processor;
        _logger = logger;
    }

    [HttpPost("process")]
    public async Task<IActionResult> ProcessModel([FromForm] ProcessRequest request)
    {
        if (request.File == null || request.File.Length == 0)
        {
            return BadRequest(new { error = "No file uploaded. Send 'file' (.fbx, .obj)" });
        }

        var projectId = request.ProjectId ?? Guid.NewGuid().ToString();
        var extension = Path.GetExtension(request.File.FileName)?.TrimStart('.').ToLower() ?? "fbx";
        var inputPath = Path.Combine(Path.GetTempPath(), $"model_input_{projectId}.{extension}");
        var outputGlbPath = Path.Combine("wwwroot", "models", $"{projectId}.glb");

        try
        {
            _logger.LogInformation($"Processing model for project {projectId}: {request.File.FileName}");

            // Save uploaded file
            using var stream = new FileStream(inputPath, FileMode.Create);
            await request.File.CopyToAsync(stream);

            // Process with Blender
            await _processor.ProcessAsync(inputPath, outputGlbPath);

            // Build URL
            var glbUrl = $"{Request.Scheme}://{Request.Host}/{outputGlbPath.Replace("\\", "/")}";

            var result = new
            {
                success = true,
                projectId,
                modelUrl = glbUrl,
                message = "Model processed successfully. Ready for AR."
            };

            _logger.LogInformation($"Model ready: {glbUrl}");
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Model processing failed");
            return StatusCode(500, new { error = "Processing failed", details = ex.Message });
        }
        finally
        {
            // Cleanup temp
            try { if (System.IO.File.Exists(inputPath)) System.IO.File.Delete(inputPath); } catch { }
        }
    }

    [HttpGet]
    public IActionResult ListModels()
    {
        var modelsDir = Path.Combine("wwwroot", "models");
        if (!Directory.Exists(modelsDir)) return Ok(new { models = Array.Empty<object>() });

        var glbs = Directory.GetFiles(modelsDir, "*.glb")
            .Select(f => new 
            {
                id = Path.GetFileNameWithoutExtension(f),
                url = $"{Request.Scheme}://{Request.Host}/{modelsDir.Replace("\\", "/")}/{Path.GetFileName(f)}",
                size = new FileInfo(f).Length
            });
        return Ok(new { models = glbs.ToArray() });
    }
}

