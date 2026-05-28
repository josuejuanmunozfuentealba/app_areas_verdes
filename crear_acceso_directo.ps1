# Elimina acceso directo anterior si existe
$desktop = [System.Environment]::GetFolderPath('Desktop')
$linkPath = "$desktop\Areas Verdes Donihue.lnk"
if (Test-Path $linkPath) { Remove-Item $linkPath -Force }

# Crea nuevo acceso directo
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($linkPath)
$Shortcut.TargetPath = "wscript.exe"
$Shortcut.Arguments = """C:\Users\HP PAVILION\app_areas_verdes\ejecutar.vbs"""
$Shortcut.WorkingDirectory = "C:\Users\HP PAVILION\app_areas_verdes"
$Shortcut.Description = "Areas Verdes Donihue"
$Shortcut.IconLocation = "C:\Users\HP PAVILION\app_areas_verdes\assets\iconoescri.ico, 0"
$Shortcut.Save()

Write-Host "Acceso directo creado en el escritorio."
