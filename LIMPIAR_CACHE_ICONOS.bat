@echo off
echo ============================================
echo LIMPIANDO CACHE DE ICONOS DE WINDOWS
echo ============================================
echo.

echo [1/4] Cerrando Explorer...
taskkill /f /im explorer.exe

echo.
echo [2/4] Eliminando base de datos de iconos...
del /f /s /q /a "%localappdata%\IconCache.db" 2>nul
del /f /s /q /a "%localappdata%\Microsoft\Windows\Explorer\iconcache*.db" 2>nul
del /f /s /q /a "%localappdata%\Microsoft\Windows\Explorer\thumbcache*.db" 2>nul

echo.
echo [3/4] Limpiando cache con ie4uinit...
ie4uinit.exe -show
ie4uinit.exe -ClearIconCache

echo.
echo [4/4] Reiniciando Explorer...
timeout /t 2 /nobreak >nul
start explorer.exe

echo.
echo ============================================
echo PROCESO COMPLETADO
echo ============================================
echo.
echo PROXIMOS PASOS:
echo 1. Desinstala "Areas Verdes" desde Configuracion - Aplicaciones
echo 2. Abre Chrome y ve a: https://app-areas-verdes.vercel.app/
echo 3. Presiona Ctrl + Shift + R (recarga forzada)
echo 4. Instala la PWA de nuevo
echo.
echo El icono verde "AV" deberia aparecer ahora.
echo.
pause
