@echo off
echo ========================================
echo Creando instalador de Areas Verdes Donihue
echo ========================================
echo.

REM Crear carpeta de distribucion
if exist "distribucion" rmdir /s /q "distribucion"
mkdir "distribucion"
mkdir "distribucion\AreasVerdesDoñihue"

echo Copiando archivos...

REM Copiar build web
xcopy "build\web" "distribucion\AreasVerdesDoñihue\build\web\" /E /I /Y

REM Copiar scripts
copy "ejecutar.vbs" "distribucion\AreasVerdesDoñihue\" /Y
copy "ejecutar.bat" "distribucion\AreasVerdesDoñihue\" /Y
copy "precarga.hta" "distribucion\AreasVerdesDoñihue\" /Y
copy "servidor.py" "distribucion\AreasVerdesDoñihue\" /Y

REM Copiar datos
copy "historial_data.json" "distribucion\AreasVerdesDoñihue\" /Y

REM Copiar assets
xcopy "assets" "distribucion\AreasVerdesDoñihue\assets\" /E /I /Y

REM Crear archivo README
echo Áreas Verdes Doñihue - Versión 12.5 > "distribucion\AreasVerdesDoñihue\LEEME.txt"
echo ====================================== >> "distribucion\AreasVerdesDoñihue\LEEME.txt"
echo. >> "distribucion\AreasVerdesDoñihue\LEEME.txt"
echo Desarrollado por: Josué Juan Muñoz Fuentealba >> "distribucion\AreasVerdesDoñihue\LEEME.txt"
echo Año: 2026 >> "distribucion\AreasVerdesDoñihue\LEEME.txt"
echo. >> "distribucion\AreasVerdesDoñihue\LEEME.txt"
echo REQUISITOS: >> "distribucion\AreasVerdesDoñihue\LEEME.txt"
echo - Python 3.x instalado en el sistema >> "distribucion\AreasVerdesDoñihue\LEEME.txt"
echo - Navegador web predeterminado del sistema >> "distribucion\AreasVerdesDoñihue\LEEME.txt"
echo. >> "distribucion\AreasVerdesDoñihue\LEEME.txt"
echo INSTALACION: >> "distribucion\AreasVerdesDoñihue\LEEME.txt"
echo 1. Copie la carpeta AreasVerdesDoñihue a C:\Program Files\ >> "distribucion\AreasVerdesDoñihue\LEEME.txt"
echo 2. Ejecute instalar.bat para crear el acceso directo >> "distribucion\AreasVerdesDoñihue\LEEME.txt"
echo. >> "distribucion\AreasVerdesDoñihue\LEEME.txt"
echo EJECUCION: >> "distribucion\AreasVerdesDoñihue\LEEME.txt"
echo - Haga doble clic en el icono del escritorio >> "distribucion\AreasVerdesDoñihue\LEEME.txt"
echo - O ejecute ejecutar.vbs directamente >> "distribucion\AreasVerdesDoñihue\LEEME.txt"

REM Crear script de instalacion
echo @echo off > "distribucion\AreasVerdesDoñihue\instalar.bat"
echo echo Creando acceso directo en el escritorio... >> "distribucion\AreasVerdesDoñihue\instalar.bat"
echo powershell -ExecutionPolicy Bypass -File crear_acceso_directo.ps1 >> "distribucion\AreasVerdesDoñihue\instalar.bat"
echo echo. >> "distribucion\AreasVerdesDoñihue\instalar.bat"
echo echo Instalacion completada! >> "distribucion\AreasVerdesDoñihue\instalar.bat"
echo pause >> "distribucion\AreasVerdesDoñihue\instalar.bat"

REM Crear script PowerShell para acceso directo
echo $WshShell = New-Object -ComObject WScript.Shell > "distribucion\AreasVerdesDoñihue\crear_acceso_directo.ps1"
echo $Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\Áreas Verdes Doñihue.lnk") >> "distribucion\AreasVerdesDoñihue\crear_acceso_directo.ps1"
echo $Shortcut.TargetPath = "$PSScriptRoot\ejecutar.vbs" >> "distribucion\AreasVerdesDoñihue\crear_acceso_directo.ps1"
echo $Shortcut.WorkingDirectory = "$PSScriptRoot" >> "distribucion\AreasVerdesDoñihue\crear_acceso_directo.ps1"
echo $Shortcut.IconLocation = "$PSScriptRoot\assets\iconoescri.ico" >> "distribucion\AreasVerdesDoñihue\crear_acceso_directo.ps1"
echo $Shortcut.Description = "Áreas Verdes Doñihue v12.5" >> "distribucion\AreasVerdesDoñihue\crear_acceso_directo.ps1"
echo $Shortcut.Save() >> "distribucion\AreasVerdesDoñihue\crear_acceso_directo.ps1"
echo Write-Host "Acceso directo creado en el escritorio" >> "distribucion\AreasVerdesDoñihue\crear_acceso_directo.ps1"

echo.
echo Comprimiendo archivos...
powershell -Command "Compress-Archive -Path 'distribucion\AreasVerdesDoñihue' -DestinationPath 'AreasVerdesDoñihue_v12.5_Instalador.zip' -Force"

echo.
echo ========================================
echo Instalador creado exitosamente!
echo Archivo: AreasVerdesDoñihue_v12.5_Instalador.zip
echo ========================================
echo.
pause
