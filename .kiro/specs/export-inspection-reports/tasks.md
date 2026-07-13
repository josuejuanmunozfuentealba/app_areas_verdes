# Implementation Plan: Export Inspection Reports

## Overview

Este plan de implementación detalla los pasos necesarios para agregar funcionalidades de exportación de reportes en formatos PDF y DOCX a la aplicación Flutter de inspecciones técnicas. La implementación se divide en componentes modulares y reutilizables, con énfasis en la separación de responsabilidades y testing incremental.

## Tasks

- [x] 1. Configurar dependencias y estructura base
  - Verificar que `pubspec.yaml` contiene las dependencias necesarias: `pdf: ^3.12.0`, `printing: ^5.14.3`, `docx_creator: ^1.2.7`
  - Crear archivo `lib/services/pdf_export_service.dart` para la generación de PDFs
  - Crear archivo `lib/services/word_export_service.dart` para la generación de Word
  - Crear archivo `lib/utils/web_download_helper.dart` para manejo de descargas web
  - Crear archivo `lib/models/inspection_data.dart` para modelos de datos
  - Agregar imports condicionales necesarios en los archivos correspondientes
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 8.7, 8.8, 8.9, 8.10_

- [x] 2. Implementar modelos de datos
  - [x] 2.1 Crear clase `InspectionData` con campos: plazaId, nombrePlaza, correoSupervisor, fechaHora, estadoGeneral, sections
    - Agregar constructor con required fields
    - Agregar validación básica en el constructor
    - _Requirements: 3.1, 6.6_
  
  - [x] 2.2 Crear clase `EvaluationSection` con campos: title, criteria, evaluations
    - Agregar getter `evaluatedItems` que retorna List<EvaluatedItem>
    - Implementar mapeo de criterios a ítems evaluados
    - _Requirements: 3.3, 3.4, 3.5_
  
  - [x] 2.3 Crear clase `EvaluatedItem` con campos: criterio, valor
    - Agregar getter `isProblematic` para identificar items Regular/Malo
    - _Requirements: 3.6_

- [x] 3. Implementar función de compilación de datos
  - [x] 3.1 Crear método `_compilarDatosInspeccion()` en InspeccionTecnicaScreen
    - Recopilar datos de todas las evaluaciones: _evaluacionesAseo, _evaluacionesCesped, _evaluacionesArbolado, _evaluacionesFlores, _evaluacionesCaminos, _evaluacionesInfraestructura
    - Recopilar todas las listas de criterios correspondientes
    - Crear instancia de InspectionData con los 6 sections en orden correcto
    - Usar "N/A" como valor por defecto para evaluaciones ausentes
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_
  
  - [x] 3.2 Implementar función `_calcularEstadoGeneral()` (ya existe, verificar lógica)
    - Contar items evaluados como "Malo"
    - Contar items evaluados como "Regular"
    - Retornar "Malo" si >5 items son "Malo"
    - Retornar "Regular" si >0 items son "Malo" OR >10 items son "Regular"
    - Retornar "Bueno" en cualquier otro caso
    - _Requirements: 3.7, 3.8, 3.9_
  
  - [ ] 3.3 Write property test for data compilation
    - **Property 1: Complete Section Coverage**
    - **Validates: Requirements 1.1, 2.1, 3.2**
  
  - [ ] 3.4 Write property test for estado general calculation
    - **Property 4: Valid Estado General Calculation**
    - **Validates: Requirements 3.7, 3.8, 3.9**
  
  - [ ] 3.5 Write property test for data immutability
    - **Property 5: Evaluation State Preservation**
    - **Validates: Requirements 3.10**

- [x] 4. Checkpoint - Verificar compilación de datos
  - Ensure all tests pass, ask the user if questions arise.

- [x] 5. Implementar servicio de exportación PDF
  - [x] 5.1 Crear clase `PDFExportService` en `lib/services/pdf_export_service.dart`
    - Importar `package:pdf/pdf.dart` y `package:pdf/widgets.dart as pw`
    - Crear método `generateInspectionPDF()` que recibe InspectionData
    - _Requirements: 1.1, 1.2_
  
  - [x] 5.2 Implementar método `_buildHeader()` en PDFExportService
    - Crear pw.Header con título "REPORTE DE INSPECCIÓN TÉCNICA"
    - Agregar pw.Divider con thickness: 2
    - _Requirements: 1.2_
  
  - [x] 5.3 Implementar método `_buildInfoTable()` en PDFExportService
    - Crear pw.Table con dos columnas (flex 1.5 y flex 3)
    - Agregar filas para: ID av, DESCRIPCIÓN, FECHA/HORA, Inspector
    - Aplicar colores de fondo: grey300 para labels, white para valores
    - Formatear fecha/hora como substring(0, 16)
    - _Requirements: 1.3, 4.10, 6.5, 6.6, 6.10_
  
  - [x] 5.4 Implementar método `_buildEvaluationSection()` en PDFExportService
    - Crear header row con título de la sección en bold, background grey300
    - Crear pw.Table con bordes usando TableBorder.all()
    - Agregar dos columnas: "ÍTEM" (flex 3) y "EVALUACIÓN" (flex 1)
    - Iterar sobre todos los criterios de la sección
    - Para cada criterio, crear fila con texto del criterio y valor de evaluación
    - Usar "N/A" para evaluaciones ausentes
    - _Requirements: 1.4, 1.5, 4.1, 4.2, 4.4, 4.5, 4.6, 4.8_
  
  - [x] 5.5 Implementar método `_buildSummary()` en PDFExportService
    - Crear pw.Container con padding y border
    - Aplicar background color grey300
    - Mostrar texto "Estado General: {estadoGeneral}" en bold
    - _Requirements: 1.6, 4.9, 6.7_
  
  - [x] 5.6 Ensamblar documento completo en `generateInspectionPDF()`
    - Crear pw.Document()
    - Agregar pw.MultiPage con pageFormat A4 y margin 32
    - En build: agregar header, SizedBox(20), info table, SizedBox(20)
    - Iterar sobre las 6 secciones en orden y agregar tabla de cada una con SizedBox(15) entre ellas
    - Agregar summary al final
    - Retornar el documento completo
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6_
  
  - [ ] 5.7 Write property test for PDF table structure
    - **Property 3: Table Structure Integrity**
    - **Validates: Requirements 1.4, 1.5, 4.2, 4.3, 4.4, 4.5**
  
  - [ ] 5.8 Write property test for column width consistency
    - **Property 12: Column Width Consistency**
    - **Validates: Requirements 4.2, 4.3**

- [ ] 6. Implementar función `_exportarReportePDF()` en InspeccionTecnicaScreen
  - [ ] 6.1 Reemplazar stub existente con implementación completa
    - Envolver todo en try-catch block
    - Llamar a `_compilarDatosInspeccion()` para obtener InspectionData
    - Crear instancia de PDFExportService
    - Llamar a `generateInspectionPDF()` con los datos compilados
    - Generar filename usando formato "Inspeccion_{plazaId}_{timestamp}.pdf" donde timestamp = DateTime.now().millisecondsSinceEpoch
    - Llamar a `Printing.layoutPdf(onLayout: (format) => pdfDoc.save(), name: filename)`
    - En caso de éxito: mostrar SnackBar verde con mensaje "✓ PDF generado exitosamente"
    - En caso de error: catch exception, mostrar SnackBar rojo con mensaje de error
    - Verificar `mounted` antes de mostrar SnackBar
    - _Requirements: 1.1, 1.7, 1.8, 1.9, 1.10, 5.1, 5.6, 6.1, 6.3, 6.8_
  
  - [ ] 6.2 Write property test for filename format
    - **Property 8: Filename Format Consistency**
    - **Validates: Requirements 1.8, 2.8, 6.1, 6.2, 6.8, 6.9**
  
  - [ ] 6.3 Write property test for error handling
    - **Property 9: Error Handling Completeness**
    - **Validates: Requirements 1.10, 2.12, 5.4, 5.5, 5.7**
  
  - [ ] 6.4 Write unit test for success SnackBar display
    - Verify green SnackBar with success message is shown
    - _Requirements: 1.9, 5.2_
  
  - [ ] 6.5 Write unit test for error SnackBar display
    - Verify red SnackBar with error message is shown
    - _Requirements: 1.10, 5.4_

- [ ] 7. Checkpoint - Verificar exportación PDF
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 8. Implementar servicio de exportación Word
  - [ ] 8.1 Crear clase `WordExportService` en `lib/services/word_export_service.dart`
    - Importar `package:docx_creator/docx_creator.dart`
    - Crear método `generateInspectionDOCX()` que recibe InspectionData y retorna Future<Uint8List>
    - _Requirements: 2.1, 2.2_
  
  - [ ] 8.2 Implementar método `_addHeader()` en WordExportService
    - Agregar heading "REPORTE DE INSPECCIÓN TÉCNICA"
    - Agregar línea divisoria (horizontal line o border)
    - _Requirements: 2.2_
  
  - [ ] 8.3 Implementar método `_addInfoTable()` en WordExportService
    - Crear tabla con dos columnas
    - Agregar filas para: ID av, DESCRIPCIÓN, FECHA/HORA, Inspector
    - Aplicar estilos similares a PDF (colores de fondo)
    - _Requirements: 2.3, 6.5, 6.6_
  
  - [ ] 8.4 Implementar método `_addEvaluationSection()` en WordExportService
    - Crear tabla con header row mostrando título de sección
    - Crear tabla con dos columnas: "ÍTEM" y "EVALUACIÓN"
    - Iterar sobre criterios y agregar filas con datos
    - Mantener la misma estructura que PDF (columnas editables)
    - _Requirements: 2.3, 2.4, 4.3, 4.7_
  
  - [ ] 8.5 Implementar método `_addSummary()` en WordExportService
    - Agregar párrafo o tabla con "Estado General: {estadoGeneral}"
    - Aplicar estilos consistentes con PDF
    - _Requirements: 2.3, 6.7_
  
  - [ ] 8.6 Ensamblar documento completo en `generateInspectionDOCX()`
    - Crear DocxCreator()
    - Llamar a _addHeader()
    - Llamar a _addInfoTable()
    - Iterar sobre las 6 secciones en orden y llamar a _addEvaluationSection() para cada una
    - Llamar a _addSummary()
    - Llamar a docx.save() para obtener Uint8List
    - Retornar bytes
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_
  
  - [ ] 8.7 Write property test for format consistency
    - **Property 2: Data Consistency Between Formats**
    - **Validates: Requirements 2.2, 2.3, 2.4**

- [ ] 9. Implementar helper de descarga web
  - [ ] 9.1 Crear clase `WebDownloadHelper` en `lib/utils/web_download_helper.dart`
    - Agregar conditional import: `import 'dart:html' as html show AnchorElement, Blob, Url;`
    - Importar `package:flutter/foundation.dart` para kIsWeb
    - Crear método estático `downloadFile({required Uint8List bytes, required String fileName, required String mimeType})`
    - _Requirements: 2.6, 2.7, 2.8_
  
  - [ ] 9.2 Implementar lógica de descarga en `downloadFile()`
    - Verificar que kIsWeb == true, si no, lanzar Exception
    - Crear html.Blob con bytes y mimeType
    - Crear url usando html.Url.createObjectUrlFromBlob(blob)
    - Crear html.AnchorElement con href = url
    - Establecer anchor.download = fileName
    - Llamar a anchor.click() para trigger download
    - Llamar a html.Url.revokeObjectUrl(url) para limpiar
    - _Requirements: 2.6, 2.7, 2.8, 2.9, 2.10_
  
  - [ ] 9.3 Write property test for resource cleanup
    - **Property 6: Resource Cleanup**
    - **Validates: Requirements 2.10, 5.8**

- [ ] 10. Implementar función `_exportarReporteWord()` en InspeccionTecnicaScreen
  - [ ] 10.1 Reemplazar stub existente con implementación completa
    - Envolver todo en try-catch block
    - Verificar que kIsWeb == true, si no, mostrar error "Word export only supported on web"
    - Llamar a `_compilarDatosInspeccion()` para obtener InspectionData
    - Crear instancia de WordExportService
    - Llamar a `generateInspectionDOCX()` con los datos compilados para obtener bytes
    - Generar filename usando formato "Inspeccion_{plazaId}_{timestamp}.docx"
    - Llamar a `WebDownloadHelper.downloadFile()` con bytes, filename, y MIME type "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    - En caso de éxito: mostrar SnackBar verde con mensaje "✓ Word generado exitosamente"
    - En caso de error: catch exception, mostrar SnackBar rojo con mensaje de error
    - Verificar `mounted` antes de mostrar SnackBar
    - _Requirements: 2.1, 2.5, 2.6, 2.7, 2.8, 2.9, 2.10, 2.11, 2.12, 2.13, 5.9, 6.2, 6.4_
  
  - [ ] 10.2 Write property test for platform check
    - **Property 14: Platform-Specific Behavior**
    - **Validates: Requirements 2.13, 5.9**
  
  - [ ] 10.3 Write unit test for success SnackBar
    - Verify green SnackBar with success message
    - _Requirements: 2.11, 5.3_
  
  - [ ] 10.4 Write unit test for error SnackBar
    - Verify red SnackBar with error message
    - _Requirements: 2.12, 5.5_

- [ ] 11. Checkpoint - Verificar exportación Word
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 12. Integración final y testing
  - [ ] 12.1 Verificar que los botones en PanelAccionesFinales llaman correctamente a las funciones
    - El botón "Descargar PDF" debe llamar a onExportarPDF callback
    - El botón "Descargar Word" debe llamar a onExportarWord callback
    - InspeccionTecnicaScreen debe pasar _exportarReportePDF como onExportarPDF
    - InspeccionTecnicaScreen debe pasar _exportarReporteWord como onExportarWord
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 7.8, 7.9, 7.10_
  
  - [ ] 12.2 Write property test for async execution
    - **Property 10: Async Execution**
    - **Validates: Requirements 5.1**
  
  - [ ] 12.3 Write property test for widget lifecycle safety
    - **Property 11: Widget Lifecycle Safety**
    - **Validates: Requirements 5.6**
  
  - [ ] 12.4 Write property test for correct data source mapping
    - **Property 13: Correct Data Source Mapping**
    - **Validates: Requirements 3.4, 3.5**
  
  - [ ] 12.5 Write integration tests
    - Test complete PDF export workflow end-to-end
    - Test complete Word export workflow end-to-end
    - Test error handling in complete workflows
    - _Requirements: 1.1-1.10, 2.1-2.13_

- [ ] 13. Testing manual en navegadores
  - Probar exportación PDF en Chrome, Firefox, y Edge
  - Probar exportación Word en Chrome, Firefox, y Edge
  - Verificar que los archivos PDF se abren correctamente en Adobe Reader
  - Verificar que los archivos DOCX se abren y editan correctamente en Microsoft Word
  - Verificar que las tablas mantienen formato consistente
  - Verificar que todos los datos se muestran correctamente
  - Verificar que los nombres de archivo son correctos

- [ ] 14. Checkpoint final
  - Ensure all tests pass, ask the user if questions arise.
  - Verificar que no hay warnings ni errores en la consola
  - Confirmar que la funcionalidad está completa y lista para uso

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties
- Unit tests validate specific examples and edge cases
- Integration tests verify end-to-end workflows
- Manual testing is required for browser-specific behavior and file format validation

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["2.1", "2.2", "2.3"] },
    { "id": 1, "tasks": ["3.1", "3.2"] },
    { "id": 2, "tasks": ["3.3", "3.4", "3.5", "5.1"] },
    { "id": 3, "tasks": ["5.2", "5.3", "5.4", "5.5"] },
    { "id": 4, "tasks": ["5.6", "5.7", "5.8"] },
    { "id": 5, "tasks": ["6.1", "8.1"] },
    { "id": 6, "tasks": ["6.2", "6.3", "6.4", "6.5", "8.2", "8.3", "8.4", "8.5"] },
    { "id": 7, "tasks": ["8.6", "8.7", "9.1"] },
    { "id": 8, "tasks": ["9.2", "9.3"] },
    { "id": 9, "tasks": ["10.1"] },
    { "id": 10, "tasks": ["10.2", "10.3", "10.4"] },
    { "id": 11, "tasks": ["12.1", "12.2", "12.3", "12.4"] },
    { "id": 12, "tasks": ["12.5"] }
  ]
}
```
