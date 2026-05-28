$WshShell = New-Object -ComObject WScript.Shell 
$Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\Áreas Verdes Doñihue.lnk") 
$Shortcut.TargetPath = "$PSScriptRoot\ejecutar.vbs" 
$Shortcut.WorkingDirectory = "$PSScriptRoot" 
$Shortcut.IconLocation = "$PSScriptRoot\assets\iconoescri.ico" 
$Shortcut.Description = "Áreas Verdes Doñihue v12.5" 
$Shortcut.Save() 
Write-Host "Acceso directo creado en el escritorio" 
