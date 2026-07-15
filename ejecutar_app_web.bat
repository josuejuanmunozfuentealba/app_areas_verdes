@echo off
REM Script para ejecutar la aplicación web Flutter con Chrome sin restricciones CORS

echo ============================================
echo  EJECUTAR APP WEB - SIN RESTRICCIONES CORS
echo ============================================
echo.

REM Verificar que el servidor está corriendo
echo [1/3] Verificando servidor Python...
curl -s http://localhost:3000/api/health >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [!] ADVERTENCIA: Servidor Python no esta corriendo
    echo.
    echo SOLUCION: Abre otra ventana CMD y ejecuta:
    echo    iniciar_servidor.bat
    echo.
    echo Presiona cualquier tecla para continuar de todas formas...
    pause >nul
) else (
    echo [OK] Servidor Python corriendo en puerto 3000
)
echo.

REM Cerrar todas las instancias de Chrome
echo [2/3] Cerrando Chrome...
taskkill /F /IM chrome.exe >nul 2>&1
timeout /t 2 /nobreak >nul
echo [OK] Chrome cerrado
echo.

REM Ejecutar Flutter Web con Chrome sin CORS
echo [3/3] Iniciando aplicacion Flutter Web...
echo.
echo IMPORTANTE:
echo - Chrome se abrira SIN restricciones de seguridad
echo - Solo usar para DESARROLLO
echo - NO navegues por internet con esta ventana
echo.
echo ============================================
echo.

REM Iniciar Flutter con Chrome en modo desarrollo (sin CORS)
flutter run -d chrome --web-browser-flag "--disable-web-security" --web-browser-flag "--user-data-dir=C:\ChromeDevSession" --web-browser-flag "--disable-features=IsolateOrigins,site-per-process"

pause
