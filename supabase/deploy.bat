@echo off
REM Script de deployment para Supabase Edge Functions
REM Proyecto: App Áreas Verdes Doñihue

echo.
echo ============================================
echo  DEPLOYMENT: Supabase Edge Function
echo  Proyecto: App Áreas Verdes Doñihue
echo ============================================
echo.

REM Verificar que Supabase CLI esté instalado
where supabase >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Supabase CLI no esta instalado
    echo.
    echo Instalar con: npm install -g supabase
    echo.
    pause
    exit /b 1
)

echo [OK] Supabase CLI detectado
echo.

REM Verificar que el proyecto esté linkeado
supabase projects list >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] No estas autenticado en Supabase
    echo.
    echo Ejecuta: supabase login
    echo.
    pause
    exit /b 1
)

echo [OK] Sesion de Supabase activa
echo.

REM Desplegar función
echo [INFO] Desplegando funcion convert-pdf-to-docx...
echo.

supabase functions deploy convert-pdf-to-docx

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Deployment fallido
    echo.
    pause
    exit /b 1
)

echo.
echo ============================================
echo  DEPLOYMENT EXITOSO
echo ============================================
echo.
echo La funcion esta disponible en:
echo https://speneggmlqitgfjhzsry.supabase.co/functions/v1/convert-pdf-to-docx
echo.
echo Proximo paso:
echo   1. Configurar CLOUDCONVERT_API_KEY si no lo has hecho:
echo      supabase secrets set CLOUDCONVERT_API_KEY=your_key
echo.
echo   2. Ver logs:
echo      supabase functions logs convert-pdf-to-docx
echo.
echo   3. Listar funciones:
echo      supabase functions list
echo.
pause
