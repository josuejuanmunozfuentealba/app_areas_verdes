import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'dart:convert';

class UrgenciaExportService {
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

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Encabezado
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.red700,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '⚠️ INSPECCIÓN DE URGENCIA',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Municipalidad de Doñihue',
                  style: const pw.TextStyle(color: PdfColors.white, fontSize: 12),
                ),
              ],
            ),
          ),
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
            ...campos.entries.map((entry) => _buildInfoRow(entry.key, entry.value)),
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
                    pw.Text('${entry.key + 1}. ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Expanded(
                      child: pw.Text(entry.value, softWrap: true),
                    ),
                  ],
                ),
              );
            }),
            pw.SizedBox(height: 16),
          ],

          // Fotos
          if (fotos.isNotEmpty) ...[
            pw.Text(
              'EVIDENCIA FOTOGRÁFICA (${fotos.length})',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 12),
            ...fotos.map((foto) {
              final bytes = foto['bytes'] as Uint8List;
              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 16),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(foto['nombre'] ?? 'Foto', style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 4),
                    pw.Container(
                      constraints: const pw.BoxConstraints(maxHeight: 300),
                      child: pw.Image(pw.MemoryImage(bytes)),
                    ),
                  ],
                ),
              );
            }),
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

    return pdf.save();
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
      final filename = 'urgencia_${plazaId}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final functionUrl = '$supabaseUrl/functions/v1/convert-pdf-to-word-ilovepdf';

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
