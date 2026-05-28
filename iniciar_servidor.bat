@echo off
REM Script para iniciar el servidor con el Python correcto

REM Cambiar al directorio donde está este script
cd /d "%~dp0"

REM Crear archivo de log
set LOGFILE="%~dp0servidor_log.txt"
echo Iniciando servidor... > %LOGFILE%
echo Fecha: %date% %time% >> %LOGFILE%
echo. >> %LOGFILE%

REM Intentar con py primero (Python Launcher)
py --version >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo Usando py launcher >> %LOGFILE%
    start /B py servidor.py >> %LOGFILE% 2>&1
    exit /b 0
)

REM Si py no funciona, intentar con python
python --version >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo Usando python >> %LOGFILE%
    start /B python servidor.py >> %LOGFILE% 2>&1
    exit /b 0
)

REM Si ninguno funciona, registrar error
echo ERROR: Python no encontrado >> %LOGFILE%
echo Por favor instale Python desde https://www.python.org/downloads/ >> %LOGFILE%
exit /b 1
