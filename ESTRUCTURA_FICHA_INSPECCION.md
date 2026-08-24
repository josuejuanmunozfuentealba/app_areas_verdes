# 📋 Estructura Completa: Ficha de Inspección Técnica

## 🏗️ Arquitectura General

### Ubicación del Archivo Principal
```
lib/screens/inspeccion_tecnica_screen.dart
```

---

## 📊 Componentes de la Ficha

### 1. **Encabezado (Tabla de Información)**
```dart
Widget _buildTablaInformacion()
```

**Contenido**:
- ID del área verde
- Descripción/nombre
- Latitud y Longitud
- Tipo de parque
- Superficie
- Población
- Sector
- Evaluación general
- Última evaluación
- Fecha/Hora actual

---

### 2. **Sistema de Pestañas (TabController)**

**Configuración actual**:
```dart
_tabController = TabController(length: 6, vsync: this);
```

**6 Pestañas actuales**:
1. **ASEO** - 7 criterios
2. **CÉSPED** - 4 criterios
3. **ARBOLADO** - 9 criterios
4. **FLORES** - 9 criterios
5. **CAMINOS** - 5 criterios
6. **INFRAESTRUCTURA** - 7 criterios

---

## 🗂️ Estructura de Datos por Pestaña

Cada pestaña tiene **3 mapas de datos**:

### 1. Evaluaciones (Map<String, String?>)
```dart
final Map<String, String?> _evaluacionesAseo = {};
final Map<String, String?> _evaluacionesCesped = {};
final Map<String, String?> _evaluacionesArbolado = {};
final Map<String, String?> _evaluacionesFlores = {};
final Map<String, String?> _evaluacionesCaminos = {};
final Map<String, String?> _evaluacionesInfraestructura = {};
```

**Valores posibles**: `'Bueno'`, `'Regular'`, `'Malo'`, `null`

---

### 2. Observaciones (Map<String, TextEditingController>)
```dart
final Map<String, TextEditingController> _observacionesAseo = {};
final Map<String, TextEditingController> _observacionesCesped = {};
final Map<String, TextEditingController> _observacionesArbolado = {};
final Map<String, TextEditingController> _observacionesFlores = {};
final Map<String, TextEditingController> _observacionesCaminos = {};
final Map<String, TextEditingController> _observacionesInfraestructura = {};
```

**Propósito**: Almacenar comentarios de texto para cada criterio

---

### 3. Criterios (List<String>)
```dart
final List<String> _criteriosAseo = [
  'Basura por tiempo indebido pero con recolección.',
  'Residuos acumulados de días anteriores.',
  // ... más criterios
];
```

**Propósito**: Lista fija de criterios a evaluar en cada sección

---

### 4. Imágenes (Map<String, List<Map<String, dynamic>>>)
```dart
final Map<String, List<Map<String, dynamic>>> _imagenesPorSeccion = {
  'ASEO': [],
  'CÉSPED': [],
  'ARBOLADO': [],
  'FLORES': [],
  'CAMINOS': [],
  'INFRAESTRUCTURA': [],
};
```

**Estructura de cada imagen**:
```dart
{
  'archivo': XFile,
  'titulo': String
}
```

---

## 🧩 Componentes por Pestaña

### Widget de Sección (Ejemplo: _buildSeccionAseo)

```dart
Widget _buildSeccionAseo() {
  return Column(
    children: [
      // 1. Encabezado de la tabla
      _buildEncabezadoTabla('ASEO'),
      
      // 2. Lista de criterios con evaluaciones
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _criteriosAseo.length,
                itemBuilder: (context, index) {
                  final criterio = _criteriosAseo[index];
                  
                  // Crear controlador si no existe
                  _observacionesAseo.putIfAbsent(
                    criterio,
                    () => TextEditingController(),
                  );
                  
                  return FilaEvaluacionWidget(
                    textoCriterio: criterio,
                    valorSeleccionado: _evaluacionesAseo[criterio],
                    onChanged: (nuevoValor) {
                      setState(() {
                        _evaluacionesAseo[criterio] = nuevoValor;
                      });
                    },
                    controllerObs: _observacionesAseo[criterio],
                  );
                },
              ),
              
              // 3. Evidencia fotográfica
              _construirEvidenciaFotografica('ASEO'),
            ],
          ),
        ),
      ),
    ],
  );
}
```

---

## 📤 Exportación de Datos

### Función _prepararDatosInspeccion()
```dart
Map<String, dynamic> _prepararDatosInspeccion() {
  return {
    'plazaId': widget.plazaId,
    'nombrePlaza': widget.nombrePlaza,
    'correoSupervisor': _correoJefeController.text,
    'fechaHora': DateTime.now().toIso8601String(),
    'allEvaluations': {
      'ASEO': _evaluacionesAseo,
      'CÉSPED': _evaluacionesCesped,
      'ARBOLADO': _evaluacionesArbolado,
      'FLORES': _evaluacionesFlores,
      'CAMINOS': _evaluacionesCaminos,
      'INFRAESTRUCTURA': _evaluacionesInfraestructura,
    },
    'allCriteria': {
      'ASEO': _criteriosAseo,
      'CÉSPED': _criteriosCesped,
      'ARBOLADO': _criteriosArbolado,
      'FLORES': _criteriosFlores,
      'CAMINOS': _criteriosCaminos,
      'INFRAESTRUCTURA': _criteriosInfraestructura,
    },
    'allObservations': {
      'ASEO': _extraerTexto(_observacionesAseo),
      'CÉSPED': _extraerTexto(_observacionesCesped),
      'ARBOLADO': _extraerTexto(_observacionesArbolado),
      'FLORES': _extraerTexto(_observacionesFlores),
      'CAMINOS': _extraerTexto(_observacionesCaminos),
      'INFRAESTRUCTURA': _extraerTexto(_observacionesInfraestructura),
    },
  };
}
```

---

## 🎨 Widget FilaEvaluacionWidget

**Ubicación**: `lib/widgets/widgets.dart`

**Estructura**:
```
┌─────────────────────────────────────────────────────────┐
│ Criterio                            │ B │ R │ M │ OBS   │
├─────────────────────────────────────────────────────────┤
│ Basura por tiempo indebido...      │ ○ │ ○ │ ○ │ [___] │
└─────────────────────────────────────────────────────────┘
```

**Columnas**:
- Criterio (texto)
- B (Bueno) - Radio button
- R (Regular) - Radio button
- M (Malo) - Radio button
- OBS (Observaciones) - TextField pequeño

---

## 💾 Guardado de Historial

### Función _guardarEnHistorial()

**Almacenamiento**: SharedPreferences
**Key**: `'historial_${widget.plazaId}'`

**Estructura guardada**:
```json
{
  "fecha": "2026-07-15T16:00:00.000",
  "plazaId": "AV-001",
  "nombrePlaza": "Plaza Central",
  "correoSupervisor": "supervisor@example.com",
  "evaluaciones": {
    "aseo": {...},
    "cesped": {...},
    "arbolado": {...},
    "flores": {...},
    "caminos": {...},
    "infraestructura": {...}
  },
  "observaciones": {
    "aseo": {...},
    "cesped": {...},
    ...
  },
  "estadoGeneral": "Regular"
}
```

---

## 📋 Panel de Acciones Finales

**Ubicación**: `lib/widgets/widgets.dart` → `PanelAccionesFinales`

**Botones**:
1. **Guardar en Historial** → `_guardarEnHistorial()`
2. **Ver Historial** → `_verHistorial()`
3. **Descargar PDF** → `LogicaBotonesHelper.generarPDF()`
4. **Descargar Word** → `LogicaBotonesHelper.generarWord()`
5. **Enviar Reporte** → `LogicaBotonesHelper.enviarReporte()`

---

## 🔄 Flujo de Datos

```
Usuario rellena formulario
          ↓
Datos guardados en Mapas (_evaluacionesXXX, _observacionesXXX)
          ↓
Usuario hace clic en botón
          ↓
_prepararDatosInspeccion() consolida todos los datos
          ↓
LogicaBotonesHelper procesa según acción:
  - PDF: PDFExportService
  - Word: WordExportService
  - Email: EmailService (Gmail/Outlook Web)
```

---

## ✅ CÓMO AGREGAR UNA NUEVA PESTAÑA

### Ejemplo: Agregar pestaña "RIEGO"

#### Paso 1: Agregar variables de estado
```dart
// En _InspeccionTecnicaScreenState

// 1. Mapa de evaluaciones
final Map<String, String?> _evaluacionesRiego = {};

// 2. Mapa de observaciones
final Map<String, TextEditingController> _observacionesRiego = {};

// 3. Lista de criterios
final List<String> _criteriosRiego = [
  'Sistema de riego funcionando correctamente.',
  'Tuberías en buen estado.',
  'Presión de agua adecuada.',
  'Cronómetros funcionando.',
  'Aspersores sin obstrucciones.',
];
```

#### Paso 2: Actualizar TabController
```dart
@override
void initState() {
  super.initState();
  _tabController = TabController(length: 7, vsync: this); // Era 6, ahora 7
}
```

#### Paso 3: Agregar pestaña al TabBar
```dart
tabs: const [
  Tab(text: 'ASEO'),
  Tab(text: 'CÉSPED'),
  Tab(text: 'ARBOLADO'),
  Tab(text: 'FLORES'),
  Tab(text: 'CAMINOS'),
  Tab(text: 'INFRAESTRUCTURA'),
  Tab(text: 'RIEGO'), // ← NUEVA
],
```

#### Paso 4: Agregar vista al TabBarView
```dart
TabBarView(
  controller: _tabController,
  children: [
    _buildSeccionAseo(),
    _buildSeccionCesped(),
    _buildSeccionArbolado(),
    _buildSeccionFlores(),
    _buildSeccionCaminos(),
    _buildSeccionInfraestructura(),
    _buildSeccionRiego(), // ← NUEVA
  ],
),
```

#### Paso 5: Crear función _buildSeccionRiego()
```dart
Widget _buildSeccionRiego() {
  return Column(
    children: [
      _buildEncabezadoTabla('RIEGO'),
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _criteriosRiego.length,
                itemBuilder: (context, index) {
                  final criterio = _criteriosRiego[index];
                  _observacionesRiego.putIfAbsent(
                    criterio,
                    () => TextEditingController(),
                  );
                  return FilaEvaluacionWidget(
                    textoCriterio: criterio,
                    valorSeleccionado: _evaluacionesRiego[criterio],
                    onChanged: (nuevoValor) {
                      setState(() {
                        _evaluacionesRiego[criterio] = nuevoValor;
                      });
                    },
                    controllerObs: _observacionesRiego[criterio],
                  );
                },
              ),
              _construirEvidenciaFotografica('RIEGO'),
            ],
          ),
        ),
      ),
    ],
  );
}
```

#### Paso 6: Agregar imágenes a _imagenesPorSeccion
```dart
final Map<String, List<Map<String, dynamic>>> _imagenesPorSeccion = {
  'ASEO': [],
  'CÉSPED': [],
  'ARBOLADO': [],
  'FLORES': [],
  'CAMINOS': [],
  'INFRAESTRUCTURA': [],
  'RIEGO': [], // ← NUEVA
};
```

#### Paso 7: Actualizar dispose()
```dart
@override
void dispose() {
  // ... código existente ...
  
  // Limpiar controladores de RIEGO
  for (var c in _observacionesRiego.values) {
    c.dispose();
  }
  
  super.dispose();
}
```

#### Paso 8: Actualizar _prepararDatosInspeccion()
```dart
'allEvaluations': {
  'ASEO': _evaluacionesAseo,
  'CÉSPED': _evaluacionesCesped,
  'ARBOLADO': _evaluacionesArbolado,
  'FLORES': _evaluacionesFlores,
  'CAMINOS': _evaluacionesCaminos,
  'INFRAESTRUCTURA': _evaluacionesInfraestructura,
  'RIEGO': _evaluacionesRiego, // ← NUEVA
},
'allCriteria': {
  'ASEO': _criteriosAseo,
  'CÉSPED': _criteriosCesped,
  'ARBOLADO': _criteriosArbolado,
  'FLORES': _criteriosFlores,
  'CAMINOS': _criteriosCaminos,
  'INFRAESTRUCTURA': _criteriosInfraestructura,
  'RIEGO': _criteriosRiego, // ← NUEVA
},
'allObservations': {
  'ASEO': _extraerTexto(_observacionesAseo),
  'CÉSPED': _extraerTexto(_observacionesCesped),
  'ARBOLADO': _extraerTexto(_observacionesArbolado),
  'FLORES': _extraerTexto(_observacionesFlores),
  'CAMINOS': _extraerTexto(_observacionesCaminos),
  'INFRAESTRUCTURA': _extraerTexto(_observacionesInfraestructura),
  'RIEGO': _extraerTexto(_observacionesRiego), // ← NUEVA
},
```

#### Paso 9: Actualizar _guardarEnHistorial()
```dart
'evaluaciones': {
  'aseo': _evaluacionesAseo,
  'cesped': _evaluacionesCesped,
  'arbolado': _evaluacionesArbolado,
  'flores': _evaluacionesFlores,
  'caminos': _evaluacionesCaminos,
  'infraestructura': _evaluacionesInfraestructura,
  'riego': _evaluacionesRiego, // ← NUEVA
},
'observaciones': {
  'aseo': _observacionesAseo.map((k, v) => MapEntry(k, v.text)),
  'cesped': _observacionesCesped.map((k, v) => MapEntry(k, v.text)),
  'arbolado': _observacionesArbolado.map((k, v) => MapEntry(k, v.text)),
  'flores': _observacionesFlores.map((k, v) => MapEntry(k, v.text)),
  'caminos': _observacionesCaminos.map((k, v) => MapEntry(k, v.text)),
  'infraestructura': _observacionesInfraestructura.map((k, v) => MapEntry(k, v.text)),
  'riego': _observacionesRiego.map((k, v) => MapEntry(k, v.text)), // ← NUEVA
},
```

---

## 🗄️ INTEGRACIÓN CON SQL (Propuesta)

### Estructura de Base de Datos Sugerida

#### Tabla: inspecciones
```sql
CREATE TABLE inspecciones (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  plaza_id TEXT NOT NULL,
  nombre_plaza TEXT NOT NULL,
  correo_supervisor TEXT,
  nombre_inspector TEXT,
  fecha_hora TEXT NOT NULL,
  estado_general TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Tabla: evaluaciones
```sql
CREATE TABLE evaluaciones (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  inspeccion_id INTEGER NOT NULL,
  seccion TEXT NOT NULL, -- 'ASEO', 'CÉSPED', etc.
  criterio TEXT NOT NULL,
  evaluacion TEXT, -- 'Bueno', 'Regular', 'Malo'
  observacion TEXT,
  FOREIGN KEY (inspeccion_id) REFERENCES inspecciones(id) ON DELETE CASCADE
);
```

#### Tabla: imagenes
```sql
CREATE TABLE imagenes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  inspeccion_id INTEGER NOT NULL,
  seccion TEXT NOT NULL,
  titulo TEXT,
  ruta_archivo TEXT NOT NULL,
  fecha_captura TEXT,
  FOREIGN KEY (inspeccion_id) REFERENCES inspecciones(id) ON DELETE CASCADE
);
```

### Paquete Recomendado
```yaml
dependencies:
  sqflite: ^2.3.0  # Para Android/iOS
  sqflite_common_ffi: ^2.3.0  # Para Windows/Linux
```

### Servicio de Base de Datos Sugerido
```
lib/services/database_service.dart
```

**Funciones principales**:
- `insertInspeccion()` - Guardar nueva inspección
- `getInspecciones()` - Obtener historial
- `getInspeccionById()` - Obtener inspección específica
- `updateInspeccion()` - Actualizar inspección
- `deleteInspeccion()` - Eliminar inspección
- `syncToCloud()` - Sincronizar con servidor (opcional)

---

## 📱 Ventajas de SQL vs SharedPreferences

| Aspecto | SharedPreferences | SQLite |
|---------|-------------------|--------|
| **Estructura** | JSON plano | Tablas relacionales |
| **Consultas** | Cargar todo en memoria | Queries SQL eficientes |
| **Tamaño** | Limitado (~1-2 MB) | Ilimitado (GB) |
| **Relaciones** | Ninguna | Claves foráneas |
| **Performance** | Lento con muchos datos | Rápido con índices |
| **Búsqueda** | Iterar todo | WHERE clauses |
| **Concurrencia** | Problemas | Transacciones |

---

## 📊 Resumen de Contadores

- **Total pestañas**: 6 (pronto 7 con RIEGO)
- **Total criterios**: 41 (7+4+9+9+5+7)
- **Mapas de datos**: 18 (6 × 3 tipos)
- **Controladores**: ~41 TextEditingControllers
- **Imágenes**: Sin límite por sección

---

## 🎯 Próximos Pasos Sugeridos

1. ✅ Agregar nueva pestaña (RIEGO u otra)
2. ✅ Implementar SQLite para historial
3. ✅ Crear sistema de sincronización en tiempo real
4. ✅ Agregar búsqueda y filtros en historial
5. ✅ Implementar gráficos de evolución temporal

---

Desarrollado por: Josué Juan Muñoz Fuentealba
Fecha: Julio 2026
