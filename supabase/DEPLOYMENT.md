# 🚀 Deployment: Supabase Edge Functions

## 📋 **PREREQUISITOS**

### 1. Instalar Supabase CLI

**Windows (PowerShell):**
```powershell
# Usando Scoop
scoop install supabase

# O usando npm
npm install -g supabase
```

**Verificar instalación:**
```bash
supabase --version
```

---

### 2. Obtener CloudConvert API Key

1. Registrarse en CloudConvert: https://cloudconvert.com/register
2. Ir al Dashboard: https://cloudconvert.com/dashboard/api/v2/keys
3. Crear nueva API Key
4. Copiar la API Key generada

---

### 3. Configurar Proyecto Supabase

**Obtener Project Reference:**
1. Ir a: https://app.supabase.com/project/[tu-proyecto]/settings/general
2. Copiar el **Reference ID** (ejemplo: `speneggmlqitgfjhzsry`)

---

## 🔧 **PASOS DE DEPLOYMENT**

### PASO 1: Login en Supabase

```bash
supabase login
```

Esto abrirá el navegador para autenticarte.

---

### PASO 2: Linkar Proyecto

```bash
cd C:\Users\HP PAVILION\app_areas_verdes
supabase link --project-ref speneggmlqitgfjhzsry
```

**Nota:** Reemplazar `speneggmlqitgfjhzsry` con tu Project Reference.

---

### PASO 3: Configurar Secret (API Key)

```bash
supabase secrets set CLOUDCONVERT_API_KEY=your_api_key_here
```

**Ejemplo:**
```bash
supabase secrets set CLOUDCONVERT_API_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Verificar secret:**
```bash
supabase secrets list
```

---

### PASO 4: Desplegar Edge Function

```bash
supabase functions deploy convert-pdf-to-docx
```

**Salida esperada:**
```
Deploying convert-pdf-to-docx (project ref: speneggmlqitgfjhzsry)
Bundled convert-pdf-to-docx in 245ms
Function URL: https://speneggmlqitgfjhzsry.supabase.co/functions/v1/convert-pdf-to-docx
```

---

### PASO 5: Verificar Deployment

```bash
supabase functions list
```

**Salida esperada:**
```
┌────────────────────────┬─────────┬────────────┬───────────────────┐
│         NAME           │  STATUS │   VERSION  │   LAST UPDATED    │
├────────────────────────┼─────────┼────────────┼───────────────────┤
│ convert-pdf-to-docx    │ ACTIVE  │ 1          │ 2026-08-26 17:15  │
└────────────────────────┴─────────┴────────────┴───────────────────┘
```

---

## 🧪 **PRUEBA MANUAL**

### Usando curl (PowerShell):

```powershell
$headers = @{
    "Authorization" = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    "Content-Type" = "application/json"
}

$body = @{
    pdfBase64 = "JVBERi0xLjQKJeLjz9MKMy4uLg=="
    filename = "test.pdf"
} | ConvertTo-Json

Invoke-RestMethod -Uri "https://speneggmlqitgfjhzsry.supabase.co/functions/v1/convert-pdf-to-docx" `
    -Method POST `
    -Headers $headers `
    -Body $body
```

---

## 📊 **MONITOREO Y LOGS**

### Ver logs en tiempo real:

```bash
supabase functions logs convert-pdf-to-docx
```

### Ver logs de una ejecución específica:

```bash
supabase functions logs convert-pdf-to-docx --filter "Starting conversion"
```

---

## 🔄 **ACTUALIZAR FUNCIÓN**

Si modificas el código de la función:

```bash
# Redesplegar
supabase functions deploy convert-pdf-to-docx

# O forzar redespliegue
supabase functions deploy convert-pdf-to-docx --no-verify-jwt
```

---

## 🗑️ **ELIMINAR FUNCIÓN**

```bash
supabase functions delete convert-pdf-to-docx
```

---

## ⚙️ **CONFIGURACIÓN AVANZADA**

### Variables de Entorno Adicionales:

```bash
# Cambiar timeout (default: 300s)
supabase secrets set FUNCTION_TIMEOUT=600

# Habilitar debug mode
supabase secrets set DEBUG_MODE=true
```

### Configurar CORS:

La función ya tiene CORS configurado para aceptar requests de cualquier origen (`*`).

Si necesitas restringir a un dominio específico, modifica `index.ts` línea 15:

```typescript
const corsHeaders = {
  'Access-Control-Allow-Origin': 'https://tu-dominio.com',
  // ...
};
```

---

## 🐛 **TROUBLESHOOTING**

### Error: "supabase: command not found"

**Solución:** Instalar Supabase CLI:
```bash
npm install -g supabase
```

### Error: "Project not linked"

**Solución:** Linkar proyecto:
```bash
supabase link --project-ref speneggmlqitgfjhzsry
```

### Error: "Unauthorized"

**Solución:** Login nuevamente:
```bash
supabase login
```

### Error: "Secret not found"

**Solución:** Configurar API Key:
```bash
supabase secrets set CLOUDCONVERT_API_KEY=your_key
```

### Ver todos los secrets configurados:

```bash
supabase secrets list
```

---

## 📚 **RECURSOS**

| Recurso | URL |
|---------|-----|
| Supabase CLI Docs | https://supabase.com/docs/guides/cli |
| Edge Functions Docs | https://supabase.com/docs/guides/functions |
| CloudConvert API | https://cloudconvert.com/api/v2 |
| Supabase Dashboard | https://app.supabase.com |

---

## 🎯 **PRÓXIMOS PASOS**

1. ✅ Edge Function desplegada
2. ⏳ Modificar `CatastroExportService` para llamar a la función
3. ⏳ Actualizar `CatastroSupabaseService` para guardar DOCX
4. ⏳ Probar flujo completo en la app

---

**Fecha:** 26/08/2026  
**Proyecto:** App Áreas Verdes Doñihue  
**Autor:** Kiro AI
