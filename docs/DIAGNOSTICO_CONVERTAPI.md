# 🔧 Diagnóstico: Conversión PDF→Word con ConvertAPI

**Fecha:** 3 de Septiembre de 2026  
**Problema reportado:** "No está disponible" al intentar convertir PDF→Word

---

## 🐛 **PROBLEMA ENCONTRADO**

### **Error 1: URL Edge Function Incorrecta**

**Código anterior (INCORRECTO):**
```dart
final functionUrl = '$supabaseUrl/functions/v1/convert-pdf-to-word-convertapi';
//                                                    ^^^^^^^^^^^^^^^^^^^^^^
//                                                    Esta función NO existe
```

**Código corregido:**
```dart
final functionUrl = '$supabaseUrl/functions/v1/convert-pdf-to-word-ilovepdf';
//                                                    ^^^^^^^^^^^^^^^^^^^^^^
//                                                    Esta SÍ existe en Supabase
```

**Explicación:**
- La Edge Function real se llama `convert-pdf-to-word-ilovepdf` (nombre histórico)
- Internamente usa ConvertAPI (migrado el 27/08/2026)
- El nombre no se cambió para mantener compatibilidad

---

## 🔑 **API KEY CONVERTAPI**

### **Información de la cuenta:**

**URL de registro:** https://www.convertapi.com/

**Dashboard:** https://www.convertapi.com/dashboard

**Plan actual:**
- 🆓 **Gratuito:** 1,500 conversiones/mes
- 📊 **Uso típico:** ~50 conversiones/mes (bien dentro del límite)

---

### **Configurar API Key en Supabase:**

#### **Paso 1: Obtener Secret**
1. Ir a: https://www.convertapi.com/a/auth
2. Login con tu cuenta
3. Copiar el **Secret** (empieza con `secret_...`)

#### **Paso 2: Configurar en Supabase**
1. Ir a: https://supabase.com/dashboard/project/speneggmlqitgfjhzsry/settings/functions
2. Click en **"Edge Functions"** → **"Secrets"**
3. Buscar si ya existe `CONVERTAPI_SECRET`
4. Si NO existe, agregar:
   - **Name:** `CONVERTAPI_SECRET`
   - **Value:** `secret_xxxxxxxxxxxxxxxxx` (tu secret de ConvertAPI)
5. Click **"Add secret"**

#### **Paso 3: Verificar que la función esté deployada**
1. Ir a: https://supabase.com/dashboard/project/speneggmlqitgfjhzsry/functions
2. Verificar que existe: `convert-pdf-to-word-ilovepdf`
3. Si NO existe, desplegarla:

```bash
# Opción A: Via CLI
supabase functions deploy convert-pdf-to-word-ilovepdf

# Opción B: Via Dashboard
# 1. Copiar código de: supabase/functions/convert-pdf-to-word-ilovepdf/index.ts
# 2. Pegar en dashboard y "Deploy"
```

---

## 🧪 **CÓMO PROBAR**

### **Test rápido en la app:**

1. **Crear catastro nuevo:**
   - Plaza: "Plaza de Prueba"
   - Inspector: Tu nombre
   - Agregar 2-3 fotos
   - Llenar 2-3 observaciones

2. **Guardar en la nube:**
   - Presionar botón morado "Guardar"
   - ✅ Debe subir exitosamente

3. **Descargar Word:**
   - Ir a historial (pantalla principal)
   - Presionar icono Word del catastro recién creado
   - ✅ Debe iniciar descarga del `.docx`

4. **Verificar Word:**
   - Abrir archivo en Microsoft Word o Google Docs
   - ✅ Debe contener todas las fotos y observaciones

---

## 📊 **LOGS DE DIAGNÓSTICO**

### **Logs exitosos:**
```
[PDF→Word ConvertAPI] Iniciando conversión: catastro_PL001_xxx.pdf
[PDF→Word ConvertAPI] Tamaño PDF: 350.5 KB
[PDF→Word ConvertAPI] Llamando a Edge Function: https://speneggmlqitgfjhzsry.supabase.co/functions/v1/convert-pdf-to-word-ilovepdf
[PDF→Word ConvertAPI] Respuesta recibida en 45s
[PDF→Word ConvertAPI] ✅ Conversión exitosa
[PDF→Word ConvertAPI] Archivo: catastro_PL001_xxx.docx
[PDF→Word ConvertAPI] URL: https://v2.convertapi.com/d/xxxxx
```

### **Logs de error:**
```
❌ [PDF→Word ConvertAPI] Error HTTP 404
   → Causa: URL incorrecta de Edge Function

❌ [PDF→Word ConvertAPI] Error HTTP 401 Unauthorized
   → Causa: CONVERTAPI_SECRET no configurado o inválido

❌ [PDF→Word ConvertAPI] Error HTTP 429 Too Many Requests
   → Causa: Excediste 1,500 conversiones/mes

❌ [PDF→Word ConvertAPI] ⏱️ Timeout después de 180s
   → Causa: PDF muy grande o ConvertAPI lento
```

---

## 🚨 **SOLUCIÓN DE PROBLEMAS**

### **Si sigue fallando:**

#### **1. Verificar logs en navegador móvil:**
- Abrir DevTools en Chrome Android
- Ver consola al hacer clic en "Descargar Word"
- Copiar mensaje de error completo

#### **2. Verificar API Key válida:**
```bash
# Test manual con curl
curl -X POST https://v2.convertapi.com/convert/pdf/to/docx \
  -H "Authorization: Bearer secret_xxxxxx" \
  -H "Content-Type: application/json" \
  -d '{"Parameters":[{"Name":"File","FileValue":{"Name":"test.pdf","Data":"base64..."}}]}'
```

#### **3. Verificar Edge Function desplegada:**
```bash
# Ver logs en tiempo real
supabase functions logs convert-pdf-to-word-ilovepdf --tail
```

#### **4. Verificar límite no excedido:**
- Ir a: https://www.convertapi.com/dashboard
- Revisar: **Conversions used this month**
- Si es 1,500/1,500 → Esperar próximo mes o upgrade

---

## ✅ **CAMBIOS APLICADOS**

| Archivo | Cambio | Estado |
|---------|--------|--------|
| `lib/services/catastro_export_service.dart` | URL Edge Function corregida | ✅ Committed |
| `docs/DIAGNOSTICO_CONVERTAPI.md` | Documentación diagnóstico | ✅ Creado |

**Commit:** `1117f4a - fix: Corregir URL Edge Function conversión PDF→Word`

---

## 🔄 **PRÓXIMOS PASOS**

1. ✅ **URL corregida** → Esperar deploy Vercel (2-3 min)
2. ⏳ **Verificar CONVERTAPI_SECRET** en Supabase
3. ⏳ **Probar conversión** en móvil con señal débil
4. ⏳ **Monitorear uso** en dashboard ConvertAPI

---

## 📚 **REFERENCIAS**

- [ConvertAPI Dashboard](https://www.convertapi.com/dashboard)
- [ConvertAPI Docs](https://www.convertapi.com/doc)
- [Supabase Edge Functions](https://supabase.com/dashboard/project/speneggmlqitgfjhzsry/functions)
- [Archivo TypeScript Edge Function](supabase/functions/convert-pdf-to-word-ilovepdf/index.ts)

---

**Última actualización:** 3/09/2026 - URL Edge Function corregida
