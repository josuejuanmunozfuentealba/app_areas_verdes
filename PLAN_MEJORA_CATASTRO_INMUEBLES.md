# 📋 Plan de Mejora: Catastro de Inmuebles con Campos Detallados

**Fecha creación**: 2026-09-09
**Versión actual**: 12.12.0
**Estado**: Pendiente de implementación

---

## 🎯 Objetivo

Expandir el formulario de **Catastro de Inmuebles** con campos detallados para cada elemento de infraestructura, permitiendo cuantificar y evaluar con mayor precisión el estado de las áreas verdes.

---

## 📊 Nueva Estructura de Campos

### **1. BANCAS**

#### Campos actuales (a mantener):
- ✅ Estado estructural de bancas (Bueno/Regular/Malo)
- ✅ Estado pintura bancas (Bueno/Regular/Malo)

#### Campos nuevos a agregar:
- **Cantidad de bancas**: `TextField` tipo número (0-99)
- **Estado estructural detallado**: 
  - Dropdown: `Bueno` / `Regular` / `Malo` / `Cambio urgente estructural`
- **Estado pintura detallado**:
  - Dropdown: `Bueno` / `Regular` / `Malo` / `Cambio urgente pintura`
- **Observaciones**: `TextField` multilinea (ya existe)

---

### **2. JUEGOS INFANTILES**

#### Campos actuales (a mantener):
- ✅ Estado estructural juegos infantiles (Bueno/Regular/Malo)
- ✅ Estado de pintura de juegos infantiles (Bueno/Regular/Malo)

#### Campos nuevos a agregar:
- **Cantidad de juegos**: `TextField` tipo número (0-99)
- **Estado estructural detallado**:
  - Dropdown: `Bueno` / `Regular` / `Malo` / `Cambio urgente estructural`
- **Estado pintura detallado**:
  - Dropdown: `Bueno` / `Regular` / `Malo` / `Cambio urgente pintura`
- **Observaciones**: `TextField` multilinea (ya existe)

---

### **3. BASUREROS**

#### Campos actuales (a mantener):
- ✅ Estado estructural basureros (Bueno/Regular/Malo)
- ✅ Estado pintura de basureros (Bueno/Regular/Malo)

#### Campos nuevos a agregar:
- **Cantidad de basureros**: `TextField` tipo número (0-99)
- **Estado estructural detallado**:
  - Dropdown: `Bueno` / `Regular` / `Malo` / `Cambio urgente estructural`
- **Estado pintura detallado**:
  - Dropdown: `Bueno` / `Regular` / `Malo` / `Cambio urgente pintura`
- **Observaciones**: `TextField` multilinea (ya existe)

---

### **4. ARRANQUES DE AGUA**

#### Campos actuales (a mantener):
- ✅ Estado llaves de paso/arranque de agua (Especificar si es de 1/2 o 3/4)

#### Campos nuevos a agregar:
- **Cantidad de arranques**: `TextField` tipo número (0-99)
- **Medida del arranque**:
  - Dropdown: `1/2"` / `3/4"` / `1"` / `1 1/4"` / `1 1/2"` / `Otra`
- **Estado funcional**:
  - Dropdown: `Bueno` / `Regular` / `Malo` / `No funciona`
- **Observaciones**: `TextField` multilinea (ya existe)

---

### **5. MEDIDORES** ⭐ NUEVO

#### Campos a crear:
- **Cantidad de medidores**: `TextField` tipo número (0-99)
- **Estado del medidor**:
  - Dropdown: `Bueno` / `Regular` / `Malo` / `No funciona`
- **Observaciones**: `TextField` multilinea

---

## 🏗️ Estructura Técnica de Implementación

### Paso 1: Crear nuevo widget `FilaInfraestructuraDetalladaWidget`

```dart
class FilaInfraestructuraDetalladaWidget extends StatelessWidget {
  final String nombre; // "Bancas", "Juegos", etc.
  final TextEditingController cantidadController;
  final String? estadoEstructural;
  final String? estadoPintura;
  final Function(String?) onEstadoEstructuralChanged;
  final Function(String?) onEstadoPinturaChanged;
  final TextEditingController observacionesController;
  
  // Para arranques de agua
  final String? medida;
  final Function(String?)? onMedidaChanged;
  final String? estadoFuncional;
  final Function(String?)? onEstadoFuncionalChanged;
  
  const FilaInfraestructuraDetalladaWidget({
    required this.nombre,
    required this.cantidadController,
    this.estadoEstructural,
    this.estadoPintura,
    required this.onEstadoEstructuralChanged,
    required this.onEstadoPinturaChanged,
    required this.observacionesController,
    this.medida,
    this.onMedidaChanged,
    this.estadoFuncional,
    this.onEstadoFuncionalChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(nombre, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            
            // Campo cantidad
            TextField(
              controller: cantidadController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Cantidad de $nombre',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            
            // Estado estructural
            DropdownButtonFormField<String>(
              value: estadoEstructural,
              decoration: InputDecoration(
                labelText: 'Estado Estructural',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'Bueno', child: Text('Bueno')),
                DropdownMenuItem(value: 'Regular', child: Text('Regular')),
                DropdownMenuItem(value: 'Malo', child: Text('Malo')),
                DropdownMenuItem(value: 'Cambio urgente estructural', child: Text('🔴 Cambio urgente estructural')),
              ],
              onChanged: onEstadoEstructuralChanged,
            ),
            SizedBox(height: 12),
            
            // Estado pintura
            DropdownButtonFormField<String>(
              value: estadoPintura,
              decoration: InputDecoration(
                labelText: 'Estado Pintura',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'Bueno', child: Text('Bueno')),
                DropdownMenuItem(value: 'Regular', child: Text('Regular')),
                DropdownMenuItem(value: 'Malo', child: Text('Malo')),
                DropdownMenuItem(value: 'Cambio urgente pintura', child: Text('🔴 Cambio urgente pintura')),
              ],
              onChanged: onEstadoPinturaChanged,
            ),
            
            // Campos especiales para arranques
            if (medida != null && onMedidaChanged != null) ...[
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: medida,
                decoration: InputDecoration(
                  labelText: 'Medida del arranque',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: '1/2"', child: Text('1/2" (12.7mm)')),
                  DropdownMenuItem(value: '3/4"', child: Text('3/4" (19.05mm)')),
                  DropdownMenuItem(value: '1"', child: Text('1" (25.4mm)')),
                  DropdownMenuItem(value: '1 1/4"', child: Text('1 1/4" (31.75mm)')),
                  DropdownMenuItem(value: '1 1/2"', child: Text('1 1/2" (38.1mm)')),
                  DropdownMenuItem(value: 'Otra', child: Text('Otra medida')),
                ],
                onChanged: onMedidaChanged,
              ),
            ],
            
            if (estadoFuncional != null && onEstadoFuncionalChanged != null) ...[
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: estadoFuncional,
                decoration: InputDecoration(
                  labelText: 'Estado Funcional',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'Bueno', child: Text('Bueno')),
                  DropdownMenuItem(value: 'Regular', child: Text('Regular')),
                  DropdownMenuItem(value: 'Malo', child: Text('Malo')),
                  DropdownMenuItem(value: 'No funciona', child: Text('🔴 No funciona')),
                ],
                onChanged: onEstadoFuncionalChanged,
              ),
            ],
            
            SizedBox(height: 12),
            
            // Observaciones
            TextField(
              controller: observacionesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Observaciones',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### Paso 2: Modificar `inspeccion_tecnica_screen.dart`

#### Variables de estado a agregar:

```dart
// Cantidades
final TextEditingController _cantidadBancas = TextEditingController();
final TextEditingController _cantidadJuegos = TextEditingController();
final TextEditingController _cantidadBasureros = TextEditingController();
final TextEditingController _cantidadArranques = TextEditingController();
final TextEditingController _cantidadMedidores = TextEditingController();

// Estados estructurales detallados
String? _estadoEstructuralBancas;
String? _estadoEstructuralJuegos;
String? _estadoEstructuralBasureros;

// Estados pintura detallados
String? _estadoPinturaBancas;
String? _estadoPinturaJuegos;
String? _estadoPinturaBasureros;

// Arranques de agua
String? _medidaArranques;
String? _estadoFuncionalArranques;

// Medidores
String? _estadoMedidores;

// Observaciones detalladas
final TextEditingController _observacionesBancasDetalladas = TextEditingController();
final TextEditingController _observacionesJuegosDetalladas = TextEditingController();
final TextEditingController _observacionesBasurerosDetalladas = TextEditingController();
final TextEditingController _observacionesArranquesDetalladas = TextEditingController();
final TextEditingController _observacionesMedidoresDetalladas = TextEditingController();
```

#### Modificar `_buildSeccionCatastroInmuebles()`:

```dart
Widget _buildSeccionCatastroInmuebles() {
  return Column(
    children: [
      _buildEncabezadoTabla('CATASTRO DE INMUEBLE DE AREAS VERDES'),
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // SECCIÓN 1: BANCAS
              FilaInfraestructuraDetalladaWidget(
                nombre: 'Bancas',
                cantidadController: _cantidadBancas,
                estadoEstructural: _estadoEstructuralBancas,
                estadoPintura: _estadoPinturaBancas,
                onEstadoEstructuralChanged: (valor) {
                  setState(() => _estadoEstructuralBancas = valor);
                },
                onEstadoPinturaChanged: (valor) {
                  setState(() => _estadoPinturaBancas = valor);
                },
                observacionesController: _observacionesBancasDetalladas,
              ),
              
              // SECCIÓN 2: JUEGOS INFANTILES
              FilaInfraestructuraDetalladaWidget(
                nombre: 'Juegos Infantiles',
                cantidadController: _cantidadJuegos,
                estadoEstructural: _estadoEstructuralJuegos,
                estadoPintura: _estadoPinturaJuegos,
                onEstadoEstructuralChanged: (valor) {
                  setState(() => _estadoEstructuralJuegos = valor);
                },
                onEstadoPinturaChanged: (valor) {
                  setState(() => _estadoPinturaJuegos = valor);
                },
                observacionesController: _observacionesJuegosDetalladas,
              ),
              
              // SECCIÓN 3: BASUREROS
              FilaInfraestructuraDetalladaWidget(
                nombre: 'Basureros',
                cantidadController: _cantidadBasureros,
                estadoEstructural: _estadoEstructuralBasureros,
                estadoPintura: _estadoPinturaBasureros,
                onEstadoEstructuralChanged: (valor) {
                  setState(() => _estadoEstructuralBasureros = valor);
                },
                onEstadoPinturaChanged: (valor) {
                  setState(() => _estadoPinturaBasureros = valor);
                },
                observacionesController: _observacionesBasurerosDetalladas,
              ),
              
              // SECCIÓN 4: ARRANQUES DE AGUA
              FilaInfraestructuraDetalladaWidget(
                nombre: 'Arranques de Agua',
                cantidadController: _cantidadArranques,
                estadoEstructural: null, // No aplica
                estadoPintura: null, // No aplica
                onEstadoEstructuralChanged: (_) {},
                onEstadoPinturaChanged: (_) {},
                medida: _medidaArranques,
                onMedidaChanged: (valor) {
                  setState(() => _medidaArranques = valor);
                },
                estadoFuncional: _estadoFuncionalArranques,
                onEstadoFuncionalChanged: (valor) {
                  setState(() => _estadoFuncionalArranques = valor);
                },
                observacionesController: _observacionesArranquesDetalladas,
              ),
              
              // SECCIÓN 5: MEDIDORES (NUEVO)
              Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Medidores', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),
                      TextField(
                        controller: _cantidadMedidores,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Cantidad de Medidores',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _estadoMedidores,
                        decoration: InputDecoration(
                          labelText: 'Estado del Medidor',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(value: 'Bueno', child: Text('Bueno')),
                          DropdownMenuItem(value: 'Regular', child: Text('Regular')),
                          DropdownMenuItem(value: 'Malo', child: Text('Malo')),
                          DropdownMenuItem(value: 'No funciona', child: Text('🔴 No funciona')),
                        ],
                        onChanged: (valor) {
                          setState(() => _estadoMedidores = valor);
                        },
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: _observacionesMedidoresDetalladas,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Observaciones',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              _construirEvidenciaFotografica('CATASTRO DE INMUEBLE DE AREAS VERDES'),
            ],
          ),
        ),
      ),
    ],
  );
}
```

---

### Paso 3: Actualizar guardado en Supabase

Modificar `_prepararDatosInspeccion()` para incluir campos nuevos:

```dart
Map<String, dynamic> _prepararDatosInspeccion() {
  return {
    'plazaId': widget.plazaId,
    'nombrePlaza': widget.nombrePlaza,
    
    // ... campos existentes ...
    
    // NUEVOS CAMPOS DETALLADOS
    'infraestructura_detallada': {
      'bancas': {
        'cantidad': int.tryParse(_cantidadBancas.text) ?? 0,
        'estado_estructural': _estadoEstructuralBancas,
        'estado_pintura': _estadoPinturaBancas,
        'observaciones': _observacionesBancasDetalladas.text,
      },
      'juegos_infantiles': {
        'cantidad': int.tryParse(_cantidadJuegos.text) ?? 0,
        'estado_estructural': _estadoEstructuralJuegos,
        'estado_pintura': _estadoPinturaJuegos,
        'observaciones': _observacionesJuegosDetalladas.text,
      },
      'basureros': {
        'cantidad': int.tryParse(_cantidadBasureros.text) ?? 0,
        'estado_estructural': _estadoEstructuralBasureros,
        'estado_pintura': _estadoPinturaBasureros,
        'observaciones': _observacionesBasurerosDetalladas.text,
      },
      'arranques_agua': {
        'cantidad': int.tryParse(_cantidadArranques.text) ?? 0,
        'medida': _medidaArranques,
        'estado_funcional': _estadoFuncionalArranques,
        'observaciones': _observacionesArranquesDetalladas.text,
      },
      'medidores': {
        'cantidad': int.tryParse(_cantidadMedidores.text) ?? 0,
        'estado': _estadoMedidores,
        'observaciones': _observacionesMedidoresDetalladas.text,
      },
    },
  };
}
```

---

### Paso 4: Actualizar esquema de Supabase

Agregar columna JSON en la tabla `catastros_inmuebles`:

```sql
-- Agregar columna para infraestructura detallada
ALTER TABLE catastros_inmuebles 
ADD COLUMN IF NOT EXISTS infraestructura_detallada JSONB;

-- Crear índice para búsquedas eficientes
CREATE INDEX IF NOT EXISTS idx_infraestructura_detallada 
ON catastros_inmuebles USING GIN (infraestructura_detallada);

-- Comentario descriptivo
COMMENT ON COLUMN catastros_inmuebles.infraestructura_detallada IS 
'Datos detallados de infraestructura: cantidades, estados estructurales, estados de pintura, medidas de arranques';
```

---

### Paso 5: Actualizar Reporte Consolidado

Modificar `reporte_consolidado_service.dart` para contar cantidades:

```dart
// SECCIÓN 3: BANCAS
int totalBancasConCantidad = 0;
int totalBancasSinCantidad = 0;
int sumaBancas = 0;

for (var catastro in response) {
  final infraDetallada = catastro['infraestructura_detallada'] as Map<String, dynamic>?;
  
  if (infraDetallada != null && infraDetallada['bancas'] != null) {
    final bancas = infraDetallada['bancas'] as Map<String, dynamic>;
    final cantidad = bancas['cantidad'] ?? 0;
    
    if (cantidad > 0) {
      totalBancasConCantidad++;
      sumaBancas += cantidad as int;
    }
  } else {
    // Catastro antiguo sin cantidad
    totalBancasSinCantidad++;
  }
}
```

---

## 📝 Compatibilidad con Datos Antiguos

### Estrategia de migración:

1. **Los catastros antiguos seguirán funcionando** sin necesidad de modificación
2. **El reporte mostrará ambos tipos**:
   - Catastros nuevos: Con cantidad exacta
   - Catastros antiguos: Estimado (1 por plaza)
3. **Formato del reporte**:
   ```
   🪑 BANCAS
   Total áreas con bancas: 53
     • Con cantidad especificada: 15 áreas (245 bancas totales)
     • Sin cantidad especificada: 38 áreas (estimado: 38 bancas)
   
   TOTAL ESTIMADO: 283 bancas
   ```

---

## ⚠️ Puntos Críticos de Atención

1. **Validación de campos numéricos**: Asegurar que cantidad ≥ 0
2. **Campos opcionales**: Todos los campos nuevos deben ser opcionales
3. **Retrocompatibilidad**: Verificar que catastros antiguos se sigan cargando correctamente
4. **Dispose de controllers**: Agregar dispose() para todos los nuevos TextEditingController
5. **Performance**: Con más campos, verificar que el formulario no se vuelva lento

---

## 🧪 Plan de Testing

1. **Crear catastro nuevo** con todos los campos llenos
2. **Crear catastro nuevo** con campos vacíos
3. **Cargar catastro antiguo** y verificar que se muestra correctamente
4. **Generar reporte** con mix de catastros nuevos y antiguos
5. **Verificar PDF/Word** con datos detallados

---

## 📦 Archivos Afectados

- ✅ `lib/screens/inspeccion_tecnica_screen.dart` (principal)
- ✅ `lib/services/catastro_supabase_service.dart` (guardado)
- ✅ `lib/services/catastro_export_service.dart` (PDF/Word)
- ✅ `lib/services/reporte_consolidado_service.dart` (reporte)
- ✅ `lib/widgets/fila_infraestructura_detallada_widget.dart` (nuevo)
- ✅ SQL: `AGREGAR_COLUMNA_INFRAESTRUCTURA_DETALLADA.sql` (nuevo)

---

## 🚀 Commits Sugeridos

1. `feat: Crear widget FilaInfraestructuraDetalladaWidget`
2. `feat: Agregar campos detallados de bancas`
3. `feat: Agregar campos detallados de juegos infantiles`
4. `feat: Agregar campos detallados de basureros`
5. `feat: Agregar campos detallados de arranques de agua`
6. `feat: Agregar sección de medidores`
7. `feat: Actualizar servicio de guardado con campos nuevos`
8. `feat: Actualizar reporte consolidado con cantidades`
9. `test: Verificar retrocompatibilidad con catastros antiguos`
10. `docs: Actualizar README con nuevos campos`

---

## 📊 Tiempo Estimado de Implementación

- **Paso 1 (Widget)**: 30 minutos
- **Paso 2 (Formulario)**: 1 hora
- **Paso 3 (Guardado)**: 30 minutos
- **Paso 4 (Supabase)**: 10 minutos
- **Paso 5 (Reporte)**: 1 hora
- **Testing**: 30 minutos

**TOTAL ESTIMADO**: 3.5 horas

---

## 📞 Contacto para Dudas

Si durante la implementación surgen dudas, revisar:
- Este documento
- Código de respaldo: `inspeccion_tecnica_screen.BACKUP_*.dart`
- Commits anteriores en GitHub

---

**Autor**: Kiro AI Assistant
**Última actualización**: 2026-09-09
