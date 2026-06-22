# Requirements Document

## Introduction

Este documento especifica los requisitos funcionales para la implementación de funcionalidades de exportación de reportes de inspección técnica en la aplicación Flutter de áreas verdes. El sistema debe permitir a los usuarios exportar sus evaluaciones en formatos PDF y Word (DOCX), proporcionando documentos profesionales y editables que contengan toda la información recopilada durante las inspecciones de las 6 categorías: ASEO, CÉSPED, ARBOLADO, FLORES, CAMINOS e INFRAESTRUCTURA.

## Glossary

- **Inspection_System**: El sistema de inspección técnica implementado en InspeccionTecnicaScreen
- **PDF_Generator**: Componente que genera documentos PDF usando la librería `pdf`
- **DOCX_Generator**: Componente que genera documentos Word usando la librería `docx_creator`
- **Web_Downloader**: Componente que maneja descargas de archivos en Flutter web
- **Evaluation_Map**: Estructura de datos Map<String, String?> que almacena evaluaciones de criterios
- **Section**: Una de las 6 categorías de evaluación (ASEO, CÉSPED, etc.)
- **Criterio**: Un ítem específico dentro de una sección que se evalúa
- **Estado_General**: Calificación agregada de toda la inspección (Bueno/Regular/Malo)
- **Browser**: Navegador web donde se ejecuta la aplicación Flutter web

## Requirements

### Requirement 1: PDF Export Functionality

**User Story:** As an inspector, I want to export inspection reports as PDF files, so that I can share professional, print-ready documents with supervisors and stakeholders.

#### Acceptance Criteria

1. WHEN the user clicks the "Descargar PDF" button, THE Inspection_System SHALL compile all evaluation data from the 6 sections
2. WHEN the PDF_Generator creates a document, THE Inspection_System SHALL include a header with "REPORTE DE INSPECCIÓN TÉCNICA" and a divider line
3. WHEN the PDF_Generator formats data, THE Inspection_System SHALL create an information table with rows for: ID av, DESCRIPCIÓN, FECHA/HORA, and Inspector email
4. WHEN the PDF_Generator adds evaluation sections, THE Inspection_System SHALL create one table per section with columns "ÍTEM" and "EVALUACIÓN"
5. WHEN the PDF_Generator processes a section, THE Inspection_System SHALL include all criteria from that section with their corresponding evaluation values (Bueno/Regular/Malo/N/A)
6. WHEN the PDF_Generator completes the document, THE Inspection_System SHALL add a summary section displaying the Estado_General in a highlighted container
7. WHEN the PDF is generated successfully, THE Inspection_System SHALL call Printing.layoutPdf to show the browser's native save dialog
8. WHEN the user saves the PDF, THE Inspection_System SHALL use the filename format "Inspeccion_{plazaId}_{timestamp}.pdf"
9. WHEN the PDF export succeeds, THE Inspection_System SHALL display a green SnackBar with message "✓ PDF generado exitosamente"
10. IF the PDF export fails, THEN THE Inspection_System SHALL catch the exception and display a red SnackBar with the error message

### Requirement 2: Word (DOCX) Export Functionality

**User Story:** As an inspector, I want to export inspection reports as editable Word documents, so that I can modify and annotate the reports in Microsoft Word.

#### Acceptance Criteria

1. WHEN the user clicks the "Descargar Word" button, THE Inspection_System SHALL compile all evaluation data from the 6 sections
2. WHEN the DOCX_Generator creates a document, THE Inspection_System SHALL add a header section identical to the PDF format
3. WHEN the DOCX_Generator formats data, THE Inspection_System SHALL create editable tables with the same structure as PDF tables
4. WHEN the DOCX_Generator processes sections, THE Inspection_System SHALL maintain the same order as PDF export (ASEO, CÉSPED, ARBOLADO, FLORES, CAMINOS, INFRAESTRUCTURA)
5. WHEN the DOCX_Generator completes the document, THE Inspection_System SHALL convert it to Uint8List bytes using the save() method
6. WHERE the application is running on Flutter web, THE Web_Downloader SHALL create a Blob object with MIME type "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
7. WHERE the application is running on Flutter web, THE Web_Downloader SHALL create an AnchorElement with href pointing to the Blob URL
8. WHERE the application is running on Flutter web, THE Web_Downloader SHALL set the download attribute to filename format "Inspeccion_{plazaId}_{timestamp}.docx"
9. WHEN the Web_Downloader triggers download, THE Inspection_System SHALL programmatically click the anchor element
10. WHEN the download completes or fails, THE Web_Downloader SHALL call Url.revokeObjectUrl to clean up the Blob URL
11. WHEN the DOCX export succeeds, THE Inspection_System SHALL display a green SnackBar with message "✓ Word generado exitosamente"
12. IF the DOCX export fails, THEN THE Inspection_System SHALL catch the exception and display a red SnackBar with the error message
13. IF the application is not running on web, THEN THE Inspection_System SHALL display an error message indicating Word export is web-only

### Requirement 3: Data Compilation and Structure

**User Story:** As a developer, I want a consistent data compilation process, so that both PDF and Word exports use the same underlying data structure.

#### Acceptance Criteria

1. WHEN compiling inspection data, THE Inspection_System SHALL create an InspectionData object containing plazaId, nombrePlaza, correoSupervisor, fechaHora, estadoGeneral, and sections map
2. WHEN collecting section data, THE Inspection_System SHALL process exactly 6 sections in order: ASEO, CÉSPED, ARBOLADO, FLORES, CAMINOS, INFRAESTRUCTURA
3. WHEN processing a section, THE Inspection_System SHALL create an EvaluationSection object with title, criteria list, and evaluations map
4. WHEN accessing evaluation values, THE Inspection_System SHALL use the evaluation maps (_evaluacionesAseo, _evaluacionesCesped, etc.)
5. WHEN accessing criteria lists, THE Inspection_System SHALL use the criteria lists (_criteriosAseo, _criteriosCesped, etc.)
6. WHEN an evaluation is missing for a criterio, THE Inspection_System SHALL use "N/A" as the default value
7. WHEN calculating Estado_General, THE Inspection_System SHALL return "Malo" if more than 5 items are evaluated as "Malo"
8. WHEN calculating Estado_General, THE Inspection_System SHALL return "Regular" if any item is "Malo" OR more than 10 items are "Regular"
9. WHEN calculating Estado_General with no problematic items, THE Inspection_System SHALL return "Bueno"
10. THE Inspection_System SHALL NOT modify the original evaluation maps during export operations

### Requirement 4: Table Formatting and Structure

**User Story:** As an inspector, I want consistent, professional table formatting in exports, so that reports are easy to read and present to stakeholders.

#### Acceptance Criteria

1. WHEN creating a section table header, THE PDF_Generator SHALL display the section name (e.g., "ASEO") in bold with background color grey300
2. WHEN creating table rows, THE PDF_Generator SHALL use two columns: first for criterio text (width flex 3), second for evaluation value (width flex 1)
3. WHEN creating DOCX tables, THE DOCX_Generator SHALL use the same column structure as PDF tables
4. WHEN displaying criterio text, THE Inspection_System SHALL show the complete text without truncation
5. WHEN displaying evaluation values, THE Inspection_System SHALL show exactly one of: "Bueno", "Regular", "Malo", or "N/A"
6. WHEN creating PDF tables, THE PDF_Generator SHALL apply borders to all cells using TableBorder.all()
7. WHEN creating DOCX tables, THE DOCX_Generator SHALL create editable cells that can be modified in Microsoft Word
8. WHEN adding sections to PDF, THE PDF_Generator SHALL add 15px spacing between consecutive sections
9. WHEN formatting the summary section, THE Inspection_System SHALL display "Estado General: {value}" in a bordered, grey background container
10. WHEN creating the information table, THE Inspection_System SHALL use two-column layout with labels in grey background cells and values in white background cells

### Requirement 5: User Feedback and Error Handling

**User Story:** As an inspector, I want clear feedback on export operations, so that I know whether my report was successfully generated or if there was an error.

#### Acceptance Criteria

1. WHEN any export operation starts, THE Inspection_System SHALL execute asynchronously without blocking the UI
2. WHEN a PDF export succeeds, THE Inspection_System SHALL display a SnackBar with green background (#FF2E7D32) and success icon
3. WHEN a Word export succeeds, THE Inspection_System SHALL display a SnackBar with green background (#FF2E7D32) and success icon
4. IF any exception occurs during PDF generation, THEN THE Inspection_System SHALL catch it and display a SnackBar with red background and error message
5. IF any exception occurs during DOCX generation, THEN THE Inspection_System SHALL catch it and display a SnackBar with red background and error message
6. IF the widget is unmounted when showing feedback, THEN THE Inspection_System SHALL check mounted flag before showing SnackBar
7. WHEN displaying error messages, THE Inspection_System SHALL include the exception message for debugging purposes
8. WHEN an export completes, THE Inspection_System SHALL ensure no resources are leaked (memory, file handles, blob URLs)
9. IF Word export is attempted on non-web platform, THEN THE Inspection_System SHALL display error message "Word export only supported on web"
10. WHEN the browser blocks a download, THE Inspection_System SHALL display appropriate error guidance to the user

### Requirement 6: File Naming and Metadata

**User Story:** As an inspector, I want exported files to have meaningful names and metadata, so that I can easily organize and identify inspection reports.

#### Acceptance Criteria

1. WHEN generating a PDF filename, THE Inspection_System SHALL use format "Inspeccion_{plazaId}_{timestamp}.pdf"
2. WHEN generating a DOCX filename, THE Inspection_System SHALL use format "Inspeccion_{plazaId}_{timestamp}.docx"
3. WHEN creating timestamp for filename, THE Inspection_System SHALL use DateTime.now().millisecondsSinceEpoch
4. WHEN setting DOCX MIME type, THE Web_Downloader SHALL use "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
5. WHEN including date/time in document, THE Inspection_System SHALL format as "YYYY-MM-DD HH:MM" substring(0, 16)
6. THE Inspection_System SHALL include plazaId, nombrePlaza, and correoSupervisor in the document metadata section
7. THE Inspection_System SHALL include calculated Estado_General in the document summary section
8. THE filenames SHALL NOT contain illegal characters that would prevent saving on Windows, Mac, or Linux
9. THE timestamp format SHALL ensure unique filenames for multiple exports of the same plaza
10. THE document SHALL include fecha/hora showing when the inspection was performed, not when it was exported

### Requirement 7: Integration with Existing UI

**User Story:** As an inspector, I want export buttons integrated into the existing panel, so that the functionality is easily accessible without UI changes.

#### Acceptance Criteria

1. THE PanelAccionesFinales widget SHALL already contain "Descargar PDF" button with red icon (Icons.picture_as_pdf)
2. THE PanelAccionesFinales widget SHALL already contain "Descargar Word" button with blue icon (Icons.description)
3. WHEN the "Descargar PDF" button is pressed, THE PanelAccionesFinales SHALL call the onExportarPDF callback
4. WHEN the "Descargar Word" button is pressed, THE PanelAccionesFinales SHALL call the onExportarWord callback
5. THE InspeccionTecnicaScreen SHALL pass _exportarReportePDF as the onExportarPDF callback
6. THE InspeccionTecnicaScreen SHALL pass _exportarReporteWord as the onExportarWord callback
7. THE existing _exportarPDF method SHALL be replaced with _exportarReportePDF implementation
8. THE existing _exportarWord method SHALL be replaced with _exportarReporteWord implementation
9. THE button callbacks SHALL be synchronous (void Function()) but SHALL call async functions internally
10. THE UI SHALL remain responsive during export operations (async execution)

### Requirement 8: Package Dependencies and Imports

**User Story:** As a developer, I want proper package management, so that all required libraries are available and correctly imported.

#### Acceptance Criteria

1. THE pubspec.yaml SHALL contain dependency "pdf: ^3.12.0" (already present)
2. THE pubspec.yaml SHALL contain dependency "printing: ^5.14.3" (already present)
3. THE pubspec.yaml SHALL contain dependency "docx_creator: ^1.2.7" (already present)
4. THE pubspec.yaml SHALL contain dependency "path_provider: ^2.1.6" (already present)
5. THE InspeccionTecnicaScreen SHALL import "package:pdf/pdf.dart"
6. THE InspeccionTecnicaScreen SHALL import "package:pdf/widgets.dart as pw"
7. THE InspeccionTecnicaScreen SHALL import "package:printing/printing.dart"
8. WHERE the platform is web, THE InspeccionTecnicaScreen SHALL conditionally import "dart:html" as html
9. THE InspeccionTecnicaScreen SHALL import "package:flutter/foundation.dart" for kIsWeb flag
10. THE code SHALL use conditional compilation or runtime checks for platform-specific code (web vs non-web)
