using DockerAspNetApps.SampleApi.Common;

namespace DockerAspNetApps.SampleApi.Endpoints;

public class GetArchitecture : IEndpoint
{
    public static void Map(IEndpointRouteBuilder app)
    {
        app.MapGet("/architecture", Handle)
            .WithName("GetArchitecture")
            .WithSummary("Get he architecture of the hostt machine")
            .WithDescription("Get the architecture of the host machine with OS and uname information");
    }

    public record Response(string OperatingSystem, string Architecture, string unameInfo);

    public static async Task<Response> Handle(OsInformationRetriever osInformationRetriever, ILogger<GetArchitecture> logger)
    {
        logger.LogInformation("Return architecture");

        return new Response(osInformationRetriever.GetOsString(),
            osInformationRetriever.GetArchitecture(),
            osInformationRetriever.GetUnameString());
    }
}