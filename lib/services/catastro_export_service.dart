import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;

/// Servicio de exportación para el módulo de Catastro de Inmuebles
/// Genera PDF y Word con fotos garantizadas en formato Base64
class CatastroExportService {
  // Criterios oficiales del catastro
  static const List<String> criteriosOficiales = [
    'Estado estructural de bancas',
    'Estado pintura bancas',
    'Estado estructural juegos infantiles',
    'Estado de pintura de juegos infantiles',
    'Estado llaves de paso/arranque de agua (Especificar si es de 1/2 o 3/4)',
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
    // Cargar y optimizar logo
    String logoBase64 = '';
    try {
      final logoData = await rootBundle.load('assets/logo_2026.png');
      final logoBytes = logoData.buffer.asUint8List();

      // Optimizar logo
      final logoImg = img.decodeImage(logoBytes);
      if (logoImg != null) {
        final logoOptimizado = img.copyResize(logoImg, width: 120);
        final logoJpeg = img.encodeJpg(logoOptimizado, quality: 85);
        logoBase64 = base64Encode(logoJpeg);
      }
    } catch (_) {}

    final fechaFormateada = DateFormat('dd/MM/yyyy HH:mm:ss').format(fechaHora);
    final estadoGeneral = _calcularEstadoGeneral(evaluaciones);

    final buffer = StringBuffer();

    // Encabezado XML Office con mejor compatibilidad para Word
    buffer.writeln('''
<html xmlns:v="urn:schemas-microsoft-com:vml"
      xmlns:o="urn:schemas-microsoft-com:office:office" 
      xmlns:w="urn:schemas-microsoft-com:office:word" 
      xmlns="http://www.w3.org/TR/REC-html40">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<!--[if gte mso 9]><xml>
<w:WordDocument>
<w:View>Print</w:View>
<w:Zoom>100</w:Zoom>
<w:DoNotOptimizeForBrowser/>
</w:WordDocument>
</xml><![endif]-->
<title>Catastro de Inmuebles - $nombrePlaza</title>
<style>
@page Section1 { 
  size: 595.3pt 841.9pt; 
  margin: 72pt 72pt 72pt 72pt; 
  mso-header-margin: 35.4pt; 
  mso-footer-margin: 35.4pt; 
  mso-paper-source: 0; 
}
div.Section1 { page: Section1; }
body { 
  font-family: Calibri, Arial, sans-serif; 
  font-size: 11pt; 
  color: #333333; 
  margin: 0;
}
table { 
  width: 100%; 
  border-collapse: collapse; 
  margin: 10px 0; 
  mso-table-lspace: 0pt;
  mso-table-rspace: 0pt;
}
td, th { 
  padding: 8px; 
  border: 1px solid #CCCCCC; 
  vertical-align: top; 
  mso-line-height-rule: exactly;
}
th { 
  background-color: #2E7D32; 
  color: white; 
  font-weight: bold; 
}
.header { 
  text-align: center; 
  margin-bottom: 20px; 
}
.info-label { 
  font-weight: bold; 
  color: #2E7D32; 
}
.foto-container { 
  text-align: center; 
  margin: 15px 0; 
  page-break-inside: avoid;
}
img { 
  max-width: 100%; 
  height: auto;
  display: block;
  margin: 0 auto;
}
</style>
</head>
<body>
<div class="Section1">
''');

    // Encabezado con logo
    buffer.writeln('<div class="header">');
    if (logoBase64.isNotEmpty) {
      buffer.writeln(
        '<table border="0" cellpadding="0" cellspacing="0" style="width: 100%; margin-bottom: 10px;">',
      );
      buffer.writeln('<tr><td align="center">');
      buffer.writeln(
        '<img src="data:image/jpeg;base64,$logoBase64" width="80" height="80" alt="Logo" />',
      );
      buffer.writeln('</td></tr>');
      buffer.writeln('</table>');
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

    // Anexo fotográfico con imágenes optimizadas para Word
    if (fotos.isNotEmpty) {
      buffer.writeln('<br clear="all" style="page-break-before: always;" />');
      buffer.writeln('<h3>ANEXO FOTOGRÁFICO</h3>');

      for (var i = 0; i < fotos.length; i++) {
        final fotoData = fotos[i];
        final XFile archivo = fotoData['archivo'] as XFile;
        final String nota = fotoData['nota'] as String? ?? '';

        try {
          // Leer imagen original
          final bytes = await archivo.readAsBytes();

          // Decodificar y redimensionar imagen para Word
          final imagenOriginal = img.decodeImage(bytes);
          if (imagenOriginal != null) {
            // Redimensionar a máximo 500px de ancho para mejor compatibilidad con Word
            final imagenOptimizada = img.copyResize(
              imagenOriginal,
              width: imagenOriginal.width > 500 ? 500 : imagenOriginal.width,
            );

            // Convertir a JPEG con compresión moderada (Word maneja mejor JPEG que PNG)
            final jpegBytes = img.encodeJpg(imagenOptimizada, quality: 60);
            final imagenBase64 = base64Encode(jpegBytes);

            // Validar que el Base64 no sea demasiado grande (máximo 400KB)
            if (imagenBase64.length > 550000) {
              buffer.writeln('<div class="foto-container">');
              buffer.writeln('<p style="font-weight: bold;">Foto ${i + 1}</p>');
              buffer.writeln(
                '<p style="color: #FF6B35;">⚠️ Imagen demasiado grande para Word. Consulte el PDF adjunto.</p>',
              );
              if (nota.isNotEmpty) {
                buffer.writeln('<p><strong>Nota:</strong> $nota</p>');
              }
              buffer.writeln('</div>');
              continue;
            }

            buffer.writeln('<div class="foto-container">');
            buffer.writeln('<p style="font-weight: bold;">Foto ${i + 1}</p>');

            // Usar tabla para mejor compatibilidad con Word
            buffer.writeln(
              '<table border="0" cellpadding="0" cellspacing="0" style="width: 100%; margin: 10px auto;">',
            );
            buffer.writeln('<tr><td align="center">');
            buffer.writeln(
              '<img src="data:image/jpeg;base64,$imagenBase64" width="450" alt="Foto ${i + 1}" />',
            );
            buffer.writeln('</td></tr>');
            if (nota.isNotEmpty) {
              buffer.writeln(
                '<tr><td align="center" style="padding-top: 8px;">',
              );
              buffer.writeln(
                '<p style="margin: 0;"><strong>Nota:</strong> $nota</p>',
              );
              buffer.writeln('</td></tr>');
            }
            buffer.writeln('</table>');
            buffer.writeln('</div>');

            // Salto de página entre fotos
            if (i < fotos.length - 1) {
              buffer.writeln(
                '<br clear="all" style="page-break-after: always;" />',
              );
            }
          } else {
            buffer.writeln('<p>Error al procesar Foto ${i + 1}</p>');
          }
        } catch (e) {
          buffer.writeln('<p>Error al cargar Foto ${i + 1}: $e</p>');
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
