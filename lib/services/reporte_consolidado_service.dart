import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:archive/archive.dart';
import 'package:intl/intl.dart';

/// Servicio para generar reportes consolidados de arranques de agua
class ReporteConsolidadoService {
  /// Extraer la medida (1/2 o 3/4) del texto de arranques
  static String? extraerMedida(String? texto) {
    if (texto == null || texto.isEmpty) return null;

    final textoLower = texto.toLowerCase();

    // Buscar "1/2" o "1/2 pulgada" o "media pulgada"
    if (textoLower.contains('1/2') ||
        textoLower.contains('media pulgada') ||
        textoLower.contains('12.7') ||
        textoLower.contains('12,7')) {
      return '1/2"';
    }

    // Buscar "3/4" o "3/4 pulgada"
    if (textoLower.contains('3/4') ||
        textoLower.contains('19.05') ||
        textoLower.contains('19,05')) {
      return '3/4"';
    }

    // Buscar "1 pulgada" (sin fracción)
    if (textoLower.contains('1 pulgada') ||
        textoLower.contains('1"') ||
        textoLower.contains('25.4') ||
        textoLower.contains('25,4')) {
      return '1"';
    }

    return null;
  }

  /// Obtener reporte consolidado de arranques
  static Future<Map<String, dynamic>> obtenerReporteArranques() async {
    try {
      print('📊 [REPORTE] Obteniendo catastros desde Supabase...');

      // Obtener todos los catastros
      final response = await Supabase.instance.client
          .from('catastros_inmuebles')
          .select('plaza_id, nombre_plaza, evaluaciones')
          .order('created_at', ascending: false);

      print('✅ [REPORTE] ${response.length} catastros encontrados');

      // Contadores
      int totalPlazas = 0;
      int totalArranques = 0;
      int arranques12 = 0;
      int arranques34 = 0;
      int arranques1 = 0;
      int sinEspecificar = 0;

      // Detalle por plaza
      List<Map<String, dynamic>> detallesPorPlaza = [];

      // Procesar cada catastro
      for (var catastro in response) {
        final plazaId = catastro['plaza_id'];
        final nombrePlaza = catastro['nombre_plaza'] ?? 'Sin nombre';
        final evaluaciones = catastro['evaluaciones'] as Map<String, dynamic>?;

        if (evaluaciones == null) continue;

        // Buscar campo de arranques
        final campoArranques =
            'Estado llaves de paso/arranque de agua (Especificar si es de 1/2 o 3/4)';
        final valorArranque = evaluaciones[campoArranques] as String?;

        if (valorArranque != null && valorArranque.isNotEmpty) {
          totalPlazas++;

          final medida = extraerMedida(valorArranque);

          if (medida == '1/2"') {
            arranques12++;
            totalArranques++;
          } else if (medida == '3/4"') {
            arranques34++;
            totalArranques++;
          } else if (medida == '1"') {
            arranques1++;
            totalArranques++;
          } else {
            sinEspecificar++;
          }

          detallesPorPlaza.add({
            'plaza_id': plazaId,
            'nombre': nombrePlaza,
            'medida': medida ?? 'Sin especificar',
            'texto_original': valorArranque,
          });

          print('  ➕ $nombrePlaza: ${medida ?? "Sin especificar"}');
        }
      }

      print('✅ [REPORTE] Procesamiento completado');
      print('   Total plazas con arranques: $totalPlazas');
      print('   Arranques 1/2": $arranques12');
      print('   Arranques 3/4": $arranques34');
      print('   Arranques 1": $arranques1');
      print('   Sin especificar: $sinEspecificar');

      return {
        'total_plazas': totalPlazas,
        'total_arranques': totalArranques,
        'arranques_12': arranques12,
        'arranques_34': arranques34,
        'arranques_1': arranques1,
        'sin_especificar': sinEspecificar,
        'detalles': detallesPorPlaza,
      };
    } catch (e, stackTrace) {
      print('❌ [REPORTE] Error obteniendo datos: $e');
      print('❌ [REPORTE] StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// Generar PDF del reporte
  static Future<Uint8List> generarPDFReporte(
    Map<String, dynamic> reporte,
  ) async {
    final pdf = pw.Document();

    // Cargar logo
    final logoBytes = await rootBundle.load('assets/logo_2026.png');
    final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());

    final fecha = DateFormat('dd/MM/yyyy').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // Header con logo
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Image(logo, width: 80, height: 80),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'REPORTE CONSOLIDADO',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'ARRANQUES DE AGUA',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Fecha: $fecha',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.SizedBox(height: 20),

          // Resumen General
          pw.Text(
            '📊 RESUMEN GENERAL',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Áreas Verdes con Arranques: ${reporte['total_plazas']}',
                ),
                pw.Text('Total de Arranques: ${reporte['total_arranques']}'),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Arranques por Medida
          pw.Text(
            '📏 ARRANQUES POR MEDIDA',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headers: ['Medida', 'Cantidad', 'Porcentaje'],
            data: [
              [
                '1/2 pulgada (12.7mm)',
                '${reporte['arranques_12']}',
                '${_calcularPorcentaje(reporte['arranques_12'], reporte['total_arranques'])}%',
              ],
              [
                '3/4 pulgada (19.05mm)',
                '${reporte['arranques_34']}',
                '${_calcularPorcentaje(reporte['arranques_34'], reporte['total_arranques'])}%',
              ],
              [
                '1 pulgada (25.4mm)',
                '${reporte['arranques_1']}',
                '${_calcularPorcentaje(reporte['arranques_1'], reporte['total_arranques'])}%',
              ],
              [
                'Sin especificar',
                '${reporte['sin_especificar']}',
                '${_calcularPorcentaje(reporte['sin_especificar'], reporte['total_plazas'])}%',
              ],
            ],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.green100),
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.all(8),
          ),
          pw.SizedBox(height: 20),

          // Detalle por Plaza
          pw.Text(
            '🏞️ DETALLE POR ÁREA VERDE',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headers: ['Plaza', 'Medida'],
            data: (reporte['detalles'] as List<Map<String, dynamic>>)
                .map((d) => [d['nombre'], d['medida']])
                .toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.green100),
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.all(8),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  /// Generar archivo Word (DOCX) del reporte
  static Future<Uint8List> generarWordReporte(
    Map<String, dynamic> reporte,
  ) async {
    // Cargar plantilla base
    final baseDocxBytes = await rootBundle.load('assets/base.docx');
    final baseArchive = ZipDecoder().decodeBytes(
      baseDocxBytes.buffer.asUint8List(),
    );

    final fecha = DateFormat('dd/MM/yyyy').format(DateTime.now());

    // Construir contenido
    final contenido = StringBuffer();
    contenido.writeln('REPORTE CONSOLIDADO - ARRANQUES DE AGUA');
    contenido.writeln('Fecha: $fecha');
    contenido.writeln('');
    contenido.writeln('═══════════════════════════════════════════');
    contenido.writeln('📊 RESUMEN GENERAL');
    contenido.writeln('═══════════════════════════════════════════');
    contenido.writeln('Áreas Verdes con Arranques: ${reporte['total_plazas']}');
    contenido.writeln('Total de Arranques: ${reporte['total_arranques']}');
    contenido.writeln('');
    contenido.writeln('📏 ARRANQUES POR MEDIDA');
    contenido.writeln('───────────────────────────────────────────');
    contenido.writeln(
      '1/2 pulgada: ${reporte['arranques_12']} (${_calcularPorcentaje(reporte['arranques_12'], reporte['total_arranques'])}%)',
    );
    contenido.writeln(
      '3/4 pulgada: ${reporte['arranques_34']} (${_calcularPorcentaje(reporte['arranques_34'], reporte['total_arranques'])}%)',
    );
    contenido.writeln(
      '1 pulgada: ${reporte['arranques_1']} (${_calcularPorcentaje(reporte['arranques_1'], reporte['total_arranques'])}%)',
    );
    contenido.writeln('Sin especificar: ${reporte['sin_especificar']}');
    contenido.writeln('');
    contenido.writeln('🏞️ DETALLE POR ÁREA VERDE');
    contenido.writeln('───────────────────────────────────────────');

    int index = 1;
    for (var detalle in reporte['detalles'] as List<Map<String, dynamic>>) {
      contenido.writeln('[$index] ${detalle['nombre']}');
      contenido.writeln('    Medida: ${detalle['medida']}');
      index++;
    }

    // Reemplazar contenido en document.xml
    String documentXml = '';
    for (var file in baseArchive.files) {
      if (file.name == 'word/document.xml') {
        documentXml = String.fromCharCodes(file.content);
        // Reemplazar placeholder
        documentXml = documentXml.replaceAll(
          '<w:t>CONTENIDO_REPORTE</w:t>',
          '<w:t>${contenido.toString()}</w:t>',
        );
        break;
      }
    }

    // Reconstruir archivo DOCX
    final newArchive = Archive();
    for (var file in baseArchive.files) {
      if (file.name == 'word/document.xml') {
        newArchive.addFile(
          ArchiveFile(file.name, documentXml.length, documentXml.codeUnits),
        );
      } else {
        newArchive.addFile(file);
      }
    }

    return Uint8List.fromList(ZipEncoder().encode(newArchive)!);
  }

  static String _calcularPorcentaje(int parte, int total) {
    if (total == 0) return '0.0';
    return ((parte / total) * 100).toStringAsFixed(1);
  }
}
