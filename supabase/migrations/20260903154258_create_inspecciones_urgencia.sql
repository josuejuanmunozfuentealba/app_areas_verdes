-- Crear tabla para inspecciones de urgencia
CREATE TABLE IF NOT EXISTS inspecciones_urgencia (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  plaza_id TEXT NOT NULL,
  nombre_plaza TEXT NOT NULL,
  titulo TEXT NOT NULL,
  inspector TEXT NOT NULL,
  fecha_hora_registro TIMESTAMPTZ NOT NULL,
  campos JSONB DEFAULT '{}'::jsonb,
  observaciones TEXT[] DEFAULT ARRAY[]::TEXT[],
  pdf_url TEXT,
  word_url TEXT,
  fecha_legible TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índice para búsquedas por plaza
CREATE INDEX IF NOT EXISTS idx_inspecciones_urgencia_plaza_id 
ON inspecciones_urgencia(plaza_id);

-- Índice para búsquedas por fecha
CREATE INDEX IF NOT EXISTS idx_inspecciones_urgencia_fecha 
ON inspecciones_urgencia(fecha_hora_registro DESC);

-- Crear bucket de almacenamiento para reportes de urgencia
INSERT INTO storage.buckets (id, name, public)
VALUES ('reportes-urgencia', 'reportes-urgencia', true)
ON CONFLICT (id) DO NOTHING;

-- Política para permitir subida de archivos
CREATE POLICY "Permitir subida pública" ON storage.objects
FOR INSERT WITH CHECK (bucket_id = 'reportes-urgencia');

-- Política para permitir lectura pública
CREATE POLICY "Permitir lectura pública" ON storage.objects
FOR SELECT USING (bucket_id = 'reportes-urgencia');

-- Comentarios
COMMENT ON TABLE inspecciones_urgencia IS 'Inspecciones de urgencia para áreas verdes';
COMMENT ON COLUMN inspecciones_urgencia.campos IS 'Campos dinámicos ingresados por el usuario (JSON)';
COMMENT ON COLUMN inspecciones_urgencia.observaciones IS 'Array de observaciones de texto';
