using System.Diagnostics;
using System.Runtime.InteropServices;

namespace DockerAspNetApps.SampleApi.SystemInfo;

public class OsInformationRetriever
{
    public string GetOsString()
    {
        string os = "other";
        
        if(RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
            os = OSPlatform.Linux.ToString();
        else if(RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
            os = OSPlatform.OSX.ToString();
        else if(RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
            os = OSPlatform.Windows.ToString();
        else if(RuntimeInformation.IsOSPlatform(OSPlatform.FreeBSD))
            os = OSPlatform.FreeBSD.ToString();
        
        return os.ToLower();
    }

    public string GetArchitecture()
    {
        return RuntimeInformation.ProcessArchitecture.ToString().ToLower();
    }

    public string GetUnameString()
    {
        try
        {
            using Process? unameProcess = Process.Start(new ProcessStartInfo()
            {
                FileName = "uname",
                Arguments = "-a",
                UseShellExecute = false,
                RedirectStandardOutput = true,
                CreateNoWindow = true
            });

            if (unameProcess is null)
                return "ERR: uname not available";

            string output = unameProcess.StandardOutput.ReadToEnd();
            unameProcess.WaitForExit();

            return unameProcess.ExitCode == 0 ? output : "ERR: uname not available";
        }
        catch
        {
            return "ERR: uname not available";
        }
    }

    public string GetOsReleaseString()
    {
        return File.ReadAllText("/etc/os-release");
    }

    public string GetExecutingUser()
    {
        return Environment.UserName;
    } 
}
