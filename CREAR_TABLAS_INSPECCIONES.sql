-- ========================================================
-- Script SQL para crear tablas de inspecciones
-- ========================================================
--
-- Este script crea las tablas necesarias para guardar:
-- 1. Inspecciones Técnicas (Áreas Verdes)
-- 2. Inspecciones de Urgencia
--
-- Fecha: 2026-09-09
-- ========================================================

-- 1. Tabla: inspecciones_tecnicas (Áreas Verdes: Aseo, Césped, Arbolado, etc.)
CREATE TABLE IF NOT EXISTS inspecciones_tecnicas (
    id BIGSERIAL PRIMARY KEY,
    plaza_id TEXT NOT NULL REFERENCES plazas(id) ON DELETE CASCADE,
    nombre_plaza TEXT NOT NULL,
    inspector TEXT NOT NULL,
    fecha_hora_registro TIMESTAMP WITH TIME ZONE NOT NULL,
    fecha_legible TEXT NOT NULL,
    estado_general TEXT NOT NULL, -- 'Bueno', 'Regular', 'Malo'
    evaluaciones JSONB NOT NULL, -- Evaluaciones de cada ítem
    observaciones JSONB NOT NULL, -- Observaciones de cada ítem
    pdf_url TEXT NOT NULL,
    correo_enviado BOOLEAN DEFAULT FALSE,
    fecha_envio_correo TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Tabla: inspecciones_urgencias (Urgencias: Problemas críticos)
CREATE TABLE IF NOT EXISTS inspecciones_urgencias (
    id BIGSERIAL PRIMARY KEY,
    plaza_id TEXT NOT NULL REFERENCES plazas(id) ON DELETE CASCADE,
    nombre_plaza TEXT NOT NULL,
    inspector TEXT NOT NULL,
    fecha_hora_registro TIMESTAMP WITH TIME ZONE NOT NULL,
    fecha_legible TEXT NOT NULL,
    estado_general TEXT NOT NULL, -- 'Bueno', 'Regular', 'Malo'
    evaluaciones JSONB NOT NULL, -- Evaluaciones de cada ítem
    observaciones JSONB NOT NULL, -- Observaciones de cada ítem
    pdf_url TEXT NOT NULL,
    correo_enviado BOOLEAN DEFAULT FALSE,
    fecha_envio_correo TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Crear índices para búsquedas eficientes
CREATE INDEX IF NOT EXISTS idx_inspecciones_tecnicas_plaza_id ON inspecciones_tecnicas(plaza_id);
CREATE INDEX IF NOT EXISTS idx_inspecciones_tecnicas_fecha ON inspecciones_tecnicas(fecha_hora_registro DESC);
CREATE INDEX IF NOT EXISTS idx_inspecciones_tecnicas_estado ON inspecciones_tecnicas(estado_general);

CREATE INDEX IF NOT EXISTS idx_inspecciones_urgencias_plaza_id ON inspecciones_urgencias(plaza_id);
CREATE INDEX IF NOT EXISTS idx_inspecciones_urgencias_fecha ON inspecciones_urgencias(fecha_hora_registro DESC);
CREATE INDEX IF NOT EXISTS idx_inspecciones_urgencias_estado ON inspecciones_urgencias(estado_general);

-- 4. Crear buckets de almacenamiento (si no existen)
-- NOTA: Estos comandos se ejecutan desde la interfaz de Supabase Storage
-- O desde la API de administración, NO desde SQL Editor

-- Bucket: reportes-inspecciones (para inspecciones técnicas)
-- INSERT INTO storage.buckets (id, name, public) VALUES ('reportes-inspecciones', 'reportes-inspecciones', true) ON CONFLICT DO NOTHING;

-- Bucket: reportes-urgencias (para inspecciones de urgencia)
-- INSERT INTO storage.buckets (id, name, public) VALUES ('reportes-urgencias', 'reportes-urgencias', true) ON CONFLICT DO NOTHING;

-- 5. Comentarios descriptivos
COMMENT ON TABLE inspecciones_tecnicas IS 
'Historial de inspecciones técnicas de áreas verdes (Aseo, Césped, Arbolado, Riego, etc.)';

COMMENT ON TABLE inspecciones_urgencias IS 
'Historial de inspecciones de urgencia (Problemas críticos que requieren atención inmediata)';

-- 6. Verificar tablas creadas
SELECT 
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name IN ('inspecciones_tecnicas', 'inspecciones_urgencias')
ORDER BY table_name, ordinal_position;
