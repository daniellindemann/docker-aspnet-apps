namespace DockerAspNetApps.SampleApi.SystemInfo;

using System.Text;

public class FileTree
{
    public string GetFileTree(string path, int depth = 0)
    {
        var (tree, _) = BuildTree(path, depth);
        return tree;
    }

    private static (string Tree, long Size) BuildTree(string path, int depth)
    {
        if (depth > 5)
        {
            throw new ArgumentException("Depth exceeds the maximum allowed value of 5.", nameof(depth));
        }

        var indent = new string(' ', depth * 4);

        if (File.Exists(path))
        {
            var fileInfo = new FileInfo(path);
            var fileName = Path.GetFileName(path);
            var line = $"{indent}{fileName} ({FormatSize(fileInfo.Length)})\n";
            return (line, fileInfo.Length);
        }

        if (!Directory.Exists(path))
        {
            throw new DirectoryNotFoundException($"Path does not exist: {path}");
        }

        var children = new StringBuilder();
        long totalSize = 0;

        foreach (var dir in Directory.GetDirectories(path))
        {
            var (childTree, childSize) = BuildTree(dir, depth + 1);
            children.Append(childTree);
            totalSize += childSize;
        }

        foreach (var file in Directory.GetFiles(path))
        {
            var fileInfo = new FileInfo(file);
            totalSize += fileInfo.Length;
            children.Append($"{indent}  {Path.GetFileName(file)} ({FormatSize(fileInfo.Length)})\n");
        }

        var name = Path.GetFileName(path);
        if (string.IsNullOrWhiteSpace(name))
        {
            name = path;
        }

        var currentLine = $"{indent}{name} ({FormatSize(totalSize)})\n";
        return ($"{currentLine}{children}", totalSize);
    }

    private static string FormatSize(long bytes)
    {
        string[] units = ["B", "KB", "MB", "GB", "TB", "PB"];
        double size = bytes;
        var unitIndex = 0;

        while (size >= 1024 && unitIndex < units.Length - 1)
        {
            size /= 1024;
            unitIndex++;
        }

        return unitIndex == 0
            ? $"{bytes} {units[unitIndex]}"
            : $"{size:0.##} {units[unitIndex]}";
    }
}