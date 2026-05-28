@echo off
echo ========================================
echo LIMPIAR CACHE DE CHROME
echo ========================================
echo.
echo Este script cerrara Chrome y limpiara su cache
echo para que la aplicacion cargue la version mas reciente.
echo.
pause

echo.
echo [1/3] Cerrando Chrome...
taskkill /F /IM chrome.exe >nul 2>&1
timeout /t 2 /nobreak >nul

echo [2/3] Limpiando cache de Chrome...
set CHROME_CACHE=%LocalAppData%\Google\Chrome\User Data\Default\Cache
set CHROME_CACHE2=%LocalAppData%\Google\Chrome\User Data\Default\Code Cache

if exist "%CHROME_CACHE%" (
    rd /s /q "%CHROME_CACHE%" 2>nul
    echo Cache principal eliminado
)

if exist "%CHROME_CACHE2%" (
    rd /s /q "%CHROME_CACHE2%" 2>nul
    echo Code Cache eliminado
)

echo.
echo [3/3] Cache limpiado correctamente
echo.
echo Ahora puede ejecutar la aplicacion normalmente.
echo La primera carga puede ser un poco mas lenta.
echo.
pause
