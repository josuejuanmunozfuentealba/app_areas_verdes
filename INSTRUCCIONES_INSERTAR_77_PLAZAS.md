# 📋 INSTRUCCIONES: Insertar 74 Plazas Faltantes en Supabase

## 🎯 OBJETIVO
Completar las 77 plazas en Supabase (actualmente solo existen 3 plazas con IDs 1-3).

---

## 📊 SITUACIÓN ACTUAL

### En Supabase tienes:
- **3 plazas reales** (IDs: 1, 2, 3) → Las primeras que insertaste manualmente
- **13 plazas con IDs automáticos** (PLZ-462368, etc.) → Test data, puedes eliminarlas si quieres

### Lo que necesitas:
- **Insertar 74 plazas** (IDs: 4-77) → Para completar las 77 del código

---

## ✅ PASOS A SEGUIR

### PASO 1: Abrir Supabase SQL Editor
1. Ve a tu proyecto en [Supabase](https://supabase.com)
2. Haz clic en **SQL Editor** en el menú lateral
3. Crea un nuevo query

### PASO 2: Ejecutar el Script Principal
1. Abre el archivo: **`INSERTAR_74_PLAZAS_COMPLETO.sql`**
2. Copia TODO el contenido
3. Pégalo en el SQL Editor de Supabase
4. Haz clic en **RUN** o presiona `Ctrl + Enter`

**⏱️ Tiempo estimado:** ~10-15 segundos

### PASO 3: Verificar la Inserción
1. Abre el archivo: **`VERIFICAR_77_PLAZAS_FINAL.sql`**
2. Copia TODO el contenido
3. Pégalo en el SQL Editor de Supabase
4. Haz clic en **RUN**

**✅ Resultados esperados:**
```
Query 1: Total plazas IDs 1-77 → 77
Query 2: Plazas con direccion → 77
Query 3: Listado completo de 77 plazas
Query 4: 0 filas (ninguna sin direccion)
```

---

## 🎉 DESPUÉS DE EJECUTAR

### 1. **Esperar el Deploy de GitHub Actions**
- Ve a tu repositorio en GitHub
- Haz clic en la pestaña **Actions**
- Espera que el deploy termine (~5-8 minutos)
- Verifica que tenga un ✅ verde

### 2. **Probar el Excel de Fugas**
1. Abre tu aplicación: https://tu-usuario.github.io/app_areas_verdes/
2. Ve al Mapa Principal
3. Haz clic en cualquier plaza
4. Registra una fuga de prueba
5. Descarga el **Excel de Fugas**

**✅ El Excel debería mostrar:**
- ✅ Columna **Direccion** con datos
- ✅ Todas las 77 plazas disponibles
- ✅ Comuna (Doñihue o Lo Miranda)
- ✅ GPS (latitud, longitud)

---

## 📁 ARCHIVOS INCLUIDOS

| Archivo | Descripción |
|---------|-------------|
| `INSERTAR_74_PLAZAS_COMPLETO.sql` | Script principal - Inserta las 74 plazas faltantes |
| `VERIFICAR_77_PLAZAS_FINAL.sql` | Script de verificación - Confirma que todo está OK |
| `INSTRUCCIONES_INSERTAR_77_PLAZAS.md` | Este archivo de instrucciones |

---

## 🔧 QUÉ HACE EL SCRIPT

### 1. **Agrega columna `direccion`**
```sql
ALTER TABLE plazas 
ADD COLUMN IF NOT EXISTS direccion TEXT;
```

### 2. **Inserta 74 plazas** (IDs 4-77)
Cada INSERT incluye:
- `id` → Texto: '4', '5', ..., '77'
- `nombre` → Nombre de la plaza
- `tipo` → Plaza, Plaza Dura, Bandejon, etc.
- `comuna` → Doñihue o Lo Miranda
- `latitud` → Coordenada GPS (DECIMAL)
- `longitud` → Coordenada GPS (DECIMAL)
- `direccion` → Dirección completa
- `activo` → true
- `estado` → 'Operativa'
- `estado_areas_verdes` → 'No aplica'
- `estado_urgencias` → 'No'

### 3. **Actualiza direcciones de plazas 1-3**
```sql
UPDATE plazas 
SET direccion = '...'
WHERE id IN ('1', '2', '3');
```

---

## 🚨 SOLUCIÓN DE PROBLEMAS

### ❌ Error: "duplicate key value"
**Causa:** Algunas plazas ya existen en la base de datos

**Solución:**
```sql
-- Eliminar plazas duplicadas primero
DELETE FROM plazas 
WHERE id IN ('4','5','6',...); -- Los IDs que estén duplicados

-- Luego ejecutar el script principal nuevamente
```

### ❌ Error: "column direccion already exists"
**Causa:** La columna ya fue creada anteriormente

**Solución:** Ignora este error, continúa con el resto del script

### ❌ Error: "invalid input syntax for type numeric"
**Causa:** Problema con coordenadas GPS

**Solución:** Verifica que las columnas `latitud` y `longitud` sean tipo `DECIMAL` o `NUMERIC`

---

## 📞 RESUMEN RÁPIDO

```bash
1. Abrir Supabase SQL Editor
2. Copiar y ejecutar: INSERTAR_74_PLAZAS_COMPLETO.sql
3. Copiar y ejecutar: VERIFICAR_77_PLAZAS_FINAL.sql
4. Confirmar: 77 plazas ✅
5. Esperar GitHub Actions deploy (~5-8 min)
6. Probar Excel de Fugas con direcciones ✅
```

---

## ✅ CHECKLIST FINAL

- [ ] Script principal ejecutado sin errores
- [ ] Verificación muestra 77 plazas
- [ ] Todas las plazas tienen direccion
- [ ] GitHub Actions deploy completado (✅ verde)
- [ ] Excel de Fugas descarga correctamente
- [ ] Excel muestra columna Direccion con datos
- [ ] Excel muestra Comuna y GPS

---

🎯 **¡Listo! Con esto tendrás las 77 plazas completas en Supabase y el reporte Excel funcionando correctamente.**
