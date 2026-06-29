using Backend.Services;
using Backend.Controllers;
using Microsoft.AspNetCore.StaticFiles;
using Microsoft.Extensions.FileProviders;
using System.IO;
using Serilog;
using Hangfire;
using Hangfire.MemoryStorage; 

Log.Logger = new LoggerConfiguration()
    .WriteTo.Console()
    .CreateLogger();

var builder = WebApplication.CreateBuilder(args);

builder.Host.UseSerilog();
builder.Configuration.AddJsonFile("appsettings.json");

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddScoped<ModelProcessor>();

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

builder.Services.AddHangfire(config => config
    .UseSimpleAssemblyNameTypeSerializer()
    .UseRecommendedSerializerSettings()
    .SetDataCompatibilityLevel(CompatibilityLevel.Version_180)
    .UseMemoryStorage());
builder.Services.AddHangfireServer();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("AllowAll");

app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(Path.Combine(app.Environment.ContentRootPath, "wwwroot")),
    RequestPath = "",
    ServeUnknownFileTypes = true,
    DefaultContentType = "application/octet-stream"
});

app.UseHangfireDashboard();

app.MapControllers();

app.MapGet("/health", () => "Backend AR Model Server v1.0 - Ready!");

var ip = System.Net.Dns.GetHostEntry(System.Net.Dns.GetHostName())
    .AddressList.FirstOrDefault(ip => ip.AddressFamily == System.Net.Sockets.AddressFamily.InterNetwork)?.ToString() ?? "localhost";

app.Lifetime.ApplicationStarted.Register(() => {
    Console.WriteLine("=== AR Backend Server Started ===");
    Console.WriteLine($"Local: http://localhost:5000/swagger");
    Console.WriteLine($"Network: http://{ip}:5000 (for phone - open firewall port 5000)");
    Console.WriteLine($"Health: http://{ip}:5000/health");
    Console.WriteLine($"List: http://{ip}:5000/api/model");
    Console.WriteLine($"Upload: POST http://{ip}:5000/api/model/process (form-data: file=.fbx, projectId=string)");
    Console.WriteLine($"Hangfire: http://{ip}:5000/hangfire");
    Console.WriteLine("=================================");
});

app.Run("http://0.0.0.0:5000");

