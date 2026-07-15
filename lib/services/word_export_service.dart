import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

/// Servicio puro para generación de documentos Word (HTML)
///
/// Este servicio es dinámico: genera campos automáticamente
/// basándose en el mapa de datos que recibe.
class WordExportService {
  /// Genera un documento Word (HTML) dinámicamente
  ///
  /// Acepta un mapa con cualquier estructura de datos y genera
  /// el documento automáticamente incluyendo TODOS los campos.
  Future<Uint8List> generarReporte({
    required Map<String, dynamic> datos,
  }) async {
    // Cargar el logo como base64
    String logoBase64 = '';
    try {
      final logoData = await rootBundle.load('assets/logo_2026.png');
      final logoBytes = logoData.buffer.asUint8List();
      logoBase64 = base64Encode(logoBytes);
    } catch (e) {
      // Si no existe el logo, continuamos sin él
    }

    // Generar contenido HTML dinámico
    final htmlContent = _generarHTMLDinamico(datos, logoBase64);

    // Convertir a bytes UTF-8
    return Uint8List.fromList(utf8.encode(htmlContent));
  }

  /// Genera el HTML con formato compatible con Microsoft Word
  /// de forma completamente DINÁMICA
  String _generarHTMLDinamico(Map<String, dynamic> datos, String logoBase64) {
    final buffer = StringBuffer();

    // Encabezado XML con namespace de Office
    buffer.writeln('''
<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:w="urn:schemas-microsoft-com:office:word" xmlns="http://www.w3.org/TR/REC-html40">
<head>
<!--[if gte mso 9]><xml><w:WordDocument><w:View>Print</w:View><w:Zoom>100</w:Zoom><w:DoNotOptimizeForBrowser/></w:WordDocument></xml><![endif]-->
<meta charset="UTF-8">
<title>Reporte de Inspección - ${datos['nombrePlaza'] ?? 'Sin nombre'}</title>
<style>
@page Section1 {
  size: A4;
  margin: 2.5cm;
}
div.Section1 {
  page: Section1;
}
body {
  font-family: 'Calibri', 'Arial', sans-serif;
  font-size: 11pt;
  color: #333333;
}
table {
  table-layout: fixed;
  width: 100%;
  border-collapse: collapse;
  mso-table-lspace: 0pt;
  mso-table-rspace: 0pt;
  margin: 10px 0;
}
td, th {
  padding: 6px;
  border: 1px solid #CCCCCC;
  mso-border-alt: solid windowtext .5pt;
  vertical-align: top;
}
th {
  background-color: #E0E0E0;
  font-weight: bold;
}
img {
  display: block;
  margin: 0 auto;
}
h1 {
  color: #1B5E20;
  font-size: 18pt;
  margin: 20px 0;
}
h2 {
  color: #2E7D32;
  font-size: 14pt;
  margin: 15px 0 10px 0;
}
.info-label {
  font-weight: bold;
  color: #1B5E20;
}
.observacion {
  font-size: 9pt;
  color: #666666;
  font-style: italic;
  background-color: #F5F5F5;
  padding: 4px 8px;
}
</style>
</head>
<body>
<div class="Section1">
''');

    // Encabezado con logo
    buffer.writeln(
      '<table border="0" style="border:none; margin-bottom:20px;">',
    );
    buffer.writeln('<tr>');
    if (logoBase64.isNotEmpty) {
      buffer.writeln(
        '<td style="width:80px; border:none; text-align:center;"><img src="data:image/png;base64,$logoBase64" width="70" height="70" alt="Logo" /></td>',
      );
    }
    buffer.writeln(
      '<td style="border:none; text-align:center;"><h1 style="margin:0;">REPORTE DE INSPECCIÓN TÉCNICA DE ÁREAS VERDES</h1><p style="margin:5px 0 0 0; font-size:10pt; color:#666;">Municipalidad de Doñihue</p></td>',
    );
    buffer.writeln('</tr></table>');

    // ===================================================================
    // SECCIÓN DE INFORMACIÓN GENERAL - COMPLETAMENTE DINÁMICA
    // ===================================================================
    buffer.writeln('<h2>INFORMACIÓN GENERAL</h2>');

    // Campos prioritarios en orden específico
    final camposPrioritarios = [
      'nombrePlaza',
      'plazaId',
      'nombreInspector',
      'correoSupervisor',
      'fechaHora',
      'estadoGeneral',
    ];

    // Mostrar campos prioritarios primero
    for (final campo in camposPrioritarios) {
      if (datos.containsKey(campo) && datos[campo] != null) {
        final valor = _formatearValor(datos[campo]);
        if (valor.isNotEmpty) {
          final etiqueta = _formatearEtiqueta(campo);
          buffer.writeln(
            '<p><span class="info-label">$etiqueta:</span> $valor</p>',
          );
        }
      }
    }

    // Información fija del encargado
    buffer.writeln(
      '<p><span class="info-label">Encargado:</span> Felipe Lagos Bastias - Ingeniero Agrónomo</p>',
    );

    // Mostrar otros campos que no sean prioritarios ni especiales
    final camposEspeciales = [
      ...camposPrioritarios,
      'allEvaluations',
      'allCriteria',
      'allObservations',
      'sections',
      'imagesBySection',
      'images',
    ];

    for (final entry in datos.entries) {
      if (!camposEspeciales.contains(entry.key) && entry.value != null) {
        final valor = _formatearValor(entry.value);
        if (valor.isNotEmpty) {
          final etiqueta = _formatearEtiqueta(entry.key);
          buffer.writeln(
            '<p><span class="info-label">$etiqueta:</span> $valor</p>',
          );
        }
      }
    }

    buffer.writeln('<hr style="border:1px solid #1B5E20; margin:20px 0;" />');

    // ===================================================================
    // SECCIÓN DE EVALUACIONES - DINÁMICA CON OBSERVACIONES
    // ===================================================================

    // Procesar evaluaciones si existen
    if (datos.containsKey('allEvaluations') &&
        datos.containsKey('allCriteria')) {
      final allEvaluations =
          datos['allEvaluations'] as Map<String, dynamic>? ?? {};
      final allCriteria = datos['allCriteria'] as Map<String, dynamic>? ?? {};
      final allObservations =
          datos['allObservations'] as Map<String, dynamic>? ?? {};

      for (final entry in allEvaluations.entries) {
        final seccion = entry.key;
        final evaluaciones = entry.value as Map<String, dynamic>? ?? {};
        final criterios =
            (allCriteria[seccion] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
        final observaciones = allObservations[seccion] as Map<String, dynamic>?;

        if (criterios.isNotEmpty) {
          buffer.writeln('<h2>$seccion</h2>');
          buffer.writeln('<table>');
          buffer.writeln('<thead>');
          buffer.writeln('<tr><th>Criterio</th><th>Evaluación</th></tr>');
          buffer.writeln('</thead>');
          buffer.writeln('<tbody>');

          for (final criterio in criterios) {
            final valor = evaluaciones[criterio]?.toString() ?? 'N/A';

            // Fila del criterio
            buffer.writeln('<tr>');
            buffer.writeln('<td>$criterio</td>');
            buffer.writeln('<td>$valor</td>');
            buffer.writeln('</tr>');

            // Fila de observación (si existe)
            if (observaciones != null && observaciones.containsKey(criterio)) {
              final observacion = observaciones[criterio]?.toString() ?? '';
              if (observacion.isNotEmpty && observacion.trim().isNotEmpty) {
                buffer.writeln('<tr>');
                buffer.writeln(
                  '<td colspan="2" class="observacion">Observación: $observacion</td>',
                );
                buffer.writeln('</tr>');
              }
            }
          }

          buffer.writeln('</tbody>');
          buffer.writeln('</table>');
        }
      }
    }

    // Procesar sections (formato InspectionData) si existe
    if (datos.containsKey('sections')) {
      final sections = datos['sections'] as Map<String, dynamic>? ?? {};

      for (final entry in sections.entries) {
        final seccion = entry.key;
        final seccionData = entry.value as Map<String, dynamic>? ?? {};

        buffer.writeln('<h2>$seccion</h2>');
        buffer.writeln('<table>');
        buffer.writeln('<thead>');
        buffer.writeln('<tr><th>Criterio</th><th>Evaluación</th></tr>');
        buffer.writeln('</thead>');
        buffer.writeln('<tbody>');

        // Obtener criterios, evaluaciones y observaciones de la sección
        final criterios =
            (seccionData['criteria'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
        final evaluaciones =
            seccionData['evaluations'] as Map<String, dynamic>? ?? {};
        final observaciones =
            seccionData['observations'] as Map<String, dynamic>?;

        for (final criterio in criterios) {
          final valor = evaluaciones[criterio]?.toString() ?? 'N/A';

          // Fila del criterio
          buffer.writeln('<tr>');
          buffer.writeln('<td>$criterio</td>');
          buffer.writeln('<td>$valor</td>');
          buffer.writeln('</tr>');

          // Fila de observación (si existe)
          if (observaciones != null && observaciones.containsKey(criterio)) {
            final observacion = observaciones[criterio]?.toString() ?? '';
            if (observacion.isNotEmpty && observacion.trim().isNotEmpty) {
              buffer.writeln('<tr>');
              buffer.writeln(
                '<td colspan="2" class="observacion">Observación: $observacion</td>',
              );
              buffer.writeln('</tr>');
            }
          }
        }

        buffer.writeln('</tbody>');
        buffer.writeln('</table>');
      }
    }

    // Cierre del documento
    buffer.writeln('</div>');
    buffer.writeln('</body>');
    buffer.writeln('</html>');

    return buffer.toString();
  }

  /// Formatea un valor para mostrarlo en el HTML
  String _formatearValor(dynamic valor) {
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

  /// Formatea una clave de campo a etiqueta legible
  String _formatearEtiqueta(String campo) {
    // Mapeo de campos técnicos a etiquetas amigables
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

    // Si no hay mapeo, convertir camelCase a Título Con Espacios
    return campo
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
