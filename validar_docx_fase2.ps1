# Script de validacion estructural del DOCX Fase 2
Write-Host "=== VALIDACION ESTRUCTURAL DOCX FASE 2 ===" -ForegroundColor Cyan
Write-Host ""

$docxPath = "docx_prueba_fase2.docx"

if (-not (Test-Path $docxPath)) {
    Write-Host "ERROR: No se encuentra $docxPath" -ForegroundColor Red
    exit 1
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead($docxPath)

$checks = @()

# 1. Verificar existencia de word/media/image1.png
$imageEntry = $zip.GetEntry("word/media/image1.png")
if ($imageEntry) {
    $checks += @{Check="Existe word/media/image1.png"; Status=$true; Details="Tamano: $($imageEntry.Length) bytes"}
} else {
    $checks += @{Check="Existe word/media/image1.png"; Status=$false; Details="No encontrado"}
}

# 2. Verificar word/_rels/document.xml.rels
$relsEntry = $zip.GetEntry("word/_rels/document.xml.rels")
if ($relsEntry) {
    $stream = $relsEntry.Open()
    $reader = New-Object System.IO.StreamReader($stream)
    $relsContent = $reader.ReadToEnd()
    $reader.Close()
    $stream.Close()
    
    if ($relsContent -match 'Id="rId1".*Target="media/image1\.png"') {
        $checks += @{Check="Relacion rId1 a media/image1.png"; Status=$true; Details="Correcta"}
    } else {
        $checks += @{Check="Relacion rId1 a media/image1.png"; Status=$false; Details="No encontrada"}
    }
} else {
    $checks += @{Check="Existe document.xml.rels"; Status=$false; Details="No encontrado"}
}

# 3. Verificar Content Types incluye PNG
$ctEntry = $zip.GetEntry("[Content_Types].xml")
if ($ctEntry) {
    $stream = $ctEntry.Open()
    $reader = New-Object System.IO.StreamReader($stream)
    $ctContent = $reader.ReadToEnd()
    $reader.Close()
    $stream.Close()
    
    if ($ctContent -match 'Extension="png".*ContentType="image/png"') {
        $checks += @{Check="Content Type PNG declarado"; Status=$true; Details="Correcto"}
    } else {
        $checks += @{Check="Content Type PNG declarado"; Status=$false; Details="No encontrado"}
    }
} else {
    $checks += @{Check="Existe Content_Types.xml"; Status=$false; Details="No encontrado"}
}

# 4. Verificar document.xml usa rId1
$docEntry = $zip.GetEntry("word/document.xml")
if ($docEntry) {
    $stream = $docEntry.Open()
    $reader = New-Object System.IO.StreamReader($stream)
    $docContent = $reader.ReadToEnd()
    $reader.Close()
    $stream.Close()
    
    if ($docContent -match 'r:embed="rId1"') {
        $checks += @{Check='document.xml usa r:embed rId1'; Status=$true; Details="Correcto"}
    } else {
        $checks += @{Check='document.xml usa r:embed rId1'; Status=$false; Details="No encontrado"}
    }
    
    # Verificar namespaces DrawingML
    $hasWP = $docContent -match 'xmlns:wp='
    $hasA = $docContent -match 'xmlns:a='
    $hasPic = $docContent -match 'xmlns:pic='
    
    if ($hasWP -and $hasA -and $hasPic) {
        $checks += @{Check="Namespaces DrawingML correctos"; Status=$true; Details="wp, a, pic presentes"}
    } else {
        $checks += @{Check="Namespaces DrawingML correctos"; Status=$false; Details="Faltan namespaces"}
    }
    
    # Verificar titulo Fase 1
    if ($docContent -match '<w:t>[^<]*FICHA[^<]*</w:t>') {
        $checks += @{Check="Contenido Fase 1 presente"; Status=$true; Details="Titulo encontrado"}
    } else {
        $checks += @{Check="Contenido Fase 1 presente"; Status=$false; Details="Titulo no encontrado"}
    }
} else {
    $checks += @{Check="Existe word/document.xml"; Status=$false; Details="No encontrado"}
}

$zip.Dispose()

# Mostrar resultados
Write-Host "RESULTADOS DE VALIDACION:" -ForegroundColor Yellow
Write-Host ""

$allPassed = $true
foreach ($check in $checks) {
    if ($check.Status) {
        Write-Host "[OK] " -ForegroundColor Green -NoNewline
        Write-Host "$($check.Check): " -NoNewline
        Write-Host "$($check.Details)" -ForegroundColor Gray
    } else {
        Write-Host "[FALLO] " -ForegroundColor Red -NoNewline
        Write-Host "$($check.Check): " -NoNewline
        Write-Host "$($check.Details)" -ForegroundColor Red
        $allPassed = $false
    }
}

Write-Host ""
if ($allPassed) {
    Write-Host "=== VALIDACION EXITOSA ===" -ForegroundColor Green
    Write-Host "El DOCX tiene la estructura correcta." -ForegroundColor Green
    Write-Host ""
    Write-Host "SIGUIENTE PASO: Abrir en Microsoft Word para validacion visual" -ForegroundColor Cyan
} else {
    Write-Host "=== VALIDACION FALLIDA ===" -ForegroundColor Red
    Write-Host "Hay problemas estructurales en el DOCX." -ForegroundColor Red
}
