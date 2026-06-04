# Elimina acceso directo anterior si existe
$desktop = [System.Environment]::GetFolderPath('Desktop')
$linkPath = Join-Path $desktop 'Áreas Verdes Donihue.lnk'
if (Test-Path $linkPath) { Remove-Item $linkPath -Force }

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$vbsPath = Join-Path $scriptDir 'ejecutar.vbs'
$iconPath = Join-Path $scriptDir 'assets\iconoescri.ico'
$wscriptPath = Join-Path $env:windir 'System32\wscript.exe'

if (-not (Test-Path $vbsPath)) {
    Write-Error "No se encontró el archivo VBS en: $vbsPath"
    exit 1
}

if (-not (Test-Path $iconPath)) {
    Write-Error "No se encontró el icono en: $iconPath"
    exit 1
}

# Crea nuevo acceso directo
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($linkPath)
$Shortcut.TargetPath = $wscriptPath
$Shortcut.Arguments = "`"$vbsPath`""
$Shortcut.WorkingDirectory = $scriptDir
$Shortcut.Description = 'Áreas Verdes Donihue'
$Shortcut.IconLocation = $iconPath
$Shortcut.Save()

Write-Host "Acceso directo creado en el escritorio: $linkPath"
