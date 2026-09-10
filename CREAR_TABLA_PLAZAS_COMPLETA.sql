-- ============================================================================
-- CREAR TABLA PLAZAS COMPLETA (Con columna direccion incluida)
-- ============================================================================
-- Este script crea la tabla plazas con TODOS los campos necesarios
-- Incluye la columna direccion que requiere el reporte Excel
-- ============================================================================

-- Crear tabla plazas si no existe  
CREATE TABLE IF NOT EXISTS plazas (  
  id TEXT PRIMARY KEY,  
  nombre TEXT NOT NULL,  
  tipo TEXT,  
  latitud DOUBLE PRECISION,  
  longitud DOUBLE PRECISION,
  direccion TEXT,  -- ⭐ COLUMNA AGREGADA PARA EL REPORTE
  estado TEXT DEFAULT 'Nuevo',  
  comuna TEXT DEFAULT 'Doñihue',  
  created_at TIMESTAMP DEFAULT NOW()  
);  
  
-- Índice para búsqueda por ubicación  
CREATE INDEX IF NOT EXISTS idx_plazas_coordenadas ON plazas(latitud, longitud);  

-- Índice para búsqueda por nombre
CREATE INDEX IF NOT EXISTS idx_plazas_nombre ON plazas(nombre);

-- Índice para búsqueda por comuna
CREATE INDEX IF NOT EXISTS idx_plazas_comuna ON plazas(comuna);
  
-- Habilitar RLS  
ALTER TABLE plazas ENABLE ROW LEVEL SECURITY;  
  
-- Eliminar políticas si existen (para evitar duplicados)  
DROP POLICY IF EXISTS "Permitir lectura pública plazas" ON plazas;  
DROP POLICY IF EXISTS "Permitir inserción pública plazas" ON plazas;  
DROP POLICY IF EXISTS "Permitir actualización pública plazas" ON plazas;  
  
-- Crear políticas públicas  
CREATE POLICY "Permitir lectura pública plazas"  
ON plazas FOR SELECT  
USING (true);  
  
CREATE POLICY "Permitir inserción pública plazas"  
ON plazas FOR INSERT  
WITH CHECK (true);  
  
CREATE POLICY "Permitir actualización pública plazas"  
ON plazas FOR UPDATE  
USING (true);

-- ============================================================================
-- VERIFICACIONES POST-CREACIÓN
-- ============================================================================

-- Verificar que la tabla se creó correctamente
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'plazas' 
ORDER BY ordinal_position;

-- Contar registros actuales
SELECT COUNT(*) as total_plazas FROM plazas;

-- ============================================================================
-- NOTAS IMPORTANTES:
-- ============================================================================
-- 1. Si la tabla YA EXISTE, este script NO la modificará
-- 2. Para agregar la columna direccion a tabla existente, usar:
--    ALTER TABLE plazas ADD COLUMN IF NOT EXISTS direccion TEXT;
-- 3. Después ejecutar ACTUALIZAR_DIRECCIONES_77_PLAZAS.sql
-- ============================================================================