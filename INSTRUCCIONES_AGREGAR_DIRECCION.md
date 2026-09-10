# 📍 Instrucciones: Agregar Columna Dirección

## Problema
La columna `direccion` no existe en la tabla `plazas` de Supabase, pero se necesita para el Excel de fugas.

## Solución

### Paso 1: Abrir Supabase SQL Editor
1. Ve a https://supabase.com/dashboard
2. Selecciona tu proyecto: `speneggmlqitgfjhzsry`
3. En el menú lateral, haz clic en **SQL Editor**

### Paso 2: Ejecutar el Script
1. Abre el archivo: `AGREGAR_COLUMNA_DIRECCION.sql`
2. **Copia TODO el contenido** del archivo
3. **Pega** en el SQL Editor de Supabase
4. Haz clic en **Run** (Ejecutar)

### Paso 3: Verificar
Deberías ver un mensaje de éxito y la lista de plazas con sus direcciones.

```sql
-- Consulta de verificación:
SELECT id, nombre, direccion, comuna 
FROM plazas 
WHERE direccion IS NOT NULL 
ORDER BY id;
```

### Paso 4: Probar la App
1. Espera 5-8 minutos a que GitHub Actions compile
2. Refresca la app web con **Ctrl + Shift + R**
3. Descarga el Excel de fugas
4. Ahora debería aparecer la columna **Dirección**

## ✅ Resultado Esperado

**Excel de Fugas con:**
- ID
- Nombre Área Verde
- **Dirección** ← Nueva columna
- Comuna
- GPS Latitud
- GPS Longitud
- Observación

## 📋 Ejemplo de Fila

| ID | Nombre | Dirección | Comuna | Lat | Lng | Obs |
|----|--------|-----------|--------|-----|-----|-----|
| 1 | Plaza de armas donihue | Delfin Carvallo con Subteniente Valenzuela | Doñihue | -34.226023 | -70.964876 | ... |

---

**Nota**: Si alguna plaza no tiene dirección asignada en el script, aparecerá como "Sin dirección" en el Excel.
