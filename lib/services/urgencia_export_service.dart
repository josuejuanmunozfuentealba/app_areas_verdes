import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/image_optimizer.dart';

class UrgenciaExportService {
  /// Genera PDF de inspección de urgencia
  /// Genera PDF de inspección de urgencia
  Future<List<int>> generarPDF({
    required String plazaId,
    required String nombrePlaza,
    required String titulo,
    required String inspector,
    required DateTime fechaHora,
    required Map<String, String> campos,
    required List<String> observaciones,
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
      debugPrint('[PDF Urgencia] Error cargando logo: $e');
      logoImage = null;
    }

    // Página principal con información
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Encabezado con logo (igual que catastro)
          _buildHeader(logoImage),
          pw.SizedBox(height: 20),

          // Información básica
          pw.Text(
            titulo,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          _buildInfoRow('Plaza', nombrePlaza),
          _buildInfoRow('Inspector', inspector),
          _buildInfoRow('Fecha', _formatearFecha(fechaHora)),
          _buildInfoRow('Hora', _formatearHora(fechaHora)),
          pw.Divider(),
          pw.SizedBox(height: 12),

          // Campos dinámicos
          if (campos.isNotEmpty) ...[
            pw.Text(
              'INFORMACIÓN',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            ...campos.entries.map(
              (entry) => _buildInfoRow(entry.key, entry.value),
            ),
            pw.SizedBox(height: 16),
          ],

          // Observaciones
          if (observaciones.isNotEmpty) ...[
            pw.Text(
              'OBSERVACIONES',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            ...observaciones.asMap().entries.map((entry) {
              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '${entry.key + 1}. ',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Expanded(child: pw.Text(entry.value, softWrap: true)),
                  ],
                ),
              );
            }),
            pw.SizedBox(height: 16),
          ],

          // Pie de página
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Text(
            'Documento generado automáticamente - Sistema de Gestión de Áreas Verdes',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
          ),
        ],
      ),
    );

    // Anexo fotográfico (igual que catastro)
    if (fotos.isNotEmpty) {
      await _addPhotoAnnex(pdf, fotos);
    }

    return pdf.save();
  }

  /// Encabezado con logo (igual que catastro)
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
                '⚠️ INSPECCIÓN DE URGENCIA',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.red900,
                ),
              ),
              pw.Text(
                'ÁREAS VERDES',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.red700,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Container(
                width: double.infinity,
                height: 2,
                color: PdfColors.red700,
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

  /// Anexo fotográfico con compresión (igual que catastro)
  Future<void> _addPhotoAnnex(
    pw.Document pdf,
    List<Map<String, dynamic>> fotos,
  ) async {
    // Comprimir fotos antes de incrustar en PDF
    final pdfImagesWithNotes = <Map<String, dynamic>>[];

    for (var i = 0; i < fotos.length; i++) {
      try {
        final fotoData = fotos[i];
        final Uint8List bytes = fotoData['bytes'] as Uint8List;
        final String nombre = fotoData['nombre'] as String? ?? 'Foto ${i + 1}';

        final originalKB = bytes.length ~/ 1024;
        debugPrint(
          '[PDF Urgencia] 📷 Procesando foto ${i + 1}: ${originalKB}KB',
        );

        // Comprimir para PDF (600x600, quality 55)
        final bytesComprimidos = await ImageOptimizer.comprimirParaPDF(bytes);
        final comprimidoKB = bytesComprimidos.length ~/ 1024;

        debugPrint(
          '[PDF Urgencia] ✅ Foto ${i + 1} comprimida: ${originalKB}KB → ${comprimidoKB}KB',
        );

        pdfImagesWithNotes.add({
          'image': pw.MemoryImage(bytesComprimidos),
          'nota': nombre,
          'index': i + 1,
        });
      } catch (e) {
        debugPrint('[PDF Urgencia] ⚠️ Error procesando foto ${i + 1}: $e');
      }
    }

    // Liberar memoria después de procesar todas las fotos
    ImageOptimizer.liberarMemoria();

    if (pdfImagesWithNotes.isEmpty) return;

    // Crear página de anexo fotográfico
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Encabezado del anexo
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.red700,
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

          // Imágenes en cuadrícula 2 columnas
          pw.Wrap(
            spacing: 16,
            runSpacing: 16,
            children: pdfImagesWithNotes.map((imageData) {
              final image = imageData['image'] as pw.MemoryImage;
              final nota = imageData['nota'] as String;
              final index = imageData['index'] as int;

              return pw.Container(
                width: (PdfPageFormat.a4.width - 64 - 16) / 2,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      height: 200,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey400),
                      ),
                      child: pw.Center(
                        child: pw.Image(image, fit: pw.BoxFit.contain),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Foto $index: $nota',
                      style: const pw.TextStyle(fontSize: 10),
                      maxLines: 2,
                      overflow: pw.TextOverflow.clip,
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

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }

  String _formatearHora(DateTime fecha) {
    return '${fecha.hour.toString().padLeft(2, '0')}:'
        '${fecha.minute.toString().padLeft(2, '0')}';
  }

  /// Genera Word convirtiendo PDF
  Future<List<int>?> generarWord({
    required String plazaId,
    required String nombrePlaza,
    required String titulo,
    required String inspector,
    required DateTime fechaHora,
    required Map<String, String> campos,
    required List<String> observaciones,
    required List<Map<String, dynamic>> fotos,
  }) async {
    try {
      // Generar PDF primero
      final pdfBytes = await generarPDF(
        plazaId: plazaId,
        nombrePlaza: nombrePlaza,
        titulo: titulo,
        inspector: inspector,
        fechaHora: fechaHora,
        campos: campos,
        observaciones: observaciones,
        fotos: fotos,
      );

      // Convertir PDF a Word usando ConvertAPI
      const supabaseUrl = 'https://speneggmlqitgfjhzsry.supabase.co';
      const anonKey =
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNwZW5lZ2dtbHFpdGdmamh6c3J5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY1MzUzMDksImV4cCI6MjEwMjExMTMwOX0.31WSG-j7m_TO4uGjmXW59jTrxrX7wFvHT8sHtY5zIQg';

      final pdfBase64 = base64Encode(pdfBytes);
      final filename =
          'urgencia_${plazaId}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final functionUrl =
          '$supabaseUrl/functions/v1/convert-pdf-to-word-ilovepdf';

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
          final docxResponse = await http.get(Uri.parse(result['docxUrl']));
          return docxResponse.bodyBytes;
        }
      }

      return null;
    } catch (e) {
      print('Error generando Word: $e');
      return null;
    }
  }
}
