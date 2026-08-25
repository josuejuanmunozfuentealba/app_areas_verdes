# Configuración de Supabase para Módulo de Catastro de Inmuebles

## 📋 Tabla de Base de Datos

Ejecuta este SQL en el editor SQL de Supabase:

```sql
CREATE TABLE catastros_inmuebles (
  id SERIAL PRIMARY KEY,
  plaza_id TEXT NOT NULL,
  nombre_plaza TEXT NOT NULL,
  inspector TEXT NOT NULL,
  fecha_hora_registro TIMESTAMP NOT NULL,
  fecha_legible TEXT NOT NULL,
  estado_general TEXT NOT NULL,
  evaluaciones JSONB NOT NULL,
  observaciones JSONB NOT NULL,
  pdf_url TEXT NOT NULL,
  word_url TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para mejorar el rendimiento
CREATE INDEX idx_catastros_plaza_id ON catastros_inmuebles(plaza_id);
CREATE INDEX idx_catastros_fecha ON catastros_inmuebles(fecha_hora_registro DESC);

-- Habilitar Row Level Security (RLS)
ALTER TABLE catastros_inmuebles ENABLE ROW LEVEL SECURITY;

-- Política para permitir lectura pública
CREATE POLICY "Permitir lectura pública de catastros"
ON catastros_inmuebles
FOR SELECT
TO public
USING (true);

-- Política para permitir inserción pública (ajustar según necesidad)
CREATE POLICY "Permitir inserción pública de catastros"
ON catastros_inmuebles
FOR INSERT
TO public
WITH CHECK (true);
```

## 🗄️ Storage Bucket

1. Ve a **Storage** en Supabase
2. Crea un nuevo bucket llamado: `reportes-catastro`
3. Configuración del bucket:
   - **Public bucket**: ✅ Activado (para permitir descargas directas)
   - **Allowed MIME types**: `application/pdf, application/msword, application/vnd.openxmlformats-officedocument.wordprocessingml.document`
   - **File size limit**: `10 MB` (ajustable según necesidad)

### Políticas del Bucket

Ejecuta estas políticas en el editor de políticas del bucket:

```sql
-- Política de lectura pública
CREATE POLICY "Permitir lectura pública de reportes"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'reportes-catastro');

-- Política de inserción pública (ajustar según necesidad)
CREATE POLICY "Permitir subida pública de reportes"
ON storage.objects FOR INSERT
TO public
WITH CHECK (bucket_id = 'reportes-catastro');
```

## ✅ Verificación de Configuración

1. **Verificar tabla creada**:
   ```sql
   SELECT * FROM catastros_inmuebles LIMIT 1;
   ```

2. **Verificar bucket**:
   - Ve a Storage > reportes-catastro
   - Debería aparecer vacío pero sin errores

3. **Probar en la app**:
   - Navega a una plaza en el mapa
   - Click en "Catastro de Inmuebles"
   - Completa el formulario de evaluación
   - Agrega fotos
   - Click en "Guardar y Subir a la Nube"
   - Verifica que aparezca en la pestaña "HISTORIAL NUBE"
   - Descarga el PDF y Word desde el historial

## 🔐 Seguridad Recomendada (Producción)

Para un entorno de producción, se recomienda:

1. **Autenticación de usuarios**:
   ```sql
   -- Cambiar políticas para requerir autenticación
   ALTER POLICY "Permitir inserción pública de catastros"
   ON catastros_inmuebles
   WITH CHECK (auth.uid() IS NOT NULL);
   ```

2. **Limitar tamaño de archivos**:
   - Configurar en el bucket: max 5-10 MB por archivo

3. **Rate limiting**:
   - Configurar límites de subida en Supabase Dashboard

## 📊 Estructura de Datos

### Tabla `catastros_inmuebles`

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | SERIAL | ID único autoincremental |
| `plaza_id` | TEXT | ID de la plaza evaluada |
| `nombre_plaza` | TEXT | Nombre de la plaza |
| `inspector` | TEXT | Nombre del inspector |
| `fecha_hora_registro` | TIMESTAMP | Fecha/hora ISO 8601 |
| `fecha_legible` | TEXT | Fecha/hora formato DD/MM/YYYY HH:mm:ss |
| `estado_general` | TEXT | Estado calculado: Bueno/Regular/Malo |
| `evaluaciones` | JSONB | Mapa de criterio -> evaluación |
| `observaciones` | JSONB | Mapa de criterio -> observación |
| `pdf_url` | TEXT | URL pública del PDF en Storage |
| `word_url` | TEXT | URL pública del Word en Storage |
| `created_at` | TIMESTAMP | Timestamp de creación |

### Ejemplo de `evaluaciones` (JSONB)
```json
{
  "Estado estructural de bancas": "Bueno",
  "Estado pintura bancas": "Regular",
  "Estado estructural juegos infantiles": "Bueno",
  "Estado de pintura de juegos infantiles": "Regular",
  "Estado llaves de paso/arranque de agua": "Malo",
  "Estado estructural basureros": "Bueno",
  "Estado pintura de basureros": "Regular"
}
```

### Ejemplo de `observaciones` (JSONB)
```json
{
  "Estado estructural de bancas": "Bancas en buen estado general",
  "Estado pintura bancas": "Requiere retoque de pintura",
  "Estado llaves de paso/arranque de agua": "Válvula oxidada, reemplazo urgente"
}
```

## 🎯 Criterios Oficiales del Catastro

1. Estado estructural de bancas
2. Estado pintura bancas
3. Estado estructural juegos infantiles
4. Estado de pintura de juegos infantiles
5. Estado llaves de paso/arranque de agua
6. Estado estructural basureros
7. Estado pintura de basureros

## 📱 Uso del Módulo

1. **Navegar desde el mapa**:
   - Click en un marcador de plaza
   - En el panel lateral, click en "Catastro de Inmuebles"

2. **Completar formulario**:
   - Ingresar nombre del inspector
   - Evaluar los 7 criterios (Bueno/Regular/Malo)
   - Agregar observaciones opcionales
   - Capturar fotos con notas

3. **Generar reportes**:
   - "Descargar PDF": genera y descarga inmediatamente
   - "Descargar Word": genera y descarga inmediatamente
   - "Guardar y Subir a la Nube": genera, sube a Supabase y muestra en historial

4. **Ver historial**:
   - Pestaña "HISTORIAL NUBE"
   - Muestra catastros de la plaza actual
   - Botones directos para descargar PDF y Word

## 🐛 Solución de Problemas

### Error: "relation 'catastros_inmuebles' does not exist"
- ✅ Solución: Ejecutar el SQL de creación de tabla

### Error: "Storage bucket not found"
- ✅ Solución: Crear el bucket `reportes-catastro` en Storage

### Error: "Row Level Security policy violation"
- ✅ Solución: Verificar que las políticas RLS estén habilitadas

### Fotos no se muestran en Word/PDF
- ✅ Solución: Las fotos se convierten a Base64, verificar permisos de lectura

### Historial vacío después de guardar
- ✅ Solución: Verificar en la consola de Supabase que el registro se insertó correctamente

## 📞 Contacto

Desarrollado por: Municipalidad de Doñihue  
Encargado: Felipe Lagos Bastias - Ingeniero Agrónomo
