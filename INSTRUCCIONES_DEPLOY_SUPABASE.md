# 📘 INSTRUCCIONES: Deploy Edge Function a Supabase

## 🎯 **OBJETIVO**
Deployar la Edge Function `convert-pdf-to-word-ilovepdf` en Supabase Dashboard (web) para activar conversión PDF→Word con iLovePDF API.

---

## ⏱️ **TIEMPO ESTIMADO: 5 MINUTOS**

---

## 📋 **PASO 1: Acceder a Supabase Dashboard**

1. Abre tu navegador
2. Ve a: https://supabase.com/dashboard
3. **Inicia sesión** con tu cuenta
4. Selecciona tu proyecto: **`speneggmlqitgfjhzsry`**

---

## 📋 **PASO 2: Ir a Edge Functions**

1. En el menú lateral izquierdo, busca **"Edge Functions"**
2. Click en **"Edge Functions"**
3. Click en el botón **"Create a new function"** (verde, esquina superior derecha)

---

## 📋 **PASO 3: Configurar la Function**

1. **Function name:** Escribe exactamente:
   ```
   convert-pdf-to-word-ilovepdf
   ```

2. **Template:** Selecciona **"Hello World"** (o cualquiera, lo vas a reemplazar)

3. Click **"Create function"**

---

## 📋 **PASO 4: Pegar el Código**

1. **Borra TODO el código** que aparece por defecto

2. **Copia y pega** este código completo:

```typescript
// Edge Function: convert-pdf-to-word-ilovepdf
// Convierte PDF a Word usando iLovePDF API

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const ILOVEPDF_PUBLIC_KEY = "project_public_aa67e358d92ab536ad62c6a2701486d2_WXYNt07c4efe816c241a9462bbd2476da40c9";
const ILOVEPDF_SECRET_KEY = "secret_key_e431169b81c9bb9c61b1e4e651c4b3f1_sCh-L87ce3f0ab9f421388af8d0be0b3b06e";
const ILOVEPDF_API_URL = "https://api.ilovepdf.com/v1";

interface ConversionRequest {
  pdfBase64: string;
  filename: string;
}

// Obtener token de autenticación
async function getAuthToken(): Promise<string> {
  const response = await fetch(`${ILOVEPDF_API_URL}/auth`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ public_key: ILOVEPDF_PUBLIC_KEY }),
  });

  if (!response.ok) {
    throw new Error(`Auth failed: ${response.status}`);
  }

  const data = await response.json();
  return data.token;
}

// Convertir PDF a Word
async function convertPdfToWord(pdfBase64: string, filename: string): Promise<string> {
  console.log("[iLovePDF] Iniciando conversión:", filename);

  // PASO 1: Autenticar
  const token = await getAuthToken();

  // PASO 2: Start task
  const startResponse = await fetch(`${ILOVEPDF_API_URL}/start/pdftopdf`, {
    method: "GET",
    headers: { "Authorization": `Bearer ${token}` },
  });

  if (!startResponse.ok) {
    throw new Error(`Start failed: ${startResponse.status}`);
  }

  const taskData = await startResponse.json();
  const taskId = taskData.task;
  const serverName = taskData.server_filename;

  console.log("[iLovePDF] Task:", taskId);

  // PASO 3: Upload PDF
  const pdfBytes = Uint8Array.from(atob(pdfBase64), c => c.charCodeAt(0));
  const blob = new Blob([pdfBytes], { type: "application/pdf" });

  const formData = new FormData();
  formData.append("task", taskId);
  formData.append("file", blob, filename);

  const uploadResponse = await fetch(`https://${serverName}/v1/upload`, {
    method: "POST",
    headers: { "Authorization": `Bearer ${token}` },
    body: formData,
  });

  if (!uploadResponse.ok) {
    throw new Error(`Upload failed: ${uploadResponse.status}`);
  }

  const uploadData = await uploadResponse.json();
  const serverFileId = uploadData.server_filename;

  // PASO 4: Process
  const processResponse = await fetch(`https://${serverName}/v1/process`, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${token}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      task: taskId,
      tool: "pdftopdf",
      files: [{ server_filename: serverFileId, filename }],
    }),
  });

  if (!processResponse.ok) {
    throw new Error(`Process failed: ${processResponse.status}`);
  }

  const processData = await processResponse.json();
  console.log("[iLovePDF] ✅ Conversión exitosa");
  
  return processData.download_url;
}

// Servidor HTTP
serve(async (req) => {
  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  };

  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    if (req.method !== "POST") {
      return new Response(
        JSON.stringify({ success: false, error: "Method not allowed" }),
        { status: 405, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const { pdfBase64, filename }: ConversionRequest = await req.json();

    if (!pdfBase64 || !filename) {
      return new Response(
        JSON.stringify({ success: false, error: "Missing parameters" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    console.log("[iLovePDF] Nueva solicitud:", filename);

    const downloadUrl = await convertPdfToWord(pdfBase64, filename);

    return new Response(
      JSON.stringify({
        success: true,
        docxUrl: downloadUrl,
        docxFilename: filename.replace(".pdf", ".docx"),
        message: "Conversión exitosa con iLovePDF"
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );

  } catch (error) {
    console.error("[iLovePDF] ❌ Error:", error);

    return new Response(
      JSON.stringify({
        success: false,
        error: error.message || "Unknown error",
        message: error.toString(),
      }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
```

3. **Verifica** que el código esté completo (desde `import` hasta el final con `});`)

---

## 📋 **PASO 5: Deploy la Function**

1. Click en el botón **"Deploy"** o **"Save"** (esquina superior derecha)

2. Espera a que aparezca: ✅ **"Function deployed successfully"**

3. La función ahora está activa en:
   ```
   https://speneggmlqitgfjhzsry.supabase.co/functions/v1/convert-pdf-to-word-ilovepdf
   ```

---

## 📋 **PASO 6: Verificar que funciona**

1. En Supabase Dashboard, ve a **"Edge Functions"**

2. Click en **`convert-pdf-to-word-ilovepdf`**

3. Busca el botón **"Test"** o **"Invoke"**

4. Si hay opción de test, prueba con este JSON:
   ```json
   {
     "pdfBase64": "JVBERi0xLjQKJeLjz9MKMy...",
     "filename": "test.pdf"
   }
   ```
   (Nota: El base64 debe ser un PDF real completo)

5. Deberías ver una respuesta como:
   ```json
   {
     "success": true,
     "docxUrl": "https://...",
     "docxFilename": "test.docx"
   }
   ```

---

## ✅ **VERIFICACIÓN FINAL**

Después del deploy, tu app Flutter automáticamente usará esta función cuando:

1. **Crees un catastro con fotos**
2. **Click "Guardar y Subir a la Nube"**
3. **La app llamará a la Edge Function**
4. **iLovePDF convertirá PDF → Word**
5. **Se guardará en Supabase con ambos archivos**

---

## ⚠️ **NOTAS IMPORTANTES**

### **Credenciales en el código:**
Las credenciales están **hardcodeadas** en este código por simplicidad. En el futuro, si quieres más seguridad, puedes:

1. Ir a **Project Settings → Environment Variables** en Supabase
2. Agregar:
   - `ILOVEPDF_PUBLIC_KEY`
   - `ILOVEPDF_SECRET_KEY`
3. Cambiar el código para usar `Deno.env.get("ILOVEPDF_PUBLIC_KEY")`

### **Límites iLovePDF:**
- ✅ **2,500 créditos/mes** gratis
- ✅ **1 crédito = 1 conversión PDF→Word**
- ✅ **Renovación:** 1 de cada mes

### **Monitoreo:**
Puedes ver los logs de la función en:
- Supabase Dashboard → Edge Functions → convert-pdf-to-word-ilovepdf → Logs

---

## 🆘 **SI ALGO SALE MAL**

### **Error al deployar:**
- Verifica que copiaste TODO el código completo
- Verifica que el nombre sea exactamente: `convert-pdf-to-word-ilovepdf`

### **Error al ejecutar:**
- Revisa los logs en Supabase Dashboard
- Verifica que las credenciales iLovePDF sean correctas
- Verifica que tengas créditos disponibles en iLovePDF

### **La app no funciona:**
- Espera 1-2 minutos después del deploy (caché)
- Limpia caché del navegador
- Reinstala la PWA si es necesario

---

## 📞 **SOPORTE**

Si necesitas ayuda:
1. Revisa los logs en Supabase Dashboard
2. Verifica tu cuenta iLovePDF: https://developer.ilovepdf.com/user/projects
3. Contacta soporte iLovePDF: support@ilovepdf.com

---

**🎉 ¡Listo! Una vez deployes, tu sistema funcionará completo con iLovePDF** 🚀
