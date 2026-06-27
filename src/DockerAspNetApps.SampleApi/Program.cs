using DockerAspNetApps.SampleApi;
using DockerAspNetApps.SampleApi.Options;
using DockerAspNetApps.SampleApi.SystemInfo;

using Microsoft.Extensions.Logging.Console;

var builder = WebApplication.CreateBuilder(args);

// configure logging
if (builder.Environment.IsProduction())
{
    builder.Logging.ClearProviders();
    // https://learn.microsoft.com/en-us/dotnet/core/extensions/console-log-formatter
    builder.Logging.AddConsole(options => options.FormatterName = ConsoleFormatterNames.Json);
}
else
{
    builder.Logging.ClearProviders();
    builder.Logging.AddConsole();
}

// Add custom configurations that can be changed by environment settings
builder.Services.AddOptions<GreetingsOptions>()
    .BindConfiguration(GreetingsOptions.PropertyName)
    .ValidateDataAnnotations()
    .ValidateOnStart();

// https://learn.microsoft.com/en-us/aspnet/core/host-and-deploy/health-checks
builder.Services.AddHealthChecks();

// add other services
builder.Services.AddSingleton<OsInformationRetriever>();
builder.Services.AddSingleton<DotNetInformationRetriever>();
builder.Services.AddSingleton<FileTree>();

// NOT REQUIRED
// Add services to the container.
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
// builder.Services.AddOpenApi();

// add cors config
// allow everything
// Let the platform handle cors
builder.Services.AddCors(options => options.AddDefaultPolicy(policy => policy.AllowAnyHeader()
    .AllowAnyMethod()
    .AllowAnyOrigin()));

var app = builder.Build();

// NOT REQUIRED
// Configure the HTTP request pipeline.
// if (app.Environment.IsDevelopment())
// {
//     app.MapOpenApi();
// }

// let the platform handle https redirection, if needed
// app.UseHttpsRedirection();

app.UseCors();  // use cors

app.MapEndpoints();

app.MapHealthChecks("/healthz");

app.Run();
