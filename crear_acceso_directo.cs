using System;
using System.IO;

class Program
{
    static int Main()
    {
        try
        {
            var exeDir = AppContext.BaseDirectory;
            var desktop = Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory);
            var linkPath = Path.Combine(desktop, "Áreas Verdes Donihue.lnk");
            var wscriptPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Windows), "System32", "wscript.exe");
            var vbsPath = Path.Combine(exeDir, "ejecutar.vbs");
            var iconPath = Path.Combine(exeDir, "assets", "iconoescri.ico");

            if (File.Exists(linkPath))
            {
                File.Delete(linkPath);
            }

            var wshShellType = Type.GetTypeFromProgID("WScript.Shell");
            if (wshShellType == null)
            {
                Console.Error.WriteLine("Error: No se pudo crear el objeto WScript.Shell.");
                return 1;
            }

            dynamic wshShell = Activator.CreateInstance(wshShellType);
            dynamic shortcut = wshShell.CreateShortcut(linkPath);
            shortcut.TargetPath = wscriptPath;
            shortcut.Arguments = $"\"{vbsPath}\"";
            shortcut.WorkingDirectory = exeDir;
            shortcut.Description = "Áreas Verdes Donihue";
            shortcut.IconLocation = iconPath;
            shortcut.Save();

            Console.WriteLine("Acceso directo creado en el escritorio.");
            return 0;
        }
        catch (Exception ex)
        {
            Console.Error.WriteLine($"Error: {ex.Message}");
            return 1;
        }
    }
}
