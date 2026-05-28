@echo off
echo ========================================
echo Compilando Instalador con Inno Setup
echo ========================================
echo.

REM Verificar si Inno Setup está instalado
if exist "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" (
    echo Inno Setup encontrado. Compilando...
    echo.
    "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" installer_setup.iss
    echo.
    if %ERRORLEVEL% EQU 0 (
        echo ========================================
        echo Instalador creado exitosamente!
        echo Ubicacion: installer_output\AreasVerdesDoñihue_Setup_v12.5.exe
        echo ========================================
    ) else (
        echo ========================================
        echo ERROR: No se pudo compilar el instalador
        echo Verifique el archivo installer_setup.iss
        echo ========================================
    )
) else (
    echo ========================================
    echo ERROR: Inno Setup no está instalado
    echo ========================================
    echo.
    echo Por favor, instale Inno Setup desde:
    echo https://jrsoftware.org/isdl.php
    echo.
    echo Despues de instalar, ejecute este script nuevamente.
    echo ========================================
)

echo.
pause
