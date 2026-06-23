using DockerAspNetApps.SampleApi.Common;
using DockerAspNetApps.SampleApi.Endpoints;

namespace DockerAspNetApps.SampleApi;

public static class EndpointExtensions
{
    public static void MapEndpoints(this WebApplication app)
    {
        app.MapGroup(string.Empty)
            .MapEndpoint<GetArchitecture>()
            .MapEndpoint<GetHello>();
    }

    private static IEndpointRouteBuilder MapEndpoint<TEndpoint>(this IEndpointRouteBuilder app) where TEndpoint : IEndpoint
    {
        TEndpoint.Map(app);
        return app;
    }
}