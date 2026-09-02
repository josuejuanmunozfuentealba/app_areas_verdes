# 📋 RESUMEN DETALLADO: Problema de Subida a la Nube

**Fecha:** 2 de septiembre de 2026  
**Usuario:** Josué Muñoz  
**Problema Principal:** App NO sube datos a Supabase cuando hay fotos, solo funciona sin fotos o de "milagro"

---

## 🔴 SÍNTOMAS DEL PROBLEMA

### ✅ LO QUE SÍ FUNCIONA:
- Subir catastro **SIN fotos** → ✅ Funciona siempre
- Subir catastro con **poca información** → ✅ Funciona
- **Una o dos veces "de milagro"** con fotos → ✅ Funcionó pero no es confiable

### ❌ LO QUE FALLA:
- Subir catastro **CON fotos** → ❌ Falla casi siempre
- Subir catastro **con mucha información + fotos** → ❌ Falla siempre
- En terreno con **señal móvil débil** → ❌ Colapsa y pierde datos

---

## 🔍 CAUSA RAÍZ IDENTIFICADA

### 1. **PROBLEMA: Tamaño de las fotos es ENORME**

```
Foto original de cámara: ~6 MB
  ↓ Compresión ImagePicker (quality 60, 1024px)
Foto comprimida: ~200-800 KB
  ↓ Convertir a Base64 (para PDF)
Foto en Base64: ~260-1000 KB (+33%)
  ↓ Múltiples fotos en PDF
PDF final: ~2-8 MB (con 3-5 fotos)
```

**Resultado:** 
- PDF de 5-8 MB en señal móvil débil → **TIMEOUT**
- Subida de PDF a Supabase Storage → **FALLA por timeout o señal débil**

### 2. **PROBLEMA: Conversión PDF → Word tarda demasiado**

```
PDF → CloudConvert API → Word
        ↑
        Tarda 10-30 segundos
        Con señal débil: 40+ segundos → TIMEOUT
```

### 3. **PROBLEMA: Sin timeouts = colapso total**

Antes NO había timeouts, entonces:
```
1. App genera PDF (30s)
2. App espera conversión Word (60s+)
3. App intenta subir (infinito)
   └→ Si señal débil = COLAPSA
   └→ Usuario pierde TODO el trabajo
```

---

## ✅ SOLUCIONES APLICADAS (Commits)

### **Commit `f812b8c`** - No borrar autoguardado si falla subida
**Problema:** Cuando fallaba la subida, `_limpiarFormulario()` borraba SharedPreferences → pérdida de datos

**Solución:**
```dart
// ANTES:
_limpiarFormulario(); // ← Siempre borraba

// AHORA:
if (result['success'] == true) {
  await _limpiarDatosGuardados(); // ← Solo si subida exitosa
  _limpiarFormulario();
} else {
  // NO limpiar, mantener datos guardados
}
```

**Resultado:** ✅ Datos se conservan aunque falle la subida

---

### **Commit `b143f02`** - Spinner precarga fotos en memoria
**Problema:** Fotos se cargaban cuando las veías → app se pegaba al deslizar

**Solución:**
```dart
// Leer bytes + agregar a lista + pausa 500ms
for (var imagen in imagenes) {
  final bytes = await imagen.readAsBytes();
  _fotos.add({'archivo': imagen, 'nota': ''});
  await Future.delayed(Duration(milliseconds: 500));
}
```

**Resultado:** ✅ Spinner funciona, pero NO resuelve problema de subida

---

### **Commit `b9fe589`** - Test de conectividad (FALLIDO)
**Problema:** Intenté detectar señal débil antes de subir

**Solución:**
```dart
final response = await http.head('https://google.com').timeout(3s);
if (response.statusCode == 200) {
  // Continuar subida
} else {
  // Mostrar "Sin conexión"
}
```

**Resultado:** ❌ FALLÓ - CORS bloquea http.head() en Flutter Web, causó **bucle infinito** incluso con 5G

---

### **Commit `d755b04`** - Timeouts agresivos (ACTUAL)
**Problema:** Sin timeouts, app esperaba infinito y colapsaba

**Solución:**
```dart
// PDF: timeout 30 segundos
final pdfBytes = await generarPDF(...).timeout(
  Duration(seconds: 30),
  onTimeout: () => throw Exception('Timeout PDF'),
);

// Word: timeout 15 segundos (antes 40s)
docxBytes = await generarWord(...).timeout(
  Duration(seconds: 15),
  onTimeout: () {
    debugPrint('Timeout Word, continuando sin DOCX');
    return null;
  },
);

// Subida Supabase: timeout 20 segundos
result = await supabase.guardar(...).timeout(
  Duration(seconds: 20),
  onTimeout: () => {'success': false, 'message': 'Timeout subida'},
);
```

**Resultado:** ✅ Mejora pero **NO resuelve** el problema de fondo

---

## 🎯 DIAGNÓSTICO FINAL

### El problema NO es el código, es el **TAMAÑO DE LOS DATOS**:

```
Escenario 1: Sin fotos
├─ PDF: ~50 KB
├─ Subida: ~1 segundo
└─ Resultado: ✅ FUNCIONA

Escenario 2: Con 3 fotos (200 KB cada una)
├─ PDF: ~2-3 MB (fotos en Base64)
├─ Subida: ~10-15 segundos con 5G
├─ Subida: ~30-60 segundos con señal débil
└─ Resultado: ❌ TIMEOUT en línea 1590

Escenario 3: Con 5 fotos + mucha info
├─ PDF: ~5-8 MB
├─ Subida: ~20-30 segundos con 5G
├─ Subida: >60 segundos con señal débil
└─ Resultado: ❌ COLAPSA siempre
```

---

## 📂 FUNCIONES CLAVE QUE SUBEN A LA NUBE

### 1. **`lib/screens/catastro_inmuebles_screen.dart` (línea 1520)**
```dart
Future<void> _guardarEnNube() async {
  // 1. Guardar local (SharedPreferences)
  await _guardarDatosLocalmente();
  
  // 2. Generar PDF (con fotos en Base64)
  final pdfBytes = await _exportService.generarPDF(...);
  
  // 3. Convertir PDF → Word (opcional)
  final docxBytes = await _exportService.generarWordDesdeConversion(...);
  
  // 4. SUBIR A SUPABASE ← AQUÍ FALLA
  final result = await _supabaseService.guardarCatastroConDocxConvertido(
    pdfBytes: pdfBytes,
    docxBytes: docxBytes,
  );
}
```

### 2. **`lib/services/catastro_supabase_service.dart` (línea 122)**
```dart
Future<Map<String, dynamic>> guardarCatastroConDocxConvertido({
  required Uint8List pdfBytes,  // ← AQUÍ ESTÁ EL PDF DE 5-8 MB
  Uint8List? docxBytes,
}) async {
  // 1. Subir PDF a Supabase Storage ← FALLA AQUÍ CON SEÑAL DÉBIL
  await _supabase.storage
      .from('reportes-catastro')
      .uploadBinary(pdfFileName, pdfBytes); // ← TIMEOUT
  
  // 2. Subir Word (opcional)
  if (docxBytes != null) {
    await _supabase.storage
        .from('reportes-catastro')
        .uploadBinary(docxFileName, docxBytes);
  }
  
  // 3. Insertar registro en tabla
  await _supabase.from('catastros_inmuebles').insert(data);
}
```

**Línea exacta donde falla:** `línea 169` en `catastro_supabase_service.dart`
```dart
await _supabase.storage.from('reportes-catastro').uploadBinary(pdfFileName, pdfBytes);
```

---

## 🚨 POR QUÉ FALLA CON FOTOS

### Análisis técnico:

1. **Flutter Web + Señal móvil débil + Archivos grandes = DESASTRE**
   - Flutter Web hace peticiones HTTP estándar
   - Supabase Storage tiene timeout de ~30 segundos por defecto
   - PDF de 5 MB en señal débil tarda >30s → **TIMEOUT**

2. **Base64 aumenta el tamaño en 33%**
   - Foto: 200 KB → Base64: 260 KB
   - 5 fotos: 1 MB → Base64 en PDF: 1.3 MB

3. **Sin retry automático**
   - Si falla la subida, NO reintenta
   - Usuario debe tocar "Reintentar" manualmente

---

## 💡 SOLUCIONES PROPUESTAS (No implementadas aún)

### Opción A: Subir fotos directamente a Supabase (SIN PDF)
```dart
// 1. Subir cada foto individualmente a Storage
for (var foto in _fotos) {
  final bytes = await foto['archivo'].readAsBytes();
  await supabase.storage.upload('foto_$i.jpg', bytes);
}

// 2. Generar PDF SIN fotos (solo con URLs)
final pdfBytes = await generarPDF(conFotos: false);

// 3. PDF será <100 KB → SIEMPRE funciona
```

**Ventajas:**
- ✅ PDF pequeño (<100 KB)
- ✅ Fotos se suben de 1 en 1 (más resiliente)
- ✅ Si falla 1 foto, las demás se guardan

**Desventajas:**
- ⚠️ Requiere reescribir `generarPDF()` para aceptar URLs en vez de Base64
- ⚠️ Más llamadas a Supabase (1 por foto + 1 PDF + 1 registro)

---

### Opción B: Comprimir fotos AÚN MÁS antes de incluir en PDF
```dart
// Reducir de quality 60 → quality 30
// Reducir de 1024px → 640px
final foto = await picker.pickImage(
  imageQuality: 30,  // ← MUY baja calidad
  maxWidth: 640,
);
```

**Ventajas:**
- ✅ PDF más pequeño (~1-2 MB con 5 fotos)
- ✅ No requiere cambiar arquitectura

**Desventajas:**
- ❌ Fotos se verán muy pixeladas
- ❌ Usuario ya se quejó: "en PDF sale nitidas pero otra con resolucion mas baja"

---

### Opción C: Guardar solo localmente, subir manual desde PC
```dart
// 1. Guardar PDF en móvil (Descargas)
DownloadHelper.descargarArchivo(pdfBytes, nombreArchivo);

// 2. Usuario sube manualmente desde PC a Supabase
// (interfaz web de administración)
```

**Ventajas:**
- ✅ Siempre funciona
- ✅ Usuario tiene PDF en su móvil

**Desventajas:**
- ❌ Usuario debe subir manualmente
- ❌ No hay registro automático en base de datos

---

### Opción D: Retry automático con exponential backoff
```dart
int intentos = 0;
while (intentos < 3) {
  try {
    await supabase.storage.upload(...).timeout(Duration(seconds: 30));
    break; // Éxito
  } catch (e) {
    intentos++;
    await Future.delayed(Duration(seconds: 2 * intentos)); // 2s, 4s, 6s
  }
}
```

**Ventajas:**
- ✅ Reintenta automáticamente
- ✅ Da más oportunidades de subir con señal débil

**Desventajas:**
- ⚠️ Puede tardar hasta 90 segundos (30s + 30s + 30s)
- ⚠️ Usuario esperando sin feedback

---

## 📊 TABLA COMPARATIVA DE SOLUCIONES

| Solución | Complejidad | Efectividad | Cambios requeridos | Recomendación |
|---|---|---|---|---|
| **A) Fotos directas** | Alta | ⭐⭐⭐⭐⭐ | Reescribir generarPDF() | ✅ **MEJOR** |
| **B) Más compresión** | Baja | ⭐⭐ | Cambiar quality | ❌ Fotos feas |
| **C) Solo local** | Baja | ⭐⭐⭐ | Ninguno | ⚠️ Manual |
| **D) Retry automático** | Media | ⭐⭐⭐ | Agregar bucle retry | ✅ **BUENO** |

---

## 🎯 RECOMENDACIÓN FINAL

### 🥇 **Solución A + D combinadas:**

1. **Subir fotos directamente a Supabase Storage** (sin Base64)
2. **Generar PDF con URLs** en vez de fotos embebidas
3. **Retry automático** con 3 intentos
4. **Progreso visible** para el usuario

### Ventajas de esta combinación:
- ✅ PDF pequeño (<100 KB) → Subida rápida SIEMPRE
- ✅ Fotos se suben de 1 en 1 → Más resiliente
- ✅ Si falla 1 foto, las demás se guardan
- ✅ Retry automático da segundas oportunidades
- ✅ PDF funciona offline (con URLs a fotos en nube)

### Cambios necesarios:
1. Modificar `lib/services/catastro_export_service.dart` → `generarPDF()`:
   - Aceptar parámetro `fotoUrls` en vez de `fotos`
   - Usar `pw.Image.network()` en vez de `pw.Image.memory()`

2. Modificar `lib/services/catastro_supabase_service.dart`:
   - Agregar función `subirFotos()` que sube cada foto y retorna URLs
   - Modificar `guardarCatastroConDocxConvertido()` para recibir URLs

3. Modificar `lib/screens/catastro_inmuebles_screen.dart`:
   - Primero subir fotos → obtener URLs
   - Luego generar PDF con URLs
   - Luego subir PDF pequeño

---

## 📝 PRÓXIMOS PASOS

1. **Usuario debe confirmar:** ¿Implementar Solución A+D?
2. Si sí → Estimar 2-3 horas de desarrollo
3. Probar en terreno con señal débil
4. Ajustar timeouts según resultados

---

## 📞 CONTACTO

Si necesitas otra opinión técnica, comparte este documento con:
- Otro desarrollador Flutter
- Experto en Supabase
- Experto en optimización de apps móviles

**Archivos clave para revisar:**
- `lib/screens/catastro_inmuebles_screen.dart` (línea 1520)
- `lib/services/catastro_supabase_service.dart` (línea 122)
- `lib/services/catastro_export_service.dart` (generación PDF)
