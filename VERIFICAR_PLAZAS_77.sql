-- =============================================
-- SCRIPT: Verificar existencia de las 77 plazas
-- Fecha: 2026-09-10
-- =============================================

-- 1. Contar total de plazas en la base de datos
SELECT 
    COUNT(*) as total_plazas,
    'Total de plazas en la base de datos' as descripcion
FROM plazas;

-- 2. Verificar si existen los IDs '1', '2', ... '77' (como texto)
SELECT 
    'Plazas con ID entre 1 y 77' as descripcion,
    COUNT(*) as cantidad_encontrada,
    '77' as cantidad_esperada
FROM plazas 
WHERE id IN (
    '1','2','3','4','5','6','7','8','9','10',
    '11','12','13','14','15','16','17','18','19','20',
    '21','22','23','24','25','26','27','28','29','30',
    '31','32','33','34','35','36','37','38','39','40',
    '41','42','43','44','45','46','47','48','49','50',
    '51','52','53','54','55','56','57','58','59','60',
    '61','62','63','64','65','66','67','68','69','70',
    '71','72','73','74','75','76','77'
);

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
WHERE id IN (
    '1','2','3','4','5','6','7','8','9','10',
    '11','12','13','14','15','16','17','18','19','20',
    '21','22','23','24','25','26','27','28','29','30',
    '31','32','33','34','35','36','37','38','39','40',
    '41','42','43','44','45','46','47','48','49','50',
    '51','52','53','54','55','56','57','58','59','60',
    '61','62','63','64','65','66','67','68','69','70',
    '71','72','73','74','75','76','77'
)
ORDER BY 
    CASE 
        WHEN id ~ '^[0-9]+$' THEN CAST(id AS INTEGER)
        ELSE 999
    END;

-- 4. Detectar cuáles de los 77 IDs FALTAN (no existen en la BD)
WITH ids_esperados AS (
    SELECT unnest(ARRAY[
        '1','2','3','4','5','6','7','8','9','10',
        '11','12','13','14','15','16','17','18','19','20',
        '21','22','23','24','25','26','27','28','29','30',
        '31','32','33','34','35','36','37','38','39','40',
        '41','42','43','44','45','46','47','48','49','50',
        '51','52','53','54','55','56','57','58','59','60',
        '61','62','63','64','65','66','67','68','69','70',
        '71','72','73','74','75','76','77'
    ]) AS id_esperado
)
SELECT 
    ie.id_esperado as id_faltante,
    'ID no existe en la base de datos' as observacion
FROM ids_esperados ie
LEFT JOIN plazas p ON p.id = ie.id_esperado
WHERE p.id IS NULL
ORDER BY CAST(ie.id_esperado AS INTEGER);

-- 5. Resumen de direcciones
SELECT 
    CASE 
        WHEN direccion IS NOT NULL THEN 'Con dirección'
        WHEN direccion IS NULL THEN 'Sin dirección'
    END as estado,
    COUNT(*) as cantidad
FROM plazas
WHERE id IN (
    '1','2','3','4','5','6','7','8','9','10',
    '11','12','13','14','15','16','17','18','19','20',
    '21','22','23','24','25','26','27','28','29','30',
    '31','32','33','34','35','36','37','38','39','40',
    '41','42','43','44','45','46','47','48','49','50',
    '51','52','53','54','55','56','57','58','59','60',
    '61','62','63','64','65','66','67','68','69','70',
    '71','72','73','74','75','76','77'
)
GROUP BY estado;

-- 6. Verificar columna 'direccion' existe
SELECT 
    column_name, 
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'plazas' 
AND column_name = 'direccion';
