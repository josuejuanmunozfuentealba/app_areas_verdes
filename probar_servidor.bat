@echo off
cls
echo ============================================
echo  PRUEBA DEL SERVIDOR PYTHON
echo ============================================
echo.
echo Este script verifica si el servidor esta activo en puerto 3000
echo.

REM Verificar si curl está disponible
curl --version >nul 2>&1
if errorlevel 1 (
    echo NOTA: curl no esta disponible, intentando con PowerShell...
    echo.
    
    REM Usar PowerShell como alternativa
    powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:3000/api/health' -UseBasicParsing; Write-Host ''; Write-Host 'RESULTADO DE LA PRUEBA:'; Write-Host '========================================'; Write-Host $response.Content; Write-Host '========================================'; Write-Host ''; Write-Host 'Estado HTTP:' $response.StatusCode; if($response.StatusCode -eq 200) { Write-Host ''; Write-Host 'EXITO: El servidor Python esta funcionando correctamente' -ForegroundColor Green; Write-Host ''; Write-Host 'Puedes usar la aplicacion ahora.'; } } catch { Write-Host ''; Write-Host 'ERROR: No se pudo conectar al servidor' -ForegroundColor Red; Write-Host ''; Write-Host 'Posibles causas:'; Write-Host '1. El servidor no esta iniciado'; Write-Host '2. El servidor se cerro por un error'; Write-Host '3. El puerto 3000 esta ocupado por otro proceso'; Write-Host ''; Write-Host 'Solucion: Ejecuta iniciar_servidor.bat primero'; Write-Host ''; }"
    
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
        echo 3. El puerto 3000 esta ocupado
        echo.
        echo Solucion: Ejecuta iniciar_servidor.bat primero
        echo.
    ) else (
        echo.
        echo ============================================
        echo EXITO: El servidor esta funcionando
        echo ============================================
        echo.
        echo Puedes usar la aplicacion ahora.
        echo.
    )
)

echo.
pause
