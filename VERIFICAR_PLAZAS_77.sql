-- =============================================
-- SCRIPT: Verificar existencia de las 77 plazas
-- Fecha: 2026-09-10
-- =============================================

-- 1. Contar total de plazas en la base de datos
SELECT 
    COUNT(*) as total_plazas,
    'Total de plazas en la base de datos' as descripcion
FROM plazas;

-- 2. Verificar si existen específicamente los IDs del 1 al 77
SELECT 
    'Plazas con ID entre 1 y 77' as descripcion,
    COUNT(*) as cantidad_encontrada,
    '77' as cantidad_esperada
FROM plazas 
WHERE CAST(id AS INTEGER) BETWEEN 1 AND 77;

-- 3. Listar cuáles de los 77 IDs SÍ existen
SELECT 
    id, 
    nombre, 
    comuna,
    CASE 
        WHEN direccion IS NOT NULL THEN '✅ Con dirección'
        ELSE '❌ Sin dirección'
    END as estado_direccion
FROM plazas 
WHERE CAST(id AS INTEGER) BETWEEN 1 AND 77
ORDER BY CAST(id AS INTEGER);

-- 4. Detectar cuáles de los 77 IDs FALTAN (no existen en la BD)
WITH ids_esperados AS (
    SELECT generate_series(1, 77) AS id_esperado
)
SELECT 
    ie.id_esperado::TEXT as id_faltante,
    'ID no existe en la base de datos' as observacion
FROM ids_esperados ie
LEFT JOIN plazas p ON p.id = ie.id_esperado::TEXT
WHERE p.id IS NULL
ORDER BY ie.id_esperado;

-- 5. Resumen de direcciones
SELECT 
    CASE 
        WHEN direccion IS NOT NULL THEN 'Con dirección'
        WHEN direccion IS NULL THEN 'Sin dirección'
    END as estado,
    COUNT(*) as cantidad
FROM plazas
WHERE CAST(id AS INTEGER) BETWEEN 1 AND 77
GROUP BY estado;

-- 6. Verificar columna 'direccion' existe
SELECT 
    column_name, 
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'plazas' 
AND column_name = 'direccion';
