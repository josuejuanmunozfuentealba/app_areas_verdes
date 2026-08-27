# 📄 CloudConvert API - Investigación para Conversión PDF → DOCX

## 🎯 **OBJETIVO**

Implementar conversión de PDF a DOCX usando CloudConvert API para el módulo de Catastro de Inmuebles.

**Flujo:** `PDF generado → CloudConvert API → DOCX → Supabase Storage`

---

## 📊 **INFORMACIÓN GENERAL DE CLOUDCONVERT**

### **¿Qué es CloudConvert?**
- Servicio de conversión de archivos en la nube
- Soporta **200+ formatos** (documentos, imágenes, audio, video, etc.)
- API REST moderna (v2)
- Tecnología de conversión PDF→Office desarrollada por **Apryse** (líder de la industria)

### **Ventajas:**
- ✅ Preserva formato, diseño y tablas
- ✅ Maneja **imágenes incrustadas** correctamente
- ✅ Salida DOCX limpia y editable
- ✅ No requiere instalación de software local
- ✅ Escalable y confiable

---

## 💰 **PRICING (PLANES Y COSTOS)**

### **Plan GRATUITO:**
| Característica | Límite |
|----------------|--------|
| **Conversiones diarias** | 10 conversiones/día |
| **Créditos** | 10 créditos/día (se resetean diariamente) |
| **Tamaño máximo archivo** | 1 GB |
| **Tiempo máximo procesamiento** | 5 minutos |
| **Tareas concurrentes** | 5 |
| **Prioridad** | Baja |
| **Soporte** | Estándar |
| **Costo** | **GRATIS** |

### **Plan de PAQUETES (Pay as you go):**
| Paquete | Costo | Costo por crédito |
|---------|-------|-------------------|
| 1,000 créditos | Varía | ~€0.008-0.01/crédito |
| Los créditos **NUNCA EXPIRAN** | | |

### **Plan de SUBSCRIPCIÓN:**
| Volumen | Costo mensual | Costo por crédito |
|---------|---------------|-------------------|
| 1,000 créditos/mes | Varía | Hasta 50% más barato |
| Créditos **NO acumulables** (se pierden al final del mes) | | |

---

## 🔑 **SISTEMA DE CRÉDITOS**

### **¿Cómo funciona?**

Cada conversión consume **créditos base + créditos por tiempo de procesamiento**.

| Tipo de Conversión | Créditos Base | Créditos por minuto |
|--------------------|---------------|---------------------|
| **General** | 1 | +1 por minuto extra |
| **Office → PDF** | 2 | +1 por minuto extra |
| **PDF → Office** | **4** ⚠️ | +1 por minuto extra |

**Ejemplo:**
- Conversión PDF → DOCX que toma 30 segundos = **4 créditos** (base)
- Conversión PDF → DOCX que toma 2 minutos = **5 créditos** (4 base + 1 extra)

### **Conclusión:**
Con el plan gratuito (10 créditos/día), puedes hacer:
- **2 conversiones PDF→DOCX por día** (si cada una toma <1 minuto)
- **1 conversión PDF→DOCX por día** (si toma ~2-3 minutos)

---

## 🔐 **AUTENTICACIÓN**

### **API Key (Bearer Token):**

CloudConvert usa **API Keys** para autenticación.

**Ubicación en Dashboard:**
```
https://cloudconvert.com/dashboard/api/v2/keys
```

**Formato de autenticación:**
```http
Authorization: Bearer YOUR_API_KEY_HERE
```

### **Sandbox API (Pruebas):**
- Permite testing sin consumir créditos reales
- Requiere **whitelist de archivos** mediante hash MD5
- Ideal para desarrollo y pruebas

---

## 🛠️ **API ENDPOINTS**

### **Base URL:**
```
https://api.cloudconvert.com/v2
```

### **Endpoint principal: Jobs**
```http
POST https://api.cloudconvert.com/v2/jobs
```

**Headers:**
```http
Authorization: Bearer YOUR_API_KEY
Content-Type: application/json
```

---

## 📋 **FLUJO DE CONVERSIÓN PDF → DOCX**

### **Paso 1: Crear Job con 3 tareas**

```json
{
  "tasks": {
    "import-pdf": {
      "operation": "import/upload"
    },
    "convert-to-docx": {
      "operation": "convert",
      "input": "import-pdf",
      "output_format": "docx"
    },
    "export-docx": {
      "operation": "export/url",
      "input": "convert-to-docx"
    }
  }
}
```

### **Paso 2: Subir archivo PDF**

Usar la URL de upload retornada por la tarea `import-pdf`:

```http
PUT [upload_url]
Content-Type: application/pdf

[PDF bytes]
```

### **Paso 3: Esperar a que el job termine**

Opciones:
1. **Polling:** Consultar el estado del job cada X segundos
2. **Webhook:** CloudConvert envía notificación cuando termina
3. **Sync endpoint:** Bloquea hasta que termine (no recomendado para archivos grandes)

### **Paso 4: Descargar DOCX**

El job retorna una URL pública de descarga:

```json
{
  "id": "job-id",
  "status": "finished",
  "tasks": [
    {
      "name": "export-docx",
      "status": "finished",
      "result": {
        "files": [
          {
            "filename": "output.docx",
            "url": "https://storage.cloudconvert.com/...",
            "size": 123456
          }
        ]
      }
    }
  ]
}
```

---

## 📦 **SDK OFICIAL (Node.js)**

CloudConvert proporciona SDK oficial para Node.js:

```bash
npm install cloudconvert
```

### **Ejemplo de código:**

```javascript
import CloudConvert from 'cloudconvert';

const cloudConvert = new CloudConvert('YOUR_API_KEY');

// Crear job
let job = await cloudConvert.jobs.create({
  tasks: {
    'import-pdf': {
      operation: 'import/upload'
    },
    'convert-to-docx': {
      operation: 'convert',
      input: 'import-pdf',
      output_format: 'docx'
    },
    'export-docx': {
      operation: 'export/url',
      input: 'convert-to-docx'
    }
  }
});

// Subir archivo
const uploadTask = job.tasks.find(t => t.name === 'import-pdf');
const inputFile = fs.createReadStream('./input.pdf');
await cloudConvert.tasks.upload(uploadTask, inputFile, 'input.pdf');

// Esperar a que termine
job = await cloudConvert.jobs.wait(job.id);

// Descargar resultado
const file = cloudConvert.jobs.getExportUrls(job)[0];
console.log('DOCX URL:', file.url);
```

---

## 🔒 **SEGURIDAD: EDGE FUNCTION DE SUPABASE**

### **❌ NO hacer esto (inseguro):**
```dart
// ❌ API Key expuesta en el código Flutter
final apiKey = 'eyJhbGci...'; // NUNCA hacer esto
```

### **✅ Hacer esto (seguro):**

**Arquitectura:**
```
Flutter App
    ↓ (envía PDF bytes)
Supabase Edge Function
    ↓ (llama CloudConvert API con API Key segura)
CloudConvert API
    ↓ (retorna DOCX)
Supabase Edge Function
    ↓ (retorna DOCX URL)
Flutter App
```

**Edge Function (Deno/TypeScript):**
```typescript
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';

serve(async (req) => {
  const { pdfBase64 } = await req.json();
  
  // API Key segura en variables de entorno
  const apiKey = Deno.env.get('CLOUDCONVERT_API_KEY');
  
  // Llamar a CloudConvert API
  const response = await fetch('https://api.cloudconvert.com/v2/jobs', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${apiKey}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      tasks: {
        'import-pdf': { operation: 'import/upload' },
        'convert-to-docx': {
          operation: 'convert',
          input: 'import-pdf',
          output_format: 'docx'
        },
        'export-docx': {
          operation: 'export/url',
          input: 'convert-to-docx'
        }
      }
    })
  });
  
  const job = await response.json();
  
  // ... continuar con upload y descarga ...
  
  return new Response(JSON.stringify({ docxUrl: '...' }), {
    headers: { 'Content-Type': 'application/json' }
  });
});
```

---

## 🧪 **PRUEBA MÍNIMA RECOMENDADA**

### **Paso 1: Registrarse en CloudConvert**
```
https://cloudconvert.com/register
```

### **Paso 2: Obtener API Key**
```
https://cloudconvert.com/dashboard/api/v2/keys
```

### **Paso 3: Crear Edge Function en Supabase**
```bash
supabase functions new convert-pdf-to-docx
```

### **Paso 4: Probar conversión con PDF de prueba**
- Generar PDF de catastro con 1 foto
- Enviar a Edge Function
- Verificar que DOCX conserve:
  - ✅ Texto
  - ✅ Tablas
  - ✅ Imágenes
  - ✅ Formato

### **Paso 5: Subir DOCX a Supabase Storage**
```dart
final docxBytes = await http.get(Uri.parse(docxUrl));
final fileName = 'catastro_${plazaId}_${DateTime.now().millisecondsSinceEpoch}.docx';
await supabase.storage.from('catastros').uploadBinary(fileName, docxBytes.bodyBytes);
```

---

## ⚠️ **LIMITACIONES Y CONSIDERACIONES**

### **Limitaciones del Plan Gratuito:**
- ❌ Solo 10 créditos/día = **2 conversiones PDF→DOCX/día**
- ❌ Prioridad baja (puede ser más lento)
- ❌ Tiempo máximo: 5 minutos

### **Consideraciones:**
- ⚠️ Si el PDF tiene muchas imágenes, puede tardar más (>1 minuto) y consumir más créditos
- ⚠️ Archivos muy grandes (>10MB) pueden tardar varios minutos
- ⚠️ CloudConvert puede **no preservar al 100%** formatos complejos

### **Alternativas si se supera límite gratuito:**
1. **Comprar paquete de créditos** (~€8 por 1,000 créditos)
2. **Subscripción mensual** (más económico a largo plazo)
3. **Usar otra API:** (pdf.co, ConvertAPI, etc.)

---

## 📚 **RECURSOS**

| Recurso | URL |
|---------|-----|
| Documentación oficial API | https://cloudconvert.com/api/v2 |
| Job Builder (constructor visual) | https://cloudconvert.com/api/v2/jobs/builder |
| Pricing | https://cloudconvert.com/pricing |
| Dashboard (API Keys) | https://cloudconvert.com/dashboard/api/v2/keys |
| SDK Node.js (GitHub) | https://github.com/cloudconvert/cloudconvert-node |
| PDF to Office API | https://cloudconvert.com/apis/pdf-to-office |

---

## ✅ **RECOMENDACIÓN FINAL**

### **Para este proyecto:**

1. **Usar plan GRATUITO** inicialmente (10 conversiones/día es suficiente para pruebas)
2. **Implementar Edge Function** de Supabase para mantener API Key segura
3. **Cachear PDFs generados** para evitar regeneración innecesaria
4. **Monitorear consumo** de créditos en dashboard de CloudConvert
5. Si se necesita más volumen, **comprar paquete de 1,000 créditos** (~€8-10)

### **Ventajas de este enfoque:**
- ✅ PDF como documento maestro (ya funciona bien)
- ✅ Conversión automática a DOCX (sin mantener código complejo)
- ✅ Formato, tablas e imágenes preservados
- ✅ API Key segura en backend
- ✅ Escalable (solo pagar si se necesita más)

---

## 🚀 **PRÓXIMOS PASOS**

1. ✅ **Investigación completada**
2. ⏳ Crear Supabase Edge Function para conversión
3. ⏳ Modificar CatastroExportService
4. ⏳ Actualizar CatastroSupabaseService
5. ⏳ Crear prueba mínima
6. ⏳ Integrar en CatastroInmueblesScreen

---

**Fecha de investigación:** 26/08/2026  
**Investigado por:** Kiro AI  
**Proyecto:** App Áreas Verdes Doñihue
