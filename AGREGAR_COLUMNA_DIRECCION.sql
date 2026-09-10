-- =============================================
-- SCRIPT: Agregar columna 'direccion' a tabla plazas
-- Fecha: 2026-09-10
-- =============================================

-- Paso 1: Agregar columna 'direccion' (si no existe)
ALTER TABLE plazas 
ADD COLUMN IF NOT EXISTS direccion TEXT;

-- Paso 2: Actualizar direcciones de las plazas existentes
-- (Datos tomados de main.dart líneas 402-1000)

UPDATE plazas SET direccion = 'Delfin Carvallo con Subteniente Valenzuela' WHERE id = '1';
UPDATE plazas SET direccion = 'Letras Turisticas Donihue en H-10 con H-286' WHERE id = '2';
UPDATE plazas SET direccion = 'Cabo Moena entre H-286 y H-276' WHERE id = '3';
UPDATE plazas SET direccion = 'Monumento Portal Lo Miranda en H-30 con H-270' WHERE id = '4';
UPDATE plazas SET direccion = 'A. Estacion con Estacion Carrera' WHERE id = '5';
UPDATE plazas SET direccion = 'Villa Centro' WHERE id = '6';
UPDATE plazas SET direccion = 'Calle Gabriela Mistral' WHERE id = '7';
UPDATE plazas SET direccion = 'Avenida San Martin con Psje Los Almendros' WHERE id = '8';
UPDATE plazas SET direccion = 'Calle Los Cerezos con Los Copihues' WHERE id = '9';
UPDATE plazas SET direccion = 'Avenida Bernardo O Higgins entre Balmaceda y Carrera' WHERE id = '10';
UPDATE plazas SET direccion = 'Area Verde Caupolicam' WHERE id = '49';
UPDATE plazas SET direccion = 'Rosa Zuniga con Psje. Juanito y Delfina' WHERE id = '51';
UPDATE plazas SET direccion = 'Pasaje Violeta Parra con Psje Victor Jara' WHERE id = '28';
UPDATE plazas SET direccion = 'Los Cerezos con Los Aromos' WHERE id = '55';
UPDATE plazas SET direccion = 'Llave Agua Gruta Las Palmas' WHERE id = '56';
UPDATE plazas SET direccion = 'Monumento Peñon Virgen Carmen Entrada Donihue' WHERE id = '57';
UPDATE plazas SET direccion = 'Monumento Virgen Pabellon Central Donihue' WHERE id = '58';
UPDATE plazas SET direccion = 'Plaza del Taxista' WHERE id = '59';
UPDATE plazas SET direccion = 'Cancha Sintetica Lo Miranda' WHERE id = '62';
UPDATE plazas SET direccion = 'Avda. Bernardo O Higgins con Balmaceda' WHERE id = '69';
UPDATE plazas SET direccion = 'Avda. Lo Miranda con Avda. Cachapoal' WHERE id = '71';
UPDATE plazas SET direccion = 'Avenida Cerrillos con Avenida Estacion' WHERE id = '76';

-- Verificar resultados
SELECT id, nombre, direccion FROM plazas WHERE direccion IS NOT NULL ORDER BY id;
