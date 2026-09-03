-- ============================================================================
-- MIGRACIÓN: Agregar columna fotos_urls a tabla catastros_inmuebles
-- Fecha: 2026-09-02
-- Propósito: Almacenar URLs de fotos separadas en vez de embedarlas en PDF
-- ============================================================================

-- Agregar columna fotos_urls tipo JSONB (permite almacenar array de URLs)
ALTER TABLE catastros_inmuebles 
ADD COLUMN IF NOT EXISTS fotos_urls JSONB DEFAULT '[]'::jsonb;

-- Agregar comentario a la columna
COMMENT ON COLUMN catastros_inmuebles.fotos_urls IS 
'Array de URLs públicas de fotos almacenadas en Supabase Storage (bucket: reportes-catastro/evidencias/)';

-- Crear índice GIN para búsquedas rápidas en el JSON
CREATE INDEX IF NOT EXISTS idx_catastros_fotos_urls 
ON catastros_inmuebles USING GIN (fotos_urls);

-- Verificar estructura final
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'catastros_inmuebles'
AND column_name = 'fotos_urls';
