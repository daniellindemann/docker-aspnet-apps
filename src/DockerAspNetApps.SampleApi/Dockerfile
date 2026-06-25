FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 6780

ENV ASPNETCORE_URLS=http://+:6780

USER app

FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:10.0 AS build
ARG configuration=Release
WORKDIR /src/DockerAspNetApps.SampleApi

COPY ["DockerAspNetApps.SampleApi.csproj", ""]
RUN dotnet restore "/src/DockerAspNetApps.SampleApi/DockerAspNetApps.SampleApi.csproj"
COPY . .

RUN dotnet build "/src/DockerAspNetApps.SampleApi/DockerAspNetApps.SampleApi.csproj" -c $configuration -o /app/build

FROM build AS publish
ARG configuration=Release
RUN dotnet publish "DockerAspNetApps.SampleApi.csproj" -c $configuration -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "DockerAspNetApps.SampleApi.dll"]
