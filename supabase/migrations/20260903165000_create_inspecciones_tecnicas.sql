-- Tabla para Inspecciones Técnicas
CREATE TABLE IF NOT EXISTS inspecciones_tecnicas (
  id TEXT PRIMARY KEY,
  plaza_id TEXT NOT NULL,
  nombre_plaza TEXT NOT NULL,
  inspector TEXT,
  correo_supervisor TEXT,
  fecha_hora_registro TIMESTAMP NOT NULL,
  fecha_legible TEXT,
  estado_general TEXT,
  evaluaciones JSONB DEFAULT '{}',
  observaciones JSONB DEFAULT '{}',
  pdf_url TEXT,
  word_url TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Índices para búsquedas rápidas
CREATE INDEX IF NOT EXISTS idx_inspecciones_tecnicas_plaza_id ON inspecciones_tecnicas(plaza_id);
CREATE INDEX IF NOT EXISTS idx_inspecciones_tecnicas_created_at ON inspecciones_tecnicas(created_at DESC);

-- Habilitar RLS (Row Level Security)
ALTER TABLE inspecciones_tecnicas ENABLE ROW LEVEL SECURITY;

-- Política: Permitir lectura pública
CREATE POLICY "Permitir lectura pública inspecciones_tecnicas"
ON inspecciones_tecnicas FOR SELECT
USING (true);

-- Política: Permitir inserción pública
CREATE POLICY "Permitir inserción pública inspecciones_tecnicas"
ON inspecciones_tecnicas FOR INSERT
WITH CHECK (true);

-- Política: Permitir actualización pública
CREATE POLICY "Permitir actualización pública inspecciones_tecnicas"
ON inspecciones_tecnicas FOR UPDATE
USING (true);

-- Política: Permitir eliminación pública
CREATE POLICY "Permitir eliminación pública inspecciones_tecnicas"
ON inspecciones_tecnicas FOR DELETE
USING (true);
