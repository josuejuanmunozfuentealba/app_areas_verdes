# 📄 Edge Function: convert-pdf-to-docx

## 🎯 Propósito

Convertir archivos PDF a formato DOCX usando CloudConvert API de forma segura, sin exponer la API Key en el cliente Flutter.

---

## 🔧 Configuración

### Variables de Entorno Requeridas:

```bash
CLOUDCONVERT_API_KEY=your_cloudconvert_api_key_here
```

### Cómo configurar en Supabase:

1. Ir al Dashboard de Supabase
2. Navegar a **Settings → Edge Functions → Secrets**
3. Agregar secret:
   - Name: `CLOUDCONVERT_API_KEY`
   - Value: `[tu API key de CloudConvert]`

---

## 📡 API

### Endpoint:

```
POST https://[tu-proyecto].supabase.co/functions/v1/convert-pdf-to-docx
```

### Headers:

```http
Content-Type: application/json
Authorization: Bearer [supabase-anon-key]
```

### Request Body:

```json
{
  "pdfBase64": "JVBERi0xLjQKJeLjz9MKMy...",
  "filename": "catastro_PL001.pdf"
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `pdfBase64` | string | ✅ Sí | PDF codificado en Base64 |
| `filename` | string | ❌ No | Nombre del archivo (default: "document.pdf") |

### Response (Éxito):

```json
{
  "success": true,
  "docxUrl": "https://storage.cloudconvert.com/...",
  "docxFilename": "catastro_PL001.docx",
  "message": "Conversion completed successfully"
}
```

### Response (Error):

```json
{
  "success": false,
  "error": "Conversion timeout or failed",
  "message": "Job status: error after 30 attempts"
}
```

---

## 🔄 Flujo de Conversión

```
1. Flutter App
   ↓ (envía PDF en Base64)
   
2. Edge Function recibe request
   ↓
   
3. Crea job en CloudConvert
   - import/upload (tarea de carga)
   - convert (tarea de conversión PDF→DOCX)
   - export/url (tarea de exportación)
   ↓
   
4. Sube PDF a CloudConvert
   ↓
   
5. Polling cada 5 segundos
   - Máximo 60 intentos (5 minutos)
   - Verifica status del job
   ↓
   
6. Job completado
   ↓
   
7. Retorna URL del DOCX
   ↓
   
8. Flutter descarga DOCX y lo sube a Supabase Storage
```

---

## ⚙️ Desplegar

### Usando Supabase CLI:

```bash
# Instalar Supabase CLI si no lo tienes
npm install -g supabase

# Login
supabase login

# Linkar proyecto
supabase link --project-ref [tu-project-ref]

# Desplegar función
supabase functions deploy convert-pdf-to-docx

# Configurar secret
supabase secrets set CLOUDCONVERT_API_KEY=your_api_key_here
```

### Verificar despliegue:

```bash
supabase functions list
```

---

## 🧪 Probar

### Usando curl:

```bash
curl -X POST 'https://[tu-proyecto].supabase.co/functions/v1/convert-pdf-to-docx' \
  -H 'Authorization: Bearer [supabase-anon-key]' \
  -H 'Content-Type: application/json' \
  -d '{
    "pdfBase64": "JVBERi0xLjQKJeLjz9MKMy4uLg==",
    "filename": "test.pdf"
  }'
```

### Usando Dart/Flutter:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String?> convertPdfToDocx(Uint8List pdfBytes, String filename) async {
  final supabaseUrl = 'https://speneggmlqitgfjhzsry.supabase.co';
  final anonKey = 'your-anon-key';
  
  final response = await http.post(
    Uri.parse('$supabaseUrl/functions/v1/convert-pdf-to-docx'),
    headers: {
      'Authorization': 'Bearer $anonKey',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'pdfBase64': base64Encode(pdfBytes),
      'filename': filename,
    }),
  );
  
  if (response.statusCode == 200) {
    final result = jsonDecode(response.body);
    if (result['success'] == true) {
      return result['docxUrl'];
    }
  }
  
  return null;
}
```

---

## ⚠️ Limitaciones

### Límites de CloudConvert (Plan Gratuito):

- **10 conversiones por día**
- **Máximo 1 GB por archivo**
- **Máximo 5 minutos de procesamiento**
- **Costo:** 4 créditos por conversión PDF→DOCX

### Límites de Supabase Edge Functions:

- **Timeout:** 300 segundos (5 minutos) máximo
- **Memory:** 512 MB
- **CPU:** Compartido

### Consideraciones:

- ⚠️ La función espera máximo 5 minutos para que CloudConvert complete la conversión
- ⚠️ Si el PDF tiene muchas imágenes, puede tardar más tiempo
- ⚠️ PDFs muy grandes (>10MB) pueden fallar por timeout

---

## 📊 Costos

### CloudConvert:

| Conversión | Créditos | Con Plan Gratuito |
|------------|----------|-------------------|
| PDF → DOCX | 4 créditos base | 2 conversiones/día |

### Supabase:

| Recurso | Plan Gratuito |
|---------|---------------|
| Edge Function invocations | 500,000/mes |
| Edge Function CPU time | 100 horas/mes |

---

## 🐛 Troubleshooting

### Error: "CloudConvert API Key not configured"

**Solución:** Configurar secret en Supabase Dashboard.

```bash
supabase secrets set CLOUDCONVERT_API_KEY=your_key
```

### Error: "Conversion timeout"

**Causa:** El PDF tardó más de 5 minutos en convertirse.

**Solución:** 
- Reducir tamaño del PDF
- Optimizar imágenes antes de generar PDF
- Aumentar timeout en el código (línea 166)

### Error: "Upload failed"

**Causa:** CloudConvert rechazó el archivo PDF.

**Solución:**
- Verificar que el PDF sea válido
- Verificar que no supere 1 GB
- Verificar que tenga créditos disponibles en CloudConvert

---

## 📚 Referencias

- [CloudConvert API Documentation](https://cloudconvert.com/api/v2)
- [Supabase Edge Functions](https://supabase.com/docs/guides/functions)
- [Deno Documentation](https://deno.land/manual)

---

**Fecha de creación:** 26/08/2026  
**Proyecto:** App Áreas Verdes Doñihue  
**Módulo:** Catastro de Inmuebles
