# Script para limpiar caché de íconos de Windows PWA
# Ejecutar como Administrador (Click derecho → Ejecutar como administrador)

Write-Host "🧹 Limpiando caché de íconos de Windows..." -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# 1. Limpiar caché de íconos de Windows
Write-Host "`n[1/3] Limpiando caché de íconos..." -ForegroundColor Yellow
try {
    ie4uinit.exe -show
    ie4uinit.exe -ClearIconCache
    Write-Host "✅ Caché de íconos limpiada" -ForegroundColor Green
} catch {
    Write-Host "❌ Error al limpiar caché de íconos: $_" -ForegroundColor Red
}

# 2. Eliminar base de datos de íconos (IconCache.db)
Write-Host "`n[2/3] Eliminando base de datos de íconos..." -ForegroundColor Yellow
try {
    $iconCacheFiles = @(
        "$env:LOCALAPPDATA\IconCache.db",
        "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\iconcache_*.db"
    )
    
    foreach ($file in $iconCacheFiles) {
        if (Test-Path $file) {
            Remove-Item $file -Force -ErrorAction SilentlyContinue
            Write-Host "  ✅ Eliminado: $file" -ForegroundColor Green
        }
    }
    
    # Eliminar caché de miniaturas
    Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Windows\Explorer" -Filter "thumbcache_*.db" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    
    Write-Host "✅ Base de datos de íconos eliminada" -ForegroundColor Green
} catch {
    Write-Host "❌ Error al eliminar base de datos: $_" -ForegroundColor Red
}

# 3. Reiniciar Explorer para aplicar cambios
Write-Host "`n[3/3] Reiniciando Windows Explorer..." -ForegroundColor Yellow
try {
    Stop-Process -Name explorer -Force
    Start-Sleep -Seconds 2
    Start-Process explorer
    Write-Host "✅ Explorer reiniciado" -ForegroundColor Green
} catch {
    Write-Host "❌ Error al reiniciar Explorer: $_" -ForegroundColor Red
}

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "✅ ¡PROCESO COMPLETADO!" -ForegroundColor Green
Write-Host "`n📋 PRÓXIMOS PASOS:" -ForegroundColor Cyan
Write-Host "   1. Desinstala la PWA 'Áreas Verdes' si aún está instalada" -ForegroundColor White
Write-Host "   2. Abre el navegador y ve a: https://app-areas-verdes.vercel.app/" -ForegroundColor White
Write-Host "   3. Presiona Ctrl + Shift + R (recarga forzada)" -ForegroundColor White
Write-Host "   4. Reinstala la PWA desde el navegador" -ForegroundColor White
Write-Host "`n🎨 El nuevo ícono verde 'AV - I.M. Doñihue' debería aparecer ahora." -ForegroundColor Green
Write-Host "`nPresiona cualquier tecla para salir..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
