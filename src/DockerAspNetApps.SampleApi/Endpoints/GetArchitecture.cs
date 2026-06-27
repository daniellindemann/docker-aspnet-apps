using DockerAspNetApps.SampleApi.Common;
using DockerAspNetApps.SampleApi.SystemInfo;

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

    public record Response(string OperatingSystem, string Architecture, string ExecutingUser, string unameInfo, string osReleaseInfo, string DotnetFrameworkInfo, string DotnetRuntimeInfo);

    public static async Task<Response> Handle(OsInformationRetriever osInformationRetriever, DotNetInformationRetriever dotNetInformationRetriever, ILogger<GetArchitecture> logger)
    {
        logger.LogInformation("Return architecture");

        return new Response(osInformationRetriever.GetOsString(),
            osInformationRetriever.GetArchitecture(),
            osInformationRetriever.GetExecutingUser(),
            osInformationRetriever.GetUnameString(),
            osInformationRetriever.GetOsReleaseString(),
            dotNetInformationRetriever.GetDotnetFramework(),
            dotNetInformationRetriever.GetDotnetRuntime());
    }
}