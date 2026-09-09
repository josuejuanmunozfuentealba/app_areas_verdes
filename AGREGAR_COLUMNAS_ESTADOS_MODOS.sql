-- ========================================================
-- Script SQL para agregar columnas de estados por modo
-- ========================================================
--
-- Este script agrega columnas para los 3 modos de inspección
--
-- Fecha: 2026-09-09
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
