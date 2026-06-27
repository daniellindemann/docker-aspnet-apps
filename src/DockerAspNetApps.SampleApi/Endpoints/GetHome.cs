using DockerAspNetApps.SampleApi.Common;

namespace DockerAspNetApps.SampleApi.Endpoints;

public class GetHome : IEndpoint
{
    public static void Map(IEndpointRouteBuilder app)
    {
        app.MapGet("/", Handle)
            .WithName("GetHome")
            .WithSummary("Get api info message")
            .WithDescription("Get api info message");
    }

    public static async Task<string> Handle(ILogger<GetHello> logger)
    {
        logger.LogInformation("Return api info message");

        return "Docker ASP.NET Apps Sample API";
    }
}
