@echo off
REM Script para iniciar el servidor Python en puerto 3000

REM Cambiar al directorio donde está este script
cd /d "%~dp0"

REM Crear archivo de log
set LOGFILE="%~dp0servidor_log.txt"
echo Iniciando servidor Python... > %LOGFILE%
echo Fecha: %date% %time% >> %LOGFILE%
echo. >> %LOGFILE%

cls
echo ============================================
echo  SERVIDOR PYTHON - AREAS VERDES
echo ============================================
echo.
echo Puerto: 3000
echo Directorio: %cd%
echo.

REM Verificar si Python está instalado
python --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Python no esta instalado
    echo.
    echo Por favor instale Python desde: https://www.python.org/downloads/
    echo.
    pause
    exit /b 1
)

echo [1/2] Python encontrado
python --version
echo.

REM Verificar si el archivo servidor.py existe
if not exist "servidor.py" (
    echo ERROR: No se encuentra servidor.py
    echo.
    echo Asegurate de estar en la carpeta correcta
    echo.
    pause
    exit /b 1
)

echo [2/2] Archivo servidor.py encontrado
echo.
echo ============================================
echo  INICIANDO SERVIDOR EN PUERTO 3000
echo ============================================
echo.
echo IMPORTANTE:
echo - NO cierres esta ventana mientras uses la app
echo - El servidor estara en: http://localhost:3000
echo - Para detener presiona: Ctrl + C
echo.
echo ============================================
echo.

REM Iniciar servidor
python servidor.py

REM Si el servidor se detiene, mostrar mensaje
echo.
echo ============================================
echo El servidor se ha detenido
echo ============================================
echo.
pause
