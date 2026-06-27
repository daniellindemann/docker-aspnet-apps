using DockerAspNetApps.SampleApi.Common;
using DockerAspNetApps.SampleApi.SystemInfo;

namespace DockerAspNetApps.SampleApi.Endpoints;

public class GetAppFileTree : IEndpoint
{
    public static void Map(IEndpointRouteBuilder app)
    {
        app.MapGet("/appfiletree", Handle)
            .WithName("GetAppFileTree")
            .WithSummary("Get the file tree of the application")
            .WithDescription("Get the file tree of the application");
    }
    
    public static async Task<string> Handle(FileTree fileTree, ILogger<GetAppFileTree> logger)
    {
        logger.LogInformation("Return application file tree");

        var applicationPath = AppContext.BaseDirectory;
        return fileTree.GetFileTree(applicationPath);
    }
}