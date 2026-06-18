# Crea un acceso directo en el escritorio que apunta al ejecutable de Windows
$desktop = [System.Environment]::GetFolderPath('Desktop')
$linkPath = Join-Path $desktop 'Áreas Verdes Donihue.lnk'

# Ruta al ejecutable construido
$exePath = Join-Path $PSScriptRoot 'build\windows\x64\runner\Release\app_areas_verdes.exe'
$iconPath = Join-Path $PSScriptRoot 'assets\iconoescri.ico'

if (-not (Test-Path $exePath)) {
    Write-Error "No se encontró el ejecutable en: $exePath"
    exit 1
}

if (Test-Path $linkPath) {
    Remove-Item $linkPath -Force
}

$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($linkPath)
$Shortcut.TargetPath = $exePath
$Shortcut.WorkingDirectory = Split-Path $exePath -Parent
$Shortcut.IconLocation = $iconPath
$Shortcut.Description = 'Áreas Verdes Donihue'
$Shortcut.Save()

Write-Host "Acceso directo creado en el escritorio: $linkPath"