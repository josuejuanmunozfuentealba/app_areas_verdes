@echo off
color 0A
echo ========================================
echo PRUEBA COMPLETA - PC 2
echo ========================================
echo.
echo Este script probara TODOS los componentes
echo y te dira exactamente que esta fallando.
echo.
pause
cls

echo ========================================
echo [1/7] VERIFICANDO PYTHON
echo ========================================
echo.

echo Probando "py --version":
py --version 2>&1
set PY_RESULT=%ERRORLEVEL%
echo Codigo de salida: %PY_RESULT%
echo.

echo Probando "python --version":
python --version 2>&1
set PYTHON_RESULT=%ERRORLEVEL%
echo Codigo de salida: %PYTHON_RESULT%
echo.

if %PY_RESULT% EQU 0 (
    echo [OK] py funciona correctamente
    set USAR_PY=1
) else if %PYTHON_RESULT% EQU 0 (
    echo [OK] python funciona correctamente
    set USAR_PY=0
) else (
    echo [ERROR] Ni py ni python funcionan
    echo.
    echo SOLUCION: Instale Python desde https://www.python.org/downloads/
    pause
    exit /b 1
)
echo.
pause

cls
echo ========================================
echo [2/7] VERIFICANDO CARPETA DE INSTALACION
echo ========================================
echo.

if exist "%ProgramFiles%\AreasVerdesDoñihue" (
    cd /d "%ProgramFiles%\AreasVerdesDoñihue"
    echo [OK] Carpeta encontrada: %CD%
) else if exist "%LocalAppData%\Programs\AreasVerdesDoñihue" (
    cd /d "%LocalAppData%\Programs\AreasVerdesDoñihue"
    echo [OK] Carpeta encontrada: %CD%
) else (
    echo [ERROR] Carpeta de instalacion NO encontrada
    pause
    exit /b 1
)
echo.

echo Verificando archivos:
if exist "servidor.py" (echo [OK] servidor.py) else (echo [ERROR] servidor.py FALTA)
if exist "build\web\index.html" (echo [OK] build\web\index.html) else (echo [ERROR] build\web\index.html FALTA)
if exist "assets\logoprecarga.png" (echo [OK] assets\logoprecarga.png) else (echo [ERROR] assets\logoprecarga.png FALTA)
echo.
pause

cls
echo ========================================
echo [3/7] VERIFICANDO PUERTO 8080
echo ========================================
echo.

netstat -ano | findstr :8080 >nul
if %ERRORLEVEL% EQU 0 (
    echo [ADVERTENCIA] Puerto 8080 YA esta en uso
    echo.
    netstat -ano | findstr :8080
    echo.
    echo Esto puede ser:
    echo 1. El servidor ya esta corriendo (OK)
    echo 2. Otra aplicacion usa el puerto (PROBLEMA)
) else (
    echo [OK] Puerto 8080 esta libre
)
echo.
pause

cls
echo ========================================
echo [4/7] INICIANDO SERVIDOR DE PRUEBA
echo ========================================
echo.

echo Matando procesos Python anteriores...
taskkill /F /IM python.exe >nul 2>&1
taskkill /F /IM py.exe >nul 2>&1
timeout /t 2 /nobreak >nul

echo Iniciando servidor...
if %USAR_PY% EQU 1 (
    echo Usando: py servidor.py
    start /min py servidor.py
) else (
    echo Usando: python servidor.py
    start /min python servidor.py
)

echo Esperando 5 segundos...
timeout /t 5 /nobreak

echo.
echo Verificando si el servidor inicio...
netstat -ano | findstr :8080 >nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] Servidor iniciado correctamente en puerto 8080
) else (
    echo [ERROR] Servidor NO inicio
    echo.
    echo Posibles causas:
    echo - Python no tiene permisos
    echo - Firewall bloquea Python
    echo - Falta algun modulo
    pause
    exit /b 1
)
echo.
pause

cls
echo ========================================
echo [5/7] PROBANDO CONEXION HTTP
echo ========================================
echo.

echo Intentando conectar a http://localhost:8080
echo.

powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:8080' -TimeoutSec 5; Write-Host '[OK] Servidor responde correctamente'; Write-Host 'Codigo de estado:' $response.StatusCode } catch { Write-Host '[ERROR] No se puede conectar al servidor'; Write-Host 'Error:' $_.Exception.Message }"

echo.
pause

cls
echo ========================================
echo [6/7] ABRIENDO CHROME
echo ========================================
echo.

echo Abriendo Chrome con la aplicacion...
start chrome http://localhost:8080

echo.
echo Chrome deberia abrirse ahora.
echo.
echo ¿Se abrio la aplicacion correctamente?
echo 1 = SI, funciona perfectamente
echo 2 = NO, Chrome no se abrio
echo 3 = Chrome se abrio pero muestra error
echo.
set /p CHROME_RESULT="Ingrese 1, 2 o 3: "

if "%CHROME_RESULT%"=="1" (
    echo.
    echo [EXITO] La aplicacion funciona correctamente!
    echo El problema estaba en como se iniciaba el servidor.
    echo.
    echo SOLUCION: Use el nuevo instalador que incluye iniciar_servidor.bat
) else if "%CHROME_RESULT%"=="2" (
    echo.
    echo [ERROR] Chrome no se abrio
    echo Verifique que Chrome este instalado
) else (
    echo.
    echo [ERROR] Chrome se abrio pero hay un error
    echo ¿Que error muestra Chrome?
    pause
)

echo.
pause

cls
echo ========================================
echo [7/7] LIMPIEZA
echo ========================================
echo.

echo Deteniendo servidor de prueba...
taskkill /F /IM python.exe >nul 2>&1
taskkill /F /IM py.exe >nul 2>&1

echo.
echo ========================================
echo PRUEBA COMPLETADA
echo ========================================
echo.
echo Si la aplicacion funciono en el PASO 6,
echo el problema esta resuelto.
echo.
echo Si NO funciono, revise los errores anteriores
echo y envielos para recibir ayuda.
echo.
pause
