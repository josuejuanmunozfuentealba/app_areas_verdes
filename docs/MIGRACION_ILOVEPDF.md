# 📄 Migración de CloudConvert a iLovePDF API

**Fecha:** 27 de Agosto de 2026  
**Versión:** 1.0.3  
**Estado:** ✅ Completado

---

## 🎯 **RESUMEN EJECUTIVO**

Se migró completamente el sistema de conversión PDF→Word de **CloudConvert** a **iLovePDF API** debido a:

1. **CloudConvert agotó límite gratuito** (25 minutos/mes)
2. **iLovePDF ofrece 100X más conversiones** (2,500 archivos/mes vs ~25-50)
3. **Workflow más simple** (4 pasos vs múltiples jobs)
4. **Mejor uptime** (99.95% garantizado)

---

## 📊 **COMPARATIVA**

| Característica | CloudConvert (Anterior) | iLovePDF (Nuevo) |
|----------------|-------------------------|------------------|
| **Plan Gratuito** | 25 minutos/mes | **2,500 créditos/mes** |
| **Conversiones/mes** | ~25-50 archivos | **~2,500 archivos** |
| **PDF → Word** | Consume minutos | **1 crédito = 1 archivo** |
| **Timeout** | 6 minutos | **45 segundos** |
| **Uptime** | No garantizado | **99.95% oficial** |
| **Precio Paid** | $9/mes = 500 min | **$9/mes = 20,000 créditos** |
| **Workflow** | Complejo (jobs, webhooks) | **4 pasos simples** |

---

## 🔑 **CREDENCIALES iLovePDF**

```
Public Key:  project_public_aa67e358d92ab536ad62c6a2701486d2_WXYNt07c4efe816c241a9462bbd2476da40c9
Secret Key:  secret_key_e431169b81c9bb9c61b1e4e651c4b3f1_sCh-L87ce3f0ab9f421388af8d0be0b3b06e
```

**⚠️ IMPORTANTE:** Estas credenciales deben estar configuradas como **variables de entorno** en:
- Vercel (deployment)
- Supabase Edge Functions
- Variables locales (desarrollo)

```bash
# Variables de entorno
ILOVEPDF_PUBLIC_KEY=project_public_aa67e358d92ab536ad62c6a2701486d2_WXYNt07c4efe816c241a9462bbd2476da40c9
ILOVEPDF_SECRET_KEY=secret_key_e431169b81c9bb9c61b1e4e651c4b3f1_sCh-L87ce3f0ab9f421388af8d0be0b3b06e
```

---

## 🚀 **CAMBIOS IMPLEMENTADOS**

### **1. Edge Function (Supabase)**

**Eliminado:**
- ❌ `supabase/functions/convert-pdf-to-docx/index.ts` (CloudConvert)

**Creado:**
- ✅ `supabase/functions/convert-pdf-to-word-ilovepdf/index.ts` (iLovePDF)

**Workflow iLovePDF:**
```typescript
1. Autenticación     → POST /v1/auth con public_key
2. Start Task        → GET  /v1/start/pdftopdf
3. Upload File       → POST /v1/upload (multipart/form-data)
4. Process           → POST /v1/process (tool: pdftopdf)
5. Download          → URL pública del DOCX generado
```

---

### **2. Dart Service (`lib/services/catastro_export_service.dart`)**

**Eliminado:**
```dart
❌ Future<String?> convertPdfToDocx()  // Método CloudConvert
```

**Agregado:**
```dart
✅ Future<String?> convertPdfToWordILovePDF()  // Método iLovePDF
```

**Cambios clave:**
- Timeout reducido: `6 minutos` → `45 segundos`
- Endpoint: `/convert-pdf-to-docx` → `/convert-pdf-to-word-ilovepdf`
- Logs: `[PDF→DOCX]` → `[PDF→Word iLovePDF]`

---

### **3. Llamadas actualizadas:**

**Antes:**
```dart
final docxUrl = await convertPdfToDocx(
  pdfBytes: pdfUint8List,
  filename: filename,
);
```

**Ahora:**
```dart
final docxUrl = await convertPdfToWordILovePDF(
  pdfBytes: pdfUint8List,
  filename: filename,
);
```

---

## 📈 **LÍMITES Y COSTOS**

### **Plan Gratuito (Actual)**
- ✅ **2,500 créditos/mes** gratis
- ✅ **PDF → Word:** 1 crédito por archivo
- ✅ **~2,500 conversiones/mes**
- ✅ **Renovación:** 1 de cada mes
- ✅ **No requiere tarjeta de crédito**

### **Plan Premium ($9/mes)**
- ✅ **20,000 créditos/mes**
- ✅ **~20,000 conversiones/mes**
- ✅ **Soporte prioritario**
- ✅ **Sin publicidad**

### **Plan Business (25+ usuarios)**
- ✅ **Créditos personalizados**
- ✅ **Contrato escalable**
- ✅ **Account Manager dedicado**
- ✅ **Single Sign-On (SSO)**

---

## 🧪 **TESTING**

### **Test local:**
```bash
# 1. Configurar variables de entorno
export ILOVEPDF_PUBLIC_KEY="project_public_aa67e..."
export ILOVEPDF_SECRET_KEY="secret_key_e431169..."

# 2. Ejecutar Edge Function localmente
supabase functions serve convert-pdf-to-word-ilovepdf

# 3. Probar conversión
dart run bin/test_edge_function.dart test_simple.pdf
```

### **Test en producción:**
```dart
// En Flutter app
final docxBytes = await _exportService.generarWordDesdeConversion(
  plazaId: '15',
  nombrePlaza: 'Plaza 21 de Mayo',
  inspector: 'Test Inspector',
  fechaHora: DateTime.now(),
  evaluaciones: testEvaluaciones,
  observaciones: testObservaciones,
  fotos: testFotos,
);

// Verificar resultado
if (docxBytes != null) {
  print('✅ DOCX generado: ${docxBytes.length} bytes');
} else {
  print('❌ Conversión falló');
}
```

---

## 📚 **DOCUMENTACIÓN OFICIAL**

- **iLovePDF API:** https://developer.ilovepdf.com/
- **API Reference:** https://www.iloveapi.com/docs/api-reference
- **Pricing:** https://www.iloveapi.com/pricing
- **GitHub:** https://github.com/ilovepdf

---

## ⚠️ **NOTAS IMPORTANTES**

1. **Límite de tareas abiertas:**
   - Máximo: 10% del límite mensual
   - Ejemplo: 2,500 créditos → máx 250 tareas simultáneas

2. **Notificación al 85%:**
   - Email automático cuando uses 85% de tus créditos
   - Recomendación: Monitorear uso en dashboard

3. **Créditos no expiran:**
   - Plan Prepaid: Los créditos NO expiran
   - Plan Subscription: Créditos se renuevan cada mes

4. **Archivos fallidos:**
   - Solo archivos procesados exitosamente consumen créditos
   - Errores NO descontarán de tu saldo

5. **Uptime garantizado:**
   - 99.95% uptime oficial
   - Servidores de respaldo automáticos en segundos

---

## 🔄 **ROLLBACK (Si es necesario)**

Para volver a CloudConvert:

1. Restaurar `supabase/functions/convert-pdf-to-docx/index.ts`
2. Revertir `convertPdfToWordILovePDF()` → `convertPdfToDocx()`
3. Cambiar endpoint en llamadas
4. Git: `git revert <commit-hash>`

**NO RECOMENDADO** debido a límites de CloudConvert.

---

## ✅ **ESTADO ACTUAL**

- ✅ Edge Function iLovePDF creada y funcional
- ✅ Código Dart actualizado y compilando
- ✅ Variables de entorno configuradas
- ✅ Testing exitoso en desarrollo
- ✅ Documentación completa
- ⏳ **Pendiente:** Deploy a producción (esperando variables Vercel)

---

## 👥 **SOPORTE**

**iLovePDF Support:**
- Email: support@ilovepdf.com
- Dashboard: https://developer.ilovepdf.com/user/projects

**Documentación interna:**
- `docs/INTEGRACION_PDF_TO_DOCX_CLOUDCONVERT.md` (deprecado)
- `docs/MIGRACION_ILOVEPDF.md` (este archivo)
- `docs/OPTIMIZACION_MOVIL_COMPLETA.md`

---

**🎉 Migración completada exitosamente el 27/08/2026**
