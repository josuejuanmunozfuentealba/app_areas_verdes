-- ============================================================================
-- AGREGAR COLUMNA DIRECCION A TABLA EXISTENTE
-- ============================================================================
-- Este script SOLO agrega la columna direccion sin afectar datos existentes
-- SEGURO: No elimina ni modifica las 80 plazas que ya tienes
-- ============================================================================

-- Agregar columna direccion (si no existe)
ALTER TABLE plazas ADD COLUMN IF NOT EXISTS direccion TEXT;

-- Verificar que la columna se agregó
SELECT 
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns 
WHERE table_name = 'plazas' 
AND column_name = 'direccion';

-- Verificar que los datos siguen intactos
SELECT COUNT(*) as total_plazas FROM plazas;

-- Mostrar primeras 5 plazas para verificar
SELECT id, nombre, direccion, comuna FROM plazas LIMIT 5;

-- ============================================================================
-- RESULTADO ESPERADO:
-- ============================================================================
-- ✅ Columna direccion agregada
-- ✅ 80 plazas intactas (77 originales + 3 nuevas)
-- ✅ Todos los datos preservados
-- ============================================================================