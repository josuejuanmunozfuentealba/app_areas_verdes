@echo off
cls
echo ============================================
echo  SERVIDOR DE CORREOS - AREAS VERDES
echo ============================================
echo.

REM Cambiar al directorio del script
cd /d "%~dp0"

echo [1/3] Verificando Node.js...
node --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Node.js no esta instalado
    echo.
    echo Descarga Node.js desde: https://nodejs.org
    echo.
    pause
    exit /b 1
)
echo OK - Node.js instalado
echo.

echo [2/3] Verificando archivo server.js...
if not exist "server.js" (
    echo ERROR: No se encuentra server.js
    echo.
    echo Asegurate de estar en la carpeta email_server
    echo.
    pause
    exit /b 1
)
echo OK - server.js encontrado
echo.

echo [3/3] Iniciando servidor en puerto 3000...
echo.
echo IMPORTANTE:
echo - NO cierres esta ventana mientras uses la app
echo - Para detener el servidor presiona: Ctrl + C
echo.
echo ============================================
echo.

REM Ejecutar el servidor
node server.js

REM Si el servidor se detiene, mostrar mensaje
echo.
echo ============================================
echo El servidor se ha detenido
echo ============================================
echo.
pause
