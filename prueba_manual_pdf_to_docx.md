# 🧪 PRUEBA MANUAL: PDF → DOCX vía CloudConvert

## ⚠️ **IMPORTANTE: ANTES DE EMPEZAR**

Esta prueba requiere que la **Edge Function** esté desplegada y configurada.

### **PRE-REQUISITOS:**

1. **CloudConvert API Key obtenida:**
   - Registrarse en: https://cloudconvert.com/register
   - Ir a: https://cloudconvert.com/dashboard/api/v2/keys
   - Crear nueva API Key
   - Copiar la key

2. **Supabase CLI instalado:**
   ```powershell
   npm install -g supabase
   ```

3. **Edge Function desplegada:**
   ```bash
   cd "C:\Users\HP PAVILION\app_areas_verdes"
   supabase login
   supabase link --project-ref speneggmlqitgfjhzsry
   supabase secrets set CLOUDCONVERT_API_KEY=[tu_api_key_aqui]
   supabase functions deploy convert-pdf-to-docx
   ```

4. **Verificar deployment:**
   ```bash
   supabase functions list
   ```

---

## 🚀 **EJECUTAR PRUEBA**

### **Opción A: Probar desde la app real**

1. Ejecutar la app:
   ```bash
   flutter run
   ```

2. En la app:
   - Ir a una plaza
   - Abrir "Catastro de Inmuebles"
   - Llenar formulario con:
     - Inspector: "Prueba"
     - 7 evaluaciones (al menos 1 como Bueno, 1 Regular, 1 Malo)
     - Observaciones en cada criterio
     - **1 fotografía** con título personalizado
   - Presionar "Exportar PDF y Word"

3. Esperar proceso (puede tardar 1-2 minutos):
   - ✅ PDF se genera y descarga
   - ⏳ Conversión PDF→DOCX en curso (30-90 segundos)
   - ✅ DOCX se descarga

4. **Abrir el DOCX descargado** en Microsoft Word

---

### **Opción B: Probar con curl (más rápido)**

1. Generar un PDF de prueba desde la app primero

2. Codificar PDF a Base64:
   ```powershell
   $pdfBytes = [System.IO.File]::ReadAllBytes("C:\ruta\al\catastro.pdf")
   $pdfBase64 = [Convert]::ToBase64String($pdfBytes)
   $pdfBase64 | Out-File -FilePath "pdf_base64.txt"
   ```

3. Llamar a la Edge Function:
   ```powershell
   $headers = @{
       "Authorization" = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNwZW5lZ2dtbHFpdGdmamh6c3J5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY1MzUzMDksImV4cCI6MjEwMjExMTMwOX0.31WSG-j7m_TO4uGjmXW59jTrxrX7wFvHT8sHtY5zIQg"
       "Content-Type" = "application/json"
   }
   
   $pdfBase64 = Get-Content "pdf_base64.txt"
   
   $body = @{
       pdfBase64 = $pdfBase64
       filename = "test.pdf"
   } | ConvertTo-Json
   
   $response = Invoke-RestMethod `
       -Uri "https://speneggmlqitgfjhzsry.supabase.co/functions/v1/convert-pdf-to-docx" `
       -Method POST `
       -Headers $headers `
       -Body $body
   
   Write-Host "Response:"
   $response | ConvertTo-Json
   ```

4. Si funciona, obtendrás:
   ```json
   {
     "success": true,
     "docxUrl": "https://storage.cloudconvert.com/...",
     "docxFilename": "test.docx"
   }
   ```

5. Descargar el DOCX:
   ```powershell
   Invoke-WebRequest -Uri $response.docxUrl -OutFile "test_catastro.docx"
   ```

6. **Abrir test_catastro.docx** en Word

---

## ✅ **CHECKLIST DE VALIDACIÓN**

Abrir el DOCX generado en Microsoft Word y verificar:

### **📄 Contenido esperado:**

- [ ] **Título:** "CATASTRO DE INMUEBLES DE ÁREAS VERDES"
- [ ] **Subtítulo:** "Municipalidad de Doñihue"
- [ ] **Logo:** Aparece en esquina superior derecha
- [ ] **Información General:**
  - [ ] Plaza: [nombre]
  - [ ] ID: [codigo]
  - [ ] Inspector: [nombre]
  - [ ] Fecha/Hora: [timestamp]
  - [ ] Estado General: [Bueno/Regular/Malo]

### **📊 Tabla de Evaluaciones:**

- [ ] **Encabezados de tabla:** "Criterio", "Evaluación", "Observaciones"
- [ ] **7 filas de criterios:**
  1. [ ] Estado estructural de bancas
  2. [ ] Estado pintura bancas
  3. [ ] Estado estructural juegos infantiles
  4. [ ] Estado de pintura de juegos infantiles
  5. [ ] Estado llaves de paso/arranque de agua
  6. [ ] Estado estructural basureros
  7. [ ] Estado pintura de basureros
- [ ] **Columna "Evaluación":** Muestra Bueno/Regular/Malo
- [ ] **Columna "Observaciones":** Muestra texto de observaciones

### **📷 Anexo Fotográfico:**

- [ ] **Título sección:** "ANEXO FOTOGRÁFICO"
- [ ] **Fotografía visible:** Imagen se muestra correctamente
- [ ] **Título de foto:** Aparece el título personalizado (NO "Foto 1" genérico)
- [ ] **Nota de foto:** Aparece la nota debajo de la imagen

### **❌ Problemas que NO deben aparecer:**

- [ ] **NO hay páginas en blanco** extra
- [ ] **NO aparece código HTML** (`<html>`, `<div>`, etc.)
- [ ] **NO aparece código XML** (`<?xml>`, `<w:document>`, etc.)
- [ ] **NO aparece Base64** visible (`JVBERi0...`, `data:image/...`)
- [ ] **NO hay advertencias** de Word al abrir
- [ ] **NO hay errores** "El archivo está dañado"
- [ ] **NO hay contenido corrupto** o ilegible

---

## 📊 **RESULTADOS ESPERADOS**

### **Si TODO está correcto:**

```
✅ Título presente
✅ Logo visible
✅ Información general completa
✅ Tabla con 7 evaluaciones
✅ Observaciones visibles
✅ Fotografía visible con título real
✅ NO hay páginas en blanco
✅ NO hay código HTML/XML/Base64
✅ Word abre sin advertencias
```

**→ La estrategia PDF → DOCX funciona correctamente**  
**→ Se puede proceder a integrar en la app**

---

### **Si HAY problemas:**

Documentar:

1. **¿Qué elemento falla?**
   - Título / Logo / Tabla / Foto / etc.

2. **¿Cómo falla?**
   - No aparece / Aparece corrupto / Aparece como código

3. **Captura de pantalla** del problema

4. **Mensaje de error** si lo hay

5. **Tamaño del DOCX:**
   ```powershell
   (Get-Item "test_catastro.docx").Length / 1KB
   ```

6. **Verificar que sea ZIP válido:**
   ```powershell
   $bytes = [System.IO.File]::ReadAllBytes("test_catastro.docx")
   Write-Host "Magic bytes: $($bytes[0].ToString('X2')) $($bytes[1].ToString('X2'))"
   # Debe mostrar: 50 4B (PK)
   ```

---

## 🐛 **TROUBLESHOOTING**

### **Error: "Edge Function no responde"**

**Causa:** Edge Function no desplegada

**Solución:**
```bash
supabase functions deploy convert-pdf-to-docx
```

---

### **Error: "CloudConvert API Key not configured"**

**Causa:** Secret no configurado en Supabase

**Solución:**
```bash
supabase secrets set CLOUDCONVERT_API_KEY=your_key_here
```

**Verificar:**
```bash
supabase secrets list
```

---

### **Error: "Conversion timeout"**

**Causa:** PDF muy grande (>2 MB)

**Solución:**
1. Reducir calidad de fotografías antes de generar PDF
2. Limitar número de fotos a 3-5
3. En `catastro_export_service.dart`, ajustar calidad JPEG:
   ```dart
   quality: 60,  // Reducir de 75 a 60
   maxWidth: 400,  // Reducir de 600 a 400
   ```

---

### **Error: "Sin créditos CloudConvert"**

**Causa:** Plan gratuito agotado (10 créditos/día)

**Solución:**
1. Esperar al día siguiente (reset a medianoche)
2. O comprar paquete de créditos: https://cloudconvert.com/pricing

**Verificar créditos:**
https://cloudconvert.com/dashboard

---

### **Error: "DOCX corrupto o no abre"**

**Causa:** Conversión falló pero no se detectó

**Diagnóstico:**
```powershell
# Ver tamaño
(Get-Item "test_catastro.docx").Length

# Ver primeros bytes
$bytes = [System.IO.File]::ReadAllBytes("test_catastro.docx")
$bytes[0..50] | Format-Hex
```

**Solución:**
- Si tamaño < 1 KB → conversión falló
- Si magic bytes ≠ PK → no es ZIP válido
- Revisar logs de Edge Function:
  ```bash
  supabase functions logs convert-pdf-to-docx
  ```

---

## 📞 **SOPORTE**

### **Logs de Edge Function:**
```bash
supabase functions logs convert-pdf-to-docx --tail
```

### **Logs de CloudConvert:**
https://cloudconvert.com/dashboard/jobs

### **Estado de Supabase:**
https://status.supabase.com/

---

## ✅ **CHECKLIST FINAL**

Antes de dar por validada la prueba:

- [ ] Edge Function desplegada y funcionando
- [ ] CLOUDCONVERT_API_KEY configurada
- [ ] PDF de prueba generado correctamente
- [ ] Conversión PDF→DOCX ejecutada sin errores
- [ ] DOCX descargado con tamaño > 1 KB
- [ ] DOCX es ZIP válido (magic bytes PK)
- [ ] DOCX abre en Word sin advertencias
- [ ] Todos los elementos visibles (título, logo, tabla, foto)
- [ ] Título de foto es personalizado (no "Foto 1")
- [ ] NO hay páginas en blanco
- [ ] NO hay código HTML/XML visible
- [ ] NO hay Base64 visible

**Si TODOS los checks están ✅:**  
**→ PRUEBA EXITOSA - Proceder con integración**

**Si ALGUNO falla:**  
**→ DETENER - Reportar problema - NO integrar**

---

**Fecha:** 26/08/2026  
**Proyecto:** App Áreas Verdes Doñihue  
**Versión:** 1.0.0
