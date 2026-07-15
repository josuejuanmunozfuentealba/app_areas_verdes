@echo off
cd /d "%~dp0"
echo Iniciando servidor en puerto 3000...
echo NO CIERRES ESTA VENTANA
echo.
node server.js
echo.
echo El servidor se detuvo. Presiona cualquier tecla para cerrar.
pause
