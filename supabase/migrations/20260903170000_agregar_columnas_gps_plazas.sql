-- Agregar columnas para plazas no mapeadas registradas desde GPS
ALTER TABLE plazas ADD COLUMN IF NOT EXISTS tipo TEXT;
ALTER TABLE plazas ADD COLUMN IF NOT EXISTS latitud DOUBLE PRECISION;
ALTER TABLE plazas ADD COLUMN IF NOT EXISTS longitud DOUBLE PRECISION;

-- Índice para búsqueda por ubicación (optimiza consultas geoespaciales)
CREATE INDEX IF NOT EXISTS idx_plazas_coordenadas ON plazas(latitud, longitud);

-- Comentarios para documentación
COMMENT ON COLUMN plazas.tipo IS 'Tipo de área verde: Plaza, Parque, Bandejón, etc.';
COMMENT ON COLUMN plazas.latitud IS 'Latitud GPS del área verde';
COMMENT ON COLUMN plazas.longitud IS 'Longitud GPS del área verde';
