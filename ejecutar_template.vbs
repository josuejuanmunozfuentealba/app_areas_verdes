Dim oShell, oFSO, scriptPath, appPath
Set oShell = CreateObject("WScript.Shell")
Set oFSO = CreateObject("Scripting.FileSystemObject")

' Obtener la ruta donde está este script
scriptPath = oFSO.GetParentFolderName(WScript.ScriptFullName)

' Ejecutar precarga.hta desde la misma carpeta
oShell.Run "mshta.exe """ & scriptPath & "\precarga.hta""", 1, False
