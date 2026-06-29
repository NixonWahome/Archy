using Microsoft.AspNetCore.Http;

namespace Backend.Models;

public class ProcessRequest
{
    public string? ProjectId { get; set; }
    public IFormFile File { get; set; } = null!;
}
