@echo off
cd /d "C:\Users\HP PAVILION\app_areas_verdes"
echo Compilando Areas Verdes Donihue...
C:\src\flutter\bin\flutter.bat build web --release
echo.
echo Compilacion lista. Ahora usa el acceso directo para abrir la app.
pause
