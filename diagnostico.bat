@echo off
echo ========================================
echo DIAGNOSTICO - Areas Verdes Donihue
echo ========================================
echo.

echo [1/5] Verificando Python...
python --version >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [OK] Python encontrado:
    for /f "tokens=*" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
    echo %PYTHON_VERSION%
    
    REM Verificar si es el alias de Microsoft Store
    echo %PYTHON_VERSION% | findstr "26.2.240" >nul
    if %ERRORLEVEL% EQU 0 (
        echo.
        echo [ADVERTENCIA] Esto NO es Python real!
        echo Es el alias de Microsoft Store que redirige a la tienda.
        echo.
        echo SOLUCION:
        echo 1. Vaya a: Configuracion ^> Aplicaciones ^> Alias de ejecucion
        echo 2. Desactive python.exe y python3.exe
        echo 3. Descargue Python real desde: https://www.python.org/downloads/
        echo 4. Durante instalacion, marque "Add Python to PATH"
        echo 5. Reinicie el PC
        echo.
        echo Lea el archivo: SOLUCION_PYTHON_MICROSOFT_STORE.txt
        set PYTHON_OK=0
    ) else (
        set PYTHON_OK=1
    )
) else (
    echo [ERROR] Python NO encontrado en PATH
    echo.
    echo SOLUCION:
    echo 1. Descargue Python desde: https://www.python.org/downloads/
    echo 2. Durante la instalacion, marque "Add Python to PATH"
    echo 3. Reinicie el PC despues de instalar
    set PYTHON_OK=0
)
echo.

echo [2/5] Verificando Google Chrome...
if exist "C:\Program Files\Google\Chrome\Application\chrome.exe" (
    echo [OK] Chrome encontrado en: C:\Program Files\Google\Chrome\
) else if exist "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" (
    echo [OK] Chrome encontrado en: C:\Program Files (x86)\Google\Chrome\
) else (
    echo [ERROR] Chrome NO encontrado
    echo.
    echo SOLUCION:
    echo Descargue Chrome desde: https://www.google.com/chrome/
)
echo.

echo [3/5] Verificando carpeta de instalacion...
if exist "%ProgramFiles%\AreasVerdesDoñihue" (
    echo [OK] Aplicacion instalada en: %ProgramFiles%\AreasVerdesDoñihue
    cd /d "%ProgramFiles%\AreasVerdesDoñihue"
) else if exist "%LocalAppData%\Programs\AreasVerdesDoñihue" (
    echo [OK] Aplicacion instalada en: %LocalAppData%\Programs\AreasVerdesDoñihue
    cd /d "%LocalAppData%\Programs\AreasVerdesDoñihue"
) else (
    echo [ERROR] Aplicacion NO encontrada
    echo Por favor, instale la aplicacion primero
    goto :end
)
echo.

echo [4/5] Verificando archivos necesarios...
set ARCHIVOS_OK=1
if exist "servidor.py" (
    echo [OK] servidor.py
) else (
    echo [ERROR] servidor.py NO encontrado
    set ARCHIVOS_OK=0
)

if exist "build\web\index.html" (
    echo [OK] build\web\index.html
) else (
    echo [ERROR] build\web\index.html NO encontrado
    set ARCHIVOS_OK=0
)

if exist "ejecutar.vbs" (
    echo [OK] ejecutar.vbs
) else (
    echo [ERROR] ejecutar.vbs NO encontrado
    set ARCHIVOS_OK=0
)

if exist "precarga.hta" (
    echo [OK] precarga.hta
) else (
    echo [ERROR] precarga.hta NO encontrado
    set ARCHIVOS_OK=0
)

if %ARCHIVOS_OK% EQU 0 (
    echo.
    echo [ERROR] Faltan archivos. Reinstale la aplicacion.
)
echo.

echo [5/5] Probando servidor Python...
if defined PYTHON_OK (
    if %PYTHON_OK% EQU 1 (
        echo Iniciando servidor de prueba...
        timeout /t 2 /nobreak >nul
        start /min python servidor.py
        timeout /t 3 /nobreak >nul
        
        netstat -ano | findstr :8080 >nul
        if %ERRORLEVEL% EQU 0 (
            echo [OK] Servidor Python iniciado correctamente en puerto 8080
            echo.
            echo Abriendo navegador de prueba...
            start chrome http://localhost:8080
            echo.
            echo Si la aplicacion se abrio correctamente, el problema esta resuelto.
            echo Si no se abrio, presione Ctrl+C y revise los errores anteriores.
        ) else (
            echo [ERROR] Servidor Python NO pudo iniciar
            echo.
            echo Posibles causas:
            echo - Puerto 8080 ocupado por otra aplicacion
            echo - Python no tiene permisos
            echo - Falta algun modulo de Python
        )
    ) else (
        echo [OMITIDO] Python no es valido (alias de Microsoft Store)
    )
) else (
    echo [OMITIDO] Python no esta disponible
)

:end
echo.
echo ========================================
echo Diagnostico completado
echo ========================================
echo.
echo Si hay errores, copie este resultado y envielo para ayuda.
echo.
pause
