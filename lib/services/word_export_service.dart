import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:docx_template/docx_template.dart';

class WordExportService {
  Future<Uint8List?> generateInspectionDOCX({
    required String plazaId,
    required String nombrePlaza,
    required String correoSupervisor,
    required String fechaHora,
    required String estadoGeneral,
    required Map<String, Map<String, String?>> allEvaluations,
  }) async {
    try {
      // Cargar plantilla desde assets
      final data = await rootBundle.load('assets/base.docx');
      final bytes = data.buffer.asUint8List();
      final docx = await DocxTemplate.fromBytes(bytes);

      // Crear contenido principal
      final content = Content();

      // Agregar datos generales
      content
        ..add(TextContent('plazaId', plazaId))
        ..add(TextContent('nombrePlaza', nombrePlaza))
        ..add(TextContent('inspector', correoSupervisor))
        ..add(TextContent('fecha', fechaHora))
        ..add(TextContent('estadoGeneral', estadoGeneral));

      // Preparar lista de secciones
      final List<Content> seccionesList = [];

      for (var entry in allEvaluations.entries) {
        final List<Content> itemsList = [];

        entry.value.forEach((criterio, valor) {
          final itemContent = Content();
          itemContent
            ..add(TextContent('criterio', criterio))
            ..add(TextContent('valor', valor ?? 'N/A'));
          itemsList.add(itemContent);
        });

        final seccionContent = Content();
        seccionContent
          ..add(TextContent('nombreSeccion', entry.key))
          ..add(ListContent('items', itemsList));

        seccionesList.add(seccionContent);
      }

      // Agregar lista de secciones al contenido principal
      content.add(ListContent('secciones', seccionesList));

      // Generar documento
      final generatedBytes = await docx.generate(content);

      return generatedBytes != null ? Uint8List.fromList(generatedBytes) : null;
    } catch (e) {
      print('Error generando documento DOCX: $e');
      return null;
    }
  }
}
