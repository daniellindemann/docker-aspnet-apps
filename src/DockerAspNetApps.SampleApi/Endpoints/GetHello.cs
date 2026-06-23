using DockerAspNetApps.SampleApi.Common;
using DockerAspNetApps.SampleApi.Options;

using Microsoft.Extensions.Options;

namespace DockerAspNetApps.SampleApi.Endpoints;

public class GetHello : IEndpoint
{
    public static void Map(IEndpointRouteBuilder app)
    {
        app.MapGet("/hello", Handle)
            .WithName("GetHello")
            .WithSummary("Get a hello message")
            .WithDescription("Get a hello message with the name of the person to greet");
    }

    public record Response(string Greeting);

    public static async Task<Response> Handle(IOptions<GreetingsOptions> appOptions, ILogger<GetHello> logger)
    {
        logger.LogInformation("Return hello");

        return new Response($"Hello {appOptions.Value.To}");
    }
}