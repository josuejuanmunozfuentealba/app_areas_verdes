@echo off
cls
echo ============================================
echo  PRUEBA DEL SERVIDOR DE CORREOS
echo ============================================
echo.
echo Este script verifica si el servidor esta activo
echo.

REM Verificar si curl está disponible
curl --version >nul 2>&1
if errorlevel 1 (
    echo NOTA: curl no esta disponible, intentando alternativa...
    echo.
    
    REM Usar PowerShell como alternativa
    powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:3000/api/health' -UseBasicParsing; Write-Host ''; Write-Host 'RESULTADO:'; Write-Host '========================================'; Write-Host $response.Content; Write-Host '========================================'; Write-Host ''; Write-Host 'Estado HTTP:' $response.StatusCode; if($response.StatusCode -eq 200) { Write-Host ''; Write-Host 'EXITO: El servidor esta funcionando correctamente' -ForegroundColor Green } } catch { Write-Host ''; Write-Host 'ERROR: No se pudo conectar al servidor' -ForegroundColor Red; Write-Host ''; Write-Host 'Posibles causas:'; Write-Host '1. El servidor no esta iniciado'; Write-Host '2. El servidor se cerro por un error'; Write-Host '3. El puerto 3000 esta bloqueado'; Write-Host ''; Write-Host 'Solucion: Ejecuta INICIAR_SERVIDOR.bat primero' }"
    
) else (
    echo Probando conexion a http://localhost:3000/api/health
    echo.
    curl -s http://localhost:3000/api/health
    
    if errorlevel 1 (
        echo.
        echo ============================================
        echo ERROR: No se pudo conectar al servidor
        echo ============================================
        echo.
        echo Posibles causas:
        echo 1. El servidor no esta iniciado
        echo 2. El servidor se cerro por un error
        echo 3. El puerto 3000 esta bloqueado
        echo.
        echo Solucion: Ejecuta INICIAR_SERVIDOR.bat primero
        echo.
    ) else (
        echo.
        echo ============================================
        echo EXITO: El servidor esta funcionando
        echo ============================================
        echo.
    )
)

echo.
pause
