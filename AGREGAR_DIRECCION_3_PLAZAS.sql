-- =============================================
-- Agregar columna direccion y actualizar las 3 plazas REALES
-- =============================================

-- Paso 1: Agregar columna direccion
ALTER TABLE plazas ADD COLUMN IF NOT EXISTS direccion TEXT;

-- Paso 2: Actualizar SOLO las 3 plazas reales (ID 1, 2, 3)
UPDATE plazas SET direccion = 'Delfin Carvallo con Subteniente Valenzuela' WHERE id = '1';
UPDATE plazas SET direccion = 'Letras Turisticas Donihue en H-10 con H-286' WHERE id = '2';
UPDATE plazas SET direccion = 'Cabo Moena entre H-286 y H-276' WHERE id = '3';

-- Verificar
SELECT id, nombre, direccion, comuna, latitud, longitud 
FROM plazas 
WHERE id IN ('1', '2', '3')
ORDER BY id;
