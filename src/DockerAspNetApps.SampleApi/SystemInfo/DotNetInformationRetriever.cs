using System.Runtime.InteropServices;

namespace DockerAspNetApps.SampleApi.SystemInfo;

public class DotNetInformationRetriever
{
    public string GetDotnetFramework()
    {
        return RuntimeInformation.FrameworkDescription;
    }

    public string GetDotnetRuntime()
    {
        return RuntimeInformation.RuntimeIdentifier;
    }
}
