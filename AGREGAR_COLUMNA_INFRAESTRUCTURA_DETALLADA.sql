-- ========================================================
-- Script SQL para agregar columna de infraestructura detallada
-- ========================================================
--
-- Este script agrega una columna JSONB a la tabla catastros_inmuebles
-- para almacenar información detallada de infraestructura
--
-- Fecha: 2026-09-09
-- ========================================================

-- 1. Agregar columna para infraestructura detallada
ALTER TABLE catastros_inmuebles 
ADD COLUMN IF NOT EXISTS infraestructura_detallada JSONB;

-- 2. Crear índice GIN para búsquedas eficientes en JSONB
CREATE INDEX IF NOT EXISTS idx_infraestructura_detallada 
ON catastros_inmuebles USING GIN (infraestructura_detallada);

-- 3. Verificar que la columna se creó correctamente
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'catastros_inmuebles'
  AND column_name = 'infraestructura_detallada';
