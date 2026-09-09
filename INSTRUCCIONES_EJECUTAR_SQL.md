# 📋 Instrucciones para Ejecutar SQL en Supabase

## ⚠️ IMPORTANTE: Ejecutar ANTES de probar la app

Antes de probar el sistema de 3 modos, debes agregar las columnas necesarias en la base de datos.

---

## 🚀 Pasos para ejecutar el SQL

### 1️⃣ Abrir Supabase SQL Editor

1. Ir a: https://supabase.com/dashboard
2. Seleccionar tu proyecto
3. Ir a: **SQL Editor** (en el menú lateral izquierdo)
4. Click en **"+ New query"**

### 2️⃣ Copiar y pegar el script

Copia TODO el contenido del archivo: `AGREGAR_COLUMNAS_ESTADOS_MODOS.sql`

O copia esto directamente:

```sql
-- ========================================================
-- Script SQL para agregar columnas de estados por modo
-- ========================================================

-- 1. Agregar columnas para estados independientes
ALTER TABLE plazas 
ADD COLUMN IF NOT EXISTS estado_areas_verdes VARCHAR(20) DEFAULT NULL;

ALTER TABLE plazas 
ADD COLUMN IF NOT EXISTS estado_urgencias VARCHAR(20) DEFAULT NULL;

-- 2. Crear índices para búsquedas eficientes
CREATE INDEX IF NOT EXISTS idx_estado_areas_verdes ON plazas(estado_areas_verdes);
CREATE INDEX IF NOT EXISTS idx_estado_urgencias ON plazas(estado_urgencias);

-- 3. Comentarios descriptivos
COMMENT ON COLUMN plazas.estado_areas_verdes IS 
'Estado calculado desde última inspección de áreas verdes (Aseo, Césped, Arbolado, etc): Bueno/Regular/Malo';

COMMENT ON COLUMN plazas.estado IS 
'Estado calculado desde último catastro de inmuebles (Bancas, Juegos, Basureros, etc): Bueno/Regular/Malo';

COMMENT ON COLUMN plazas.estado_urgencias IS 
'Estado calculado desde última inspección de urgencia: Bueno/Regular/Malo';

-- 4. Verificar columnas creadas
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'plazas'
  AND column_name IN ('estado', 'estado_areas_verdes', 'estado_urgencias')
ORDER BY column_name;
```

### 3️⃣ Ejecutar el script

1. Click en **"Run"** (o presiona `Ctrl + Enter`)
2. Esperar a que termine (debe mostrar "Success")
3. Verificar que aparezcan las 3 columnas al final

---

## ✅ Resultado esperado

Deberías ver una tabla al final con estas 3 filas:

| column_name           | data_type      | is_nullable | column_default |
|-----------------------|----------------|-------------|----------------|
| estado                | varchar(20)    | YES         | NULL           |
| estado_areas_verdes   | varchar(20)    | YES         | NULL           |
| estado_urgencias      | varchar(20)    | YES         | NULL           |

---

## 🧪 Probar que funciona

Después de ejecutar el SQL:

1. **Recargar la app** (Ctrl + R o F5)
2. Debería aparecer la **pantalla de selección** con 3 botones:
   - 🌳 Áreas Verdes
   - 🏗️ Catastro de Inmuebles
   - ⚠️ Inspección de Urgencia
3. Al elegir un modo, el mapa debe mostrar:
   - **Top-left**: Indicador del modo actual (ej: "🌳 Áreas Verdes")
   - **Top-right**: Botón para cambiar modo (⇄)
   - **Marcadores**: Colores según el estado del modo seleccionado

---

## 🎨 Colores de los marcadores

Los colores cambian según el estado del **modo activo**:

- 🔵 **Azul** = Bueno / Excelente
- 🟠 **Naranja** = Regular
- 🔴 **Rojo** = Malo / Crítico
- ⚪ **Gris** = Sin evaluar (sin historial)

---

## ❓ Si algo no funciona

1. **Verificar que el SQL se ejecutó correctamente**
   - Revisar el resultado final (las 3 columnas)
   
2. **Limpiar caché de la app**
   - En el navegador: Ctrl + Shift + R
   - En Flutter: `flutter clean && flutter pub get`

3. **Revisar logs en consola**
   - Debe aparecer: `✅ Modo seleccionado: [nombre del modo]`

---

## 📞 Contacto

Si tienes problemas ejecutando el SQL o probando el sistema:
- Revisa los logs de la consola del navegador (F12)
- Verifica que Supabase esté conectado correctamente
- Comprueba que las credenciales estén actualizadas

---

**Fecha:** 2026-09-09  
**Versión:** 1.0.0  
**Commit:** Sistema de 3 modos de inspección
