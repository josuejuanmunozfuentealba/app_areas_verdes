# 🏛️ Perfil de Arquitectura - Sistema de Inspección de Áreas Verdes

> Documento de contexto completo para continuación del desarrollo por otra IA o desarrollador

---

## 📌 Información del Proyecto

### Identidad
- **Nombre**: Sistema de Inspección de Áreas Verdes
- **Cliente**: Municipalidad de Doñihue
- **Versión Actual**: 12.12.0+13
- **Plataformas**: Web (producción), Android (producción)
- **Framework**: Flutter 3.11.5
- **Lenguaje**: Dart

### Equipo
- **Desarrollador Principal**: Josué Juan Muñoz Fuentealba
- **Usuario Final**: Felipe Lagos Bastias (Ingeniero Agrónomo)
- **Repositorio**: https://github.com/josuejuanmunozfuentealba/app_areas_verdes

---

## 🎯 Propósito del Sistema

### Objetivo Principal
Sistema para realizar inspecciones técnicas de áreas verdes municipales, evaluando 6 categorías con 41 criterios totales, generando reportes profesionales y manteniendo historial de evaluaciones.

### Casos de Uso Principales
1. **Inspector de campo** evalúa plaza usando tablet/móvil
2. **Genera reportes** PDF y Word con evaluaciones
3. **Envía reportes** por correo al supervisor
4. **Consulta historial** de inspecciones anteriores
5. **Captura evidencia** fotográfica por sección

---

## 🏗️ Arquitectura Actual

### Patrón Arquitectónico
**Arquitectura Limpia + Compilación Condicional por Plataforma**

```
Presentación (UI)
    ↓
Coordinadores (Logic Helpers) ← Condicional: Web | Android
    ↓
Servicios (PDF, Word, Email)
    ↓
Modelos de Datos
    ↓
Almacenamiento (SharedPreferences | SQL futuro)
```

### Estructura de Carpetas

```
lib/
├── main.dart                              # Punto de entrada
├── screens/                               # UI Screens
│   ├── inspeccion_tecnica_screen.dart     # Ficha principal (2600+ líneas)
│   ├── logica_botones_helper.dart         # Export condicional
│   ├── logica_botones_helper_web.dart     # Lógica Web (dart:html)
│   └── logica_botones_helper_android.dart # Lógica Android (path_provider)
├── services/                              # Capa de servicios
│   ├── pdf_export_service.dart            # Generación PDF
│   ├── word_export_service.dart           # Generación Word (HTML)
│   └── email_service.dart                 # Enlaces Gmail/Outlook
├── models/                                # Modelos de datos
│   └── inspection_data.dart               # Modelo principal
├── widgets/                               # Widgets reutilizables
│   └── widgets.dart                       # FilaEvaluacionWidget, etc.
└── utils/                                 # Utilidades
    ├── download_helper.dart               # Export condicional
    ├── download_helper_web.dart
    └── download_helper_mobile.dart
```

### Compilación Condicional

**Técnica usada**: Export condicional de Dart

```dart
// logica_botones_helper.dart
export 'logica_botones_helper_web.dart'
    if (dart.library.io) 'logica_botones_helper_android.dart';
```

**Resultado**:
- `flutter build web` → usa `_web.dart`
- `flutter build apk` → usa `_android.dart`
- Sin código específico de plataforma en componentes

---

## 📊 Modelo de Datos

### Estructura de Inspección

```dart
class InspectionData {
  String plazaId;               // Identificador único
  String nombrePlaza;           // Nombre descriptivo
  String correoSupervisor;      // Email destino
  String nombreInspector;       // Quien inspecciona
  String fechaHoraFormatted;    // Timestamp
  String estadoGeneral;         // Bueno/Regular/Malo
  
  Map<String, EvaluationSection> sections; // 6 secciones
}

class EvaluationSection {
  String title;                 // "ASEO", "CÉSPED", etc.
  List<String> criteria;        // Lista de criterios
  Map<String, String> evaluations;    // criterio → "Bueno"/"Regular"/"Malo"
  Map<String, String> observations;   // criterio → texto observación
}
```

### 6 Secciones de Evaluación

| Sección | Criterios | Propósito |
|---------|-----------|-----------|
| ASEO | 7 | Limpieza, basura, residuos |
| CÉSPED | 4 | Estado del pasto, malezas |
| ARBOLADO | 9 | Árboles, podas, tutores |
| FLORES | 9 | Plantas ornamentales, macizos |
| CAMINOS | 5 | Senderos, material árido |
| INFRAESTRUCTURA | 7 | Riego, bancas, estructuras |

### Almacenamiento Actual

**SharedPreferences (JSON)**
- Key: `historial_${plazaId}`
- Valor: Lista JSON de inspecciones
- Límite: ~1-2 MB
- Performance: Buena hasta 50-100 inspecciones

---

## 🔧 Stack Tecnológico

### Dependencias Core

```yaml
flutter: SDK
flutter_map: ^8.3.0           # Mapas interactivos OpenStreetMap
latlong2: ^0.9.1              # Coordenadas geográficas
url_launcher: ^6.3.2          # Abrir URLs/emails
shared_preferences: ^2.5.5    # Almacenamiento K-V local
```

### Generación de Reportes

```yaml
pdf: ^3.12.0                  # Generación PDF nativa
printing: ^5.14.3             # Preview e impresión
docx_template: 0.4.0          # Word (no usado actualmente)
```

### Captura de Datos

```yaml
image_picker: ^1.2.2          # Fotos desde cámara/galería
image: ^4.1.7                 # Procesamiento de imágenes
```

### Específico por Plataforma

```yaml
# Android/iOS
path_provider: ^2.1.6         # Directorios del sistema
open_file: ^3.3.2             # Abrir archivos con app nativa
share_plus: ^7.2.2            # Compartir archivos

# Web
# dart:html (built-in)         # Blob, AnchorElement para descarga
```

---

## 🎨 Componentes UI Principales

### InspeccionTecnicaScreen

**Responsabilidades**:
- Gestionar TabController (6 pestañas)
- Mantener estado de evaluaciones (18 mapas)
- Coordinar guardado de datos
- Orquestar exportación

**Estado complejo**:
```dart
// 6 mapas de evaluaciones (Map<String, String?>)
_evaluacionesAseo, _evaluacionesCesped, _evaluacionesArbolado,
_evaluacionesFlores, _evaluacionesCaminos, _evaluacionesInfraestructura

// 6 mapas de observaciones (Map<String, TextEditingController>)
_observacionesAseo, _observacionesCesped, ...

// 6 listas de criterios (List<String>)
_criteriosAseo, _criteriosCesped, ...

// 1 mapa de imágenes por sección
_imagenesPorSeccion = {
  'ASEO': [],
  'CÉSPED': [],
  ...
}
```

### FilaEvaluacionWidget

**Widget reutilizable para cada criterio**:
```
┌────────────────────────────────────────────────┐
│ Criterio de evaluación  │ ○B │ ○R │ ○M │ [___]│
└────────────────────────────────────────────────┘
```

- Radio buttons para Bueno/Regular/Malo
- TextField para observaciones
- Diseño responsive

### PanelAccionesFinales

**5 botones de acción**:
1. Guardar en Historial (SharedPreferences)
2. Ver Historial (Diálogo con lista)
3. Descargar PDF
4. Descargar Word
5. Enviar Reporte (Gmail/Outlook)

---

## 📤 Sistema de Exportación

### PDFExportService

**Tecnología**: Package `pdf` + `printing`

**Características**:
- Generación nativa de PDF (no HTML)
- Logo institucional embebido (base64)
- Tablas con bordes y colores
- Formato A4 profesional
- ~500-800 KB por reporte

**Flujo**:
```dart
datos → PDFExportService.generarReporte()
     → pdf.Document()
     → pdf.save()
     → Uint8List (bytes)
```

### WordExportService

**Tecnología**: HTML con namespace Office XML

**Características**:
- Generación HTML con metadatos MSO
- Compatible con MS Word 2007+
- Estilos CSS embebidos
- Tablas con bordes
- Totalmente editable
- ~100-200 KB por reporte

**Estructura HTML**:
```html
<html xmlns:o="urn:schemas-microsoft-com:office:office" ...>
  <head>
    <meta charset="UTF-8">
    <style>/* Estilos CSS */</style>
  </head>
  <body>
    <div class="Section1">
      <!-- Contenido del reporte -->
    </div>
  </body>
</html>
```

### EmailService

**Método**: Enlaces web directos (sin backend)

**Gmail**:
```
https://mail.google.com/mail/?view=cm&to=EMAIL&su=ASUNTO&body=CUERPO
```

**Outlook**:
```
https://outlook.office.com/mail/deeplink/compose?to=EMAIL&subject=ASUNTO&body=CUERPO
```

**Ventajas**:
- ✅ Sin servidor backend
- ✅ Sin problemas CORS
- ✅ Funciona en Web y móvil
- ✅ Usuario usa su cliente familiar

---

## 🔄 Flujos de Datos Críticos

### Flujo 1: Crear Nueva Inspección

```
1. Usuario selecciona plaza
   ↓
2. InspeccionTecnicaScreen.initState()
   - Crea TabController (6 tabs)
   - Inicializa 18 mapas vacíos
   ↓
3. Usuario navega por pestañas
   - Selecciona Bueno/Regular/Malo por criterio
   - Escribe observaciones
   - Agrega fotos
   ↓
4. Datos guardados en memoria (setState)
```

### Flujo 2: Guardar en Historial

```
1. Usuario click "Guardar en Historial"
   ↓
2. _guardarEnHistorial()
   - Consolida datos de 18 mapas
   - Calcula estadoGeneral
   - Serializa a JSON
   ↓
3. SharedPreferences
   - Key: "historial_${plazaId}"
   - Valor: [inspeccion1, inspeccion2, ...]
   ↓
4. SnackBar de confirmación
```

### Flujo 3: Exportar PDF (Web)

```
1. Usuario click "Descargar PDF"
   ↓
2. _prepararDatosInspeccion()
   - Extrae texto de TextEditingControllers
   - Consolida evaluaciones
   - Retorna Map<String, dynamic>
   ↓
3. LogicaBotonesHelper.generarPDF()
   ↓
4. PDFExportService.generarReporte()
   - Genera pdf.Document
   - Retorna Uint8List
   ↓
5. logica_botones_helper_web.dart
   - Crea html.Blob(bytes)
   - Crea html.AnchorElement
   - Simula click → descarga
   ↓
6. Archivo en carpeta Downloads del navegador
```

### Flujo 4: Exportar PDF (Android)

```
1. Usuario click "Descargar PDF"
   ↓
2. (Pasos 1-4 iguales a Web)
   ↓
5. logica_botones_helper_android.dart
   - getApplicationDocumentsDirectory()
   - File.writeAsBytes(bytes)
   - Guarda en almacenamiento interno
   ↓
6. Diálogo con opciones:
   - Abrir (OpenFile.open())
   - Compartir (Share.shareXFiles())
```

### Flujo 5: Enviar Reporte

```
1. Usuario ingresa email supervisor
   ↓
2. Usuario click "Enviar Reporte"
   ↓
3. Diálogo: ¿Gmail o Outlook?
   ↓
4. EmailService.generarEnlaceGmailWeb() o generarEnlaceOutlookWeb()
   - Construye URL con parámetros
   - Email, asunto, cuerpo prellenados
   ↓
5. url_launcher.launchUrl()
   - Abre navegador/app nativa
   ↓
6. Usuario ve correo prellenado
   - Adjunta PDF/Word manualmente
   - Envía
```

---

## 🐛 Problemas Conocidos y Soluciones

### Problema 1: CORS en Web
**Descripción**: Navegador bloquea peticiones HTTP a localhost desde app Flutter Web.

**Solución Implementada**: Eliminado servidor backend, uso de enlaces web directos.

**Estado**: ✅ Resuelto

---

### Problema 2: dart:html en Android
**Descripción**: `dart:html` solo funciona en Web, causa errores en APK.

**Solución Implementada**: Compilación condicional con archivos separados.

**Estado**: ✅ Resuelto

---

### Problema 3: TextEditingController en JSON
**Descripción**: No se pueden serializar TextEditingController a JSON directamente.

**Solución Implementada**: Función `_extraerTexto()` que convierte a Map<String, String>.

```dart
Map<String, String> _extraerTexto(Map<String, TextEditingController> controladores) {
  return controladores.map((key, controller) => MapEntry(key, controller.text));
}
```

**Estado**: ✅ Resuelto

---

### Problema 4: Límites de SharedPreferences
**Descripción**: SharedPreferences limitado a ~1-2 MB, performance degrada con muchos datos.

**Solución Propuesta**: Migrar a SQLite.

**Estado**: 🔄 Pendiente (en roadmap)

---

## 🚀 Roadmap de Mejoras

### Prioridad Alta

#### 1. Migración a SQLite
**Objetivo**: Reemplazar SharedPreferences con base de datos relacional.

**Tareas**:
- [ ] Agregar dependencia `sqflite`
- [ ] Diseñar esquema de 3 tablas (inspecciones, evaluaciones, imagenes)
- [ ] Crear `DatabaseService` con operaciones CRUD
- [ ] Migrar datos existentes de SharedPreferences
- [ ] Actualizar `_guardarEnHistorial()` para usar SQL
- [ ] Actualizar `_verHistorial()` con queries SQL
- [ ] Agregar índices para búsqueda rápida

**Beneficios**:
- Capacidad ilimitada
- Búsqueda y filtrado eficiente
- Relaciones entre datos
- Mejor performance

**Estimación**: 8-12 horas

---

#### 2. Agregar Nueva Pestaña: RIEGO
**Objetivo**: Expandir evaluación con criterios de sistema de riego.

**Tareas**:
- [ ] Definir 5-7 criterios de riego (ver documento)
- [ ] Agregar variables de estado (_evaluacionesRiego, etc.)
- [ ] Actualizar TabController length a 7
- [ ] Crear _buildSeccionRiego()
- [ ] Actualizar exportación de datos
- [ ] Probar PDF/Word con nueva sección

**Beneficios**:
- Evaluación más completa
- Cumplimiento normativo

**Estimación**: 2-3 horas

---

### Prioridad Media

#### 3. Dashboard de Análisis
**Objetivo**: Vista de estadísticas y tendencias.

**Features**:
- Gráfico de evolución temporal por plaza
- Comparativa entre plazas
- Indicadores: % Bueno/Regular/Malo
- Filtros por fecha, sección, estado
- Exportar gráficos a PDF

**Tecnología sugerida**: `fl_chart` package

**Estimación**: 16-20 horas

---

#### 4. Sincronización Cloud
**Objetivo**: Backup automático y acceso multi-dispositivo.

**Opciones**:
- Firebase Firestore (más fácil)
- Servidor REST propio (más control)

**Features**:
- Sync automático cuando hay internet
- Modo offline con queue de cambios
- Resolución de conflictos
- Backup periódico

**Estimación**: 20-30 horas

---

### Prioridad Baja

#### 5. Modo Offline Robusto
**Objetivo**: Funcionalidad completa sin internet.

**Features**:
- Detección de conectividad
- Queue de sincronización
- Indicador visual de estado
- Retry automático

**Estimación**: 8-12 horas

---

#### 6. Autenticación de Usuarios
**Objetivo**: Multi-usuario con roles.

**Roles**:
- Inspector (crea inspecciones)
- Supervisor (ve reportes)
- Admin (gestiona usuarios)

**Tecnología sugerida**: Firebase Auth o custom JWT

**Estimación**: 12-16 horas

---

## 🎨 Guía de Estilo y Convenciones

### Naming Conventions

```dart
// Clases: PascalCase
class InspeccionTecnicaScreen extends StatefulWidget {}

// Variables privadas: _camelCase
final Map<String, String?> _evaluacionesAseo = {};

// Funciones privadas: _camelCase
void _guardarEnHistorial() {}

// Constantes: SCREAMING_SNAKE_CASE
static const String API_URL = 'https://...';

// Archivos: snake_case
inspeccion_tecnica_screen.dart
```

### Estructura de Widgets

```dart
Widget _buildComponente() {
  return Column(
    children: [
      _buildSubComponente1(),
      _buildSubComponente2(),
    ],
  );
}
```

### Comentarios

```dart
/// Documentación de función (triple slash)
/// 
/// Parámetros:
/// - [param1]: Descripción
/// 
/// Returns: Descripción del retorno
String miFuncion(String param1) {}

// Comentario de línea para explicaciones inline
final value = 42; // Respuesta universal
```

### Colores del Tema

```dart
// Azul principal
const Color(0xFF1565C0)

// Verde éxito
const Color(0xFF2E7D32)

// Rojo error
Colors.red

// Gris texto secundario
const Color(0xFF757575)

// Gris background
const Color(0xFFF5F5F5)
```

---

## 🧪 Testing

### Estado Actual
⚠️ **Sin tests implementados**

### Recomendaciones

```dart
// test/widget_test.dart
void main() {
  testWidgets('FilaEvaluacionWidget shows criteria', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FilaEvaluacionWidget(
            textoCriterio: 'Criterio test',
            valorSeleccionado: null,
            onChanged: (_) {},
            controllerObs: TextEditingController(),
          ),
        ),
      ),
    );
    
    expect(find.text('Criterio test'), findsOneWidget);
  });
}
```

### Coverage Objetivo
- Unit tests: 70%
- Widget tests: 50%
- Integration tests: Flujos críticos

---

## 📱 Compilación y Deploy

### Web

```bash
# Desarrollo
flutter run -d chrome

# Producción
flutter build web --release

# Output: build/web/
# Deployment: Subir carpeta build/web a hosting
```

### Android

```bash
# Debug
flutter run -d <device-id>

# Release
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
# Tamaño: ~58 MB

# Split per ABI (más pequeño)
flutter build apk --split-per-abi
# Output: app-armeabi-v7a-release.apk (~20 MB)
#         app-arm64-v8a-release.apk (~22 MB)
#         app-x86_64-release.apk (~22 MB)
```

### Firma de APK (Producción)

⚠️ **Actualmente usa debug keys**

Para Google Play Store:
```bash
# 1. Crear keystore
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# 2. Configurar en android/key.properties
# storePassword=<password>
# keyPassword=<password>
# keyAlias=upload
# storeFile=<path-to-keystore>

# 3. Actualizar android/app/build.gradle
# (ver documentación Flutter)

# 4. Compilar
flutter build apk --release
```

---

## 🔐 Seguridad

### Datos Sensibles
- ❌ No almacenar contraseñas en SharedPreferences
- ❌ No hacer commits con API keys
- ✅ Usar .env para configuración
- ✅ Validar inputs del usuario

### CORS y Web Security
- ✅ Ya solucionado con enlaces web directos
- ⚠️ Si se agrega API: implementar CORS correctamente

---

## 📞 Contacto y Soporte

### Para Preguntas Técnicas
- Revisar `ESTRUCTURA_FICHA_INSPECCION.md`
- Revisar `README.md`
- Consultar código inline (comentarios)

### Para Cambios de Requerimientos
- Contactar: Josué Juan Muñoz Fuentealba
- Cliente: Municipalidad de Doñihue

---

## 🎯 Objetivos para Próxima IA/Desarrollador

### Tareas Inmediatas
1. ✅ Verificar compilación de APK v12.12.0
2. ✅ Probar funcionalidad de descarga en Android
3. ✅ Probar envío de correos desde APK
4. 🔄 Implementar SQLite (siguiente sprint)

### Tareas de Mejora
1. Agregar tests unitarios
2. Optimizar performance (eliminar mapas redundantes)
3. Refactorizar InspeccionTecnicaScreen (muy grande)
4. Documentar con dartdoc

### Innovaciones Sugeridas
1. IA para detectar problemas en fotos
2. Reconocimiento de voz para observaciones
3. Geolocalización automática
4. Timeline de evolución de cada plaza

---

## 📚 Recursos Adicionales

### Documentación Clave
- [`README.md`](README.md) - Documentación general
- [`ESTRUCTURA_FICHA_INSPECCION.md`](ESTRUCTURA_FICHA_INSPECCION.md) - Detalle técnico
- [`APK_ACTUALIZADO_ICONO.txt`](APK_ACTUALIZADO_ICONO.txt) - Historial APK

### Packages Importantes
- [Flutter Map](https://pub.dev/packages/flutter_map) - Mapas
- [PDF](https://pub.dev/packages/pdf) - Generación PDF
- [Printing](https://pub.dev/packages/printing) - Preview PDF
- [SharedPreferences](https://pub.dev/packages/shared_preferences) - Storage
- [ImagePicker](https://pub.dev/packages/image_picker) - Fotos

### Comunidad Flutter
- [Flutter Docs](https://docs.flutter.dev/)
- [Dart Docs](https://dart.dev/guides)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)

---

## ✅ Checklist para Nueva IA

Antes de empezar a desarrollar, verificar:

- [ ] He leído README.md completo
- [ ] He leído ESTRUCTURA_FICHA_INSPECCION.md
- [ ] Entiendo el sistema de compilación condicional
- [ ] Sé dónde está cada componente
- [ ] Entiendo el flujo de datos
- [ ] He revisado los problemas conocidos
- [ ] He visto el roadmap de mejoras
- [ ] Sé cómo compilar Web y Android
- [ ] Entiendo las convenciones de código
- [ ] Sé a quién contactar para dudas

---

<div align="center">

**Sistema de Inspección de Áreas Verdes**

Perfil de Arquitectura v1.0

Creado: Julio 2026

</div>
