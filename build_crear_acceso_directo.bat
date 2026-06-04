@echo off
setlocal
set SRC=crear_acceso_directo.cs
set OUT=crear_acceso_directo.exe

if exist "%OUT%" del /f /q "%OUT%"

where csc >nul 2>&1
if %ERRORLEVEL%==0 (
    echo Compilando %SRC% con csc...
    csc /nologo /out:%OUT% /target:exe %SRC%
    if %ERRORLEVEL%==0 (
        echo Ejecutable creado: %OUT%
        exit /b 0
    ) else (
        echo Error al compilar con csc.
        exit /b 1
    )
) else (
    echo No se encontró csc en el PATH.
    echo Instale el SDK de .NET Framework o agregue csc al PATH.
    exit /b 1
)
