@echo off
set "APP_DIR=%~dp0"

if exist "%APP_DIR%build\web\index.html" (
    echo Abriendo la aplicacion web sin dependencias de Python...
    start "" "%APP_DIR%build\web\index.html"
) else (
    echo No se encontro la carpeta build\web.
    echo Verifique que el instalador haya incluido los archivos web.
    pause
)
