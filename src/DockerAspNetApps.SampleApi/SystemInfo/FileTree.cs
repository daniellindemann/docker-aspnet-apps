namespace DockerAspNetApps.SampleApi.SystemInfo;

public class FileTree
{
    public string GetFileTree(string path, int depth = 0)
    {
        if (depth > 5) // Limit the depth to avoid too deep recursion
        {
            throw new ArgumentException("Depth exceeds the maximum allowed value of 5.", nameof(depth));
        }

        var indent = new string(' ', depth * 4);
        var result = $"{indent}{Path.GetFileName(path)}\n";

        if (Directory.Exists(path))
        {
            foreach (var dir in Directory.GetDirectories(path))
            {
                result += GetFileTree(dir, depth + 1);
            }

            foreach (var file in Directory.GetFiles(path))
            {
                result += $"{indent}  {Path.GetFileName(file)}\n";
            }
        }

        return result;
    }
}