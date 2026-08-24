# 🌳 Sistema de Inspección de Áreas Verdes

![Version](https://img.shields.io/badge/version-12.12.0-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.11.5-02569B?logo=flutter)
![Platform](https://img.shields.io/badge/platform-Web%20%7C%20Android-green.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

> Sistema de gestión y evaluación técnica de áreas verdes y plazas públicas para la Municipalidad de Doñihue

---

## 📋 Tabla de Contenidos

- [Descripción](#-descripción)
- [Características](#-características)
- [Arquitectura](#-arquitectura)
- [Instalación](#-instalación)
- [Uso](#-uso)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Ficha de Inspección](#-ficha-de-inspección)
- [Exportación de Reportes](#-exportación-de-reportes)
- [Desarrollo](#-desarrollo)
- [Roadmap](#-roadmap)
- [Autor](#-autor)

---

## 📖 Descripción

Sistema multiplataforma para la inspección técnica de áreas verdes que permite:

- ✅ Evaluación sistemática de 6 categorías (41 criterios totales)
- ✅ Captura de evidencia fotográfica por sección
- ✅ Generación automática de reportes PDF y Word
- ✅ Envío directo por correo electrónico (Gmail/Outlook)
- ✅ Historial de inspecciones por plaza
- ✅ Funcionamiento offline con sincronización

---

## ✨ Características

### 🎯 Funcionalidades Principales

#### 📋 Ficha de Inspección
- **6 Secciones de Evaluación**:
  - 🧹 ASEO (7 criterios)
  - 🌱 CÉSPED (4 criterios)
  - 🌳 ARBOLADO (9 criterios)
  - 🌺 FLORES (9 criterios)
  - 🛤️ CAMINOS (5 criterios)
  - 🏗️ INFRAESTRUCTURA (7 criterios)

- **Sistema de Calificación**: Bueno / Regular / Malo
- **Observaciones**: Campo de texto por cada criterio
- **Evidencia Fotográfica**: Múltiples imágenes por sección con títulos editables

#### 📄 Generación de Reportes
- **PDF**: Documento profesional con logo, tablas y datos completos
- **Word**: Archivo editable con formato compatible con MS Word
- **Email**: Envío directo a Gmail o Outlook Web (sin servidor backend)

#### 💾 Gestión de Datos
- **Historial Local**: SharedPreferences (actual)
- **Sincronización**: Preparado para SQLite + Cloud (futuro)
- **Exportación**: JSON, PDF, DOCX

### 🌐 Multiplataforma

| Plataforma | Estado | Características |
|------------|--------|----------------|
| **Web** | ✅ Producción | Descarga directa de archivos, Gmail/Outlook Web |
| **Android** | ✅ Producción | Almacenamiento local, compartir archivos, apps nativas |
| **iOS** | 🔄 Planeado | Mismo código que Android |
| **Windows** | 🔄 Planeado | Ejecutable nativo |

---

## 🏗️ Arquitectura

### 📁 Estructura General

```
app_areas_verdes/
├── lib/
│   ├── main.dart                          # Punto de entrada
│   ├── screens/                           # Pantallas
│   │   ├── inspeccion_tecnica_screen.dart # Ficha principal
│   │   ├── logica_botones_helper.dart     # Punto de entrada (condicional)
│   │   ├── logica_botones_helper_web.dart # Lógica para Web
│   │   └── logica_botones_helper_android.dart # Lógica para Android/móvil
│   ├── services/                          # Servicios
│   │   ├── pdf_export_service.dart        # Generación de PDF
│   │   ├── word_export_service.dart       # Generación de Word
│   │   └── email_service.dart             # Enlaces de correo
│   ├── models/                            # Modelos de datos
│   │   └── inspection_data.dart
│   ├── widgets/                           # Widgets reutilizables
│   │   └── widgets.dart
│   └── utils/                             # Utilidades
│       ├── download_helper.dart           # Descarga condicional
│       ├── download_helper_web.dart
│       └── download_helper_mobile.dart
├── android/                               # Configuración Android
├── web/                                   # Configuración Web
├── assets/                                # Recursos
│   ├── iconoescri.png                    # Icono de la app
│   └── logo_2026.png                     # Logo para reportes
└── docs/
    ├── README.md                          # Este archivo
    └── ESTRUCTURA_FICHA_INSPECCION.md    # Documentación técnica detallada
```

### 🔧 Arquitectura de Exportación

```
                    ┌─────────────────────┐
                    │   Usuario hace clic  │
                    └──────────┬──────────┘
                               │
                    ┌──────────▼──────────┐
                    │ LogicaBotonesHelper │ ← Punto de entrada
                    └──────────┬──────────┘
                               │
              ┌────────────────┴────────────────┐
              │                                  │
    ┌─────────▼──────────┐          ┌──────────▼─────────┐
    │ helper_web.dart     │          │ helper_android.dart │
    │ (Navegador)         │          │ (APK/móvil)        │
    └─────────┬──────────┘          └──────────┬─────────┘
              │                                  │
    ┌─────────▼──────────┐          ┌──────────▼─────────┐
    │ dart:html           │          │ path_provider      │
    │ Blob + AnchorElement│          │ open_file          │
    │ Descarga directa    │          │ share_plus         │
    └─────────────────────┘          └────────────────────┘
```

**Ventajas**:
- ✅ Mismo código fuente
- ✅ Compilación condicional automática
- ✅ Sin código específico de plataforma en componentes
- ✅ Fácil mantenimiento

---

## 🚀 Instalación

### Prerrequisitos

```bash
# Flutter SDK 3.11.5 o superior
flutter --version

# Verificar instalación
flutter doctor
```

### Clonar Repositorio

```bash
git clone https://github.com/josuejuanmunozfuentealba/app_areas_verdes.git
cd app_areas_verdes
```

### Instalar Dependencias

```bash
flutter pub get
```

### Ejecutar en Web

```bash
flutter run -d chrome
```

### Compilar APK para Android

```bash
flutter build apk --release
```

El APK se generará en: `build/app/outputs/flutter-apk/app-release.apk`

---

## 💻 Uso

### 1. Inicio de Inspección

1. Abrir la aplicación
2. Seleccionar plaza desde el mapa o lista
3. Acceder a "Ficha de Inspección"

### 2. Completar Evaluación

1. Revisar información de la plaza (tabla superior)
2. Navegar entre las 6 pestañas
3. Para cada criterio:
   - Seleccionar: Bueno (B), Regular (R) o Malo (M)
   - Agregar observaciones opcionales
4. Agregar fotos de evidencia por sección

### 3. Generar Reportes

#### Opción A: Descargar Archivos
```
1. Click en "Descargar PDF"
   → Se descarga archivo PDF
   
2. Click en "Descargar Word"
   → Se descarga archivo DOCX editable
```

#### Opción B: Enviar por Correo
```
1. Ingresar email del supervisor
2. Click en "Enviar Reporte"
3. Seleccionar Gmail o Outlook
4. Se abre correo prellenado
5. Adjuntar PDF/Word descargados
6. Enviar
```

### 4. Gestionar Historial

```
1. Click en "Guardar en Historial"
   → Inspección guardada localmente
   
2. Click en "Ver Historial"
   → Ver inspecciones anteriores de la plaza
```

---

## 📊 Ficha de Inspección

### Estructura de Datos

Cada inspección contiene:

```dart
{
  "plazaId": "AV-001",
  "nombrePlaza": "Plaza Central",
  "correoSupervisor": "supervisor@example.com",
  "fechaHora": "2026-07-15T16:00:00.000",
  "allEvaluations": {
    "ASEO": { "criterio1": "Bueno", "criterio2": "Regular" },
    "CÉSPED": { ... },
    "ARBOLADO": { ... },
    "FLORES": { ... },
    "CAMINOS": { ... },
    "INFRAESTRUCTURA": { ... }
  },
  "allCriteria": {
    "ASEO": ["criterio1", "criterio2", ...],
    "CÉSPED": [...],
    ...
  },
  "allObservations": {
    "ASEO": { "criterio1": "Observación de ejemplo" },
    ...
  }
}
```

### Categorías y Criterios

| Sección | Criterios | Ejemplos |
|---------|-----------|----------|
| **ASEO** | 7 | Basura, residuos, escombros, aseo general |
| **CÉSPED** | 4 | Césped seco, densidad, pasto cortado, malezas |
| **ARBOLADO** | 9 | Enfermedades, podas, tutores, tazas |
| **FLORES** | 9 | Estado plantas, densidad, terreno, malezas |
| **CAMINOS** | 5 | Malezas, material árido, compactación |
| **INFRAESTRUCTURA** | 7 | Mantención, pintura, riego, reparaciones |

Para detalles completos, ver: [`ESTRUCTURA_FICHA_INSPECCION.md`](ESTRUCTURA_FICHA_INSPECCION.md)

---

## 📤 Exportación de Reportes

### PDF (PDFExportService)

**Características**:
- ✅ Logo institucional
- ✅ Tabla de información general
- ✅ Secciones de evaluación con colores
- ✅ Criterios con calificaciones
- ✅ Observaciones incluidas
- ✅ Formato profesional A4

**Tecnología**: Package `pdf` + `printing`

### Word (WordExportService)

**Características**:
- ✅ Formato HTML compatible con MS Word
- ✅ Namespace Office XML
- ✅ Tablas con bordes
- ✅ Estilos personalizados
- ✅ 100% editable

**Tecnología**: Generación HTML con metadatos de Office

### Email (EmailService)

**Método Actual**: Enlaces Web Directos

```dart
// Gmail
https://mail.google.com/mail/?view=cm&to=EMAIL&su=ASUNTO&body=CUERPO

// Outlook
https://outlook.office.com/mail/deeplink/compose?to=EMAIL&subject=ASUNTO&body=CUERPO
```

**Ventajas**:
- ✅ Sin servidor backend
- ✅ Sin problemas de CORS
- ✅ Funciona en Web y móvil
- ✅ Cliente de correo familiar al usuario

---

## 🛠️ Desarrollo

### Agregar Nueva Pestaña a la Ficha

**Documentación completa**: [`ESTRUCTURA_FICHA_INSPECCION.md`](ESTRUCTURA_FICHA_INSPECCION.md) - Sección "Cómo Agregar Nueva Pestaña"

**Resumen de pasos**:
1. Agregar 3 variables de estado (evaluaciones, observaciones, criterios)
2. Actualizar `TabController` length
3. Agregar pestaña al `TabBar`
4. Agregar vista al `TabBarView`
5. Crear función `_buildSeccionXXX()`
6. Actualizar mapas de imágenes
7. Actualizar `dispose()`
8. Actualizar `_prepararDatosInspeccion()`
9. Actualizar `_guardarEnHistorial()`

### Estructura de Código

#### Imports Condicionales

```dart
// lib/screens/logica_botones_helper.dart
export 'logica_botones_helper_web.dart'
    if (dart.library.io) 'logica_botones_helper_android.dart';
```

**Resultado**:
- En Web → usa `logica_botones_helper_web.dart`
- En Android/iOS → usa `logica_botones_helper_android.dart`

### Dependencias Principales

```yaml
dependencies:
  flutter_map: ^8.3.0           # Mapa interactivo
  latlong2: ^0.9.1              # Coordenadas
  url_launcher: ^6.3.2          # Abrir URLs
  shared_preferences: ^2.5.5    # Almacenamiento local
  pdf: ^3.12.0                  # Generación PDF
  printing: ^5.14.3             # Imprimir PDF
  http: ^1.2.1                  # Peticiones HTTP
  image_picker: ^1.2.2          # Captura de fotos
  path_provider: ^2.1.6         # Directorios del sistema
  open_file: ^3.3.2             # Abrir archivos (Android)
  share_plus: ^7.2.2            # Compartir archivos (Android)
```

### Comandos Útiles

```bash
# Limpiar proyecto
flutter clean

# Actualizar dependencias
flutter pub get

# Analizar código
flutter analyze

# Ejecutar tests
flutter test

# Compilar Web
flutter build web

# Compilar APK (Release)
flutter build apk --release

# Compilar APK por arquitectura (más pequeños)
flutter build apk --split-per-abi

# Ver dispositivos conectados
flutter devices
```

---

## 🗄️ Roadmap - Integración SQL

### Estado Actual
- ✅ SharedPreferences (almacenamiento local simple)
- ✅ JSON para exportar/importar
- ⚠️ Limitado a ~1-2 MB de datos

### Próxima Versión: SQLite

#### Esquema Propuesto

```sql
-- Tabla principal de inspecciones
CREATE TABLE inspecciones (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  plaza_id TEXT NOT NULL,
  nombre_plaza TEXT NOT NULL,
  correo_supervisor TEXT,
  nombre_inspector TEXT,
  fecha_hora TEXT NOT NULL,
  estado_general TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Evaluaciones por criterio
CREATE TABLE evaluaciones (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  inspeccion_id INTEGER NOT NULL,
  seccion TEXT NOT NULL,
  criterio TEXT NOT NULL,
  evaluacion TEXT,
  observacion TEXT,
  FOREIGN KEY (inspeccion_id) REFERENCES inspecciones(id)
);

-- Imágenes de evidencia
CREATE TABLE imagenes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  inspeccion_id INTEGER NOT NULL,
  seccion TEXT NOT NULL,
  titulo TEXT,
  ruta_archivo TEXT NOT NULL,
  fecha_captura TEXT,
  FOREIGN KEY (inspeccion_id) REFERENCES inspecciones(id)
);
```

#### Ventajas de SQLite
- ✅ Capacidad ilimitada (GB de datos)
- ✅ Consultas SQL eficientes
- ✅ Relaciones entre tablas
- ✅ Transacciones ACID
- ✅ Búsqueda y filtrado avanzado
- ✅ Mejor performance con muchos datos

#### Implementación Planeada
```dart
// lib/services/database_service.dart
class DatabaseService {
  Future<int> insertInspeccion(InspectionData data);
  Future<List<InspectionData>> getInspecciones({String? plazaId});
  Future<InspectionData?> getInspeccionById(int id);
  Future<void> updateInspeccion(int id, InspectionData data);
  Future<void> deleteInspeccion(int id);
  Future<void> syncToCloud(); // Sincronización opcional
}
```

---

## 📈 Versiones

### v12.12.0 (Actual) - Julio 2026
- ✅ Sistema de envío sin servidor (Gmail/Outlook Web)
- ✅ Arquitectura multiplataforma (Web/Android separados)
- ✅ Solución de problemas CORS
- ✅ Función `_extraerTexto()` para conversión de datos
- ✅ Mejoras en formato de correos
- ✅ Dependencias: `open_file`, `share_plus`

### v12.11.0 - Mayo 2026
- ✅ Sidebar moderno
- ✅ Icono actualizado (escudo de Doñihue)

### v12.10.0 - Mayo 2026
- ✅ Integración Felipe Lagos
- ✅ Sistema de reportes básico

### Próximas Versiones
- 🔄 v13.0.0 - Integración SQLite
- 🔄 v13.1.0 - Nueva pestaña RIEGO
- 🔄 v14.0.0 - Sincronización en la nube
- 🔄 v14.1.0 - Modo offline completo
- 🔄 v15.0.0 - Dashboard de análisis

---

## 📝 Changelog

Ver [`CHANGELOG.md`](CHANGELOG.md) para historial completo de cambios.

---

## 🤝 Contribuir

Este es un proyecto privado para la Municipalidad de Doñihue. 

Para sugerencias o reportes de bugs, contactar al desarrollador.

---

## 📄 Licencia

Copyright © 2026 Josué Juan Muñoz Fuentealba

Todos los derechos reservados. Este software es propiedad de la Municipalidad de Doñihue.

---

## 👨‍💻 Autor

**Josué Juan Muñoz Fuentealba**
- Email: josue.munoz@example.com
- GitHub: [@josuejuanmunozfuentealba](https://github.com/josuejuanmunozfuentealba)

---

## 📚 Documentación Adicional

- 📘 [Estructura de la Ficha de Inspección](ESTRUCTURA_FICHA_INSPECCION.md)
- 📙 [Guía para Agregar Pestañas](ESTRUCTURA_FICHA_INSPECCION.md#cómo-agregar-una-nueva-pestaña)
- 📗 [Integración SQL Propuesta](ESTRUCTURA_FICHA_INSPECCION.md#integración-con-sql-propuesta)
- 📕 APK - [Notas de Actualización](APK_ACTUALIZADO_ICONO.txt)

---

## 🙏 Agradecimientos

- Municipalidad de Doñihue
- Felipe Lagos Bastias - Ingeniero Agrónomo (Encargado)
- Equipo de Áreas Verdes

---

<div align="center">

**Sistema de Inspección de Áreas Verdes** | Municipalidad de Doñihue | 2026

Desarrollado con ❤️ usando Flutter

</div>
