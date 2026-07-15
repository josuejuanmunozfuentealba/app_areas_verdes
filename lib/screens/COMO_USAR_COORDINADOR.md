# Cómo Usar el Coordinador LogicaBotonesHelper

## Arquitectura Limpia Implementada

```
┌─────────────────────────────────────────────┐
│     inspeccion_tecnica_screen.dart          │
│            (Pantalla/UI)                    │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────┐
│      LogicaBotonesHelper.dart               │
│         (COORDINADOR MAESTRO)               │
│  - Recibe datos                             │
│  - Coordina servicios                       │
│  - Muestra progreso/errores                 │
└──────┬──────────┬───────────┬───────────────┘
       │          │           │
       ▼          ▼           ▼
┌──────────┐ ┌──────────┐ ┌──────────┐
│ PDF      │ │ Word     │ │ Email    │
│ Service  │ │ Service  │ │ Service  │
│ (Obrero) │ │ (Obrero) │ │ (Obrero) │
└──────────┘ └──────────┘ └──────────┘
```

## Ejemplo 1: Exportar PDF y Word (Sin Enviar)

```dart
// En inspeccion_tecnica_screen.dart

Future<void> _exportarReportePDF() async {
  // Preparar datos
  final datosInspeccion = {
    'plazaId': widget.plazaId,
    'nombrePlaza': widget.nombrePlaza,
    'correoSupervisor': _correoJefeController.text,
    'fechaHora': DateTime.now().toString().substring(0, 16),
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
    'estadoGeneral': _calcularEstadoGeneral(),
    'imagesBySection': _imagenesPorSeccion,
    'nombreInspector': _nombreSupervisorController.text,
  };

  // Llamar al coordinador (genera PDF y Word, NO envía)
  final archivos = await LogicaBotonesHelper.generarYGestionarReportes(
    context: context,
    datosInspeccion: datosInspeccion,
    paraEnviar: false, // No enviar por correo
  );

  if (archivos != null) {
    // Opcionalmente, descargar los archivos
    final pdfBytes = archivos['pdf']!;
    final wordBytes = archivos['word']!;
    
    // Usar Printing.sharePdf para compartir el PDF
    await Printing.sharePdf(
      bytes: Uint8List.fromList(pdfBytes),
      filename: 'Inspeccion_${widget.nombrePlaza}.pdf',
    );
  }
}
```

## Ejemplo 2: Exportar y Enviar por Correo

```dart
// En inspeccion_tecnica_screen.dart

Future<void> _enviarAlJefe() async {
  final correo = _correoJefeController.text.trim();

  if (correo.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('⚠ Ingrese el correo del inspector')),
    );
    return;
  }

  // Preparar datos (igual que antes)
  final datosInspeccion = {
    'plazaId': widget.plazaId,
    'nombrePlaza': widget.nombrePlaza,
    'correoSupervisor': correo,
    'fechaHora': DateTime.now().toString().substring(0, 16),
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
    'estadoGeneral': _calcularEstadoGeneral(),
    'imagesBySection': _imagenesPorSeccion,
    'nombreInspector': _nombreSupervisorController.text,
  };

  // Llamar al coordinador (genera Y ENVÍA)
  await LogicaBotonesHelper.generarYGestionarReportes(
    context: context,
    datosInspeccion: datosInspeccion,
    paraEnviar: true, // SÍ enviar por correo
    destinatarioEmail: correo, // Email del destinatario
  );

  // El coordinador se encarga de:
  // 1. Generar PDF
  // 2. Generar Word
  // 3. Enviar ambos por correo
  // 4. Mostrar progreso
  // 5. Mostrar éxito o error
}
```

## Ejemplo 3: Generar Solo PDF

```dart
// Si solo necesitas el PDF (sin Word ni envío)

final datosInspeccion = { /* ... */ };

final pdfBytes = await LogicaBotonesHelper.generarSoloPDF(
  datosInspeccion: datosInspeccion,
);

// Usar los bytes del PDF
await Printing.sharePdf(
  bytes: Uint8List.fromList(pdfBytes),
  filename: 'reporte.pdf',
);
```

## Ejemplo 4: Generar Solo Word

```dart
// Si solo necesitas el Word (sin PDF ni envío)

final datosInspeccion = { /* ... */ };

final wordBytes = await LogicaBotonesHelper.generarSoloWord(
  datosInspeccion: datosInspeccion,
);

// Descargar el Word
await word_export.downloadWordFile(
  utf8.decode(wordBytes),
  'reporte.doc',
);
```

## Estructura de Datos Requerida

El coordinador requiere un mapa con los siguientes campos:

```dart
Map<String, dynamic> datosInspeccion = {
  // REQUERIDOS
  'plazaId': String,                              // ID de la plaza
  'nombrePlaza': String,                          // Nombre de la plaza
  'correoSupervisor': String,                     // Email del supervisor
  'fechaHora': String,                            // Fecha y hora formateada
  'allEvaluations': Map<String, Map<String, String?>>, // Evaluaciones por sección
  'allCriteria': Map<String, List<String>>,       // Criterios por sección
  'estadoGeneral': String,                        // Estado general (Bueno/Regular/Malo)
  'imagesBySection': Map<String, List<Map<String, dynamic>>>, // Imágenes por sección
  
  // OPCIONALES
  'nombreInspector': String?,                     // Nombre del inspector (opcional)
};
```

## Ventajas de esta Arquitectura

✅ **Separación de responsabilidades**: Cada servicio hace UNA cosa
✅ **Reutilizable**: Puedes usar PDFService o WordService independientemente
✅ **Testeable**: Cada servicio se puede testear por separado
✅ **Sin duplicación**: Toda la lógica está centralizada en el coordinador
✅ **Fácil mantenimiento**: Si cambias PDFService, el coordinador sigue igual
✅ **Mensajes automáticos**: El coordinador maneja progreso y errores por ti

## Eliminación de Código Duplicado

### ❌ ANTES (Código duplicado en 3 lugares):
- `inspeccion_tecnica_screen.dart`: Lógica de exportación mezclada
- `pdf_export_service.dart`: Intentaba generar Word también
- `logica_botones_helper.dart`: Lógica incompleta

### ✅ AHORA (Arquitectura limpia):
- `LogicaBotonesHelper`: ÚNICO coordinador
- `PDFExportService`: Solo genera PDFs
- `WordExportService`: Solo genera Word
- `EmailService`: Solo envía correos

## Notas Importantes

1. **No modifiques los servicios** (`PDFExportService`, `WordExportService`) para agregar lógica de coordinación. Usa el helper.

2. **No agregues lógica de exportación en la pantalla**. Toda la lógica debe pasar por el coordinador.

3. **El coordinador valida los datos** automáticamente. Si falta un campo, lanza una excepción clara.

4. **El coordinador maneja errores** y muestra mensajes apropiados al usuario.

5. **Para añadir nuevas funcionalidades** (ej: exportar a Excel), crea un nuevo servicio y llámalo desde el coordinador.
