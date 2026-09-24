-- Agregar campo correo_enviado a tabla inspecciones_urgencia
-- Fecha: 24/09/2026 15:30:00

-- Agregar campo correo_enviado (false por defecto)
ALTER TABLE inspecciones_urgencia 
ADD COLUMN IF NOT EXISTS correo_enviado BOOLEAN DEFAULT false;

-- Crear índice para búsquedas por estado de correo
CREATE INDEX IF NOT EXISTS idx_inspecciones_urgencia_correo_enviado 
ON inspecciones_urgencia(correo_enviado);

-- Comentario del campo
COMMENT ON COLUMN inspecciones_urgencia.correo_enviado IS 'Indica si el correo de alerta fue enviado al jefe';

-- Actualizar registros existentes (marcar como no enviados)
UPDATE inspecciones_urgencia 
SET correo_enviado = false 
WHERE correo_enviado IS NULL;