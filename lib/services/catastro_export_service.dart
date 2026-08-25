import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:intl/intl.dart';

/// Servicio de exportación para el módulo de Catastro de Inmuebles
/// Genera PDF y Word con fotos garantizadas en formato Base64
class CatastroExportService {
  // Criterios oficiales del catastro
  static const List<String> criteriosOficiales = [
    'Estado estructural de bancas',
    'Estado pintura bancas',
    'Estado estructural juegos infantiles',
    'Estado de pintura de juegos infantiles',
    'Estado llaves de paso/arranque de agua',
    'Estado estructural basureros',
    'Estado pintura de basureros',
  ];

  /// Genera un documento PDF con el catastro completo
  Future<List<int>> generarPDF({
    required String plazaId,
    required String nombrePlaza,
    required String inspector,
    required DateTime fechaHora,
    required Map<String, String?> evaluaciones,
    required Map<String, String> observaciones,
    required List<Map<String, dynamic>> fotos,
  }) async {
    final pdf = pw.Document();

    // Cargar logo
    pw.ImageProvider? logoImage;
    try {
      final imageData = await rootBundle.load('assets/logo_2026.png');
      final bytes = imageData.buffer.asUint8List();
      logoImage = pw.MemoryImage(bytes);
    } catch (e) {
      logoImage = null;
    }

    // Formatear fecha y hora
    final fechaFormateada = DateFormat('dd/MM/yyyy HH:mm:ss').format(fechaHora);
    final estadoGeneral = _calcularEstadoGeneral(evaluaciones);

    // Página principal
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Encabezado con logo
          _buildHeader(logoImage),
          pw.SizedBox(height: 20),

          // Información general
          _buildInfoTable(
            plazaId,
            nombrePlaza,
            inspector,
            fechaFormateada,
            estadoGeneral,
          ),
          pw.SizedBox(height: 20),

          // Tabla de evaluación
          _buildEvaluationTable(evaluaciones, observaciones),
          pw.SizedBox(height: 20),

          // Resumen
          _buildSummary(estadoGeneral),
        ],
      ),
    );

    // Anexo fotográfico
    if (fotos.isNotEmpty) {
      await _addPhotoAnnex(pdf, fotos);
    }

    return await pdf.save();
  }

  /// Genera un documento Word (HTML con formato MSO)
  Future<List<int>> generarWord({
    required String plazaId,
    required String nombrePlaza,
    required String inspector,
    required DateTime fechaHora,
    required Map<String, String?> evaluaciones,
    required Map<String, String> observaciones,
    required List<Map<String, dynamic>> fotos,
  }) async {
    // Cargar logo como base64
    String logoBase64 = '';
    try {
      final logoData = await rootBundle.load('assets/logo_2026.png');
      final logoBytes = logoData.buffer.asUint8List();
      logoBase64 = base64Encode(logoBytes);
    } catch (_) {}

    final fechaFormateada = DateFormat('dd/MM/yyyy HH:mm:ss').format(fechaHora);
    final estadoGeneral = _calcularEstadoGeneral(evaluaciones);

    final buffer = StringBuffer();

    // Encabezado XML Office
    buffer.writeln('''
<html xmlns:o="urn:schemas-microsoft-com:office:office" 
      xmlns:w="urn:schemas-microsoft-com:office:word" 
      xmlns="http://www.w3.org/TR/REC-html40">
<head>
<!--[if gte mso 9]><xml><w:WordDocument><w:View>Print</w:View><w:Zoom>100</w:Zoom></w:WordDocument></xml><![endif]-->
<meta charset="UTF-8">
<title>Catastro de Inmuebles - $nombrePlaza</title>
<style>
@page Section1 { size: A4; margin: 2.5cm; }
div.Section1 { page: Section1; }
body { font-family: 'Calibri', 'Arial', sans-serif; font-size: 11pt; color: #333; }
table { width: 100%; border-collapse: collapse; margin: 10px 0; }
td, th { padding: 8px; border: 1px solid #CCCCCC; vertical-align: top; }
th { background-color: #2E7D32; color: white; font-weight: bold; }
.header { text-align: center; margin-bottom: 20px; }
.info-label { font-weight: bold; color: #2E7D32; }
.foto-container { text-align: center; margin: 20px 0; }
</style>
</head>
<body>
<div class="Section1">
''');

    // Encabezado con logo
    buffer.writeln('<div class="header">');
    if (logoBase64.isNotEmpty) {
      buffer.writeln(
        '<img src="data:image/png;base64,$logoBase64" width="80" height="80" alt="Logo" />',
      );
    }
    buffer.writeln(
      '<h1 style="color: #2E7D32; margin: 10px 0;">CATASTRO DE INMUEBLES DE ÁREAS VERDES</h1>',
    );
    buffer.writeln('<p style="color: #666;">Municipalidad de Doñihue</p>');
    buffer.writeln('</div>');

    // Información general
    buffer.writeln('<h3>INFORMACIÓN GENERAL</h3>');
    buffer.writeln('<table>');
    buffer.writeln(
      '<tr><td class="info-label">Plaza:</td><td>$nombrePlaza</td></tr>',
    );
    buffer.writeln('<tr><td class="info-label">ID:</td><td>$plazaId</td></tr>');
    buffer.writeln(
      '<tr><td class="info-label">Inspector:</td><td>$inspector</td></tr>',
    );
    buffer.writeln(
      '<tr><td class="info-label">Fecha/Hora:</td><td>$fechaFormateada</td></tr>',
    );
    buffer.writeln(
      '<tr><td class="info-label">Estado General:</td><td>$estadoGeneral</td></tr>',
    );
    buffer.writeln('</table>');

    // Tabla de evaluación
    buffer.writeln('<h3>EVALUACIÓN DE CRITERIOS</h3>');
    buffer.writeln('<table>');
    buffer.writeln(
      '<thead><tr><th>Criterio</th><th>Evaluación</th><th>Observaciones</th></tr></thead>',
    );
    buffer.writeln('<tbody>');

    for (final criterio in criteriosOficiales) {
      final eval = evaluaciones[criterio] ?? 'N/A';
      final obs = observaciones[criterio] ?? '';
      buffer.writeln('<tr>');
      buffer.writeln('<td>$criterio</td>');
      buffer.writeln('<td>$eval</td>');
      buffer.writeln('<td>${obs.isNotEmpty ? obs : '-'}</td>');
      buffer.writeln('</tr>');
    }

    buffer.writeln('</tbody>');
    buffer.writeln('</table>');

    // Anexo fotográfico con imágenes en Base64
    if (fotos.isNotEmpty) {
      buffer.writeln('<h3>ANEXO FOTOGRÁFICO</h3>');

      for (var i = 0; i < fotos.length; i++) {
        final fotoData = fotos[i];
        final XFile archivo = fotoData['archivo'] as XFile;
        final String nota = fotoData['nota'] as String? ?? '';

        try {
          final bytes = await archivo.readAsBytes();
          final imagenBase64 = base64Encode(bytes);

          buffer.writeln('<div class="foto-container">');
          buffer.writeln('<h4>Foto ${i + 1}</h4>');
          buffer.writeln(
            '<img src="data:image/png;base64,$imagenBase64" style="max-width: 500px; max-height: 400px;" alt="Foto ${i + 1}" />',
          );
          if (nota.isNotEmpty) {
            buffer.writeln('<p><strong>Nota:</strong> $nota</p>');
          }
          buffer.writeln('</div>');

          // Salto de página entre fotos (excepto la última)
          if (i < fotos.length - 1) {
            buffer.writeln('<br style="page-break-after: always;" />');
          }
        } catch (e) {
          buffer.writeln('<p>Error al cargar Foto ${i + 1}</p>');
        }
      }
    }

    buffer.writeln('</div>');
    buffer.writeln('</body>');
    buffer.writeln('</html>');

    return utf8.encode(buffer.toString());
  }

  // ============================================================================
  // MÉTODOS PRIVADOS PARA PDF
  // ============================================================================

  pw.Widget _buildHeader(pw.ImageProvider? logo) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'CATASTRO DE INMUEBLES',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green900,
                ),
              ),
              pw.Text(
                'ÁREAS VERDES',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green700,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Container(
                width: double.infinity,
                height: 2,
                color: PdfColors.green700,
              ),
            ],
          ),
        ),
        if (logo != null) ...[
          pw.SizedBox(width: 20),
          pw.Image(logo, width: 80, height: 80, fit: pw.BoxFit.contain),
        ],
      ],
    );
  }

  pw.Widget _buildInfoTable(
    String plazaId,
    String nombrePlaza,
    String inspector,
    String fechaHora,
    String estadoGeneral,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        _buildInfoRow('Plaza', nombrePlaza),
        _buildInfoRow('ID', plazaId),
        _buildInfoRow('Inspector', inspector),
        _buildInfoRow('Fecha/Hora', fechaHora),
        _buildInfoRow('Estado General', estadoGeneral),
        _buildInfoRow('Encargado', 'Felipe Lagos Bastias - Ingeniero Agrónomo'),
      ],
    );
  }

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

  pw.Widget _buildEvaluationTable(
    Map<String, String?> evaluaciones,
    Map<String, String> observaciones,
  ) {
    final rows = <pw.TableRow>[];

    // Header
    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.green700),
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(
              'Criterio',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(
              'Evaluación',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(
              'Observaciones',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
        ],
      ),
    );

    // Data rows
    for (final criterio in criteriosOficiales) {
      final eval = evaluaciones[criterio] ?? 'N/A';
      final obs = observaciones[criterio] ?? '';

      rows.add(
        pw.TableRow(
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(criterio, style: const pw.TextStyle(fontSize: 10)),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(eval, style: const pw.TextStyle(fontSize: 10)),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                obs.isNotEmpty ? obs : '-',
                style: const pw.TextStyle(fontSize: 9),
              ),
            ),
          ],
        ),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(2.5),
      },
      children: rows,
    );
  }

  pw.Widget _buildSummary(String estadoGeneral) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.green700, width: 2),
        color: PdfColors.green50,
      ),
      child: pw.Text(
        'Estado General del Catastro: $estadoGeneral',
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.green900,
        ),
      ),
    );
  }

  Future<void> _addPhotoAnnex(
    pw.Document pdf,
    List<Map<String, dynamic>> fotos,
  ) async {
    final pdfImagesWithNotes = <Map<String, dynamic>>[];

    for (var i = 0; i < fotos.length; i++) {
      try {
        final fotoData = fotos[i];
        final archivo = fotoData['archivo'] as XFile;
        final String nota = fotoData['nota'] as String? ?? '';

        final bytes = await archivo.readAsBytes();
        pdfImagesWithNotes.add({
          'image': pw.MemoryImage(bytes),
          'nota': nota.isNotEmpty ? nota : 'Foto ${i + 1}',
          'index': i + 1,
        });
      } catch (e) {
        // Skip images that fail to load
      }
    }

    if (pdfImagesWithNotes.isEmpty) return;

    // Create photo annex page
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Section header
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.green700,
              border: pw.Border.all(),
            ),
            child: pw.Text(
              'ANEXO FOTOGRÁFICO',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
          pw.SizedBox(height: 16),

          // Images in 2-column grid
          pw.Wrap(
            spacing: 16,
            runSpacing: 16,
            children: pdfImagesWithNotes.map((imageData) {
              final image = imageData['image'] as pw.MemoryImage;
              final nota = imageData['nota'] as String;

              return pw.Container(
                width: (PdfPageFormat.a4.width - 96) / 2,
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
                      nota,
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green900,
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

  String _calcularEstadoGeneral(Map<String, String?> evaluaciones) {
    int totalMalos = 0;
    int totalRegulares = 0;
    int totalBuenos = 0;

    for (var valor in evaluaciones.values) {
      if (valor == 'Malo') {
        totalMalos++;
      } else if (valor == 'Regular') {
        totalRegulares++;
      } else if (valor == 'Bueno') {
        totalBuenos++;
      }
    }

    if (totalMalos >= 3) return 'Malo';
    if (totalMalos > 0 || totalRegulares >= 4) return 'Regular';
    if (totalBuenos > 0) return 'Bueno';
    return 'Sin evaluar';
  }
}
