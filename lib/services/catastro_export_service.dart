import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;
import 'package:docx_template/docx_template.dart';
import 'dart:typed_data';

/// Servicio de exportación para el módulo de Catastro de Inmuebles
/// Genera PDF y DOCX real con fotografías incrustadas
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

  /// Genera un documento Word en formato DOCX real
  /// Delega al generador DOCX real (generarWordDocx)
  Future<List<int>> generarWord({
    required String plazaId,
    required String nombrePlaza,
    required String inspector,
    required DateTime fechaHora,
    required Map<String, String?> evaluaciones,
    required Map<String, String> observaciones,
    required List<Map<String, dynamic>> fotos,
  }) async {
    // Delegar al generador DOCX real
    return generarWordDocx(
      plazaId: plazaId,
      nombrePlaza: nombrePlaza,
      inspector: inspector,
      fechaHora: fechaHora,
      evaluaciones: evaluaciones,
      observaciones: observaciones,
      fotos: fotos,
    );
  }

  /// Genera un documento DOCX REAL usando docx_template
  /// Esta función reemplaza el método HTML anterior para mayor estabilidad
  Future<List<int>> generarWordDocx({
    required String plazaId,
    required String nombrePlaza,
    required String inspector,
    required DateTime fechaHora,
    required Map<String, String?> evaluaciones,
    required Map<String, String> observaciones,
    required List<Map<String, dynamic>> fotos,
  }) async {
    try {
      // Cargar plantilla base.docx desde assets
      final templateData = await rootBundle.load('assets/base.docx');
      final templateBytes = templateData.buffer.asUint8List();

      // Crear DocxTemplate
      final docx = await DocxTemplate.fromBytes(templateBytes);

      // Preparar datos básicos
      final fechaFormateada = DateFormat(
        'dd/MM/yyyy HH:mm:ss',
      ).format(fechaHora);
      final estadoGeneral = _calcularEstadoGeneral(evaluaciones);

      // Crear contenedor de contenido
      final content = Content();

      // Agregar datos generales como TextContent
      content
        ..add(TextContent('plaza_id', plazaId))
        ..add(TextContent('nombre_plaza', nombrePlaza))
        ..add(TextContent('inspector', inspector))
        ..add(TextContent('fecha_hora', fechaFormateada))
        ..add(TextContent('estado_general', estadoGeneral));

      // Procesar y agregar logo
      try {
        final logoData = await rootBundle.load('assets/logo_2026.png');
        final logoBytes = logoData.buffer.asUint8List();
        final logoOptimizado = await _optimizarImagenParaDocx(
          logoBytes,
          maxWidth: 120,
          quality: 85,
          nombre: 'logo',
        );
        if (logoOptimizado != null) {
          content.add(ImageContent('logo', logoOptimizado));
        }
      } catch (e) {
        debugPrint('[DOCX] Error al cargar logo: $e');
      }

      // Preparar tabla de evaluación como ListContent
      final evaluacionesList = <Content>[];
      for (final criterio in criteriosOficiales) {
        evaluacionesList.add(
          PlainContent('evaluacion')
            ..add(TextContent('criterio', criterio))
            ..add(TextContent('evaluacion', evaluaciones[criterio] ?? 'N/A'))
            ..add(TextContent('observaciones', observaciones[criterio] ?? '-')),
        );
      }
      content.add(ListContent('evaluaciones', evaluacionesList));

      // Procesar fotografías
      debugPrint('[DOCX] Procesando ${fotos.length} fotografías...');
      int fotosExitosas = 0;
      int fotosConError = 0;
      final fotosList = <Content>[];

      for (var i = 0; i < fotos.length; i++) {
        try {
          final fotoData = fotos[i];
          final XFile archivo = fotoData['archivo'] as XFile;
          final String nota = fotoData['nota'] as String? ?? '';

          final bytes = await archivo.readAsBytes();
          final fotoOptimizada = await _optimizarImagenParaDocx(
            bytes,
            maxWidth: 600,
            quality: 75,
            nombre: 'Foto ${i + 1}',
          );

          if (fotoOptimizada != null) {
            final fotoContent = PlainContent('foto')
              ..add(TextContent('numero', 'Foto ${i + 1}'))
              ..add(ImageContent('imagen', fotoOptimizada))
              ..add(TextContent('nota', nota.isNotEmpty ? nota : 'Sin nota'));

            fotosList.add(fotoContent);
            fotosExitosas++;
            debugPrint(
              '[DOCX] ✓ Foto ${i + 1} procesada (${(fotoOptimizada.length / 1024).toStringAsFixed(1)} KB)',
            );
          } else {
            fotosConError++;
            debugPrint('[DOCX] ✗ Foto ${i + 1} no pudo optimizarse');
          }
        } catch (e) {
          fotosConError++;
          debugPrint('[DOCX] ✗ Error en Foto ${i + 1}: $e');
        }
      }

      content.add(ListContent('fotos', fotosList));
      debugPrint(
        '[DOCX] Resumen: $fotosExitosas exitosas, $fotosConError con error',
      );

      // Generar documento
      final startTime = DateTime.now();
      final docxBytes = await docx.generate(content);

      if (docxBytes == null) {
        throw Exception('Error: docx.generate() retornó null');
      }

      final duration = DateTime.now().difference(startTime);

      debugPrint('[DOCX] Documento generado en ${duration.inMilliseconds}ms');
      debugPrint(
        '[DOCX] Tamaño final: ${(docxBytes.length / 1024).toStringAsFixed(1)} KB',
      );

      return docxBytes;
    } catch (e) {
      debugPrint('[DOCX] ERROR CRÍTICO: $e');
      rethrow;
    }
  }

  /// Optimiza una imagen para insertar en DOCX
  /// Retorna null si la optimización falla
  Future<Uint8List?> _optimizarImagenParaDocx(
    Uint8List bytesOriginales, {
    required int maxWidth,
    required int quality,
    required String nombre,
  }) async {
    try {
      // Decodificar imagen
      final imagen = img.decodeImage(bytesOriginales);
      if (imagen == null) {
        debugPrint('[DOCX] No se pudo decodificar imagen: $nombre');
        return null;
      }

      debugPrint('[DOCX] Procesando $nombre: ${imagen.width}x${imagen.height}');

      // Redimensionar si excede el ancho máximo
      img.Image imagenProcesada = imagen;
      if (imagen.width > maxWidth) {
        imagenProcesada = img.copyResize(
          imagen,
          width: maxWidth,
          interpolation: img.Interpolation.average,
        );
        debugPrint(
          '[DOCX]   - Redimensionada a ${imagenProcesada.width}x${imagenProcesada.height}',
        );
      }

      // Convertir a JPEG con calidad controlada
      final jpegBytes = Uint8List.fromList(
        img.encodeJpg(imagenProcesada, quality: quality),
      );

      final tamanoOriginal = (bytesOriginales.length / 1024).toStringAsFixed(1);
      final tamanoFinal = (jpegBytes.length / 1024).toStringAsFixed(1);
      debugPrint('[DOCX]   - Tamaño: $tamanoOriginal KB → $tamanoFinal KB');

      // Validar que no sea excesivamente grande (máximo 800KB por imagen)
      if (jpegBytes.length > 800 * 1024) {
        debugPrint(
          '[DOCX]   - ⚠️ Imagen aún muy grande, reintentando con calidad reducida',
        );

        // Segundo intento con calidad más baja
        final qualityReducida = (quality - 20).clamp(1, 100);
        final jpegBytes2 = Uint8List.fromList(
          img.encodeJpg(imagenProcesada, quality: qualityReducida),
        );

        if (jpegBytes2.length > 800 * 1024) {
          debugPrint(
            '[DOCX]   - ⚠️ Imagen sigue siendo muy grande después de optimización',
          );
          // Aún así la devolvemos, Word debería poder manejarla
        }
        return jpegBytes2;
      }

      return jpegBytes;
    } catch (e) {
      debugPrint('[DOCX] Error al optimizar $nombre: $e');
      return null;
    }
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
