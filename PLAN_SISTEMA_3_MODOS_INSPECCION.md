# 📋 Plan: Sistema de 3 Modos de Inspección

**Fecha creación**: 2026-09-09
**Versión actual**: 12.12.0
**Estado**: Pendiente de implementación

---

## 🎯 Objetivo

Implementar un sistema de selección de modos que permita visualizar el estado de las áreas verdes según 3 tipos diferentes de inspección, cada uno con su propio historial y estados independientes.

---

## 📊 Los 3 Modos de Inspección

### **Modo 1: 🌳 ÁREAS VERDES**
- **Evalúa**: Pasto, Árboles, Riego, Aseo, Césped, Arbolado, Flores, Caminos
- **Pantallas**: Las 6 primeras pestañas de `inspeccion_tecnica_screen.dart`
- **Campo en BD**: `estado_areas_verdes`
- **Color en mapa**: Según el último registro de inspección de áreas verdes

### **Modo 2: 🏗️ CATASTRO DE INMUEBLES**
- **Evalúa**: Bancas, Juegos Infantiles, Basureros, Arranques de Agua, Medidores
- **Pantallas**: Pestaña "Catastro de Inmuebles"
- **Campo en BD**: `estado_inmuebles` (ya existe como `estado`)
- **Color en mapa**: Según el último catastro de inmuebles

### **Modo 3: ⚠️ INSPECCIÓN DE URGENCIA**
- **Evalúa**: Problemas críticos que requieren atención inmediata
- **Pantallas**: `inspeccion_urgencia_screen.dart`
- **Campo en BD**: `estado_urgencias`
- **Color en mapa**: Según la última inspección de urgencia

---

## 🏗️ Arquitectura del Sistema

### Flujo de Usuario:

```
[Splash Screen]
       ↓
[Pantalla Selección de Modo]
  ┌──────┬──────┬──────┐
  │  🌳  │  🏗️  │  ⚠️  │
  │ Áreas│Inmue │Urgen │
  │Verdes│bles │cias  │
  └──────┴──────┴──────┘
       ↓
[Mapa con colores según modo seleccionado]
       ↓
[Click en plaza]
       ↓
[Panel flotante con opciones]
```

---

## 📦 Cambios en Base de Datos (Supabase)

### Script SQL a ejecutar:

```sql
-- Agregar columnas para estados independientes
ALTER TABLE plazas 
ADD COLUMN IF NOT EXISTS estado_areas_verdes VARCHAR(20) DEFAULT NULL;

ALTER TABLE plazas 
ADD COLUMN IF NOT EXISTS estado_urgencias VARCHAR(20) DEFAULT NULL;

-- Renombrar columna estado existente para claridad
ALTER TABLE plazas 
RENAME COLUMN estado TO estado_inmuebles;

-- Crear índices para búsquedas eficientes
CREATE INDEX IF NOT EXISTS idx_estado_areas_verdes ON plazas(estado_areas_verdes);
CREATE INDEX IF NOT EXISTS idx_estado_urgencias ON plazas(estado_urgencias);

-- Comentarios descriptivos
COMMENT ON COLUMN plazas.estado_areas_verdes IS 
'Estado calculado desde última inspección de áreas verdes (Aseo, Césped, Arbolado, etc)';

COMMENT ON COLUMN plazas.estado_inmuebles IS 
'Estado calculado desde último catastro de inmuebles (Bancas, Juegos, Basureros, etc)';

COMMENT ON COLUMN plazas.estado_urgencias IS 
'Estado calculado desde última inspección de urgencia';
```

---

## 🖥️ Archivos Nuevos a Crear

### 1. `lib/screens/modo_seleccion_screen.dart`

```dart
import 'package:flutter/material.dart';

class ModoSeleccionScreen extends StatelessWidget {
  const ModoSeleccionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Icon(
                  Icons.park,
                  size: 80,
                  color: Colors.white,
                ),
                SizedBox(height: 16),
                
                // Título
                Text(
                  'Áreas Verdes Doñihue',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Selecciona el tipo de inspección',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                
                SizedBox(height: 60),
                
                // Botón 1: Áreas Verdes
                _buildModoButton(
                  context: context,
                  icon: Icons.nature,
                  titulo: 'ÁREAS VERDES',
                  subtitulo: 'Pasto, Árboles, Riego, Aseo',
                  color: Color(0xFF2E7D32),
                  modo: 'areas_verdes',
                ),
                
                SizedBox(height: 20),
                
                // Botón 2: Catastro de Inmuebles
                _buildModoButton(
                  context: context,
                  icon: Icons.chair_outlined,
                  titulo: 'CATASTRO DE INMUEBLES',
                  subtitulo: 'Bancas, Juegos, Basureros',
                  color: Color(0xFF1565C0),
                  modo: 'inmuebles',
                ),
                
                SizedBox(height: 20),
                
                // Botón 3: Inspección de Urgencia
                _buildModoButton(
                  context: context,
                  icon: Icons.warning_amber,
                  titulo: 'INSPECCIÓN DE URGENCIA',
                  subtitulo: 'Problemas críticos',
                  color: Color(0xFFD32F2F),
                  modo: 'urgencias',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModoButton({
    required BuildContext context,
    required IconData icon,
    required String titulo,
    required String subtitulo,
    required Color color,
    required String modo,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pushReplacementNamed(
          context,
          '/mapa',
          arguments: {'modo': modo},
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitulo,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF9E9E9E),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### 2. `lib/models/modo_inspeccion.dart`

```dart
enum ModoInspeccion {
  areasVerdes,
  inmuebles,
  urgencias,
}

extension ModoInspeccionExtension on ModoInspeccion {
  String get nombre {
    switch (this) {
      case ModoInspeccion.areasVerdes:
        return 'Áreas Verdes';
      case ModoInspeccion.inmuebles:
        return 'Catastro de Inmuebles';
      case ModoInspeccion.urgencias:
        return 'Inspección de Urgencia';
    }
  }

  String get campoEstado {
    switch (this) {
      case ModoInspeccion.areasVerdes:
        return 'estado_areas_verdes';
      case ModoInspeccion.inmuebles:
        return 'estado_inmuebles';
      case ModoInspeccion.urgencias:
        return 'estado_urgencias';
    }
  }

  String get icono {
    switch (this) {
      case ModoInspeccion.areasVerdes:
        return '🌳';
      case ModoInspeccion.inmuebles:
        return '🏗️';
      case ModoInspeccion.urgencias:
        return '⚠️';
    }
  }
}
```

---

## 🔧 Modificaciones en Archivos Existentes

### 1. **`lib/main.dart`**

#### Agregar variable de modo actual:

```dart
class _MainMapScreenState extends State<MainMapScreen> {
  // ... código existente ...
  
  // ⭐ NUEVO: Modo de inspección actual
  ModoInspeccion _modoActual = ModoInspeccion.areasVerdes;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Obtener modo desde argumentos de navegación
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null && args['modo'] != null) {
      switch (args['modo']) {
        case 'areas_verdes':
          _modoActual = ModoInspeccion.areasVerdes;
          break;
        case 'inmuebles':
          _modoActual = ModoInspeccion.inmuebles;
          break;
        case 'urgencias':
          _modoActual = ModoInspeccion.urgencias;
          break;
      }
    }
  }
}
```

#### Modificar función de colores:

```dart
// Cambiar de:
Color markerColor;
switch (plaza['estado'].toString().toLowerCase()) {
  case 'excelente':
  case 'bueno':
    markerColor = const Color(0xFF2B6CB0);
    break;
  // ...
}

// A:
Color markerColor;
final estadoClave = _modoActual.campoEstado;
final estadoValor = plaza[estadoClave]?.toString().toLowerCase() ?? 'sin evaluar';

switch (estadoValor) {
  case 'bueno':
    markerColor = const Color(0xFF2B6CB0); // Azul
    break;
  case 'regular':
    markerColor = const Color(0xFFD97706); // Naranja
    break;
  case 'malo':
    markerColor = const Color(0xFFDC2626); // Rojo
    break;
  default:
    markerColor = const Color(0xFF718096); // Gris
}
```

#### Agregar botón flotante para cambiar modo:

```dart
// Dentro de Stack de botones flotantes
Positioned(
  top: 20,
  right: 20,
  child: FloatingActionButton(
    onPressed: () {
      Navigator.pushReplacementNamed(context, '/seleccion_modo');
    },
    child: Icon(_modoActual == ModoInspeccion.areasVerdes
        ? Icons.nature
        : _modoActual == ModoInspeccion.inmuebles
            ? Icons.chair_outlined
            : Icons.warning_amber),
    backgroundColor: Colors.white,
    foregroundColor: Color(0xFF1565C0),
    tooltip: 'Cambiar modo: ${_modoActual.nombre}',
  ),
),
```

#### Mostrar indicador del modo actual:

```dart
Positioned(
  top: 20,
  left: 20,
  child: Container(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 6,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _modoActual.icono,
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(width: 8),
        Text(
          _modoActual.nombre,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF212121),
          ),
        ),
      ],
    ),
  ),
),
```

---

### 2. **`lib/screens/inspeccion_tecnica_screen.dart`**

#### Modificar guardado para actualizar campo correcto:

```dart
// Al guardar inspección de áreas verdes, actualizar estado_areas_verdes
Future<void> _guardarInspeccionAreasVerdes() async {
  // ... código de guardado ...
  
  // Actualizar estado en plazas
  await Supabase.instance.client
    .from('plazas')
    .update({'estado_areas_verdes': estadoCalculado})
    .eq('id', widget.plazaId);
}
```

---

### 3. **`lib/services/catastro_supabase_service.dart`**

Ya actualiza `estado` (ahora `estado_inmuebles`), no necesita cambios.

---

### 4. **`lib/services/urgencia_supabase_service.dart`**

#### Agregar actualización de estado:

```dart
Future<Map<String, dynamic>> guardarInspeccion({
  // ... parámetros existentes ...
}) async {
  // ... código existente ...
  
  // ⭐ NUEVO: Calcular y actualizar estado de urgencias
  final estadoUrgencia = _calcularEstadoUrgencia(campos);
  
  await Supabase.instance.client
    .from('plazas')
    .update({'estado_urgencias': estadoUrgencia})
    .eq('id', plazaId);
  
  // ... resto del código ...
}

String _calcularEstadoUrgencia(Map<String, String> campos) {
  // Si hay campos críticos marcados como "Malo" → Estado = Malo
  final tieneProblemasCriticos = campos.values.any((v) => v.toLowerCase().contains('malo'));
  
  if (tieneProblemasCriticos) return 'Malo';
  return 'Regular'; // Las urgencias siempre son al menos Regular
}
```

---

## 🎨 Actualizar Rutas en `main.dart`

```dart
MaterialApp(
  title: 'Áreas Verdes Doñihue',
  initialRoute: '/seleccion_modo',
  routes: {
    '/seleccion_modo': (context) => ModoSeleccionScreen(),
    '/mapa': (context) => MainMapScreen(),
  },
  // ... resto del código ...
)
```

---

## 📊 Actualizar Reporte Consolidado

El reporte consolidado debe mostrar estadísticas separadas por cada modo:

```dart
// En reporte_consolidado_service.dart
static Future<Map<String, dynamic>> obtenerReporteCompleto() async {
  // ... código existente ...
  
  // AGREGAR: Conteo por cada tipo de estado
  int plazasBuenasAreasVerdes = 0;
  int plazasBuenasInmuebles = 0;
  int plazasBuenasUrgencias = 0;
  
  for (var plaza in plazas) {
    if (plaza['estado_areas_verdes'] == 'Bueno') plazasBuenasAreasVerdes++;
    if (plaza['estado_inmuebles'] == 'Bueno') plazasBuenasInmuebles++;
    if (plaza['estado_urgencias'] == 'Bueno') plazasBuenasUrgencias++;
  }
  
  return {
    // ... datos existentes ...
    'estados_por_modo': {
      'areas_verdes': {
        'bueno': plazasBuenasAreasVerdes,
        'regular': plazasRegularesAreasVerdes,
        'malo': plazasMalasAreasVerdes,
      },
      'inmuebles': {
        'bueno': plazasBuenasInmuebles,
        'regular': plazasRegularesInmuebles,
        'malo': plazasMalasInmuebles,
      },
      'urgencias': {
        'bueno': plazasBuenasUrgencias,
        'regular': plazasRegularesUrgencias,
        'malo': plazasMalasUrgencias,
      },
    },
  };
}
```

---

## ⚠️ Puntos Críticos de Atención

1. **Migración de datos existentes**: El campo `estado` actual debe renombrarse a `estado_inmuebles`
2. **Compatibilidad**: Verificar que plazas sin estados no rompan la app
3. **Caché**: Limpiar caché al cambiar de modo
4. **Performance**: Cargar solo el estado del modo actual para optimizar

---

## 🧪 Plan de Testing

1. ✅ Crear plaza nueva y hacer inspección de áreas verdes
2. ✅ Cambiar a modo inmuebles, verificar colores cambian
3. ✅ Hacer catastro de inmuebles
4. ✅ Cambiar a modo urgencias, verificar colores
5. ✅ Generar reporte consolidado con los 3 estados
6. ✅ Verificar que plazas antiguas siguen funcionando

---

## 🚀 Orden de Implementación

1. **Ejecutar SQL** en Supabase (agregar columnas)
2. **Crear** `modo_seleccion_screen.dart`
3. **Crear** `modo_inspeccion.dart` (enum)
4. **Modificar** `main.dart` (rutas + lógica de colores)
5. **Modificar** `inspeccion_tecnica_screen.dart` (guardar estado áreas verdes)
6. **Modificar** `urgencia_supabase_service.dart` (guardar estado urgencias)
7. **Actualizar** reporte consolidado
8. **Testing** completo

---

## 📦 Archivos de Respaldo

- ✅ `lib/main.BACKUP_20260909_*.dart`
- ✅ `lib/screens/inspeccion_tecnica_screen.BACKUP_20260909_*.dart`

---

## 📞 Notas Importantes

- El campo `estado` actual en la tabla `plazas` se renombrará a `estado_inmuebles`
- Cada modo guarda su estado independiente
- El reporte consolidado mostrará estadísticas de los 3 modos
- Los colores del mapa cambian según el modo seleccionado

---

**Autor**: Kiro AI Assistant  
**Última actualización**: 2026-09-09  
**Tiempo estimado**: 4-5 horas
