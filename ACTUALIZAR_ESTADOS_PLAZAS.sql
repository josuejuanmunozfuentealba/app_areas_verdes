-- ========================================================
-- Script SQL para actualizar el campo 'estado' en la tabla 'plazas'
-- basándose en el último catastro registrado de cada plaza
-- ========================================================
--
-- Ejecutar este script en Supabase SQL Editor para que las plazas
-- que ya tienen catastros muestren el color correcto en el mapa.
--
-- Fecha: 2026-09-09
-- ========================================================

UPDATE plazas
SET estado = (
  SELECT estado_general
  FROM catastros_inmuebles
  WHERE catastros_inmuebles.plaza_id = plazas.id
  ORDER BY fecha_hora_registro DESC
  LIMIT 1
)
WHERE id IN (
  SELECT DISTINCT plaza_id 
  FROM catastros_inmuebles
);

-- Verificar cuántas plazas se actualizaron
SELECT 
  estado, 
  COUNT(*) as total
FROM plazas
WHERE estado IS NOT NULL
GROUP BY estado
ORDER BY 
  CASE estado
    WHEN 'Malo' THEN 1
    WHEN 'Regular' THEN 2
    WHEN 'Bueno' THEN 3
    ELSE 4
  END;

-- Ver plazas actualizadas con sus estados
SELECT 
  id,
  nombre,
  estado,
  updated_at
FROM plazas
WHERE estado IN ('Malo', 'Regular', 'Bueno')
ORDER BY updated_at DESC
LIMIT 20;
