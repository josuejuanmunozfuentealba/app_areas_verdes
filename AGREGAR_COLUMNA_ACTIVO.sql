-- ============================================================================
-- SCRIPT PARA AGREGAR COLUMNA "activo" A LA TABLA "plazas"
-- Implementación de Soft Delete (Borrado Lógico)
-- ============================================================================

-- 1. Agregar columna "activo" (BOOLEAN, por defecto TRUE)
ALTER TABLE plazas
ADD COLUMN IF NOT EXISTS activo BOOLEAN DEFAULT true;

-- 2. Agregar columna "fecha_eliminacion" (opcional, para auditoría)
ALTER TABLE plazas
ADD COLUMN IF NOT EXISTS fecha_eliminacion TIMESTAMPTZ;

-- 3. Actualizar todas las plazas existentes como activas (por si acaso)
UPDATE plazas
SET activo = true
WHERE activo IS NULL;

-- 4. Crear índice para mejorar performance de consultas con filtro activo=true
CREATE INDEX IF NOT EXISTS idx_plazas_activo ON plazas(activo);

-- 5. Verificar que se aplicó correctamente
SELECT 
    column_name, 
    data_type, 
    column_default
FROM information_schema.columns
WHERE table_name = 'plazas'
AND column_name IN ('activo', 'fecha_eliminacion');

-- ============================================================================
-- RESULTADO ESPERADO:
-- column_name        | data_type | column_default
-- -------------------|-----------|---------------
-- activo             | boolean   | true
-- fecha_eliminacion  | timestamp | NULL
-- ============================================================================

-- 6. Consulta de prueba: Contar plazas activas vs eliminadas
SELECT 
    activo,
    COUNT(*) as total
FROM plazas
GROUP BY activo;
