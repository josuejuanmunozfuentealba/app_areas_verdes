@echo off
REM Ejecuta el script PowerShell que crea el acceso directo en el escritorio.
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File "%~dp0crear_acceso_directo.ps1"
if %ERRORLEVEL% neq 0 pause
