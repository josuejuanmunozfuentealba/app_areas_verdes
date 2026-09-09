# 📋 Instrucciones para Crear Tablas y Buckets en Supabase

## ⚠️ IMPORTANTE: Ejecutar AHORA para que funcionen los 3 modos

---

## 🗄️ Paso 1: Crear las tablas (SQL)

1. **Abre Supabase SQL Editor:**
   - Ve a: https://supabase.com/dashboard
   - Selecciona tu proyecto
   - Click en **"SQL Editor"** (menú izquierdo)
   - Click en **"+ New query"**

2. **Copia y pega este SQL:**

```sql
-- 1. Tabla: inspecciones_tecnicas (Áreas Verdes)
CREATE TABLE IF NOT EXISTS inspecciones_tecnicas (
    id BIGSERIAL PRIMARY KEY,
    plaza_id TEXT NOT NULL REFERENCES plazas(id) ON DELETE CASCADE,
    nombre_plaza TEXT NOT NULL,
    inspector TEXT NOT NULL,
    fecha_hora_registro TIMESTAMP WITH TIME ZONE NOT NULL,
    fecha_legible TEXT NOT NULL,
    estado_general TEXT NOT NULL,
    evaluaciones JSONB NOT NULL,
    observaciones JSONB NOT NULL,
    pdf_url TEXT NOT NULL,
    correo_enviado BOOLEAN DEFAULT FALSE,
    fecha_envio_correo TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Tabla: inspecciones_urgencias
CREATE TABLE IF NOT EXISTS inspecciones_urgencias (
    id BIGSERIAL PRIMARY KEY,
    plaza_id TEXT NOT NULL REFERENCES plazas(id) ON DELETE CASCADE,
    nombre_plaza TEXT NOT NULL,
    inspector TEXT NOT NULL,
    fecha_hora_registro TIMESTAMP WITH TIME ZONE NOT NULL,
    fecha_legible TEXT NOT NULL,
    estado_general TEXT NOT NULL,
    evaluaciones JSONB NOT NULL,
    observaciones JSONB NOT NULL,
    pdf_url TEXT NOT NULL,
    correo_enviado BOOLEAN DEFAULT FALSE,
    fecha_envio_correo TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Crear índices
CREATE INDEX IF NOT EXISTS idx_inspecciones_tecnicas_plaza_id ON inspecciones_tecnicas(plaza_id);
CREATE INDEX IF NOT EXISTS idx_inspecciones_tecnicas_fecha ON inspecciones_tecnicas(fecha_hora_registro DESC);

CREATE INDEX IF NOT EXISTS idx_inspecciones_urgencias_plaza_id ON inspecciones_urgencias(plaza_id);
CREATE INDEX IF NOT EXISTS idx_inspecciones_urgencias_fecha ON inspecciones_urgencias(fecha_hora_registro DESC);
```

3. **Ejecuta:**
   - Click en **"Run"** o `Ctrl + Enter`
   - Deberías ver: **"Success"** ✅

---

## 📦 Paso 2: Crear los buckets de almacenamiento

### Opción A: Desde la interfaz web (MÁS FÁCIL) ⭐

1. **Abre Supabase Storage:**
   - En tu proyecto de Supabase
   - Click en **"Storage"** (menú izquierdo)
   - Click en **"New bucket"**

2. **Crear bucket 1:**
   - Name: `reportes-inspecciones`
   - Public: ✅ (activar)
   - Click en **"Create bucket"**

3. **Crear bucket 2:**
   - Click en **"New bucket"** otra vez
   - Name: `reportes-urgencias`
   - Public: ✅ (activar)
   - Click en **"Create bucket"**

4. **Verificar:**
   - Deberías ver 3 buckets ahora:
     - `reportes-catastro` (ya existe)
     - `reportes-inspecciones` ⭐ NUEVO
     - `reportes-urgencias` ⭐ NUEVO

---

### Opción B: Desde SQL (si prefieres)

```sql
-- Crear buckets
INSERT INTO storage.buckets (id, name, public) 
VALUES ('reportes-inspecciones', 'reportes-inspecciones', true) 
ON CONFLICT DO NOTHING;

INSERT INTO storage.buckets (id, name, public) 
VALUES ('reportes-urgencias', 'reportes-urgencias', true) 
ON CONFLICT DO NOTHING;
```

---

## ✅ Verificar que todo está creado

### Verificar tablas:

```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_name IN ('inspecciones_tecnicas', 'inspecciones_urgencias');
```

Deberías ver 2 filas ✅

### Verificar buckets:

```sql
SELECT id, name, public 
FROM storage.buckets 
WHERE name IN ('reportes-catastro', 'reportes-inspecciones', 'reportes-urgencias');
```

Deberías ver 3 filas ✅

---

## 🚀 Después de crear todo

1. **Recarga la app**
2. **Selecciona "Áreas Verdes"**
3. **Haz una inspección técnica**
4. **Guarda el reporte**
5. **El marcador debería cambiar de color** según el estado ✅

---

## 🎨 Funcionamiento esperado

| Modo | Tabla | Bucket | Campo actualizado |
|------|-------|--------|-------------------|
| 🌳 Áreas Verdes | `inspecciones_tecnicas` | `reportes-inspecciones` | `estado_areas_verdes` |
| 🏗️ Catastro Inmuebles | `catastros_inmuebles` | `reportes-catastro` | `estado` |
| ⚠️ Urgencias | `inspecciones_urgencias` | `reportes-urgencias` | `estado_urgencias` |

---

## ❓ Si algo no funciona

1. Verificar que las tablas existen
2. Verificar que los buckets existen y son públicos
3. Revisar logs de consola (F12)
4. Verificar que las columnas `estado_areas_verdes` y `estado_urgencias` existen en tabla `plazas`

---

**Fecha:** 2026-09-09  
**Versión:** 1.0.0  
**Commit:** Servicios Supabase para inspecciones
