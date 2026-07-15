@echo off
REM Script de diagnóstico para verificar el estado del servidor

echo ============================================
echo  DIAGNOSTICO DEL SERVIDOR PYTHON
echo ============================================
echo.

REM Verificar Python
echo [1/5] Verificando Python...
python --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [X] ERROR: Python no esta instalado
    echo.
    echo SOLUCION: Instala Python desde https://www.python.org/downloads/
    echo.
    pause
    exit /b 1
) else (
    python --version
    echo [OK] Python encontrado
)
echo.

REM Verificar archivo servidor.py
echo [2/5] Verificando servidor.py...
if not exist "servidor.py" (
    echo [X] ERROR: No se encuentra servidor.py
    echo.
    echo SOLUCION: Asegurate de estar en la carpeta correcta del proyecto
    echo.
    pause
    exit /b 1
) else (
    echo [OK] servidor.py encontrado
)
echo.

REM Verificar puerto 3000
echo [3/5] Verificando si el puerto 3000 esta ocupado...
netstat -ano | findstr ":3000" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [!] ADVERTENCIA: Puerto 3000 ya esta en uso
    echo.
    echo Procesos usando puerto 3000:
    netstat -ano | findstr ":3000"
    echo.
    echo SOLUCION: Cierra el proceso o usa un puerto diferente
    echo.
) else (
    echo [OK] Puerto 3000 disponible
)
echo.

REM Verificar directorio build/web
echo [4/5] Verificando directorio build/web...
if not exist "build\web" (
    echo [!] ADVERTENCIA: No se encuentra build\web
    echo.
    echo SOLUCION: Ejecuta primero: flutter build web
    echo.
) else (
    echo [OK] Directorio build\web encontrado
)
echo.

REM Verificar que no haya otro servidor Python corriendo
echo [5/5] Verificando procesos Python...
tasklist | findstr /I "python.exe" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [!] Procesos Python activos:
    tasklist | findstr /I "python.exe"
    echo.
    echo Si alguno de estos es el servidor, ya esta corriendo
) else (
    echo [OK] No hay procesos Python activos
)
echo.

echo ============================================
echo  DIAGNOSTICO COMPLETO
echo ============================================
echo.
echo SIGUIENTES PASOS:
echo.
echo 1. Si el puerto 3000 esta libre:
echo    - Ejecuta: iniciar_servidor.bat
echo.
echo 2. Si el puerto esta ocupado:
echo    - Cierra el proceso que lo usa
echo    - O cambia el puerto en servidor.py
echo.
echo 3. Si build/web no existe:
echo    - Ejecuta: flutter build web
echo    - Luego: iniciar_servidor.bat
echo.
echo 4. Para probar la conexion:
echo    - Abre: http://localhost:3000/api/health
echo    - Deberia responder: {"status": "ok", ...}
echo.
echo ============================================
echo.
pause
