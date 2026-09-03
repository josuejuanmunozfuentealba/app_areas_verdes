import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Servicio puro para generación de reportes PDF de inspección
///
/// Este servicio es dinámico: genera campos automáticamente
/// basándose en el mapa de datos que recibe.
class PDFExportService {
  /// Genera un documento PDF con todas las secciones de evaluación
  ///
  /// Este método es compatible con la llamada desde inspeccion_tecnica_screen
  /// y acepta parámetros estructurados.
  Future<pw.Document> generateInspectionPDF({
    required String plazaId,
    required String nombrePlaza,
    required String correoSupervisor,
    required String fechaHora,
    required Map<String, dynamic> allEvaluations,
    required Map<String, dynamic> allCriteria,
    required String estadoGeneral,
    Map<String, dynamic>? imagesBySection,
  }) async {
    // Construir el mapa de datos en el formato esperado
    final datos = <String, dynamic>{
      'plazaId': plazaId,
      'nombrePlaza': nombrePlaza,
      'correoSupervisor': correoSupervisor,
      'fechaHora': fechaHora,
      'estadoGeneral': estadoGeneral,
      'allEvaluations': allEvaluations,
      'allCriteria': allCriteria,
      'imagesBySection': ?imagesBySection,
    };

    // Construir y retornar el documento PDF completo
    return _buildPdfDocument(datos);
  }

  /// Construye un documento PDF completo desde el mapa de datos
  Future<pw.Document> _buildPdfDocument(Map<String, dynamic> datos) async {
    final pdf = pw.Document();

    // Cargar el logo
    final header = await _buildHeaderWithLogo(
      datos['nombrePlaza']?.toString() ?? 'Sin nombre',
    );

    // Main report page
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          header,
          pw.SizedBox(height: 20),
          _buildInfoTableDinamica(datos),
          pw.SizedBox(height: 20),
          ..._buildEvaluacionesDinamicas(datos),
          _buildSummary(datos['estadoGeneral']?.toString() ?? 'N/A'),
        ],
      ),
    );

    // Add photo annex if there are any images
    await _addPhotoAnnexDinamico(pdf, datos);

    return pdf;
  }

  /// Genera un reporte PDF dinámicamente desde un mapa de datos
  ///
  /// Acepta cualquier estructura de datos y genera el PDF automáticamente
  Future<List<int>> generarReporte({
    required Map<String, dynamic> datos,
  }) async {
    final pdf = await _buildPdfDocument(datos);
    final pdfBytes = await pdf.save();
    return pdfBytes;
  }

  /// Builds the header section with title, divider and logo
  Future<pw.Widget> _buildHeaderWithLogo(String nombrePlaza) async {
    // Cargar el logo desde assets
    pw.ImageProvider? logoImage;
    try {
      final imageData = await rootBundle.load('assets/logo_2026.png');
      final bytes = imageData.buffer.asUint8List();
      logoImage = pw.MemoryImage(bytes);
    } catch (e) {
      // Si el logo no existe, continuamos sin él
      logoImage = null;
    }

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Título a la izquierda
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'REPORTE DE INSPECCIÓN TÉCNICA',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Container(
                width: double.infinity,
                height: 2,
                color: PdfColors.black,
              ),
            ],
          ),
        ),
        // Logo a la derecha
        if (logoImage != null) ...[
          pw.SizedBox(width: 20),
          pw.Image(logoImage, width: 120, height: 60, fit: pw.BoxFit.contain),
        ],
      ],
    );
  }

  /// Builds the information table with plaza details - DINÁMICO
  pw.Widget _buildInfoTableDinamica(Map<String, dynamic> datos) {
    final rows = <pw.TableRow>[];

    // Campos prioritarios en orden
    final camposPrioritarios = [
      ('nombrePlaza', 'Área Verde / Plaza'),
      ('plazaId', 'ID Código'),
      ('nombreInspector', 'Inspector'),
      ('correoSupervisor', 'Email Supervisor'),
      ('fechaHora', 'Fecha de Inspección'),
      ('estadoGeneral', 'Estado General'),
    ];

    // Agregar campos prioritarios
    for (final campo in camposPrioritarios) {
      final clave = campo.$1;
      final etiqueta = campo.$2;

      if (datos.containsKey(clave) && datos[clave] != null) {
        final valor = _formatearValorPDF(datos[clave]);
        if (valor.isNotEmpty) {
          rows.add(_buildInfoRow(etiqueta, valor));
        }
      }
    }

    // Agregar fila fija del encargado
    rows.add(
      _buildInfoRow('Encargado', 'Felipe Lagos Bastias - Ingeniero Agrónomo'),
    );

    // Agregar otros campos no prioritarios
    final camposEspeciales = [
      'nombrePlaza',
      'plazaId',
      'nombreInspector',
      'correoSupervisor',
      'fechaHora',
      'estadoGeneral',
      'allEvaluations',
      'allCriteria',
      'sections',
      'imagesBySection',
      'images',
    ];

    for (final entry in datos.entries) {
      if (!camposEspeciales.contains(entry.key) && entry.value != null) {
        final valor = _formatearValorPDF(entry.value);
        if (valor.isNotEmpty) {
          final etiqueta = _formatearEtiquetaPDF(entry.key);
          rows.add(_buildInfoRow(etiqueta, valor));
        }
      }
    }

    return pw.Table(border: pw.TableBorder.all(), children: rows);
  }

  /// Construye las secciones de evaluación dinámicamente
  List<pw.Widget> _buildEvaluacionesDinamicas(Map<String, dynamic> datos) {
    final widgets = <pw.Widget>[];

    // Procesar formato allEvaluations + allCriteria + allObservations
    if (datos.containsKey('allEvaluations') &&
        datos.containsKey('allCriteria')) {
      final allEvaluations =
          datos['allEvaluations'] as Map<String, dynamic>? ?? {};
      final allCriteria = datos['allCriteria'] as Map<String, dynamic>? ?? {};
      final allObservations =
          datos['allObservations'] as Map<String, dynamic>? ?? {};

      for (final entry in allEvaluations.entries) {
        final sectionTitle = entry.key;
        final evaluations = entry.value as Map<String, dynamic>? ?? {};
        final criteria =
            (allCriteria[sectionTitle] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
        final observations =
            allObservations[sectionTitle] as Map<String, dynamic>?;

        if (criteria.isNotEmpty) {
          widgets.add(
            _buildEvaluationSection(
              sectionTitle,
              evaluations,
              criteria,
              observations: observations,
            ),
          );
          widgets.add(pw.SizedBox(height: 15));
        }
      }
    }

    // Procesar formato sections (InspectionData)
    if (datos.containsKey('sections')) {
      final sections = datos['sections'] as Map<String, dynamic>? ?? {};

      for (final entry in sections.entries) {
        final sectionTitle = entry.key;
        final seccionData = entry.value as Map<String, dynamic>? ?? {};

        final criteria =
            (seccionData['criteria'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
        final evaluations =
            seccionData['evaluations'] as Map<String, dynamic>? ?? {};
        final observations =
            seccionData['observations'] as Map<String, dynamic>?;

        if (criteria.isNotEmpty) {
          widgets.add(
            _buildEvaluationSection(
              sectionTitle,
              evaluations,
              criteria,
              observations: observations,
            ),
          );
          widgets.add(pw.SizedBox(height: 15));
        }
      }
    }

    return widgets;
  }

  /// Formatea un valor para el PDF
  String _formatearValorPDF(dynamic valor) {
    if (valor == null) return '';

    if (valor is String) {
      return valor;
    } else if (valor is DateTime) {
      return '${valor.day.toString().padLeft(2, '0')}/${valor.month.toString().padLeft(2, '0')}/${valor.year} ${valor.hour.toString().padLeft(2, '0')}:${valor.minute.toString().padLeft(2, '0')}';
    } else if (valor is num) {
      return valor.toString();
    } else if (valor is bool) {
      return valor ? 'Sí' : 'No';
    } else if (valor is List) {
      return valor.join(', ');
    } else if (valor is Map) {
      return ''; // Los mapas se procesan aparte
    }

    return valor.toString();
  }

  /// Formatea una etiqueta de campo para el PDF
  String _formatearEtiquetaPDF(String campo) {
    final etiquetas = {
      'nombrePlaza': 'Área Verde / Plaza',
      'plazaId': 'ID Código',
      'nombreInspector': 'Inspector',
      'correoSupervisor': 'Email Supervisor',
      'fechaHora': 'Fecha de Inspección',
      'estadoGeneral': 'Estado General',
      'latitud': 'Latitud',
      'longitud': 'Longitud',
      'tipoParque': 'Tipo de Parque',
      'superficie': 'Superficie',
      'poblacion': 'Población',
      'sector': 'Sector',
    };

    if (etiquetas.containsKey(campo)) {
      return etiquetas[campo]!;
    }

    // Convertir camelCase a Título Con Espacios
    return campo
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Agrega anexo fotográfico de forma dinámica
  Future<void> _addPhotoAnnexDinamico(
    pw.Document pdf,
    Map<String, dynamic> datos,
  ) async {
    // Intentar con imagesBySection primero
    if (datos.containsKey('imagesBySection')) {
      final imagesBySection =
          datos['imagesBySection'] as Map<String, dynamic>? ?? {};
      await _addPhotoAnnex(pdf, imagesBySection);
    }

    // Intentar con images (formato InspectionData)
    if (datos.containsKey('images')) {
      final images = datos['images'] as Map<String, dynamic>? ?? {};
      await _addPhotoAnnex(pdf, images);
    }
  }

  /// Builds a single row for the information table
  pw.TableRow _buildInfoRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          color: PdfColors.grey300,
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value),
        ),
      ],
    );
  }

  /// Builds an evaluation section table with individual observations per item
  pw.Widget _buildEvaluationSection(
    String sectionTitle,
    Map<String, dynamic> evaluations,
    List<String> criteria, {
    Map<String, dynamic>? observations,
  }) {
    // Preparar lista de filas
    final rows = <pw.TableRow>[];

    // Header row
    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey300),
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(
              sectionTitle,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(
              'EVALUACIÓN',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    // Data rows con observaciones
    for (final criterio in criteria) {
      final valor = evaluations[criterio]?.toString() ?? 'N/A';

      // Fila del criterio
      rows.add(
        pw.TableRow(
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(criterio),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(valor),
            ),
          ],
        ),
      );

      // Fila de observación (si existe)
      if (observations != null && observations.containsKey(criterio)) {
        final observacion = observations[criterio]?.toString() ?? '';
        if (observacion.isNotEmpty && observacion.trim().isNotEmpty) {
          rows.add(
            pw.TableRow(
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.fromLTRB(16, 4, 8, 8),
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  child: pw.Text(
                    'Observación: $observacion',
                    style: pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey700,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ),
                pw.Container(), // Segunda columna vacía
              ],
            ),
          );
        }
      }
    }

    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
      },
      children: rows,
    );
  }

  /// Builds the summary section with Estado General
  pw.Widget _buildSummary(String estadoGeneral) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        color: PdfColors.grey300,
      ),
      child: pw.Text(
        'Estado General: $estadoGeneral',
        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  /// Adds photo annex pages to the PDF document
  ///
  /// Creates separate pages for each section that has images,
  /// displaying them in a 2-column grid layout with titles
  Future<void> _addPhotoAnnex(
    pw.Document pdf,
    Map<String, dynamic> imagesBySection,
  ) async {
    for (final entry in imagesBySection.entries) {
      final sectionName = entry.key;
      final imagesData = entry.value as List<dynamic>? ?? [];

      if (imagesData.isEmpty) continue;

      // Load images with their titles into memory
      final List<Map<String, dynamic>> pdfImagesWithTitles = [];
      for (var i = 0; i < imagesData.length; i++) {
        try {
          final fotoData = imagesData[i] as Map<String, dynamic>? ?? {};
          final archivo = fotoData['archivo'];
          final String titulo = fotoData['titulo']?.toString() ?? '';

          if (archivo is XFile) {
            final bytes = await archivo.readAsBytes();
            pdfImagesWithTitles.add({
              'image': pw.MemoryImage(bytes),
              'titulo': titulo.isNotEmpty ? titulo : 'Foto ${i + 1}',
              'index': i + 1,
            });
          }
        } catch (e) {
          // Skip images that fail to load
        }
      }

      if (pdfImagesWithTitles.isEmpty) continue;

      // Create photo annex page for this section
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            // Section header
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey300,
                border: pw.Border.all(),
              ),
              child: pw.Text(
                'ANEXO FOTOGRÁFICO - $sectionName',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 16),

            // Images in 2-column grid with titles
            pw.Wrap(
              spacing: 16,
              runSpacing: 16,
              children: pdfImagesWithTitles.map((imageData) {
                final image = imageData['image'] as pw.MemoryImage;
                final titulo = imageData['titulo'] as String;

                return pw.Container(
                  width:
                      (PdfPageFormat.a4.width - 96) /
                      2, // 2 columns with margins
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey400),
                        ),
                        child: pw.Image(
                          image,
                          fit: pw.BoxFit.cover,
                          width: (PdfPageFormat.a4.width - 96) / 2,
                          height: 180,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        titulo,
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    }
  }

  /// Convierte PDF a Word usando Edge Function ConvertAPI
  Future<List<int>?> generarWord({
    required String plazaId,
    required String nombrePlaza,
    required String correoSupervisor,
    required String fechaHora,
    required Map<String, dynamic> allEvaluations,
    required Map<String, dynamic> allCriteria,
    required String estadoGeneral,
    Map<String, dynamic>? imagesBySection,
  }) async {
    try {
      debugPrint('[Word] Generando PDF primero...');

      // 1. Generar PDF
      final pdfDoc = await generateInspectionPDF(
        plazaId: plazaId,
        nombrePlaza: nombrePlaza,
        correoSupervisor: correoSupervisor,
        fechaHora: fechaHora,
        allEvaluations: allEvaluations,
        allCriteria: allCriteria,
        estadoGeneral: estadoGeneral,
        imagesBySection: imagesBySection,
      );

      final pdfBytes = await pdfDoc.save();
      debugPrint(
        '[Word] PDF generado: ${(pdfBytes.length / 1024).toStringAsFixed(1)} KB',
      );

      // 2. Convertir PDF a Word usando ConvertAPI
      const supabaseUrl = 'https://speneggmlqitgfjhzsry.supabase.co';
      const anonKey =
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNwZW5lZ2dtbHFpdGdmamh6c3J5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY1MzUzMDksImV4cCI6MjEwMjExMTMwOX0.31WSG-j7m_TO4uGjmXW59jTrxrX7wFvHT8sHtY5zIQg';

      final pdfBase64 = base64Encode(pdfBytes);
      final filename =
          'inspeccion_${plazaId}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final functionUrl =
          '$supabaseUrl/functions/v1/convert-pdf-to-word-ilovepdf';

      debugPrint('[Word] Convirtiendo PDF a Word...');
      final response = await http
          .post(
            Uri.parse(functionUrl),
            headers: {
              'Authorization': 'Bearer $anonKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'pdfBase64': pdfBase64, 'filename': filename}),
          )
          .timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] == true && result['docxUrl'] != null) {
          // Descargar el Word generado
          debugPrint('[Word] Descargando Word desde: ${result['docxUrl']}');
          final docxResponse = await http.get(Uri.parse(result['docxUrl']));
          debugPrint(
            '[Word] ✓ Word generado: ${(docxResponse.bodyBytes.length / 1024).toStringAsFixed(1)} KB',
          );
          return docxResponse.bodyBytes;
        }
      }

      debugPrint('[Word] ✗ Error en conversión: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('[Word] ✗ Error: $e');
      return null;
    }
  }
}
